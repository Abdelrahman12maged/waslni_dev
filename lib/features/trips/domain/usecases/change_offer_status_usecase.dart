import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class ChangeOfferStatusUseCase {
  final TripsRepository _repository;
  const ChangeOfferStatusUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int offerId,
    required String status,
    required int userId,
  }) =>
      _repository.changeOfferStatus(
        offerId: offerId,
        status: status,
        userId: userId,
      );
}
