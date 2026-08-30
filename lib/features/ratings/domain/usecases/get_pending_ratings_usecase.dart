import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/domain/repositories/ratings_repository.dart';
import 'package:dartz/dartz.dart';

class GetPendingRatingsUseCase {
  final RatingsRepository repository;

  GetPendingRatingsUseCase(this.repository);

  Future<Either<Failure, List<PendingRatingTrip>>> call() async {
    return await repository.getPendingRatings();
  }
}
