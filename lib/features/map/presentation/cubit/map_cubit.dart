import 'dart:async';
import 'dart:developer';

import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/map/presentation/cubit/map_state.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Manages all map interactions — location, pin, autocomplete, route, markers.
///
/// Rules:
/// - Knows NOTHING about Dio, CacheHelper, or Navigator
/// - Depends ONLY on [MapService] injected via constructor
/// - Emits states — UI reacts to them
class MapCubit extends Cubit<MapState> {
  final MapService _mapService;

  MapCubit(this._mapService) : super(const MapInitial());

  static MapCubit of(BuildContext context) => BlocProvider.of<MapCubit>(context);

  // ─── State ────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  LatLng? currentLocation;
  LocationResult? startLocation;
  LocationResult? destinationLocation;
  Set<Marker> _markers = {};

  Timer? _debounce;

  // ─── Controller Setup ─────────────────────────────────────────────────────

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    AppMapStyle.applyStyle(controller);
  }

  void disposeController() {
    _mapController?.dispose();
    _mapController = null;
    _debounce?.cancel();
  }

  // ─── Current Location ─────────────────────────────────────────────────────

  Future<void> loadCurrentLocation() async {
    emit(const MapLoading());

    final result = await _mapService.getCurrentLocation();
    result.fold(
      (failure) => emit(MapError(failure.message)),
      (latLng) {
        currentLocation = latLng;
        emit(MapLocationLoaded(latLng));
        _animateCameraTo(latLng);
      },
    );
  }

  // ─── Pin / Camera Movement ────────────────────────────────────────────────

  /// Called while the user is dragging the map (camera moving).
  void onCameraMove(CameraPosition position) {
    emit(const MapPinMoving());
  }

  /// Called when the camera stops moving — resolve address from pin center.
  Future<void> onCameraIdle(LatLng pinPosition) async {
    final result = await _mapService.getAddressFromLatLng(pinPosition);
    result.fold(
      (failure) => emit(MapError(failure.message)),
      (locationResult) => emit(MapPinSettled(
        position: pinPosition,
        locationResult: locationResult,
      )),
    );
  }

  // ─── Autocomplete ─────────────────────────────────────────────────────────

  /// Debounced search — waits 400ms after user stops typing.
  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(const MapSuggestionsCleared());
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    final result = await _mapService.searchPlaces(query);
    result.fold(
      (failure) => emit(MapError(failure.message)),
      (suggestions) => emit(MapSuggestionsLoaded(suggestions)),
    );
  }

  void clearSuggestions() => emit(const MapSuggestionsCleared());

  // ─── Place Selection ──────────────────────────────────────────────────────

  Future<void> selectPlace(PlaceSuggestion suggestion) async {
    emit(const MapLoading());

    final result = await _mapService.getPlaceDetails(suggestion.placeId);
    result.fold(
      (failure) => emit(MapError(failure.message)),
      (locationResult) {
        emit(MapPlaceSelected(locationResult));
        _animateCameraTo(
          LatLng(locationResult.latitude, locationResult.longitude),
        );
      },
    );
  }

  // ─── Markers ──────────────────────────────────────────────────────────────

  /// Sets start location and updates the start marker.
  Future<void> setStartLocation(LocationResult location, BitmapDescriptor icon) async {
    startLocation = location;
    _markers.removeWhere((m) => m.markerId.value == 'trip_start');
    _markers.add(Marker(
      markerId: const MarkerId('trip_start'),
      position: LatLng(location.latitude, location.longitude),
      icon: icon,
    ));
    emit(MapMarkersUpdated(Set.from(_markers)));
  }

  /// Sets destination location and updates the destination marker.
  Future<void> setDestinationLocation(LocationResult location, BitmapDescriptor icon) async {
    destinationLocation = location;
    _markers.removeWhere((m) => m.markerId.value == 'trip_destination');
    _markers.add(Marker(
      markerId: const MarkerId('trip_destination'),
      position: LatLng(location.latitude, location.longitude),
      icon: icon,
    ));
    emit(MapMarkersUpdated(Set.from(_markers)));
  }

  /// Sets both markers from saved trip details (for ongoing trip view).
  Future<void> setTripMarkers({
    required LocationResult start,
    required LocationResult destination,
    required BitmapDescriptor startIcon,
    required BitmapDescriptor destinationIcon,
  }) async {
    startLocation = start;
    destinationLocation = destination;
    _markers = {
      Marker(
        markerId: const MarkerId('trip_start'),
        position: LatLng(start.latitude, start.longitude),
        icon: startIcon,
      ),
      Marker(
        markerId: const MarkerId('trip_destination'),
        position: LatLng(destination.latitude, destination.longitude),
        icon: destinationIcon,
      ),
    };
    emit(MapMarkersUpdated(Set.from(_markers)));
    _fitCameraToBounds(
      LatLng(start.latitude, start.longitude),
      LatLng(destination.latitude, destination.longitude),
    );
  }

  void clearMarkers() {
    _markers.clear();
    startLocation = null;
    destinationLocation = null;
    emit(MapMarkersUpdated(const {}));
  }

  // ─── Route ────────────────────────────────────────────────────────────────

  Future<void> loadRoute() async {
    if (startLocation == null || destinationLocation == null) return;

    final result = await _mapService.getRoutePolyline(
      from: LatLng(startLocation!.latitude, startLocation!.longitude),
      to: LatLng(destinationLocation!.latitude, destinationLocation!.longitude),
    );
    result.fold(
      (failure) {
        log(failure.message, name: 'MapCubit.loadRoute');
        // Route failure is non-critical — don't show error to user
      },
      (points) => emit(MapRouteLoaded(points)),
    );
  }

  // ─── Camera Utils ─────────────────────────────────────────────────────────

  void _animateCameraTo(LatLng target, {double zoom = 15.0}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _fitCameraToBounds(LatLng from, LatLng to) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        from.latitude < to.latitude ? from.latitude : to.latitude,
        from.longitude < to.longitude ? from.longitude : to.longitude,
      ),
      northeast: LatLng(
        from.latitude > to.latitude ? from.latitude : to.latitude,
        from.longitude > to.longitude ? from.longitude : to.longitude,
      ),
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  /// Public method to get the current camera center from controller.
  Future<LatLng?> getCurrentCameraPosition() async {
    try {
      final pos = await _mapController?.getVisibleRegion();
      if (pos == null) return null;
      return LatLng(
        (pos.northeast.latitude + pos.southwest.latitude) / 2,
        (pos.northeast.longitude + pos.southwest.longitude) / 2,
      );
    } catch (_) {
      return null;
    }
  }
}
