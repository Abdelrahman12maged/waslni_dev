import 'package:car_app/features/settings/domain/entities/saved_location.dart';

abstract class SavedLocationsState {}

class SavedLocationsInitial extends SavedLocationsState {}

class SavedLocationsLoading extends SavedLocationsState {}

class SavedLocationsSuccess extends SavedLocationsState {
  final List<SavedLocation> savedLocations;
  SavedLocationsSuccess(this.savedLocations);
}

class SavedLocationsError extends SavedLocationsState {
  final String message;
  SavedLocationsError(this.message);
}

class SaveLocationLoading extends SavedLocationsState {}

class SaveLocationSuccess extends SavedLocationsState {}

class SaveLocationError extends SavedLocationsState {
  final String message;
  SaveLocationError(this.message);
}

class SaveLocationSuccessSnackBarState extends SavedLocationsState {}
