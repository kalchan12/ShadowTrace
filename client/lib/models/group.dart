class Group {
  final String id;
  final String createdByDeviceId;
  final int createdAt;
  final String? inviteSecret;
  final String role;

  const Group({
    required this.id,
    this.createdByDeviceId = 'local-device',
    required this.createdAt,
    this.inviteSecret,
    this.role = 'member',
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['group_id'] as String,
      createdByDeviceId:
          json['created_by_device_id'] as String? ?? 'local-device',
      createdAt: json['created_at'] as int,
      inviteSecret: json['invite_secret'] as String?,
      role: json['role'] as String? ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': id,
      'created_by_device_id': createdByDeviceId,
      'created_at': createdAt,
      if (inviteSecret != null) 'invite_secret': inviteSecret,
      'role': role,
    };
  }
}
