import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadowtrace_client/services/service_bridge/service_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceBridge Tests', () {
    late ServiceBridge bridge;
    const channel = MethodChannel('com.shadowtrace.client/service_bridge');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      bridge = ServiceBridge();
      log.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            switch (methodCall.method) {
              case 'isServiceInstalled':
                return true;
              case 'getDeviceId':
                return 'dev_sha256_mock_device_id_12345';
              case 'startBroadcasting':
                return true;
              case 'stopBroadcasting':
                return true;
              case 'getServiceStatus':
                return '{"is_running":true,"is_broadcasting":true,"active_group_id":"grp-1","last_update_timestamp":1700000000,"battery_optimization_ignored":true,"location_permission_status":"granted_fine"}';
              case 'getLastKnownLocation':
                return '{"device_id":"dev_sha256_mock_device_id_12345","group_id":"grp-1","latitude":37.7749,"longitude":-122.4194,"accuracy_m":5.0,"speed_mps":1.2,"bearing_deg":90.0,"timestamp":1700000000}';
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('isServiceInstalled queries method channel correctly', () async {
      final installed = await bridge.isServiceInstalled();
      expect(installed, isTrue);
      expect(log, hasLength(1));
      expect(log.first.method, 'isServiceInstalled');
    });

    test('getDeviceId returns valid hardware identity string', () async {
      final id = await bridge.getDeviceId();
      expect(id, 'dev_sha256_mock_device_id_12345');
      expect(log.first.method, 'getDeviceId');
    });

    test('startBroadcasting passes group ID argument', () async {
      final success = await bridge.startBroadcasting('target-group-123');
      expect(success, isTrue);
      expect(log.first.method, 'startBroadcasting');
      expect(log.first.arguments, {'groupId': 'target-group-123'});
    });

    test('stopBroadcasting sends stop command', () async {
      final success = await bridge.stopBroadcasting();
      expect(success, isTrue);
      expect(log.first.method, 'stopBroadcasting');
    });

    test('queryServiceStatus parses JSON correctly', () async {
      final status = await bridge.queryServiceStatus();
      expect(status.isRunning, isTrue);
      expect(status.isBroadcasting, isTrue);
      expect(status.activeGroupId, 'grp-1');
      expect(status.batteryOptimizationIgnored, isTrue);
      expect(status.locationPermissionStatus, 'granted_fine');
    });

    test('getLastKnownLocation parses JSON correctly', () async {
      final loc = await bridge.getLastKnownLocation();
      expect(loc, isNotNull);
      expect(loc!.deviceId, 'dev_sha256_mock_device_id_12345');
      expect(loc.groupId, 'grp-1');
      expect(loc.latitude, 37.7749);
      expect(loc.longitude, -122.4194);
      expect(loc.accuracyM, 5.0);
    });
  });
}
