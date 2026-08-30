import 'package:car_app/features/trips/domain/entities/trip.dart';

abstract class DriverAddSharedTripState {}

class DriverAddSharedTripInitialState extends DriverAddSharedTripState {}

class DriverAddSharedTripChangeBottomSheetShowState extends DriverAddSharedTripState {}

class DriverAddSharedTripSetStartAndDestinationLocationState extends DriverAddSharedTripState {}

class DriverAddSharedTripChangeTripDateState extends DriverAddSharedTripState {}

class DriverAddSharedTripChangeTripTimeState extends DriverAddSharedTripState {}

class DriverAddSharedTripLoadingState extends DriverAddSharedTripState {}

class DriverAddSharedTripSuccessState extends DriverAddSharedTripState {
  final Trip trip;
  DriverAddSharedTripSuccessState(this.trip);
}

class DriverAddSharedTripErrorState extends DriverAddSharedTripState {
  final String error;
  final String? errorCode;
  DriverAddSharedTripErrorState(this.error, {this.errorCode});
}
