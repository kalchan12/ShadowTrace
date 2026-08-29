import 'dart:async';
import 'dart:math';
import '../repositories/location_repository.dart';
import '../../models/location_update.dart';

class MockLocationRepository implements LocationRepository {
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();
  Timer? _timer;
  bool _isBroadcasting = false;

  final double _baseLat = 37.7749;
  final double _baseLng = -122.4194;
  final Random _random = Random();

  MockLocationRepository() {
    _startSimulatedUpdates();
  }

  void _startSimulatedUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_controller.isClosed) {
        final latDelta = (_random.nextDouble() - 0.5) * 0.002;
        final lngDelta = (_random.nextDouble() - 0.5) * 0.002;

        final update = LocationUpdate(
          deviceId:
              'f8a93e1b7c2d0e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f',
          groupId: 'mock-group-001',
          latitude: _baseLat + latDelta,
          longitude: _baseLng + lngDelta,
          accuracyM: 4.5 + _random.nextDouble() * 3.0,
          altitudeM: 15.0,
          speedMps: 1.2 + _random.nextDouble() * 4.0,
          bearingDeg: _random.nextDouble() * 360.0,
          batteryPct: 88,
          isCharging: false,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        _controller.add(update);
      }
    });
  }

  @override
  Stream<LocationUpdate> watchGroupLocations(String groupId) {
    return _controller.stream;
  }

  @override
  Future<LocationUpdate?> getLastKnownLocation() async {
    return LocationUpdate(
      deviceId: 'local-device-id-0000',
      groupId: 'mock-group-001',
      latitude: _baseLat,
      longitude: _baseLng,
      accuracyM: 5.0,
      altitudeM: 12.0,
      speedMps: 0.0,
      bearingDeg: 0.0,
      batteryPct: 92,
      isCharging: true,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<bool> startBroadcasting(String groupId) async {
    _isBroadcasting = true;
    return true;
  }

  @override
  Future<bool> stopBroadcasting() async {
    _isBroadcasting = false;
    return true;
  }

  @override
  Future<void> ingestLocationUpdate(LocationUpdate update) async {
    _controller.add(update);
  }

  bool get isBroadcasting => _isBroadcasting;

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
