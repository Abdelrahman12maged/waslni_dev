import 'package:car_app/features/trips/domain/entities/trip.dart';

abstract class DriverTripsState {
  const DriverTripsState();
}

class DriverTripsInitial extends DriverTripsState {
  const DriverTripsInitial();
}

class DriverTripsLoading extends DriverTripsState {
  const DriverTripsLoading();
}

/// All driver trips categorized.
class DriverTripsLoaded extends DriverTripsState {
  final List<Trip> currentPrivate;
  final List<Trip> completedPrivate;
  final List<Trip> suspendedPrivate;
  final List<Trip> canceledPrivate;

  final List<Trip> currentShared;
  final List<Trip> completedShared;
  final List<Trip> suspendedShared;
  final List<Trip> canceledShared;

  const DriverTripsLoaded({
    required this.currentPrivate,
    required this.completedPrivate,
    required this.suspendedPrivate,
    required this.canceledPrivate,
    required this.currentShared,
    required this.completedShared,
    required this.suspendedShared,
    required this.canceledShared,
  });

  /// All active trips (open + accepted) across private and shared.
  List<Trip> get allCurrent => [...currentPrivate, ...currentShared];
}

class DriverTripsError extends DriverTripsState {
  final String message;
  const DriverTripsError(this.message);
}

/// Offer submitted successfully.
class DriverOfferSubmitted extends DriverTripsState {
  const DriverOfferSubmitted();
}

/// Trip status changed (e.g., driver accepted/completed a trip).
class DriverTripStatusChanged extends DriverTripsState {
  const DriverTripStatusChanged();
}

/// Trip details refreshed.
class DriverTripDetailsLoaded extends DriverTripsState {
  final Trip trip;
  const DriverTripDetailsLoaded(this.trip);
}

/// Guard fired: driver tried to submit an offer while already having
/// an active (accepted / ongoing) trip. The UI should show a blocking dialog.
class DriverHasActiveTripError extends DriverTripsState {
  const DriverHasActiveTripError();
}
