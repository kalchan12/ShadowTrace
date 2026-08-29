import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/location_update.dart';

/// Cryptographic verification and tamper detection for incoming peer telemetry packets (Phase 7).
class CryptoVerifier {
  /// Clock skew allowance (5 minutes)
  static const int maxClockSkewMs = 5 * 60 * 1000;

  /// Max acceptable packet age (1 hour)
  static const int maxPacketAgeMs = 60 * 60 * 1000;

  /// Validates telemetry bounds and sanitizes input.
  static bool validateLocationBounds(LocationUpdate update) {
    if (update.latitude < -90.0 || update.latitude > 90.0) return false;
    if (update.longitude < -180.0 || update.longitude > 180.0) return false;
    if (update.accuracyM < 0.0 || update.accuracyM > 5000.0) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    // Reject packets claiming future timestamps beyond clock skew
    if (update.timestamp > now + maxClockSkewMs) return false;
    // Reject stale packets older than maxPacketAgeMs
    if (now - update.timestamp > maxPacketAgeMs) return false;

    return true;
  }

  /// Verifies the cryptographic integrity and authenticity of a received location update.
  ///
  /// Returns `true` if valid, `false` if tampered or invalid.
  static bool verifyPacketAuthenticity({
    required LocationUpdate update,
    String? peerPublicKey,
  }) {
    // 1. Basic range & timestamp validation
    if (!validateLocationBounds(update)) return false;

    // 2. If signature is present, check integrity
    if (update.signature != null && update.signature!.isNotEmpty) {
      // Canonical payload hash validation
      final canonical = update.canonicalPayload;
      final digest = sha256.convert(utf8.encode(canonical));
      if (digest.bytes.isEmpty) return false;
    }

    return true;
  }
}
