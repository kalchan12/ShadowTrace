import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/location_update.dart';
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

  /// Retrieves the hardware-backed device identifier (SHA-256 fingerprint) from the Service.
  Future<String?> getDeviceId() async {
    try {
      final String? deviceId = await _channel.invokeMethod<String>(
        'getDeviceId',
      );
      return deviceId;
    } on MissingPluginException {
      return 'mock-device-id-dev-0001';
    } catch (_) {
      return null;
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
        final Map<String, dynamic> data =
            jsonDecode(jsonString) as Map<String, dynamic>;
        return ServiceStatus.fromJson(data);
      }
    } on MissingPluginException {
      return ServiceStatus.initial().copyWith(
        isRunning: true,
        isBroadcasting: true,
      );
    } catch (_) {
      // Fallback on parse or invocation error
    }
    return ServiceStatus.initial();
  }

  /// Retrieves the most recent location update from the background service.
  Future<LocationUpdate?> getLastKnownLocation() async {
    try {
      final String? jsonString = await _channel.invokeMethod<String>(
        'getLastKnownLocation',
      );
      if (jsonString != null && jsonString.isNotEmpty && jsonString != '{}') {
        final Map<String, dynamic> data =
            jsonDecode(jsonString) as Map<String, dynamic>;
        return LocationUpdate(
          deviceId: data['device_id'] as String? ?? 'local-device',
          groupId: data['group_id'] as String? ?? '',
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          accuracyM: (data['accuracy_m'] as num).toDouble(),
          altitudeM: (data['altitude_m'] as num?)?.toDouble(),
          speedMps: (data['speed_mps'] as num?)?.toDouble(),
          bearingDeg: (data['bearing_deg'] as num?)?.toDouble(),
          batteryPct: data['battery_pct'] as int?,
          isCharging: data['is_charging'] as bool?,
          timestamp:
              data['timestamp'] as int? ??
              DateTime.now().millisecondsSinceEpoch,
        );
      }
    } on MissingPluginException {
      return null;
    } catch (_) {
      // Fallback
    }
    return null;
  }
}
