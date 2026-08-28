import 'package:flutter/services.dart';
import '../../models/service_status.dart';

class ServiceBridge {
  static const MethodChannel _channel = MethodChannel(
    'com.shadowtrace.client/service_bridge',
  );

  /// Check if the native ShadowTrace Service APK is installed on this device.
  Future<bool> isServiceInstalled() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'isServiceInstalled',
      );
      return result ?? false;
    } on MissingPluginException {
      // In mock/development mode without native runner
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Request the Service to start broadcasting for the given group ID.
  Future<bool> startBroadcasting(String groupId) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'startBroadcasting',
        {'groupId': groupId},
      );
      return result ?? true;
    } on MissingPluginException {
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Request the Service to halt broadcasting.
  Future<bool> stopBroadcasting() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'stopBroadcasting',
      );
      return result ?? true;
    } on MissingPluginException {
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Query the current Service status via IPC.
  Future<ServiceStatus> queryServiceStatus() async {
    try {
      final String? jsonString = await _channel.invokeMethod<String>(
        'getServiceStatus',
      );
      if (jsonString != null && jsonString.isNotEmpty) {
        return ServiceStatus.initial().copyWith(isRunning: true);
      }
    } on MissingPluginException {
      return ServiceStatus.initial().copyWith(
        isRunning: true,
        isBroadcasting: true,
      );
    } catch (_) {
      // Fallback
    }
    return ServiceStatus.initial();
  }
}
