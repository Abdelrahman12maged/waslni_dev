import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class ChangePassengerStatusUseCase {
  final TripsRepository _repository;
  const ChangePassengerStatusUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int tripId,
    required int inCar,
    String? passState,
  }) =>
      _repository.changePassengerStatus(
        tripId: tripId,
        inCar: inCar,
        passState: passState,
      );
}
