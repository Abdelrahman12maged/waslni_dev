import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class CreateTripUseCase {
  final TripsRepository _repository;
  const CreateTripUseCase(this._repository);

  Future<Either<Failure, Trip>> call(Map<String, dynamic> tripData) =>
      _repository.createTrip(tripData: tripData);
}
