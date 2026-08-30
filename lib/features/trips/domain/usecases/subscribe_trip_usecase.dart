import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class SubscribeTripUseCase {
  final TripsRepository _repository;
  const SubscribeTripUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int tripId,
    int seats = 1,
  }) =>
      _repository.subscribeTrip(tripId: tripId, seats: seats);
}

