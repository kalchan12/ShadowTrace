import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/data/mock/mock_location_repository.dart';

void main() {
  group('MockLocationRepository Tests', () {
    late MockLocationRepository repo;

    setUp(() {
      repo = MockLocationRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    test('getLastKnownLocation returns valid initial coordinate', () async {
      final loc = await repo.getLastKnownLocation();
      expect(loc, isNotNull);
      expect(loc!.latitude, closeTo(37.7749, 0.01));
      expect(loc.longitude, closeTo(-122.4194, 0.01));
      expect(loc.accuracyM, greaterThan(0));
    });

    test('startBroadcasting and stopBroadcasting toggle state', () async {
      expect(repo.isBroadcasting, isFalse);
      await repo.startBroadcasting('group-test');
      expect(repo.isBroadcasting, isTrue);
      await repo.stopBroadcasting();
      expect(repo.isBroadcasting, isFalse);
    });
  });
}
