import 'package:car_app/features/trips/domain/entities/trip.dart';

abstract class DriverAddPrivateTripState {}

class DriverAddPrivateTripInitialState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripChangeBottomSheetShowState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripSetStartAndDestinationLocationState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripChangeTripDateState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripChangeTripTimeState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripChangeGenderState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripChangeSeatsState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripLoadingState extends DriverAddPrivateTripState {}

class DriverAddPrivateTripSuccessState extends DriverAddPrivateTripState {
  final Trip trip;
  DriverAddPrivateTripSuccessState(this.trip);
}

class DriverAddPrivateTripErrorState extends DriverAddPrivateTripState {
  final String error;
  final String? errorCode;
  DriverAddPrivateTripErrorState(this.error, {this.errorCode});
}
