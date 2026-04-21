import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/logger.dart';
import '../data/room_client.dart';
import '../data/room_foreground_service.dart';
import '../data/room_host_server.dart';
import '../data/room_message.dart';
import '../data/room_participant.dart';
import 'host_election.dart';
import 'room_discovery.dart';
import 'room_state.dart';

class RoomController extends Notifier<RoomState> {
  static const _uuid = Uuid();
  static const _notificationDuration = Duration(seconds: 5);

  RoomDiscovery? _discovery;
  RoomHostServer? _server;
  RoomClient? _client;

  StreamSubscription<List<DiscoveredPeer>>? _discoverySub;
  StreamSubscription<List<RoomParticipant>>? _serverRosterSub;
  StreamSubscription<HostIncoming>? _serverIncomingSub;
  StreamSubscription<RoomMessage>? _clientIncomingSub;
  StreamSubscription<void>? _clientClosedSub;

  Timer? _notificationTimer;
  final Map<String, DiscoveredPeer> _peers = {};
  List<RoomParticipant> _wsRoster = const [];

  @override
  RoomState build() {
    RoomForegroundService.init();
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    ref.onDispose(() {
      FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
      unawaited(_teardown());
    });
    return const RoomState();
  }

  void _onTaskData(Object data) {
    if (data is Map && data['action'] == roomLeaveAction) {
      unawaited(cancel());
    }
  }

  String _buildNotificationText() {
    final count = state.participants.length;
    final host = state.hostParticipant?.name;
    final role = state.isHost ? '내가 호스트' : (host != null ? '호스트: $host' : '게스트');
    return '$count명 접속 · $role';
  }

  Future<void> startSearch({required String nickname}) async {
    if (state.isActive) return;
    await _teardown();

    final trimmed = nickname.trim().isEmpty ? '게스트' : nickname.trim();
    final selfId = _uuid.v4();

    final server = RoomHostServer(selfId: selfId, selfName: trimmed);
    final int port;
    try {
      port = await server.start();
    } catch (e, st) {
      log.e('Failed to start room server', error: e, stackTrace: st);
      state = state.copyWith(
        phase: RoomPhase.error,
        errorMessage: '방 서버 시작에 실패했어요.',
      );
      await server.dispose();
      return;
    }

    final discovery = RoomDiscovery();
    try {
      await discovery.start(
        selfId: selfId,
        selfName: trimmed,
        port: port,
      );
    } catch (e, st) {
      log.e('Failed to start discovery', error: e, stackTrace: st);
      await server.dispose();
      await discovery.dispose();
      state = state.copyWith(
        phase: RoomPhase.error,
        errorMessage: '네트워크 검색을 시작할 수 없어요. 같은 Wi-Fi인지 확인해주세요.',
      );
      return;
    }

    _server = server;
    _discovery = discovery;
    _wsRoster = [
      RoomParticipant(id: selfId, name: trimmed, isHost: true),
    ];

    state = RoomState(
      phase: RoomPhase.searching,
      selfId: selfId,
      selfName: trimmed,
      hostId: selfId,
      participants: _wsRoster,
    );

    _serverRosterSub = server.rosterStream.listen(_onServerRoster);
    _serverIncomingSub = server.incomingStream.listen(_onServerIncoming);
    _discoverySub = discovery.peerStream.listen(_onDiscoveryPeers);
  }

  Future<void> cancel() async {
    await _teardown();
    state = const RoomState();
  }

  Future<void> lockRoom() async {
    if (!state.canLock) return;
    _server?.lockRoom();
    await _discovery?.stop();
    state = state.copyWith(phase: RoomPhase.locked);
    _recomputeRoster();
    await _syncForegroundNotification(start: true);
  }

  bool _foregroundStarted = false;

  Future<void> _syncForegroundNotification({required bool start}) async {
    if (state.phase != RoomPhase.locked) return;
    if (start || !_foregroundStarted) {
      _foregroundStarted = true;
      await RoomForegroundService.start(
        title: '방서치 방 활성 중',
        text: _buildNotificationText(),
      );
    } else {
      await RoomForegroundService.update(
        title: '방서치 방 활성 중',
        text: _buildNotificationText(),
      );
    }
  }

