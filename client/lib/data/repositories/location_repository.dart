import '../../models/location_update.dart';

abstract class LocationRepository {
  /// Stream of incoming real-time location updates for the active group.
  Stream<LocationUpdate> watchGroupLocations(String groupId);

  /// Fetch the latest known location packet for the local device.
  Future<LocationUpdate?> getLastKnownLocation();

  /// Start broadcasting location via the background service.
  Future<bool> startBroadcasting(String groupId);

  /// Stop broadcasting location.
  Future<bool> stopBroadcasting();

  /// Ingest an incoming location update packet from P2P network.
  Future<void> ingestLocationUpdate(LocationUpdate update);
}
