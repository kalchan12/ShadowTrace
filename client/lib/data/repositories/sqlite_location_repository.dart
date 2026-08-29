import 'dart:async';
import '../local/app_database.dart';
import '../../models/location_update.dart';
import '../../services/service_bridge/service_bridge.dart';
import 'location_repository.dart';

class SqliteLocationRepository implements LocationRepository {
  final AppDatabase _database;
  final ServiceBridge _serviceBridge;
  final StreamController<LocationUpdate> _locationsController =
      StreamController<LocationUpdate>.broadcast();

  SqliteLocationRepository(this._database, this._serviceBridge);

  @override
  Stream<LocationUpdate> watchGroupLocations(String groupId) {
    return _locationsController.stream.where(
      (update) => update.groupId == groupId,
    );
  }

  @override
  Future<LocationUpdate?> getLastKnownLocation() async {
    return _serviceBridge.getLastKnownLocation();
  }

  @override
  Future<bool> startBroadcasting(String groupId) async {
    return _serviceBridge.startBroadcasting(groupId);
  }

  @override
  Future<bool> stopBroadcasting() async {
    return _serviceBridge.stopBroadcasting();
  }

  /// Ingest an incoming peer location packet: persists snapshot to SQLite and emits to stream
  Future<void> ingestLocationUpdate(LocationUpdate update) async {
    await _database.upsertPeerLocation(update);
    _locationsController.add(update);
  }

  Future<LocationUpdate?> getCachedPeerLocation(String deviceId) async {
    return _database.getLatestPeerLocation(deviceId);
  }

  void dispose() {
    _locationsController.close();
  }
}
