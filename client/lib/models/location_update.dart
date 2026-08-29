class LocationUpdate {
  final String deviceId;
  final String groupId;
  final double latitude;
  final double longitude;
  final double accuracyM;
  final double? altitudeM;
  final double? speedMps;
  final double? bearingDeg;
  final int? batteryPct;
  final bool? isCharging;
  final int timestamp;
  final String? signature;

  const LocationUpdate({
    required this.deviceId,
    required this.groupId,
    required this.latitude,
    required this.longitude,
    required this.accuracyM,
    this.altitudeM,
    this.speedMps,
    this.bearingDeg,
    this.batteryPct,
    this.isCharging,
    required this.timestamp,
    this.signature,
  });

  String get canonicalPayload =>
      '$deviceId:$groupId:$latitude:$longitude:$accuracyM:$timestamp';

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      deviceId: json['device_id'] as String,
      groupId: json['group_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyM: (json['accuracy_m'] as num).toDouble(),
      altitudeM: (json['altitude_m'] as num?)?.toDouble(),
      speedMps: (json['speed_mps'] as num?)?.toDouble(),
      bearingDeg: (json['bearing_deg'] as num?)?.toDouble(),
      batteryPct: json['battery_pct'] as int?,
      isCharging: json['is_charging'] as bool?,
      timestamp: json['timestamp'] as int,
      signature: json['sig'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'group_id': groupId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_m': accuracyM,
      if (altitudeM != null) 'altitude_m': altitudeM,
      if (speedMps != null) 'speed_mps': speedMps,
      if (bearingDeg != null) 'bearing_deg': bearingDeg,
      if (batteryPct != null) 'battery_pct': batteryPct,
      if (isCharging != null) 'is_charging': isCharging,
      'timestamp': timestamp,
      if (signature != null) 'sig': signature,
    };
  }
}
