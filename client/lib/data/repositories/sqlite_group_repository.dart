import 'dart:math';
import 'package:uuid/uuid.dart';
import '../local/app_database.dart';
import 'group_repository.dart';
import '../../models/group.dart';

class SqliteGroupRepository implements GroupRepository {
  final AppDatabase _database;

  SqliteGroupRepository(this._database);

  @override
  Future<List<Group>> getJoinedGroups() async {
    return _database.getGroups();
  }

  @override
  Future<Group> createGroup() async {
    final newGroup = Group(
      id: const Uuid().v4(),
      createdByDeviceId: 'local-device-owner',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      inviteSecret: 'sec_${Random().nextInt(999999999).toRadixString(16)}',
      role: 'admin',
    );
    await _database.insertGroup(newGroup);
    return newGroup;
  }

  @override
  Future<Group> joinGroup(String groupId, String inviteSecret) async {
    final existing = await _database.getGroupById(groupId);
    if (existing != null) {
      return existing;
    }
    final joined = Group(
      id: groupId,
      createdByDeviceId: 'remote-device-creator',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      inviteSecret: inviteSecret,
      role: 'member',
    );
    await _database.insertGroup(joined);
    return joined;
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await _database.deleteGroup(groupId);
  }
}
