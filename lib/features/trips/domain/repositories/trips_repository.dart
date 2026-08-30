import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:dartz/dartz.dart';

/// Abstract contract for all trips-related data operations.
/// The Presentation layer depends ONLY on this interface — never on Dio or HTTP.
abstract class TripsRepository {
  /// Returns all trips where the given user is the passenger.
  Future<Either<Failure, List<Trip>>> getPassengerTrips({
    required int passengerId,
  });

  /// Returns all trips where the given user is the driver.
  Future<Either<Failure, List<Trip>>> getDriverTrips({
    required int driverId,
  });

  /// Returns nearby trips based on location and criteria.
  Future<Either<Failure, List<Trip>>> getTripsNearMe({
    required double lat,
    required double lng,
    required String creationType,
    required String radius,
    required String status,
    String? onGoingStatus,
    String? type,
    String? date,
  });

  /// Returns all offers submitted for a specific trip.
  Future<Either<Failure, List<Offer>>> getOffersByTrip({
    required int tripId,
  });

  /// Changes the status of an offer (accept / reject).
  Future<Either<Failure, void>> changeOfferStatus({
    required int offerId,
    required String status, // 'accepted' | 'rejected'
    required int userId,
  });

  /// Makes a new offer on a trip.
  Future<Either<Failure, void>> makeOffer({
    required Map<String, dynamic> offerData,
  });

  /// Changes the status of a trip (canceled / completed / etc.) and ongoing status.
  Future<Either<Failure, void>> changeTripStatus({
    required int tripId,
    required String status,
    String? onGoingStatus,
    String? reason,
  });

  /// Creates a new private trip for a passenger.
  Future<Either<Failure, Trip>> createTrip({
    required Map<String, dynamic> tripData,
  });

  /// Fetches the latest details for a single trip.
  Future<Either<Failure, Trip>> getTripDetails({
    required int tripId,
  });

  /// Changes passenger boarding status (in car or not) and ongoing status.
  Future<Either<Failure, void>> changePassengerStatus({
    required int tripId,
    required int inCar,
    String? passState,
  });

  /// Subscribes passenger to a shared trip.
  Future<Either<Failure, void>> subscribeTrip({
    required int tripId,
    int seats = 1,
  });

  /// Returns nearby shared trips matching the passenger's location (and optionally destination/time).
  Future<Either<Failure, List<Trip>>> getNearbySharedTrips({
    required double fromLat,
    required double fromLng,
    double? toLat,
    double? toLng,
    String? tripDatetime,
    double originRadiusKm = 2.0,
    double destinationRadiusKm = 2.0,
    double timeWindowHours = 1.0,
  });
}
