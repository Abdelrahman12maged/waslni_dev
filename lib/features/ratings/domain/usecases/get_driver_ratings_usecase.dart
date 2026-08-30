import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/ratings/domain/entities/driver_ratings_page.dart';
import 'package:car_app/features/ratings/domain/repositories/ratings_repository.dart';
import 'package:dartz/dartz.dart';

class GetDriverRatingsUseCase {
  final RatingsRepository repository;

  GetDriverRatingsUseCase(this.repository);

  Future<Either<Failure, DriverRatingsPage>> call({
    required int driverId,
    int page = 1,
    int perPage = 15,
  }) async {
    return await repository.getDriverRatings(
      driverId: driverId,
      page: page,
      perPage: perPage,
    );
  }
}
