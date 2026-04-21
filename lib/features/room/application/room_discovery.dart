import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nsd/nsd.dart' as nsd;

import '../../../core/utils/logger.dart';

class DiscoveredPeer {
  const DiscoveredPeer({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
  });

  final String id;
  final String name;
  final String host;
  final int port;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredPeer &&
          other.id == id &&
          other.name == name &&
          other.host == host &&
          other.port == port;

  @override
  int get hashCode => Object.hash(id, name, host, port);
}

class RoomDiscovery {
  static const String serviceType = '_roomsearch._tcp';

  nsd.Registration? _registration;
  nsd.Discovery? _discovery;
  final StreamController<List<DiscoveredPeer>> _peersController =
      StreamController<List<DiscoveredPeer>>.broadcast();
  final Map<String, DiscoveredPeer> _peers = {};
  String _selfId = '';

  Stream<List<DiscoveredPeer>> get peerStream => _peersController.stream;

  List<DiscoveredPeer> get currentPeers =>
      _peers.values.toList(growable: false);

  bool get isRegistered => _registration != null;

  Future<void> start({
    required String selfId,
    required String selfName,
    required int port,
  }) async {
    _selfId = selfId;
    _peers.clear();
    _peersController.add(const []);

    _registration = await nsd.register(
      nsd.Service(
        name: selfId,
        type: serviceType,
        port: port,
        txt: _encodeTxt({'id': selfId, 'name': selfName}),
      ),
    );
    log.i('Room advertised as $selfId on port $port');

    _discovery = await nsd.startDiscovery(
      serviceType,
      ipLookupType: nsd.IpLookupType.v4,
    );
    _discovery!.addServiceListener(_onService);
    log.i('Room discovery started');
  }

  Future<void> _onService(nsd.Service service, nsd.ServiceStatus status) async {
    final id = _txtString(service.txt, 'id');
    if (id == null || id.isEmpty) return;
    if (id == _selfId) return;

    if (status == nsd.ServiceStatus.found) {
      final port = service.port;
      if (port == null) return;
      final host = _pickHost(service);
      if (host == null) return;
      _peers[id] = DiscoveredPeer(
        id: id,
        name: _txtString(service.txt, 'name') ?? id,
        host: host,
        port: port,
      );
      log.d('Peer found: $id @ $host:$port');
    } else {
      _peers.remove(id);
      log.d('Peer lost: $id');
    }
    if (!_peersController.isClosed) {
      _peersController.add(currentPeers);
    }
  }

  String? _pickHost(nsd.Service service) {
    final addresses = service.addresses;
    if (addresses != null && addresses.isNotEmpty) {
      final v4 = addresses.firstWhere(
        (a) => a.type == InternetAddressType.IPv4,
        orElse: () => addresses.first,
      );
      return v4.address;
    }
    return service.host;
  }

  String? _txtString(Map<String, Uint8List?>? txt, String key) {
    final v = txt?[key];
    if (v == null) return null;
    try {
      return utf8.decode(v);
    } catch (_) {
      return null;
    }
  }

  Map<String, Uint8List> _encodeTxt(Map<String, String> entries) => {
        for (final e in entries.entries)
          e.key: Uint8List.fromList(utf8.encode(e.value)),
      };

  /// Stops advertising but keeps discovery active (used when host locks the
  /// room so no new devices can discover it, yet the host can still see any
  /// lingering services go away).
  Future<void> unregisterSelf() async {
    final r = _registration;
    _registration = null;
    if (r != null) {
      try {
        await nsd.unregister(r);
        log.i('Room advertisement unregistered');
      } catch (e, st) {
        log.w('unregister failed: $e', stackTrace: st);
      }
    }
  }

  Future<void> stop() async {
    await unregisterSelf();
    final d = _discovery;
    _discovery = null;
    if (d != null) {
      try {
        await nsd.stopDiscovery(d);
        log.i('Room discovery stopped');
      } catch (e, st) {
        log.w('stopDiscovery failed: $e', stackTrace: st);
      }
    }
    _peers.clear();
    if (!_peersController.isClosed) {
      _peersController.add(const []);
    }
  }

  Future<void> dispose() async {
    await stop();
    if (!_peersController.isClosed) {
      await _peersController.close();
    }
  }
}
