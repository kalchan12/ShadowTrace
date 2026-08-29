import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/models/pairing_payload.dart';

void main() {
  group('PairingPayload Model & Parser', () {
    test('generate and parse valid GroupInvitePayload', () {
      const invite = GroupInvitePayload(
        groupId: 'a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d',
        inviteSecret: 'sec9f83ab21e054cc48d1e2f3a4b5c6d7e8',
        expirationEpochMs: 2000000000000,
      );

      final uri = invite.toUri();
      expect(
        uri,
        'shadowtrace://v1/join?gid=a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d&sec=sec9f83ab21e054cc48d1e2f3a4b5c6d7e8&exp=2000000000000',
      );

      final parsed = PairingPayload.parse(uri);
      expect(parsed, isA<GroupInvitePayload>());
      final groupPayload = parsed as GroupInvitePayload;
      expect(groupPayload.groupId, 'a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d');
      expect(groupPayload.inviteSecret, 'sec9f83ab21e054cc48d1e2f3a4b5c6d7e8');
      expect(groupPayload.expirationEpochMs, 2000000000000);
    });

    test('generate and parse valid PeerPairingPayload', () {
      const peer = PeerPairingPayload(
        deviceId: 'd9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0',
        publicKey: 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...',
        alias: 'VIPER-42',
        groupId: 'grp-test-uuid',
      );

      final uri = peer.toUri();
      expect(uri, contains('shadowtrace://v1/peer?did='));
      expect(uri, contains('alias=VIPER-42'));

      final parsed = PairingPayload.parse(uri);
      expect(parsed, isA<PeerPairingPayload>());
      final peerPayload = parsed as PeerPairingPayload;
      expect(
        peerPayload.deviceId,
        'd9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0',
      );
      expect(peerPayload.publicKey, 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...');
      expect(peerPayload.alias, 'VIPER-42');
      expect(peerPayload.groupId, 'grp-test-uuid');
    });

    test('throws ExpiredInviteException when invite expiration has passed', () {
      const expiredUri =
          'shadowtrace://v1/join?gid=a8b3c4d5-e6f7-4a1b-8c2d-3e4f5a6b7c8d&sec=testsecret&exp=1000000000000';
      expect(
        () => PairingPayload.parse(expiredUri),
        throwsA(isA<ExpiredInviteException>()),
      );
    });

    test('throws InvalidPairingPayloadException on invalid scheme or missing parameters', () {
      expect(
        () => PairingPayload.parse('https://example.com/join'),
        throwsA(isA<InvalidPairingPayloadException>()),
      );

      expect(
        () => PairingPayload.parse('shadowtrace://v1/join?sec=testsecret'),
        throwsA(isA<InvalidPairingPayloadException>()),
      );

      expect(
        () => PairingPayload.parse(''),
        throwsA(isA<InvalidPairingPayloadException>()),
      );
    });
  });
}
