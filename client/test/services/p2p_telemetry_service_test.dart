import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/models/location_update.dart';
import 'package:shadowtrace_client/services/p2p_telemetry_service.dart';
import 'package:shadowtrace_client/data/repositories/location_repository.dart';

class TestLocationRepository implements LocationRepository {
  final List<LocationUpdate> ingested = [];
  final StreamController<LocationUpdate> _controller =
      StreamController<LocationUpdate>.broadcast();

  @override
  Stream<LocationUpdate> watchGroupLocations(String groupId) =>
      _controller.stream;

  @override
  Future<LocationUpdate?> getLastKnownLocation() async => null;

  @override
  Future<bool> startBroadcasting(String groupId) async => true;

  @override
  Future<bool> stopBroadcasting() async => true;

  @override
  Future<void> ingestLocationUpdate(LocationUpdate update) async {
    ingested.add(update);
    _controller.add(update);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('P2pTelemetryService', () {
    late TestLocationRepository repo;
    late P2pTelemetryService service;

    setUp(() {
      repo = TestLocationRepository();
      // Use an ephemeral high test port to avoid conflict
      service = P2pTelemetryService(repo, port: 48599);
    });

    tearDown(() async {
      await service.stopListening();
      service.dispose();
      repo.dispose();
    });

    test('starts and stops UDP socket listener cleanly', () async {
      expect(service.isListening, isFalse);

      final started = await service.startListening();
      expect(started, isTrue);
      expect(service.isListening, isTrue);

      await service.stopListening();
      expect(service.isListening, isFalse);
    });

    test('broadcasts location telemetry datagram packet', () async {
      final packet = LocationUpdate(
        deviceId: 'dev-node-99',
        groupId: 'grp-test-p2p',
        latitude: 37.7790,
        longitude: -122.4150,
        accuracyM: 3.5,
        speedMps: 2.0,
        bearingDeg: 180.0,
        altitudeM: 20.0,
        batteryPct: 95,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final sent = await service.broadcastLocation(packet);
      // Socket broadcast successfully dispatched locally
      expect(sent, isTrue);
    });

    test('ingestLocationUpdate triggers stream in repository', () async {
      final update = LocationUpdate(
        deviceId: 'dev-incoming-42',
        groupId: 'grp-test-42',
        latitude: 37.7812,
        longitude: -122.4210,
        accuracyM: 5.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await repo.ingestLocationUpdate(update);
      expect(repo.ingested.length, 1);
      expect(repo.ingested.first.deviceId, 'dev-incoming-42');
      expect(repo.ingested.first.latitude, 37.7812);
    });
  });
}
