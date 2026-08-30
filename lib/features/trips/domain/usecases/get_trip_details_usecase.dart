import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class GetTripDetailsUseCase {
  final TripsRepository _repository;
  const GetTripDetailsUseCase(this._repository);

  Future<Either<Failure, Trip>> call(int tripId) =>
      _repository.getTripDetails(tripId: tripId);
}
