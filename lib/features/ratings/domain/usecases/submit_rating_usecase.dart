import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/ratings/domain/entities/rating_result.dart';
import 'package:car_app/features/ratings/domain/repositories/ratings_repository.dart';
import 'package:dartz/dartz.dart';

class SubmitRatingUseCase {
  final RatingsRepository repository;

  SubmitRatingUseCase(this.repository);

  Future<Either<Failure, RatingResult>> call({
    required int tripId,
    required int stars,
    String? comment,
    int? ratedUserId,
  }) async {
    return await repository.submitRating(
      tripId: tripId,
      stars: stars,
      comment: comment,
      ratedUserId: ratedUserId,
    );
  }
}
