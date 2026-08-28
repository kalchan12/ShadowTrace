import 'dart:math';
import 'package:uuid/uuid.dart';
import '../repositories/group_repository.dart';
import '../../models/group.dart';

class MockGroupRepository implements GroupRepository {
  final List<Group> _groups = [
    Group(
      id: 'a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d',
      createdByDeviceId: 'local-device-id-0000',
      createdAt: DateTime.now()
          .subtract(const Duration(days: 7))
          .millisecondsSinceEpoch,
      inviteSecret: 'sec_7f9a8b1c2d3e4f5a6b7c8d9e0f1a2b3c',
    ),
  ];

  @override
  Future<List<Group>> getJoinedGroups() async {
    return List.unmodifiable(_groups);
  }

  @override
  Future<Group> createGroup() async {
    final newGroup = Group(
      id: const Uuid().v4(),
      createdByDeviceId: 'local-device-id-0000',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      inviteSecret: 'sec_${Random().nextInt(999999999).toRadixString(16)}',
    );
    _groups.add(newGroup);
    return newGroup;
  }

  @override
  Future<Group> joinGroup(String groupId, String inviteSecret) async {
    final existing = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => Group(
        id: groupId,
        createdByDeviceId: 'remote-device-creator',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        inviteSecret: inviteSecret,
      ),
    );
    if (!_groups.contains(existing)) {
      _groups.add(existing);
    }
    return existing;
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    _groups.removeWhere((g) => g.id == groupId);
  }
}
