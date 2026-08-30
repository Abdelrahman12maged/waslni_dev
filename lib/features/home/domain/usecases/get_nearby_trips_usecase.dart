import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/home/domain/entities/nearby_trip.dart';
import 'package:car_app/features/home/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class GetNearbyTripsUseCase {
  final HomeRepository _repository;

  GetNearbyTripsUseCase(this._repository);

  Future<Either<Failure, List<NearbyTrip>>> call({
    double? lat,
    double? lng,
    String? creationType,
    int? radius,
    String? status,
  }) {
    return _repository.getNearbyTrips(
      lat: lat,
      lng: lng,
      creationType: creationType,
      radius: radius,
      status: status,
    );
  }
}
