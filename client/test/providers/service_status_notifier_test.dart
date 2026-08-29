import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/core/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceStatusNotifier Tests', () {
    const channel = MethodChannel('com.shadowtrace.client/service_bridge');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            switch (methodCall.method) {
              case 'getServiceStatus':
                return '{"is_running":true,"is_broadcasting":false,"active_group_id":null,"last_update_timestamp":null,"battery_optimization_ignored":true,"location_permission_status":"granted_fine"}';
              case 'startBroadcasting':
                return true;
              case 'stopBroadcasting':
                return true;
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('Initializes and reads service status from bridge', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger initial read
      final status = container.read(serviceStatusProvider);
      expect(status, isNotNull);

      // Wait a tick for async checkStatus
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final updatedStatus = container.read(serviceStatusProvider);
      expect(updatedStatus.isRunning, isTrue);
      expect(updatedStatus.isBroadcasting, isFalse);
    });

    test('toggleBroadcast starts then stops broadcast state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(serviceStatusProvider.notifier);

      await notifier.toggleBroadcast('test-grp-42');
      var status = container.read(serviceStatusProvider);
      expect(status.isBroadcasting, isTrue);
      expect(status.activeGroupId, 'test-grp-42');

      await notifier.toggleBroadcast('test-grp-42');
      status = container.read(serviceStatusProvider);
      expect(status.isBroadcasting, isFalse);
      expect(status.activeGroupId, isNull);
    });
  });
}
