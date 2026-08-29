/// Base class for all ShadowTrace QR pairing payloads.
abstract class PairingPayload {
  const PairingPayload();

  /// Serialize payload into standard URI format.
  String toUri();

  /// Parse a QR raw string or URI into a concrete [PairingPayload].
  ///
  /// Supports:
  /// - `shadowtrace://v1/join?gid=<UUID>&sec=<HEX_TOKEN>&exp=<UNIX_MS>`
  /// - `shadowtrace://v1/peer?did=<DEV_ID>&pk=<PUB_KEY>&alias=<ALIAS>&gid=<GROUP_ID>`
  static PairingPayload parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const InvalidPairingPayloadException('Payload cannot be empty');
    }

    final Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (e) {
      throw InvalidPairingPayloadException('Malformed URI string: $e');
    }

    if (uri.scheme != 'shadowtrace') {
      // Fallback check if user entered standard hex token or uuid
      if (trimmed.contains('gid=') || trimmed.contains('sec=')) {
        // Try parsing query directly
        final queryParams = Uri.splitQueryString(trimmed);
        return _parseGroupInvite(queryParams);
      }
      throw const InvalidPairingPayloadException(
        'Invalid URI scheme. Expected shadowtrace://',
      );
    }

    final path = uri.path.replaceAll(RegExp(r'^/+|/+$'), '');
    final hostAndPath = uri.host.isNotEmpty ? '${uri.host}/$path' : path;

    if (hostAndPath == 'v1/join' ||
        uri.path == '/v1/join' ||
        (uri.host == 'v1' && uri.path == '/join')) {
      return _parseGroupInvite(uri.queryParameters);
    } else if (hostAndPath == 'v1/peer' ||
        uri.path == '/v1/peer' ||
        (uri.host == 'v1' && uri.path == '/peer')) {
      return _parsePeerPairing(uri.queryParameters);
    } else {
      throw InvalidPairingPayloadException('Unknown protocol path: ${uri.path}');
    }
  }

  static GroupInvitePayload _parseGroupInvite(Map<String, String> query) {
    final gid = query['gid'];
    final sec = query['sec'];
    final expStr = query['exp'];

    if (gid == null || gid.isEmpty) {
      throw const InvalidPairingPayloadException(
        'Missing required "gid" (Group ID)',
      );
    }
    if (sec == null || sec.isEmpty) {
      throw const InvalidPairingPayloadException(
        'Missing required "sec" (Invite Secret)',
      );
    }

    int? exp;
    if (expStr != null && expStr.isNotEmpty) {
      exp = int.tryParse(expStr);
      if (exp != null && exp > 0) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now > exp) {
          throw ExpiredInviteException('Invite expired at $exp (current: $now)');
        }
      }
    }

    return GroupInvitePayload(
      groupId: gid,
      inviteSecret: sec,
      expirationEpochMs: exp,
    );
  }

  static PeerPairingPayload _parsePeerPairing(Map<String, String> query) {
    final did = query['did'];
    final pk = query['pk'];
    final alias = query['alias'];
    final gid = query['gid'];

    if (did == null || did.isEmpty) {
      throw const InvalidPairingPayloadException(
        'Missing required "did" (Device ID)',
      );
    }
    if (pk == null || pk.isEmpty) {
      throw const InvalidPairingPayloadException(
        'Missing required "pk" (Public Key)',
      );
    }

    return PeerPairingPayload(
      deviceId: did,
      publicKey: pk,
      alias:
          alias != null && alias.isNotEmpty ? Uri.decodeComponent(alias) : null,
      groupId: gid != null && gid.isNotEmpty ? gid : null,
    );
  }
}

/// Represents a Group Invite payload encoded in QR code.
/// Format: `shadowtrace://v1/join?gid=<UUID>&sec=<32_BYTE_HEX_TOKEN>&exp=<UNIX_EPOCH_MS>`
class GroupInvitePayload extends PairingPayload {
  final String groupId;
  final String inviteSecret;
  final int? expirationEpochMs;

  const GroupInvitePayload({
    required this.groupId,
    required this.inviteSecret,
    this.expirationEpochMs,
  });

  @override
  String toUri() {
    final buffer = StringBuffer('shadowtrace://v1/join?');
    buffer.write('gid=${Uri.encodeQueryComponent(groupId)}');
    buffer.write('&sec=${Uri.encodeQueryComponent(inviteSecret)}');
    if (expirationEpochMs != null) {
      buffer.write('&exp=$expirationEpochMs');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupInvitePayload &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          inviteSecret == other.inviteSecret &&
          expirationEpochMs == other.expirationEpochMs;

  @override
  int get hashCode =>
      groupId.hashCode ^
      inviteSecret.hashCode ^
      (expirationEpochMs?.hashCode ?? 0);

  @override
  String toString() =>
      'GroupInvitePayload(groupId: $groupId, inviteSecret: $inviteSecret, exp: $expirationEpochMs)';
}

/// Represents a Direct Device-to-Device Public Key Exchange payload.
/// Format: `shadowtrace://v1/peer?did=<HEX_DEVICE_ID>&pk=<BASE64_PUBLIC_KEY>&alias=<ALIAS>&gid=<GROUP_ID>`
class PeerPairingPayload extends PairingPayload {
  final String deviceId;
  final String publicKey;
  final String? alias;
  final String? groupId;

  const PeerPairingPayload({
    required this.deviceId,
    required this.publicKey,
    this.alias,
    this.groupId,
  });

  @override
  String toUri() {
    final buffer = StringBuffer('shadowtrace://v1/peer?');
    buffer.write('did=${Uri.encodeQueryComponent(deviceId)}');
    buffer.write('&pk=${Uri.encodeQueryComponent(publicKey)}');
    if (alias != null && alias!.isNotEmpty) {
      buffer.write('&alias=${Uri.encodeQueryComponent(alias!)}');
    }
    if (groupId != null && groupId!.isNotEmpty) {
      buffer.write('&gid=${Uri.encodeQueryComponent(groupId!)}');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeerPairingPayload &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          publicKey == other.publicKey &&
          alias == other.alias &&
          groupId == other.groupId;

  @override
  int get hashCode =>
      deviceId.hashCode ^
      publicKey.hashCode ^
      (alias?.hashCode ?? 0) ^
      (groupId?.hashCode ?? 0);

  @override
  String toString() =>
      'PeerPairingPayload(deviceId: $deviceId, publicKey: $publicKey, alias: $alias, groupId: $groupId)';
}

/// Exception thrown when parsing an invalid or unsupported QR code payload.
class InvalidPairingPayloadException implements Exception {
  final String message;
  const InvalidPairingPayloadException(this.message);

  @override
  String toString() => 'InvalidPairingPayloadException: $message';
}

/// Exception thrown when attempting to use an expired invite QR code.
class ExpiredInviteException implements Exception {
  final String message;
  const ExpiredInviteException(this.message);

  @override
  String toString() => 'ExpiredInviteException: $message';
}
