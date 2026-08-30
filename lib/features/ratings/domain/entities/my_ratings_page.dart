import 'package:car_app/features/ratings/domain/entities/rating.dart';

/// Paginated list of ratings submitted by the current passenger.
/// Returned by `GET /api/ratings/mine`.
class MyRatingsPage {
  final List<Rating> ratings;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const MyRatingsPage({
    required this.ratings,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasNextPage => currentPage < lastPage;

  factory MyRatingsPage.fromMap(Map<String, dynamic> map) {
    final ratingsList = <Rating>[];
    if (map['ratings'] is List) {
      for (final r in map['ratings'] as List) {
        if (r is Map) {
          ratingsList.add(Rating.fromMap(Map<String, dynamic>.from(r)));
        }
      }
    }

    final meta = map['meta'] is Map ? map['meta'] as Map : map;

    return MyRatingsPage(
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
