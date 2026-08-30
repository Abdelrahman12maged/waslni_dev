import 'package:car_app/features/ratings/domain/entities/rating.dart';
import 'package:car_app/features/ratings/domain/entities/rating_summary.dart';

/// Result wrapper returned by `POST /api/ratings/store`.
/// Contains the saved [Rating] record and the updated [RatingSummary] (`driver_rating`).
class RatingResult {
  final Rating rating;
  final RatingSummary driverRating;
  final String? message;

  const RatingResult({
    required this.rating,
    required this.driverRating,
    this.message,
  });

  factory RatingResult.fromMap(Map<String, dynamic> map) {
    final ratingMap = map['rating'] is Map
        ? Map<String, dynamic>.from(map['rating'] as Map)
        : <String, dynamic>{};
    final driverRatingMap = map['driver_rating'] is Map
        ? Map<String, dynamic>.from(map['driver_rating'] as Map)
        : <String, dynamic>{};

    return RatingResult(
      rating: Rating.fromMap(ratingMap),
      driverRating: RatingSummary.fromMap(driverRatingMap),
      message: map['message']?.toString(),
    );
  }

  /// Like [fromMap] but never throws — used when the server may omit
  /// `driver_rating` (e.g. on update vs create).
  factory RatingResult.fromMapSafe(Map<String, dynamic> map) {
    // Rating object — look in 'rating', or treat the whole map as the rating
    Map<String, dynamic> ratingMap;
    if (map['rating'] is Map) {
      ratingMap = Map<String, dynamic>.from(map['rating'] as Map);
    } else {
      // Fallback: the root map IS the rating (some APIs return flat structure)
      ratingMap = map;
    }

    // Driver rating summary — optional field
    Map<String, dynamic> driverRatingMap;
    if (map['driver_rating'] is Map) {
      driverRatingMap = Map<String, dynamic>.from(map['driver_rating'] as Map);
    } else {
      driverRatingMap = <String, dynamic>{};
    }

    return RatingResult(
      rating: Rating.fromMap(ratingMap),
      driverRating: RatingSummary.fromMap(driverRatingMap),
      message: map['message']?.toString(),
    );
  }
}