  void shareTheme({
    required int themeRefId,
    required String themeName,
    String? photoUrl,
  }) {
    if (!state.canShare) return;
    if (state.isHost) {
      _server?.broadcast(
        RoomMessage.share(
          from: state.selfId,
          themeRefId: themeRefId,
          themeName: themeName,
          photoUrl: photoUrl,
        ),
      );
    } else {
      _client?.sendShare(
        themeRefId: themeRefId,
        themeName: themeName,
        photoUrl: photoUrl,
      );
    }
  }

  void dismissNotification() {
    _notificationTimer?.cancel();
    if (state.currentNotification != null) {
      state = state.copyWith(clearNotification: true);
    }
  }

  void _onDiscoveryPeers(List<DiscoveredPeer> peers) {
    _peers
      ..clear()
      ..addEntries(peers.map((p) => MapEntry(p.id, p)));

    // Once the room is locked, the host is committed. Discovery.stop() emits
    // an empty peer list which would otherwise trigger spurious re-election
    // and force guests to migrate back to themselves (dropping the WS).
    if (state.phase == RoomPhase.locked) return;

    final ids = <String>{state.selfId, ..._peers.keys};
    final newHost = electHost(ids);
    if (newHost == null) return;
    if (newHost != state.hostId) {
      unawaited(_migrateTo(newHost));
    } else {
      _recomputeRoster();
    }
  }

  Future<void> _migrateTo(String newHostId) async {
    log.i('Host migration: ${state.hostId} → $newHostId');
    state = state.copyWith(hostId: newHostId);
    if (newHostId == state.selfId) {
      await _clientIncomingSub?.cancel();
      _clientIncomingSub = null;
      await _clientClosedSub?.cancel();
      _clientClosedSub = null;
      await _client?.dispose();
      _client = null;
      _wsRoster = [
        RoomParticipant(id: state.selfId, name: state.selfName, isHost: true),
      ];
    } else {
      final peer = _peers[newHostId];
      if (peer == null) return;
      await _clientIncomingSub?.cancel();
      await _clientClosedSub?.cancel();
      await _client?.dispose();
      final client = RoomClient(
        selfId: state.selfId,
        selfName: state.selfName,
      );
      _client = client;
      _clientIncomingSub = client.incomingStream.listen(_onClientIncoming);
      _clientClosedSub = client.closedStream.listen((_) => _onClientClosed());
      try {
        await client.connect(host: peer.host, port: peer.port);
      } catch (e, st) {
        log.w('client connect failed: $e', stackTrace: st);
      }
    }
    _recomputeRoster();
  }

  void _onServerRoster(List<RoomParticipant> roster) {
    if (!state.isHost) return;
    _detectLeaves(_wsRoster, roster);
    _wsRoster = roster;
    _recomputeRoster();
  }

  void _detectLeaves(
    List<RoomParticipant> previous,
    List<RoomParticipant> current,
  ) {
    if (state.phase != RoomPhase.locked) return;
    if (previous.isEmpty) return;
    final currentIds = {for (final p in current) p.id};
    for (final p in previous) {
      if (p.id == state.selfId) continue;
      if (!currentIds.contains(p.id)) {
        _pushLeaveNotification(fromId: p.id, fromName: p.name);
      }
    }
  }

  void _onServerIncoming(HostIncoming ev) {
    if (!state.isHost) return;
    final msg = ev.message;
    if (msg.type == RoomMessageType.share) {
      _server?.broadcast(msg);
      _pushNotification(
        fromId: msg.from,
        fromName: _participantName(msg.from),
        themeRefId: msg.shareThemeRefId,
        themeName: msg.shareThemeName,
        photoUrl: msg.sharePhotoUrl,
      );
    }
  }

