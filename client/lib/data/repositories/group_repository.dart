import '../../models/group.dart';

abstract class GroupRepository {
  /// Fetch all groups the local device is a member of.
  Future<List<Group>> getJoinedGroups();

  /// Create a new group with a high-entropy invite secret.
  Future<Group> createGroup();

  /// Join a group using the invite secret token.
  Future<Group> joinGroup(String groupId, String inviteSecret);

  /// Leave or delete a group.
  Future<void> leaveGroup(String groupId);
}
