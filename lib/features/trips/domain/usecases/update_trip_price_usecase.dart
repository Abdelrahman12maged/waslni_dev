import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateTripPriceUseCase {
  final TripsRepository _repository;

  const UpdateTripPriceUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int tripId,
    required double newPrice,
  }) {
    return _repository.updateTripPrice(
      tripId: tripId,
      newPrice: newPrice,
    );
  }
}
