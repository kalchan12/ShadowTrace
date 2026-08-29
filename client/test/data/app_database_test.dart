import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shadowtrace_client/data/local/app_database.dart';
import 'package:shadowtrace_client/models/group.dart';
import 'package:shadowtrace_client/models/location_update.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late AppDatabase appDb;

  setUp(() async {
    appDb = await AppDatabase.open(
      databaseFactory: databaseFactoryFfi,
      inMemoryPath: inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await appDb.close();
  });

  group('AppDatabase - Local Groups', () {
    test('Can insert, query, and delete groups', () async {
      final group = Group(
        id: 'grp-test-01',
        inviteSecret: 'sec_abcdef123456',
        role: 'admin',
        createdAt: 1700000000000,
      );

      await appDb.insertGroup(group);

      final groups = await appDb.getGroups();
      expect(groups.length, 1);
      expect(groups.first.id, 'grp-test-01');
      expect(groups.first.inviteSecret, 'sec_abcdef123456');

      final queried = await appDb.getGroupById('grp-test-01');
      expect(queried, isNotNull);
      expect(queried!.role, 'admin');

      await appDb.deleteGroup('grp-test-01');
      final afterDelete = await appDb.getGroups();
      expect(afterDelete, isEmpty);
    });
  });

  group('AppDatabase - Local Peers', () {
    test(
      'Can insert peers, query with location join, and update nickname',
      () async {
        // First insert group
        final group = Group(
          id: 'grp-peers-01',
          inviteSecret: 'sec_test_secret',
          role: 'member',
          createdAt: 1700000000000,
        );
        await appDb.insertGroup(group);

        // Insert peer
        await appDb.insertOrUpdatePeer(
          deviceId: 'dev-peer-01',
          groupId: 'grp-peers-01',
          nickname: 'VIPER-1',
          publicKey: 'pub_ec_p256_dummy_key_01',
          joinedAt: 1700000010000,
        );

        final peers = await appDb.getPeersForGroup('grp-peers-01');
        expect(peers.length, 1);
        expect(peers.first.deviceId, 'dev-peer-01');
        expect(peers.first.localNickname, 'VIPER-1');

        // Update nickname
        await appDb.updatePeerNickname(
          'dev-peer-01',
          'grp-peers-01',
          'GHOST-9',
        );
        final updatedNickname = await appDb.getPeerNickname('dev-peer-01');
        expect(updatedNickname, 'GHOST-9');

        // Delete peer
        await appDb.deletePeer('dev-peer-01', 'grp-peers-01');
        final afterDelete = await appDb.getPeersForGroup('grp-peers-01');
        expect(afterDelete, isEmpty);
      },
    );
  });

  group('AppDatabase - Cached Peer Locations', () {
    test(
      'Overwrites previous location snapshot and joins with peers query',
      () async {
        final group = Group(
          id: 'grp-loc-01',
          inviteSecret: 'sec_test_secret',
          role: 'member',
          createdAt: 1700000000000,
        );
        await appDb.insertGroup(group);

        await appDb.insertOrUpdatePeer(
          deviceId: 'dev-loc-01',
          groupId: 'grp-loc-01',
          nickname: 'SPECTER',
          publicKey: 'pub_key',
          joinedAt: 1700000000000,
        );

        final loc1 = LocationUpdate(
          deviceId: 'dev-loc-01',
          groupId: 'grp-loc-01',
          latitude: 37.7749,
          longitude: -122.4194,
          accuracyM: 5.0,
          speedMps: 1.2,
          batteryPct: 90,
          timestamp: 1700000050000,
        );

        await appDb.upsertPeerLocation(loc1);

        final retrieved = await appDb.getLatestPeerLocation('dev-loc-01');
        expect(retrieved, isNotNull);
        expect(retrieved!.latitude, 37.7749);
        expect(retrieved.batteryPct, 90);

        // Verify joined peer query returns location fields
        final peers = await appDb.getPeersForGroup('grp-loc-01');
        expect(peers.first.latitude, 37.7749);
        expect(peers.first.batteryPct, 90);

        // Overwrite location
        final loc2 = LocationUpdate(
          deviceId: 'dev-loc-01',
          groupId: 'grp-loc-01',
          latitude: 37.7800,
          longitude: -122.4200,
          accuracyM: 3.5,
          speedMps: 2.0,
          batteryPct: 89,
          timestamp: 1700000080000,
        );
        await appDb.upsertPeerLocation(loc2);

        final updated = await appDb.getLatestPeerLocation('dev-loc-01');
        expect(updated!.latitude, 37.7800);
        expect(updated.batteryPct, 89);
      },
    );
  });
}
