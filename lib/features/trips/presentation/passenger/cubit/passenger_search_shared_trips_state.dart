import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:equatable/equatable.dart';

abstract class PassengerSearchSharedTripsState extends Equatable {
  const PassengerSearchSharedTripsState();

  @override
  List<Object?> get props => [];
}

class PassengerSearchSharedTripsInitial extends PassengerSearchSharedTripsState {
  const PassengerSearchSharedTripsInitial();
}

class PassengerSearchSharedTripsLoading extends PassengerSearchSharedTripsState {
  const PassengerSearchSharedTripsLoading();
}

class PassengerSearchSharedTripsLoaded extends PassengerSearchSharedTripsState {
  final List<Trip> allTrips;
  final List<Trip> filteredTrips;
  final List<Map<String, dynamic>> savedLocations;
  final List<PlaceSuggestion> placeSuggestions;
  final List<PlaceSuggestion> originPlaceSuggestions;
  final bool isSearchingPlace;
  final bool isSearchingOrigin;
  final String selectedQuery;

  // GPS & coords
  final double? originLat;
  final double? originLng;
  final double? destLat;
  final double? destLng;

  // Custom origin
  final bool isUsingCustomOrigin;
  final String customOriginName;

  // Optional time filter
  final DateTime? selectedTime;

  const PassengerSearchSharedTripsLoaded({
    required this.allTrips,
    required this.filteredTrips,
    required this.savedLocations,
    required this.placeSuggestions,
    required this.isSearchingPlace,
    required this.selectedQuery,
    this.originPlaceSuggestions = const [],
    this.isSearchingOrigin = false,
    this.originLat,
    this.originLng,
    this.destLat,
    this.destLng,
    this.isUsingCustomOrigin = false,
    this.customOriginName = '',
    this.selectedTime,
  });

  @override
  List<Object?> get props => [
        allTrips,
        filteredTrips,
        savedLocations,
        placeSuggestions,
        originPlaceSuggestions,
        isSearchingPlace,
        isSearchingOrigin,
        selectedQuery,
        originLat,
        originLng,
        destLat,
        destLng,
        isUsingCustomOrigin,
        customOriginName,
        selectedTime,
      ];
}

class PassengerSearchSharedTripsError extends PassengerSearchSharedTripsState {
  final String message;

  const PassengerSearchSharedTripsError(this.message);

  @override
  List<Object?> get props => [message];
}
