import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

class GetTripsNearMeUseCase {
  final TripsRepository repository;

  GetTripsNearMeUseCase(this.repository);

  Future<Either<Failure, List<Trip>>> call({
    required double lat,
    required double lng,
    required String creationType,
    required String radius,
    required String status,
    String? onGoingStatus,
    String? type,
    String? date,
  }) async {
    return await repository.getTripsNearMe(
      lat: lat,
      lng: lng,
      creationType: creationType,
      radius: radius,
      status: status,
      onGoingStatus: onGoingStatus,
      type: type,
      date: date,
    );
  }
}
