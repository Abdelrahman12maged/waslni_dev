import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class GetDriverTripsUseCase {
  final TripsRepository _repository;
  const GetDriverTripsUseCase(this._repository);

  Future<Either<Failure, List<Trip>>> call(int driverId) =>
      _repository.getDriverTrips(driverId: driverId);
}
