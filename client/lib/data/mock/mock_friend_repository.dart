import 'dart:async';
import '../repositories/friend_repository.dart';
import '../../models/friend.dart';

class MockFriendRepository implements FriendRepository {
  final Map<String, String> _localNicknames = {
    'f8a93e1b7c2d0e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f':
        'PHANTOM-4',
    'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2':
        'VIPER-9',
    'c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4':
        'SPECTER-2',
  };

  @override
  Stream<List<Friend>> watchGroupFriends(String groupId) async* {
    yield [
      Friend(
        deviceId:
            'f8a93e1b7c2d0e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f',
        localNickname:
            _localNicknames['f8a93e1b7c2d0e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f']!,
        role: 'admin',
        joinedAt: DateTime.now()
            .subtract(const Duration(days: 4))
            .millisecondsSinceEpoch,
        lastSeen: DateTime.now()
            .subtract(const Duration(seconds: 8))
            .millisecondsSinceEpoch,
        distanceMeters: 420.0,
        latitude: 37.7758,
        longitude: -122.4182,
        accuracyMeters: 4.8,
        speedMps: 1.4,
        bearingDegrees: 45.0,
        batteryPct: 88,
      ),
      Friend(
        deviceId:
            'b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2',
        localNickname:
            _localNicknames['b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2']!,
        role: 'member',
        joinedAt: DateTime.now()
            .subtract(const Duration(days: 2))
            .millisecondsSinceEpoch,
        lastSeen: DateTime.now()
            .subtract(const Duration(minutes: 2))
            .millisecondsSinceEpoch,
        distanceMeters: 1350.0,
        latitude: 37.7692,
        longitude: -122.4250,
        accuracyMeters: 12.0,
        speedMps: 0.0,
        bearingDegrees: 180.0,
        batteryPct: 64,
      ),
      Friend(
        deviceId:
            'c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4',
        localNickname:
            _localNicknames['c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4']!,
        role: 'member',
        joinedAt: DateTime.now()
            .subtract(const Duration(hours: 12))
            .millisecondsSinceEpoch,
        lastSeen: DateTime.now()
            .subtract(const Duration(minutes: 15))
            .millisecondsSinceEpoch,
        distanceMeters: 3200.0,
        latitude: 37.7880,
        longitude: -122.4050,
        accuracyMeters: 25.0,
        speedMps: null,
        bearingDegrees: null,
        batteryPct: 35,
      ),
    ];
  }

  @override
  Future<void> updateNickname(String deviceId, String newNickname) async {
    _localNicknames[deviceId] = newNickname;
  }

  @override
  Future<String> getNickname(String deviceId) async {
    return _localNicknames[deviceId] ??
        'CALLSIGN-${deviceId.take(4).toUpperCase()}';
  }

  @override
  Future<void> registerPeer({
    required String deviceId,
    required String groupId,
    required String nickname,
    required String publicKey,
    int? joinedAt,
  }) async {
    _localNicknames[deviceId] = nickname;
  }
}

extension StringExtension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
