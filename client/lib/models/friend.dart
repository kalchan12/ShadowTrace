enum PeerStatus { online, stale, offline }

class Friend {
  final String deviceId;
  final String localNickname;
  final String role;
  final int joinedAt;
  final int? lastSeen;
  final double? distanceMeters;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final double? speedMps;
  final double? bearingDegrees;
  final int? batteryPct;

  const Friend({
    required this.deviceId,
    required this.localNickname,
    required this.role,
    required this.joinedAt,
    this.lastSeen,
    this.distanceMeters,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.speedMps,
    this.bearingDegrees,
    this.batteryPct,
  });

  PeerStatus get status {
    if (lastSeen == null) return PeerStatus.offline;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastSeen!;
    if (diff < 30000) return PeerStatus.online; // < 30 seconds
    if (diff < 300000) return PeerStatus.stale; // < 5 minutes
    return PeerStatus.offline;
  }

  Friend copyWith({
    String? localNickname,
    String? role,
    int? lastSeen,
    double? distanceMeters,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? speedMps,
    double? bearingDegrees,
    int? batteryPct,
  }) {
    return Friend(
      deviceId: deviceId,
      localNickname: localNickname ?? this.localNickname,
      role: role ?? this.role,
      joinedAt: joinedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      speedMps: speedMps ?? this.speedMps,
      bearingDegrees: bearingDegrees ?? this.bearingDegrees,
      batteryPct: batteryPct ?? this.batteryPct,
    );
  }
}
