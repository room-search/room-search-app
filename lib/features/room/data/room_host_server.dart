import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/utils/logger.dart';
import 'room_message.dart';
import 'room_participant.dart';

class _GuestConn {
  _GuestConn({required this.id, required this.name, required this.socket});

  final String id;
  String name;
  final WebSocketChannel socket;
}

class HostIncoming {
  const HostIncoming({required this.from, required this.message});

  final String from;
  final RoomMessage message;
}

class RoomHostServer {
  RoomHostServer({required this.selfId, required this.selfName});

  final String selfId;
  final String selfName;

  HttpServer? _httpServer;
  final Map<String, _GuestConn> _guests = {};
  bool _locked = false;

  final StreamController<List<RoomParticipant>> _rosterController =
      StreamController<List<RoomParticipant>>.broadcast();
  final StreamController<HostIncoming> _incomingController =
      StreamController<HostIncoming>.broadcast();

  Stream<List<RoomParticipant>> get rosterStream => _rosterController.stream;
  Stream<HostIncoming> get incomingStream => _incomingController.stream;
  bool get locked => _locked;
  int? get port => _httpServer?.port;

  Future<int> start() async {
    final handler = webSocketHandler(_onConnect);
    _httpServer =
        await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
    log.i('Room host listening on port ${_httpServer!.port}');
    _emitRoster();
    return _httpServer!.port;
  }

  void _onConnect(WebSocketChannel socket, String? _) {
    String? guestId;
    socket.stream.listen(
      (raw) {
        if (raw is! String) return;
        final msg = RoomMessage.decode(raw);
        if (msg.type == RoomMessageType.hello) {
          if (_locked) {
            socket.sink.close(1008, 'room locked');
            return;
          }
          guestId = msg.from;
          if (guestId == null || guestId!.isEmpty || guestId == selfId) {
            socket.sink.close(1008, 'invalid id');
            return;
          }
          _guests[guestId!] = _GuestConn(
            id: guestId!,
            name: msg.helloName.isNotEmpty ? msg.helloName : guestId!,
            socket: socket,
          );
          log.i('Guest joined: $guestId (${msg.helloName})');
          _emitRoster();
          _broadcastRoster();
          return;
        }
        final from = guestId;
        if (from == null) return;
        if (msg.type == RoomMessageType.leave) {
          _removeGuest(from);
          return;
        }
        _incomingController.add(HostIncoming(from: from, message: msg));
      },
      onDone: () {
        if (guestId != null) _removeGuest(guestId!);
      },
      onError: (Object e, StackTrace st) {
        log.w('Guest socket error: $e', stackTrace: st);
        if (guestId != null) _removeGuest(guestId!);
      },
      cancelOnError: true,
    );
  }

  void _removeGuest(String id) {
    final conn = _guests.remove(id);
    if (conn == null) return;
    try {
      conn.socket.sink.close();
    } catch (_) {}
    log.i('Guest left: $id');
    _emitRoster();
    _broadcastRoster();
  }

  List<RoomParticipant> _buildRoster() {
    return [
      RoomParticipant(id: selfId, name: selfName, isHost: true),
      for (final g in _guests.values)
        RoomParticipant(id: g.id, name: g.name, isHost: false),
    ];
  }

  void _emitRoster() {
    if (_rosterController.isClosed) return;
    _rosterController.add(_buildRoster());
  }

  void _broadcastRoster() {
    final msg = RoomMessage.roster(
      from: selfId,
      participants: _buildRoster(),
      locked: _locked,
    );
    _broadcast(msg.encode());
  }

  void _broadcast(String raw, {String? except}) {
    for (final g in _guests.values) {
      if (except != null && g.id == except) continue;
      try {
        g.socket.sink.add(raw);
      } catch (e, st) {
        log.w('broadcast to ${g.id} failed: $e', stackTrace: st);
      }
    }
  }

  void broadcast(RoomMessage message) {
    _broadcast(message.encode());
  }

  void lockRoom() {
    if (_locked) return;
    _locked = true;
    final lockMsg = RoomMessage.lock(from: selfId).encode();
    _broadcast(lockMsg);
    _broadcastRoster();
    log.i('Room locked by host');
  }

  Future<void> stop() async {
    for (final g in _guests.values) {
      try {
        g.socket.sink.close();
      } catch (_) {}
    }
    _guests.clear();
    final s = _httpServer;
    _httpServer = null;
    if (s != null) {
      try {
        await s.close(force: true);
      } catch (e, st) {
        log.w('server close failed: $e', stackTrace: st);
      }
    }
    if (!_rosterController.isClosed) _rosterController.add(const []);
  }

  Future<void> dispose() async {
    await stop();
    if (!_rosterController.isClosed) await _rosterController.close();
    if (!_incomingController.isClosed) await _incomingController.close();
  }
}

