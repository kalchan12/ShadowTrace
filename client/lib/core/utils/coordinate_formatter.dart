import 'dart:math';

class CoordinateFormatter {
  static String formatLat(double lat) {
    final direction = lat >= 0 ? 'N' : 'S';
    return '${lat.abs().toStringAsFixed(4)}° $direction';
  }

  static String formatLng(double lng) {
    final direction = lng >= 0 ? 'E' : 'W';
    return '${lng.abs().toStringAsFixed(4)}° $direction';
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(2)} km';
  }

  static String formatSpeed(double? mps) {
    if (mps == null) return '-- km/h';
    final kmh = mps * 3.6;
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  static String formatLastSeen(int timestampMs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffSeconds = max(0, (now - timestampMs) ~/ 1000);

    if (diffSeconds < 10) return 'JUST NOW';
    if (diffSeconds < 60) return '${diffSeconds}s AGO';
    if (diffSeconds < 3600) return '${diffSeconds ~/ 60}m AGO';
    return '${diffSeconds ~/ 3600}h AGO';
  }
}

extension StringTakeExtension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
