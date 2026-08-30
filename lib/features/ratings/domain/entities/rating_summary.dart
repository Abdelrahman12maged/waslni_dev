/// Star-breakdown summary for a driver's ratings.
/// Returned inside POST /api/ratings/store (`driver_rating`) and
/// GET /api/drivers/{id}/ratings (`summary`).
class RatingSummary {
  final double average;
  final int count;

  /// Number of ratings per star level: {1: 0, 2: 0, 3: 1, 4: 2, 5: 5}
  final Map<int, int> breakdown;

  const RatingSummary({
    required this.average,
    required this.count,
    required this.breakdown,
  });

  factory RatingSummary.fromMap(Map<String, dynamic> map) {
    final rawBreakdown = map['breakdown'];
    final breakdown = <int, int>{};
    if (rawBreakdown is Map) {
      rawBreakdown.forEach((key, value) {
        final k = int.tryParse(key.toString());
        final v = int.tryParse(value.toString()) ?? 0;
        if (k != null) breakdown[k] = v;
      });
    }
    return RatingSummary(
      average: _parseDouble(map['average']),
      count: _parseInt(map['count']),
      breakdown: breakdown,
    );
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
