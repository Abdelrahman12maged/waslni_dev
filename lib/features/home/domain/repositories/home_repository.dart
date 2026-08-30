import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/home/domain/entities/driver_trips_summary.dart';
import 'package:car_app/features/home/domain/entities/nearby_trip.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  /// Fetches trips near the user's GPS location.
  ///
  /// [lat] and [lng] — current device coordinates.
  /// [creationType] — 'driver' or 'passenger'.
  /// [radius] — search radius in meters. Defaults to 5000.
  Future<Either<Failure, List<NearbyTrip>>> getNearbyTrips({
    double? lat,
    double? lng,
    String? creationType,
    int? radius,
    String? status,
  });

  /// Fetches trip count totals for the authenticated driver.
  Future<Either<Failure, DriverTripsSummary>> getDriverTripsTotals({
    required int driverId,
  });
}
