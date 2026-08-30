import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';

/// Base state for all passenger trip events.
abstract class PassengerTripsState {
  const PassengerTripsState();
}

class PassengerTripsInitial extends PassengerTripsState {
  const PassengerTripsInitial();
}

class PassengerTripsLoading extends PassengerTripsState {
  const PassengerTripsLoading();
}

/// Trips loaded and categorized.
class PassengerTripsLoaded extends PassengerTripsState {
  final List<Trip> currentPrivate;
  final List<Trip> completedPrivate;
  final List<Trip> suspendedPrivate;
  final List<Trip> canceledPrivate;

  final List<Trip> currentShared;
  final List<Trip> completedShared;
  final List<Trip> suspendedShared;
  final List<Trip> canceledShared;

  const PassengerTripsLoaded({
    required this.currentPrivate,
    required this.completedPrivate,
    required this.suspendedPrivate,
    required this.canceledPrivate,
    required this.currentShared,
    required this.completedShared,
    required this.suspendedShared,
    required this.canceledShared,
  });
}

class PassengerTripsError extends PassengerTripsState {
  final String message;
  const PassengerTripsError(this.message);
}

/// Offers loaded for a specific trip.
class PassengerOffersLoaded extends PassengerTripsState {
  final List<Offer> offers;
  const PassengerOffersLoaded(this.offers);
}

/// Offer status changed successfully.
class PassengerOfferStatusChanged extends PassengerTripsState {
  const PassengerOfferStatusChanged();
}

/// Trip status changed successfully (e.g., canceled).
class PassengerTripStatusChanged extends PassengerTripsState {
  const PassengerTripStatusChanged();
}

/// A new trip was just created.
class PassengerTripCreated extends PassengerTripsState {
  final Trip trip;
  const PassengerTripCreated(this.trip);
}

/// Trip details refreshed.
class PassengerTripDetailsLoaded extends PassengerTripsState {
  final Trip trip;
  const PassengerTripDetailsLoaded(this.trip);
}
