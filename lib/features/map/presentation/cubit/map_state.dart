import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Base state for all map-related events.
abstract class MapState {
  const MapState();
}

/// Initial state — map not yet loaded.
class MapInitial extends MapState {
  const MapInitial();
}

/// Loading state — waiting for location or address.
class MapLoading extends MapState {
  const MapLoading();
}

/// Current location successfully retrieved.
class MapLocationLoaded extends MapState {
  final LatLng currentLocation;
  const MapLocationLoaded(this.currentLocation);
}

/// Camera pin moved — address is being resolved.
class MapPinMoving extends MapState {
  const MapPinMoving();
}

/// Camera pin settled — address resolved successfully.
class MapPinSettled extends MapState {
  final LatLng position;
  final LocationResult locationResult;
  const MapPinSettled({required this.position, required this.locationResult});
}

/// Autocomplete suggestions loaded.
class MapSuggestionsLoaded extends MapState {
  final List<PlaceSuggestion> suggestions;
  const MapSuggestionsLoaded(this.suggestions);
}

/// Suggestions cleared (e.g. field is empty).
class MapSuggestionsCleared extends MapState {
  const MapSuggestionsCleared();
}

/// A place suggestion was selected — location resolved.
class MapPlaceSelected extends MapState {
  final LocationResult locationResult;
  const MapPlaceSelected(this.locationResult);
}

/// Route polyline successfully calculated.
class MapRouteLoaded extends MapState {
  final List<LatLng> polylinePoints;
  const MapRouteLoaded(this.polylinePoints);
}

/// Markers updated (start / destination changed).
class MapMarkersUpdated extends MapState {
  final Set<Marker> markers;
  const MapMarkersUpdated(this.markers);
}

/// Error state.
class MapError extends MapState {
  final String message;
  const MapError(this.message);
}
