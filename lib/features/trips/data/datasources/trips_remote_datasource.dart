import 'package:car_app/features/trips/data/models/offer_model.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';

/// Abstract contract for the trips remote data source.
abstract class TripsRemoteDataSource {
  Future<List<TripModel>> getPassengerTrips(int passengerId, String token);
  Future<List<TripModel>> getDriverTrips(int driverId, String token);
  Future<List<TripModel>> getTripsNearMe(double lat, double lng,
      String creationType, String radius, String status, String token,
      {String? onGoingStatus, String? type, String? date});
  Future<List<OfferModel>> getOffersByTrip(int tripId, String token);
  Future<void> changeOfferStatus(
      int offerId, String status, int userId, String token);
  Future<void> makeOffer(Map<String, dynamic> offerData, String token);
  Future<void> changeTripStatus(int tripId, String status, String token,
      {String? onGoingStatus, String? reason});
  Future<TripModel> createTrip(Map<String, dynamic> tripData, String token);
  Future<TripModel> getTripDetails(int tripId, String token);
  Future<void> changePassengerStatus(int tripId, int inCar, String token,
      {String? passState});
  Future<void> subscribeTrip(int tripId, String token, {int seats = 1});
  Future<List<TripModel>> getNearbySharedTrips({
    required double fromLat,
    required double fromLng,
    double? toLat,
    double? toLng,
    String? tripDatetime,
    double originRadiusKm = 2.0,
    double destinationRadiusKm = 2.0,
    double timeWindowHours = 1.0,
    required String token,
  });
}
