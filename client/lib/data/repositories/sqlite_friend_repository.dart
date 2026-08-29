import 'dart:async';
import '../local/app_database.dart';
import 'friend_repository.dart';
import '../../models/friend.dart';

class SqliteFriendRepository implements FriendRepository {
  final AppDatabase _database;
  final StreamController<List<Friend>> _streamController =
      StreamController<List<Friend>>.broadcast();

  SqliteFriendRepository(this._database);

  @override
  Stream<List<Friend>> watchGroupFriends(String groupId) async* {
    // Initial emission from SQLite
    yield await _database.getPeersForGroup(groupId);
    // Yield from stream updates
    yield* _streamController.stream;
  }

  @override
  Future<void> updateNickname(String deviceId, String newNickname) async {
    final groups = await _database.getGroups();
    for (final group in groups) {
      await _database.updatePeerNickname(deviceId, group.id, newNickname);
      final updatedPeers = await _database.getPeersForGroup(group.id);
      _streamController.add(updatedPeers);
    }
  }

  @override
  Future<String> getNickname(String deviceId) async {
    final nickname = await _database.getPeerNickname(deviceId);
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }
    final prefix = deviceId.length >= 4 ? deviceId.substring(0, 4) : deviceId;
    return 'CALLSIGN-${prefix.toUpperCase()}';
  }

  /// Register or update a paired peer in SQLite
  Future<void> registerPeer({
    required String deviceId,
    required String groupId,
    required String nickname,
    required String publicKey,
    int? joinedAt,
  }) async {
    await _database.insertOrUpdatePeer(
      deviceId: deviceId,
      groupId: groupId,
      nickname: nickname,
      publicKey: publicKey,
      joinedAt: joinedAt ?? DateTime.now().millisecondsSinceEpoch,
    );
    final peers = await _database.getPeersForGroup(groupId);
    _streamController.add(peers);
  }

  void dispose() {
    _streamController.close();
  }
}
