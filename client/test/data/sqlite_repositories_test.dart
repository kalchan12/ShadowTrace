import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shadowtrace_client/data/local/app_database.dart';
import 'package:shadowtrace_client/data/repositories/sqlite_group_repository.dart';
import 'package:shadowtrace_client/data/repositories/sqlite_friend_repository.dart';
import 'package:shadowtrace_client/data/repositories/sqlite_location_repository.dart';
import 'package:shadowtrace_client/services/service_bridge/service_bridge.dart';
import 'package:shadowtrace_client/models/location_update.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late AppDatabase appDb;
  late SqliteGroupRepository groupRepo;
  late SqliteFriendRepository friendRepo;
  late SqliteLocationRepository locationRepo;

  setUp(() async {
    appDb = await AppDatabase.open(
      databaseFactory: databaseFactoryFfi,
      inMemoryPath: inMemoryDatabasePath,
    );
    groupRepo = SqliteGroupRepository(appDb);
    friendRepo = SqliteFriendRepository(appDb);
    locationRepo = SqliteLocationRepository(appDb, ServiceBridge());
  });

  tearDown(() async {
    friendRepo.dispose();
    locationRepo.dispose();
    await appDb.close();
  });

  group('SqliteGroupRepository', () {
    test('createGroup, getJoinedGroups, joinGroup, and leaveGroup', () async {
      final created = await groupRepo.createGroup();
      expect(created.id, isNotEmpty);
      expect(created.role, 'admin');

      final groups = await groupRepo.getJoinedGroups();
      expect(groups.length, 1);
      expect(groups.first.id, created.id);

      final joined = await groupRepo.joinGroup('grp-ext-99', 'sec_external_99');
      expect(joined.id, 'grp-ext-99');
      expect(joined.role, 'member');

      final totalGroups = await groupRepo.getJoinedGroups();
      expect(totalGroups.length, 2);

      await groupRepo.leaveGroup('grp-ext-99');
      final afterLeave = await groupRepo.getJoinedGroups();
      expect(afterLeave.length, 1);
    });
  });

  group('SqliteFriendRepository', () {
    test('registerPeer, watchGroupFriends, and updateNickname', () async {
      final group = await groupRepo.createGroup();

      await friendRepo.registerPeer(
        deviceId: 'dev-peer-42',
        groupId: group.id,
        nickname: 'VIPER-42',
        publicKey: 'pub_ec_p256_mock_key',
      );

      final friends = await friendRepo.watchGroupFriends(group.id).first;
      expect(friends.length, 1);
      expect(friends.first.deviceId, 'dev-peer-42');
      expect(friends.first.localNickname, 'VIPER-42');

      await friendRepo.updateNickname('dev-peer-42', 'STRIKER-1');
      final updatedCallsign = await friendRepo.getNickname('dev-peer-42');
      expect(updatedCallsign, 'STRIKER-1');
    });
  });

  group('SqliteLocationRepository', () {
    test('ingestLocationUpdate caches and streams to listeners', () async {
      final group = await groupRepo.createGroup();

      final locPacket = LocationUpdate(
        deviceId: 'dev-peer-100',
        groupId: group.id,
        latitude: 37.7850,
        longitude: -122.4060,
        accuracyM: 4.2,
        batteryPct: 77,
        timestamp: 1700000100000,
      );

      // Listen on stream
      final streamFuture = locationRepo.watchGroupLocations(group.id).first;

      await locationRepo.ingestLocationUpdate(locPacket);

      final received = await streamFuture;
      expect(received.deviceId, 'dev-peer-100');
      expect(received.latitude, 37.7850);

      final cached = await locationRepo.getCachedPeerLocation('dev-peer-100');
      expect(cached, isNotNull);
      expect(cached!.latitude, 37.7850);
      expect(cached.batteryPct, 77);
    });
  });
}
