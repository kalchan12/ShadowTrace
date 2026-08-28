class ServiceStatus {
  final bool isRunning;
  final bool isBroadcasting;
  final String? activeGroupId;
  final int? lastUpdateTimestamp;
  final bool batteryOptimizationIgnored;
  final String locationPermissionStatus;

  const ServiceStatus({
    required this.isRunning,
    required this.isBroadcasting,
    this.activeGroupId,
    this.lastUpdateTimestamp,
    required this.batteryOptimizationIgnored,
    required this.locationPermissionStatus,
  });

  factory ServiceStatus.initial() {
    return const ServiceStatus(
      isRunning: false,
      isBroadcasting: false,
      activeGroupId: null,
      lastUpdateTimestamp: null,
      batteryOptimizationIgnored: false,
      locationPermissionStatus: 'unknown',
    );
  }

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      isRunning: json['is_running'] as bool? ?? false,
      isBroadcasting: json['is_broadcasting'] as bool? ?? false,
      activeGroupId: json['active_group_id'] as String?,
      lastUpdateTimestamp: json['last_update_timestamp'] as int?,
      batteryOptimizationIgnored:
          json['battery_optimization_ignored'] as bool? ?? false,
      locationPermissionStatus:
          json['location_permission_status'] as String? ?? 'unknown',
    );
  }

  ServiceStatus copyWith({
    bool? isRunning,
    bool? isBroadcasting,
    String? activeGroupId,
    int? lastUpdateTimestamp,
    bool? batteryOptimizationIgnored,
    String? locationPermissionStatus,
  }) {
    return ServiceStatus(
      isRunning: isRunning ?? this.isRunning,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      activeGroupId: activeGroupId ?? this.activeGroupId,
      lastUpdateTimestamp: lastUpdateTimestamp ?? this.lastUpdateTimestamp,
      batteryOptimizationIgnored:
          batteryOptimizationIgnored ?? this.batteryOptimizationIgnored,
      locationPermissionStatus:
          locationPermissionStatus ?? this.locationPermissionStatus,
    );
  }
}
