import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/core/crypto/crypto_verifier.dart';
import 'package:shadowtrace_client/models/location_update.dart';

void main() {
  group('CryptoVerifier', () {
    test('accepts valid coordinates within earth bounds', () {
      final update = LocationUpdate(
        deviceId: 'dev-node-1',
        groupId: 'grp-test-1',
        latitude: 37.7749,
        longitude: -122.4194,
        accuracyM: 5.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        signature: 'mock_sig_base64',
      );

      final isValid = CryptoVerifier.verifyPacketAuthenticity(update: update);
      expect(isValid, isTrue);
    });

    test('rejects out-of-bounds latitude or longitude', () {
      final invalidLat = LocationUpdate(
        deviceId: 'dev-node-1',
        groupId: 'grp-test-1',
        latitude: 95.0, // Invalid > 90
        longitude: -122.4194,
        accuracyM: 5.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      expect(CryptoVerifier.verifyPacketAuthenticity(update: invalidLat), isFalse);

      final invalidLng = LocationUpdate(
        deviceId: 'dev-node-1',
        groupId: 'grp-test-1',
        latitude: 37.7749,
        longitude: 190.0, // Invalid > 180
        accuracyM: 5.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      expect(CryptoVerifier.verifyPacketAuthenticity(update: invalidLng), isFalse);
    });

    test('rejects future timestamps beyond clock skew allowance', () {
      final futurePacket = LocationUpdate(
        deviceId: 'dev-node-1',
        groupId: 'grp-test-1',
        latitude: 37.7749,
        longitude: -122.4194,
        accuracyM: 5.0,
        // 10 minutes in the future (> 5 min max skew)
        timestamp: DateTime.now().millisecondsSinceEpoch + (10 * 60 * 1000),
      );
      expect(CryptoVerifier.verifyPacketAuthenticity(update: futurePacket), isFalse);
    });

    test('canonicalPayload formats deterministic serialization string', () {
      final update = LocationUpdate(
        deviceId: 'dev-node-1',
        groupId: 'grp-test-1',
        latitude: 37.7749,
        longitude: -122.4194,
        accuracyM: 5.0,
        timestamp: 1772184000000,
      );

      expect(
        update.canonicalPayload,
        'dev-node-1:grp-test-1:37.7749:-122.4194:5.0:1772184000000',
      );
    });
  });
}
