import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../data/repositories/location_repository.dart';
import '../models/location_update.dart';

/// Direct Peer-to-Peer Telemetry Service across local Wi-Fi / subnet broadcast (Phase 6).
class P2pTelemetryService {
  static const int defaultPort = 48550;
  static const String broadcastAddress = '255.255.255.255';

  final LocationRepository _locationRepository;
  final int port;

  RawDatagramSocket? _socket;
  StreamSubscription<RawSocketEvent>? _subscription;
  bool _isListening = false;

  final StreamController<LocationUpdate> _incomingController =
      StreamController<LocationUpdate>.broadcast();

  P2pTelemetryService(
    this._locationRepository, {
    this.port = defaultPort,
  });

  bool get isListening => _isListening;
  Stream<LocationUpdate> get incomingLocations => _incomingController.stream;

  /// Start listening for incoming P2P location packets on local network.
  Future<bool> startListening() async {
    if (_isListening) return true;

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        port,
        reuseAddress: true,
        reusePort: true,
      );
      _socket?.broadcastEnabled = true;

      _subscription = _socket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket?.receive();
          if (datagram != null) {
            _processIncomingDatagram(datagram);
          }
        }
      });

      _isListening = true;
      return true;
    } catch (e) {
      _isListening = false;
      return false;
    }
  }

  void _processIncomingDatagram(Datagram datagram) {
    try {
      final jsonString = utf8.decode(datagram.data).trim();
      if (!jsonString.startsWith('{') || !jsonString.endsWith('}')) return;

      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final update = LocationUpdate.fromJson(map);

      _incomingController.add(update);

      // Automatically ingest into repository to persist snapshot and notify map/squad
      _locationRepository.ingestLocationUpdate(update);
    } catch (_) {
      // Ephemeral corrupted packet ignored
    }
  }

  /// Broadcast a location update directly to local subnet peers.
  Future<bool> broadcastLocation(LocationUpdate update) async {
    try {
      final jsonStr = jsonEncode(update.toJson());
      final bytes = utf8.encode(jsonStr);

      final socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      socket.broadcastEnabled = true;
      socket.send(
        bytes,
        InternetAddress(broadcastAddress),
        port,
      );
      socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Stop listening and clean up resources.
  Future<void> stopListening() async {
    _isListening = false;
    await _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
  }

  void dispose() {
    stopListening();
    _incomingController.close();
  }
}
