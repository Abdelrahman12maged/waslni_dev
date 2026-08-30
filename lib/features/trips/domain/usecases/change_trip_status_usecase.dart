import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class ChangeTripStatusUseCase {
  final TripsRepository _repository;
  const ChangeTripStatusUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int tripId,
    required String status,
    String? onGoingStatus,
    String? reason,
  }) =>
      _repository.changeTripStatus(
        tripId: tripId,
        status: status,
        onGoingStatus: onGoingStatus,
        reason: reason,
      );
}
