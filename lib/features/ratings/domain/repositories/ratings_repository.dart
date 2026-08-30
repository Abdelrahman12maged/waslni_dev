import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/ratings/domain/entities/driver_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/my_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/domain/entities/rating_result.dart';
import 'package:dartz/dartz.dart';

/// Contract for all Rating operations.
/// Presentation depends only on this interface.
abstract class RatingsRepository {
  /// Submits a new rating or updates an existing rating (within 24h) for a trip.
  Future<Either<Failure, RatingResult>> submitRating({
    required int tripId,
    required int stars,
    String? comment,
    int? ratedUserId,
  });

  /// Fetches trips completed by the current passenger that haven't been rated yet.
  Future<Either<Failure, List<PendingRatingTrip>>> getPendingRatings();

  /// Fetches paginated ratings submitted by the current passenger.
  Future<Either<Failure, MyRatingsPage>> getMyRatings({
    int page = 1,
    int perPage = 15,
  });

  /// Fetches paginated public ratings and breakdown summary for a specific driver.
  Future<Either<Failure, DriverRatingsPage>> getDriverRatings({
    required int driverId,
    int page = 1,
    int perPage = 15,
  });
}
