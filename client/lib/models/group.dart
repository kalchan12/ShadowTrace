class Group {
  final String id;
  final String createdByDeviceId;
  final int createdAt;
  final String? inviteSecret;

  const Group({
    required this.id,
    required this.createdByDeviceId,
    required this.createdAt,
    this.inviteSecret,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['group_id'] as String,
      createdByDeviceId: json['created_by_device_id'] as String,
      createdAt: json['created_at'] as int,
      inviteSecret: json['invite_secret'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': id,
      'created_by_device_id': createdByDeviceId,
      'created_at': createdAt,
      if (inviteSecret != null) 'invite_secret': inviteSecret,
    };
  }
}
