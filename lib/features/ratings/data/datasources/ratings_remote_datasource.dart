import 'package:car_app/features/ratings/domain/entities/driver_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/my_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/domain/entities/rating_result.dart';

abstract class RatingsRemoteDataSource {
  Future<RatingResult> submitRating({
    required int tripId,
    required int stars,
    String? comment,
    int? ratedUserId,
    required String token,
  });

  Future<List<PendingRatingTrip>> getPendingRatings({
    required String token,
  });

  Future<MyRatingsPage> getMyRatings({
    required String token,
    int page = 1,
    int perPage = 15,
  });

  Future<DriverRatingsPage> getDriverRatings({
    required int driverId,
    required String token,
    int page = 1,
    int perPage = 15,
  });
}
