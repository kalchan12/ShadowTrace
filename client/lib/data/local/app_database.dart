import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../models/friend.dart';
import '../../models/group.dart';
import '../../models/location_update.dart';

class AppDatabase {
  final Database _db;

  AppDatabase(this._db);

  static const String dbName = 'shadowtrace_local.db';
  static const int dbVersion = 1;

  /// Open or create the local SQLite database.
  static Future<AppDatabase> open({
    DatabaseFactory? databaseFactory,
    String? inMemoryPath,
  }) async {
    final factory = databaseFactory ?? databaseFactorySqflitePlugin;
    final String path;

    if (inMemoryPath != null) {
      path = inMemoryPath;
    } else {
      final databasesPath = await factory.getDatabasesPath();
      path = p.join(databasesPath, dbName);
    }

    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: dbVersion,
        onCreate: (db, version) async {
          await db.execute('PRAGMA foreign_keys = ON;');
          await _createTables(db);
        },
        onOpen: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
      ),
    );

    return AppDatabase(db);
  }

  static Future<void> _createTables(Database db) async {
    // 1. Local groups table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_groups (
        id TEXT PRIMARY KEY,
        invite_secret TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'member',
        created_at INTEGER NOT NULL
      );
    ''');

    // 2. Local peer contacts table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_peers (
        device_id TEXT NOT NULL,
        group_id TEXT NOT NULL REFERENCES local_groups(id) ON DELETE CASCADE,
        nickname TEXT NOT NULL,
        public_key TEXT NOT NULL,
        joined_at INTEGER NOT NULL,
        PRIMARY KEY (group_id, device_id)
      );
    ''');

    // 3. Cached peer latest coordinates (Overwritten on update - Zero History)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_peer_locations (
        device_id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL REFERENCES local_groups(id) ON DELETE CASCADE,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        accuracy_m REAL NOT NULL,
        speed_mps REAL,
        bearing_deg REAL,
        altitude_m REAL,
        battery_pct INTEGER,
        updated_at INTEGER NOT NULL
      );
    ''');
  }

  Database get rawDb => _db;

  // ---------------------------------------------------------------------------
  // Groups Operations
  // ---------------------------------------------------------------------------

  Future<void> insertGroup(Group group) async {
    await _db.insert('local_groups', {
      'id': group.id,
      'invite_secret': group.inviteSecret,
      'role': group.role,
      'created_at': group.createdAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Group>> getGroups() async {
    final List<Map<String, dynamic>> maps = await _db.query('local_groups');
    return maps.map((row) {
      return Group(
        id: row['id'] as String,
        inviteSecret: row['invite_secret'] as String,
        role: row['role'] as String,
        createdAt: row['created_at'] as int,
      );
    }).toList();
  }

  Future<Group?> getGroupById(String groupId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'local_groups',
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final row = maps.first;
    return Group(
      id: row['id'] as String,
      inviteSecret: row['invite_secret'] as String,
      role: row['role'] as String,
      createdAt: row['created_at'] as int,
    );
  }

  Future<void> deleteGroup(String groupId) async {
    await _db.delete('local_groups', where: 'id = ?', whereArgs: [groupId]);
  }

  // ---------------------------------------------------------------------------
  // Peers Operations
  // ---------------------------------------------------------------------------

  Future<void> insertOrUpdatePeer({
    required String deviceId,
    required String groupId,
    required String nickname,
    required String publicKey,
    required int joinedAt,
  }) async {
    await _db.insert('local_peers', {
      'device_id': deviceId,
      'group_id': groupId,
      'nickname': nickname,
      'public_key': publicKey,
      'joined_at': joinedAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Friend>> getPeersForGroup(String groupId) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery(
      '''
      SELECT 
        p.device_id,
        p.group_id,
        p.nickname,
        p.joined_at,
        loc.latitude,
        loc.longitude,
        loc.accuracy_m,
        loc.speed_mps,
        loc.bearing_deg,
        loc.battery_pct,
        loc.updated_at
      FROM local_peers p
      LEFT JOIN cached_peer_locations loc 
        ON p.device_id = loc.device_id AND p.group_id = loc.group_id
      WHERE p.group_id = ?
    ''',
      [groupId],
    );

    return maps.map((row) {
      return Friend(
        deviceId: row['device_id'] as String,
        localNickname: row['nickname'] as String,
        role: 'member',
        joinedAt: row['joined_at'] as int,
        lastSeen: row['updated_at'] as int?,
        latitude: (row['latitude'] as num?)?.toDouble(),
        longitude: (row['longitude'] as num?)?.toDouble(),
        accuracyMeters: (row['accuracy_m'] as num?)?.toDouble(),
        speedMps: (row['speed_mps'] as num?)?.toDouble(),
        bearingDegrees: (row['bearing_deg'] as num?)?.toDouble(),
        batteryPct: row['battery_pct'] as int?,
      );
    }).toList();
  }

  Future<void> updatePeerNickname(
    String deviceId,
    String groupId,
    String newNickname,
  ) async {
    await _db.update(
      'local_peers',
      {'nickname': newNickname},
      where: 'device_id = ? AND group_id = ?',
      whereArgs: [deviceId, groupId],
    );
  }

  Future<String?> getPeerNickname(String deviceId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'local_peers',
      columns: ['nickname'],
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['nickname'] as String?;
  }

  Future<void> deletePeer(String deviceId, String groupId) async {
    await _db.delete(
      'local_peers',
      where: 'device_id = ? AND group_id = ?',
      whereArgs: [deviceId, groupId],
    );
  }

  // ---------------------------------------------------------------------------
  // Location Cache Operations (Zero-Cloud Latest Snapshot)
  // ---------------------------------------------------------------------------

  Future<void> upsertPeerLocation(LocationUpdate update) async {
    await _db.insert('cached_peer_locations', {
      'device_id': update.deviceId,
      'group_id': update.groupId,
      'latitude': update.latitude,
      'longitude': update.longitude,
      'accuracy_m': update.accuracyM,
      'speed_mps': update.speedMps,
      'bearing_deg': update.bearingDeg,
      'altitude_m': update.altitudeM,
      'battery_pct': update.batteryPct,
      'updated_at': update.timestamp,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<LocationUpdate?> getLatestPeerLocation(String deviceId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'cached_peer_locations',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final row = maps.first;
    return LocationUpdate(
      deviceId: row['device_id'] as String,
      groupId: row['group_id'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      accuracyM: (row['accuracy_m'] as num).toDouble(),
      altitudeM: (row['altitude_m'] as num?)?.toDouble(),
      speedMps: (row['speed_mps'] as num?)?.toDouble(),
      bearingDeg: (row['bearing_deg'] as num?)?.toDouble(),
      batteryPct: row['battery_pct'] as int?,
      timestamp: row['updated_at'] as int,
    );
  }

  Future<void> close() async {
    await _db.close();
  }
}
