class Device {
  final String deviceId;
  final String publicKey;
  final int createdAt;
  final int lastSeen;

  const Device({
    required this.deviceId,
    required this.publicKey,
    required this.createdAt,
    required this.lastSeen,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_id'] as String,
      publicKey: json['public_key'] as String,
      createdAt: json['created_at'] as int,
      lastSeen: json['last_seen'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'public_key': publicKey,
      'created_at': createdAt,
      'last_seen': lastSeen,
    };
  }
}
