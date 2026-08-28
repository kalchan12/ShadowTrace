import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/models/device.dart';
import 'package:shadowtrace_client/models/friend.dart';

void main() {
  group('Device Model Tests', () {
    test('Device JSON serialization / deserialization round-trip', () {
      final json = {
        'device_id':
            'f8a93e1b7c2d0e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f',
        'public_key': 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...',
        'created_at': 1772184000000,
        'last_seen': 1772184005000,
      };

      final device = Device.fromJson(json);
      expect(
        device.deviceId,
        'f8a93e1b7c2d0e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f',
      );
      expect(device.toJson(), json);
    });
  });

  group('Friend Model Tests', () {
    test('Peer status computes online when lastSeen is recent', () {
      final friend = Friend(
        deviceId: 'dev-1',
        localNickname: 'ALPHA',
        role: 'admin',
        joinedAt: 1000,
        lastSeen: DateTime.now().millisecondsSinceEpoch - 5000, // 5s ago
      );
      expect(friend.status, PeerStatus.online);
    });

    test('Peer status computes stale when lastSeen is between 30s and 5m', () {
      final friend = Friend(
        deviceId: 'dev-1',
        localNickname: 'ALPHA',
        role: 'admin',
        joinedAt: 1000,
        lastSeen: DateTime.now().millisecondsSinceEpoch - 120000, // 2m ago
      );
      expect(friend.status, PeerStatus.stale);
    });

    test('Peer status computes offline when lastSeen is over 5m ago', () {
      final friend = Friend(
        deviceId: 'dev-1',
        localNickname: 'ALPHA',
        role: 'admin',
        joinedAt: 1000,
        lastSeen: DateTime.now().millisecondsSinceEpoch - 400000, // >6m ago
      );
      expect(friend.status, PeerStatus.offline);
    });
  });
}
