import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/home/domain/entities/driver_trips_summary.dart';
import 'package:car_app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class GetDriverTripsTotalsUseCase {
  final HomeRepository _repository;

  GetDriverTripsTotalsUseCase(this._repository);

  Future<Either<Failure, DriverTripsSummary>> call({required int driverId}) {
    return _repository.getDriverTripsTotals(driverId: driverId);
  }
}
