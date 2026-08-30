import 'package:car_app/features/trips/domain/entities/trip.dart';

abstract class PassengerAddSharedTripState {}

class PassengerAddSharedTripInitialState extends PassengerAddSharedTripState {}

class PassengerAddSharedTripChangeBottomSheetShowState extends PassengerAddSharedTripState {}

class PassengerAddSharedTripSetStartAndDestinationLocationState extends PassengerAddSharedTripState {}

class PassengerAddSharedTripChangeTripDateState extends PassengerAddSharedTripState {}

class PassengerAddSharedTripChangeTripTimeState extends PassengerAddSharedTripState {}

class PassengerAddSharedTripLoadingState extends PassengerAddSharedTripState {}

class PassengerAddSharedTripSuccessState extends PassengerAddSharedTripState {
  final Trip trip;
  PassengerAddSharedTripSuccessState(this.trip);
}

class PassengerAddSharedTripErrorState extends PassengerAddSharedTripState {
  final String error;
  final String? errorCode;
  PassengerAddSharedTripErrorState(this.error, {this.errorCode});
}

class PassengerAddSharedTripMatchingTripFoundState
    extends PassengerAddSharedTripState {
  final Trip matchingTrip;
  final List<Trip> allMatchingTrips;
  PassengerAddSharedTripMatchingTripFoundState({
    required this.matchingTrip,
    required this.allMatchingTrips,
  });
}
