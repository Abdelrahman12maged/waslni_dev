import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:dartz/dartz.dart';

/// Fetches shared trips near the passenger's location.
/// Destination and trip_datetime are optional — if not provided, no geo/time
/// filtering is applied on that dimension.
class GetNearbySharedTripsUseCase {
  final TripsRepository repository;

  GetNearbySharedTripsUseCase(this.repository);

  Future<Either<Failure, List<Trip>>> call({
    required double fromLat,
    required double fromLng,
    double? toLat,
    double? toLng,
    String? tripDatetime,
    double originRadiusKm = 2.0,
    double destinationRadiusKm = 2.0,
    double timeWindowHours = 1.0,
  }) async {
    return await repository.getNearbySharedTrips(
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: toLat,
      toLng: toLng,
      tripDatetime: tripDatetime,
      originRadiusKm: originRadiusKm,
      destinationRadiusKm: destinationRadiusKm,
      timeWindowHours: timeWindowHours,
    );
  }
}
