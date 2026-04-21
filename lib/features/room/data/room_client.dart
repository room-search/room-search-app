import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/utils/logger.dart';
import 'room_message.dart';

class RoomClient {
  RoomClient({required this.selfId, required this.selfName});

  final String selfId;
  final String selfName;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  final StreamController<RoomMessage> _incomingController =
      StreamController<RoomMessage>.broadcast();
  final StreamController<void> _closedController =
      StreamController<void>.broadcast();

  Stream<RoomMessage> get incomingStream => _incomingController.stream;
  Stream<void> get closedStream => _closedController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect({required String host, required int port}) async {
    await close();
    final uri = Uri.parse('ws://$host:$port/');
    log.i('Room client connecting to $uri');
    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    _channel = channel;
    _sub = channel.stream.listen(
      (raw) {
        if (raw is! String) return;
        try {
          _incomingController.add(RoomMessage.decode(raw));
        } catch (e, st) {
          log.w('Failed to decode room message: $e', stackTrace: st);
        }
      },
      onDone: _handleDone,
      onError: (Object e, StackTrace st) {
        log.w('Client socket error: $e', stackTrace: st);
        _handleDone();
      },
      cancelOnError: true,
    );
    channel.sink.add(
      RoomMessage.hello(from: selfId, name: selfName).encode(),
    );
    log.i('Room client connected');
  }

  void sendShare({
    required int themeRefId,
    required String themeName,
    String? photoUrl,
  }) {
    final ch = _channel;
    if (ch == null) return;
    ch.sink.add(
      RoomMessage.share(
        from: selfId,
        themeRefId: themeRefId,
        themeName: themeName,
        photoUrl: photoUrl,
      ).encode(),
    );
  }

  void sendLeave() {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(RoomMessage.leave(from: selfId).encode());
    } catch (_) {}
  }

  void _handleDone() {
    if (_channel == null) return;
    _channel = null;
    _sub?.cancel();
    _sub = null;
    if (!_closedController.isClosed) _closedController.add(null);
    log.i('Room client disconnected');
  }

  Future<void> close() async {
    final ch = _channel;
    _channel = null;
    await _sub?.cancel();
    _sub = null;
    if (ch != null) {
      try {
        await ch.sink.close();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    await close();
    if (!_incomingController.isClosed) await _incomingController.close();
    if (!_closedController.isClosed) await _closedController.close();
  }
}