  void _onClientIncoming(RoomMessage msg) {
    switch (msg.type) {
      case RoomMessageType.roster:
        final nextRoster = msg.rosterParticipants();
        if (msg.rosterLocked && state.phase == RoomPhase.searching) {
          unawaited(_discovery?.stop());
          state = state.copyWith(phase: RoomPhase.locked);
        }
        _detectLeaves(_wsRoster, nextRoster);
        _wsRoster = nextRoster;
        _recomputeRoster();
      case RoomMessageType.lock:
        unawaited(_discovery?.stop());
        if (state.phase != RoomPhase.locked) {
          state = state.copyWith(phase: RoomPhase.locked);
        }
        _recomputeRoster();
      case RoomMessageType.share:
        if (msg.from == state.selfId) break;
        _pushNotification(
          fromId: msg.from,
          fromName: _participantName(msg.from),
          themeRefId: msg.shareThemeRefId,
          themeName: msg.shareThemeName,
          photoUrl: msg.sharePhotoUrl,
        );
      case RoomMessageType.hello:
      case RoomMessageType.leave:
      case RoomMessageType.unknown:
        break;
    }
  }

  void _onClientClosed() {
    if (state.phase == RoomPhase.locked) {
      state = state.copyWith(
        phase: RoomPhase.error,
        errorMessage: '호스트와 연결이 끊어졌어요.',
      );
    }
  }

  void _recomputeRoster() {
    final hostId = state.hostId;
    if (hostId == null) return;

    if (state.phase == RoomPhase.locked) {
      state = state.copyWith(
        participants: _wsRoster
            .map((p) => p.copyWith(isHost: p.id == hostId))
            .toList(growable: false),
      );
      unawaited(_syncForegroundNotification(start: false));
      return;
    }

    final merged = <String, RoomParticipant>{
      state.selfId: RoomParticipant(
        id: state.selfId,
        name: state.selfName,
        isHost: state.selfId == hostId,
      ),
    };
    for (final p in _wsRoster) {
      merged[p.id] = p.copyWith(isHost: p.id == hostId);
    }
    for (final peer in _peers.values) {
      merged.putIfAbsent(
        peer.id,
        () => RoomParticipant(
          id: peer.id,
          name: peer.name,
          isHost: peer.id == hostId,
        ),
      );
    }
    state = state.copyWith(participants: merged.values.toList(growable: false));
  }

  String _participantName(String id) {
    for (final p in state.participants) {
      if (p.id == id) return p.name;
    }
    return _peers[id]?.name ?? '알 수 없음';
  }

  void _pushNotification({
    required String fromId,
    required String fromName,
    required int themeRefId,
    required String themeName,
    String? photoUrl,
  }) {
    _emitNotification(
      RoomShareNotification(
        id: _uuid.v4(),
        fromId: fromId,
        fromName: fromName,
        themeRefId: themeRefId,
        themeName: themeName,
        photoUrl: photoUrl,
        receivedAt: DateTime.now(),
      ),
    );
  }

  void _pushLeaveNotification({
    required String fromId,
    required String fromName,
  }) {
    _emitNotification(
      RoomShareNotification(
        kind: RoomBannerKind.leave,
        id: _uuid.v4(),
        fromId: fromId,
        fromName: fromName,
        receivedAt: DateTime.now(),
      ),
    );
  }

  void _emitNotification(RoomShareNotification notif) {
    state = state.copyWith(currentNotification: notif);
    _notificationTimer?.cancel();
    _notificationTimer = Timer(_notificationDuration, () {
      if (state.currentNotification?.id == notif.id) {
        state = state.copyWith(clearNotification: true);
      }
    });
  }

  Future<void> _teardown() async {
    _notificationTimer?.cancel();
    _notificationTimer = null;

    _foregroundStarted = false;
    await RoomForegroundService.stop();

    await _discoverySub?.cancel();
    _discoverySub = null;
    await _serverRosterSub?.cancel();
    _serverRosterSub = null;
    await _serverIncomingSub?.cancel();
    _serverIncomingSub = null;
    await _clientIncomingSub?.cancel();
    _clientIncomingSub = null;
    await _clientClosedSub?.cancel();
    _clientClosedSub = null;

    if (_client != null) {
      _client!.sendLeave();
      await _client!.dispose();
      _client = null;
    }
    if (_discovery != null) {
      await _discovery!.dispose();
      _discovery = null;
    }
    if (_server != null) {
      await _server!.dispose();
      _server = null;
    }
    _peers.clear();
    _wsRoster = const [];
  }
}

final roomControllerProvider =
    NotifierProvider<RoomController, RoomState>(RoomController.new);
