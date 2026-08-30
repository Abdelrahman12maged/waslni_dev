import 'package:car_app/features/ratings/domain/entities/rating.dart';
import 'package:car_app/features/ratings/domain/entities/rating_summary.dart';

/// Paginated driver ratings response containing summary, breakdown, and list of reviews.
/// Returned by `GET /api/drivers/{driver_id}/ratings`.
class DriverRatingsPage {
  final int driverId;
  final RatingSummary summary;
  final List<Rating> ratings;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const DriverRatingsPage({
    required this.driverId,
    required this.summary,
    required this.ratings,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory DriverRatingsPage.fromMap(Map<String, dynamic> map) {
    final summaryMap = map['summary'] is Map
        ? Map<String, dynamic>.from(map['summary'] as Map)
        : <String, dynamic>{};

    final ratingsList = <Rating>[];
    if (map['ratings'] is List) {
      for (final r in map['ratings'] as List) {
        if (r is Map) {
          ratingsList.add(Rating.fromMap(Map<String, dynamic>.from(r)));
        }
      }
    }

    final meta = map['meta'] is Map ? map['meta'] as Map : map;

    return DriverRatingsPage(
      driverId: _parseInt(map['driver_id']),
      summary: RatingSummary.fromMap(summaryMap),
      ratings: ratingsList,
      currentPage: _parseInt(meta['current_page'] ?? 1),
      lastPage: _parseInt(meta['last_page'] ?? 1),
      total: _parseInt(meta['total'] ?? ratingsList.length),
      perPage: _parseInt(meta['per_page'] ?? 15),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
