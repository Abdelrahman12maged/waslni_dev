import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/ratings/domain/entities/my_ratings_page.dart';
import 'package:car_app/features/ratings/domain/repositories/ratings_repository.dart';
import 'package:dartz/dartz.dart';

class GetMyRatingsUseCase {
  final RatingsRepository repository;

  GetMyRatingsUseCase(this.repository);

  Future<Either<Failure, MyRatingsPage>> call({
    int page = 1,
    int perPage = 15,
  }) async {
    return await repository.getMyRatings(page: page, perPage: perPage);
  }
}
