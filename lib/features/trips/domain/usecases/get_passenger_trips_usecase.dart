import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class GetPassengerTripsUseCase {
  final TripsRepository _repository;
  const GetPassengerTripsUseCase(this._repository);

  Future<Either<Failure, List<Trip>>> call(int passengerId) =>
      _repository.getPassengerTrips(passengerId: passengerId);
}
