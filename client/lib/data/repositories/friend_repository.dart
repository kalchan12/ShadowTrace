import '../../models/friend.dart';

abstract class FriendRepository {
  /// Stream or fetch friends in the active group.
  Stream<List<Friend>> watchGroupFriends(String groupId);

  /// Update local alias/nickname for a specific device.
  Future<void> updateNickname(String deviceId, String newNickname);

  /// Get locally stored nickname or fallback to callsign.
  Future<String> getNickname(String deviceId);
}
