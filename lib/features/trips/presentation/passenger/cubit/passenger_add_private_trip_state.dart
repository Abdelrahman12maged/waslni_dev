import 'package:car_app/features/trips/domain/entities/trip.dart';

abstract class PassengerAddPrivateTripState {}

class PassengerAddPrivateTripInitialState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripChangeBottomSheetShowState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripSetStartAndDestinationLocationState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripChangeTripDateState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripChangeTripTimeState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripChangeGenderState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripChangeSeatsState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripChangeFareState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripToggleAutoAcceptState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripLoadingState extends PassengerAddPrivateTripState {}

class PassengerAddPrivateTripSuccessState extends PassengerAddPrivateTripState {
  final Trip trip;
  PassengerAddPrivateTripSuccessState(this.trip);
}

class PassengerAddPrivateTripErrorState extends PassengerAddPrivateTripState {
  final String error;
  final String? errorCode;
  PassengerAddPrivateTripErrorState(this.error, {this.errorCode});
}
