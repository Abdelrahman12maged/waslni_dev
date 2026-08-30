import 'dart:async';
import 'dart:developer';

import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/usecases/get_nearby_shared_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_search_shared_trips_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

/// Searches and filters available nearby shared trips for a passenger to join.
///
/// Uses [GetNearbySharedTripsUseCase] with the new `/api/trips/nearby-shared`
/// endpoint (with automatic fallback to the old `/nearme` endpoint if the
/// backend hasn't deployed the new one yet).
///
/// Key improvements over the previous version:
///  - Real GPS via MapService.getCurrentLocation() — no hardcoded coords.
///  - Autocomplete resolves to real coordinates for geo-filtered server search.
///  - Optional time filter (trip_datetime) — user selects preferred time.
class PassengerSearchSharedTripsCubit
    extends Cubit<PassengerSearchSharedTripsState> {
  final GetNearbySharedTripsUseCase _getNearbySharedTrips;
  final GetTripDetailsUseCase _getTripDetails;
  final MapService _mapService;
  final LocalStorage _storage;

  PassengerSearchSharedTripsCubit({
    required GetNearbySharedTripsUseCase getNearbySharedTrips,
    required GetTripDetailsUseCase getTripDetails,
    required MapService mapService,
    required LocalStorage storage,
  })  : _getNearbySharedTrips = getNearbySharedTrips,
        _getTripDetails = getTripDetails,
        _mapService = mapService,
        _storage = storage,
        super(const PassengerSearchSharedTripsInitial());

  static PassengerSearchSharedTripsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final TextEditingController searchController = TextEditingController();
  final TextEditingController originController = TextEditingController();
  Timer? _debounceTimer;
  Timer? _originDebounceTimer;

  List<Trip> _allSharedTrips = [];
  List<Trip> _filteredTrips = [];
  List<Map<String, dynamic>> _savedLocations = [];
  List<PlaceSuggestion> _placeSuggestions = [];
  List<PlaceSuggestion> _originPlaceSuggestions = [];
  bool _isSearchingPlace = false;
  bool _isSearchingOrigin = false;
  String _selectedQuery = '';

  // GPS — passenger's current location
  double? _originLat;
  double? _originLng;
  bool _isLocating = false;
  bool _isUsingCustomOrigin = false; // true when user set a custom origin
  String _customOriginName = ''; // display name of custom origin

  // Destination coords (resolved from autocomplete)
  double? _destLat;
  double? _destLng;

  // Optional time filter
  DateTime? _selectedTime;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    emit(const PassengerSearchSharedTripsLoading());
    await Future.wait([
      _loadSavedLocations(),
      _resolveCurrentLocation(),
    ]);
    await fetchSharedTrips();
  }

  Future<void> _loadSavedLocations() async {
    try {
      final box = await Hive.openBox('hive_box');
      final rawUser = box.get('user_data');
      if (rawUser is Map && rawUser['user_locations'] is List) {
        _savedLocations = (rawUser['user_locations'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (e) {
      log('Error loading saved locations: $e',
          name: 'PassengerSearchSharedTripsCubit');
    }
  }

  /// Resolves the passenger's current GPS location via MapService.
  /// If permission is denied, silently falls back to null (no origin filter).
  Future<void> _resolveCurrentLocation() async {
    _isLocating = true;
    try {
      final result = await _mapService.getCurrentLocation();
      result.fold(
        (failure) {
          log('GPS unavailable: ${failure.message}',
              name: 'PassengerSearchSharedTripsCubit');
          _originLat = null;
          _originLng = null;
        },
        (latLng) {
          _originLat = latLng.latitude;
          _originLng = latLng.longitude;
        },
      );
    } catch (e) {
      log('Exception getting GPS: $e', name: 'PassengerSearchSharedTripsCubit');
    }
    _isLocating = false;
  }

  // ─── Fetch ────────────────────────────────────────────────────────────────

  /// Fetches nearby shared trips from the server using current GPS + optional dest/time.
  Future<void> fetchSharedTrips() async {
    if (state is! PassengerSearchSharedTripsLoaded) {
      emit(const PassengerSearchSharedTripsLoading());
    }

    // If GPS hasn't been resolved yet, try again.
    if (_originLat == null && !_isLocating) {
      await _resolveCurrentLocation();
    }

    // If still no GPS, show error (we need at least origin coords).
    if (_originLat == null || _originLng == null) {
      emit(PassengerSearchSharedTripsError(
        S.current.cannotDetermineCurrentLocation,
      ));
      return;
    }

    // Build optional trip_datetime string if user selected a time.
    String? tripDatetimeUtc;
    if (_selectedTime != null) {
      tripDatetimeUtc =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(_selectedTime!.toUtc());
    }

    try {
      final result = await _getNearbySharedTrips(
        fromLat: _originLat!,
        fromLng: _originLng!,
        toLat: _destLat,
        toLng: _destLng,
        tripDatetime: tripDatetimeUtc,
        originRadiusKm: 2.0,
        destinationRadiusKm: 2.0,
        timeWindowHours: 1.0,
      );

      result.fold(
        (failure) {
          log('Failed to fetch nearby shared trips: ${failure.message}',
              name: 'PassengerSearchSharedTripsCubit');
          emit(PassengerSearchSharedTripsError(failure.message));
        },
        (trips) async {
          final enriched = await _enrichTripsWithDetails(trips);
          for (final t in enriched) {
            log('TRIP_WITH_MATCH_DISTANCE: id=${t.id}, matchDistanceOriginKm=${t.matchDistanceOriginKm}, matchDistanceDestinationKm=${t.matchDistanceDestinationKm}',
                name: 'PassengerSearchSharedTripsCubit');
          }
          _allSharedTrips = List.from(enriched);
          _filteredTrips = List.from(enriched);
          _emitLoadedState();
        },
      );
    } catch (e) {
      log('Exception fetching nearby shared trips: $e',
          name: 'PassengerSearchSharedTripsCubit');
      emit(PassengerSearchSharedTripsError(e.toString()));
    }
  }

  /// Automatically enriches trips whose list response lacked price or seat/passenger relation data in parallel,
  /// while ensuring matchDistanceOriginKm and matchDistanceDestinationKm are computed and preserved.
  Future<List<Trip>> _enrichTripsWithDetails(List<Trip> trips) async {
    try {
      final enriched = await Future.wait(trips.map((trip) async {
        Trip resolvedTrip = trip;

        final bool needsPrice =
            (trip.approvedPrice == null || trip.approvedPrice! <= 0) &&
                trip.maximumPrice <= 0 &&
                trip.minimumPrice <= 0;
        final bool needsPassengers = trip.passengers.isEmpty;

        if (needsPrice || needsPassengers) {
          final res = await _getTripDetails(trip.id);
          resolvedTrip = res.fold(
            (_) => trip,
            (t) => t.copyWith(
              matchDistanceOriginKm: trip.matchDistanceOriginKm,
              matchDistanceDestinationKm: trip.matchDistanceDestinationKm,
            ),
          );
        }

        // Calculate match distance if not already provided by server
        if (resolvedTrip.matchDistanceOriginKm == null &&
            _originLat != null &&
            _originLng != null &&
            resolvedTrip.fromLatitude != 0 &&
            resolvedTrip.fromLongitude != 0) {
          final distMeters = Geolocator.distanceBetween(
            _originLat!,
            _originLng!,
            resolvedTrip.fromLatitude,
            resolvedTrip.fromLongitude,
          );
          double? destKm;
          if (_destLat != null &&
              _destLng != null &&
              resolvedTrip.toLatitude != 0 &&
              resolvedTrip.toLongitude != 0) {
            destKm = Geolocator.distanceBetween(
                  _destLat!,
                  _destLng!,
                  resolvedTrip.toLatitude,
                  resolvedTrip.toLongitude,
                ) /
                1000.0;
          }
          resolvedTrip = resolvedTrip.copyWith(
            matchDistanceOriginKm: distMeters / 1000.0,
            matchDistanceDestinationKm: destKm,
          );
        }

        return resolvedTrip;
      }));

      return enriched;
    } catch (e) {
      log('Error during _enrichTripsWithDetails: $e',
          name: 'PassengerSearchSharedTripsCubit');
      return trips;
    }
  }

  // ─── Origin Search / Autocomplete ──────────────────────────────────────────

  void onOriginQueryChanged(String query) {
    _originDebounceTimer?.cancel();
    _originDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final q = query.trim();
      if (q.length >= 2) {
        _isSearchingOrigin = true;
        _emitLoadedState();

        final result = await _mapService.searchPlaces(q);
        result.fold(
          (failure) => _originPlaceSuggestions = [],
          (suggestions) => _originPlaceSuggestions = suggestions,
        );

        _isSearchingOrigin = false;
        _emitLoadedState();
      } else {
        _originPlaceSuggestions = [];
        _isSearchingOrigin = false;
        _emitLoadedState();
      }
    });
  }

  /// Selects a Place suggestion as the NEW origin and re-fetches trips.
  Future<void> selectOriginSuggestion(PlaceSuggestion suggestion) async {
    originController.text = suggestion.description;
    _customOriginName = suggestion.description;
    _originPlaceSuggestions = [];
    _isSearchingOrigin = true;
    _emitLoadedState();

    final detailResult = await _mapService.getPlaceDetails(suggestion.placeId);
    detailResult.fold(
      (failure) {
        log('Could not resolve origin coords: ${failure.message}',
            name: 'PassengerSearchSharedTripsCubit');
        // keep old origin if resolution fails
      },
      (locationResult) {
        _originLat = locationResult.latitude;
        _originLng = locationResult.longitude;
        _isUsingCustomOrigin = true;
      },
    );

    _isSearchingOrigin = false;
    await fetchSharedTrips();
  }

  /// Resets origin back to the device's GPS location.
  Future<void> resetOriginToGps() async {
    originController.clear();
    _customOriginName = '';
    _isUsingCustomOrigin = false;
    _originPlaceSuggestions = [];
    await refreshLocation();
  }

  void clearOriginSearch() {
    originController.clear();
    _originPlaceSuggestions = [];
    _isSearchingOrigin = false;
    _emitLoadedState();
  }

  // ─── Set from Map Picker ──────────────────────────────────────────────────

  Future<void> setRouteFromMap({
    required double originLat,
    required double originLng,
    required String originName,
    required double destLat,
    required double destLng,
    required String destName,
  }) async {
    _originLat = originLat;
    _originLng = originLng;
    _isUsingCustomOrigin = true;
    _customOriginName = originName;
    originController.text = originName;

    _destLat = destLat;
    _destLng = destLng;
    _selectedQuery = destName;
    searchController.text = destName;

    _placeSuggestions = [];
    _originPlaceSuggestions = [];
    _isSearchingPlace = false;
    _isSearchingOrigin = false;

    await fetchSharedTrips();
  }

  Future<void> setOriginFromMap({
    required double lat,
    required double lng,
    required String name,
  }) async {
    _originLat = lat;
    _originLng = lng;
    _isUsingCustomOrigin = true;
    _customOriginName = name;
    originController.text = name;
    _originPlaceSuggestions = [];
    _isSearchingOrigin = false;

    await fetchSharedTrips();
  }

  Future<void> setDestinationFromMap({
    required double lat,
    required double lng,
    required String name,
  }) async {
    _destLat = lat;
    _destLng = lng;
    _selectedQuery = name;
    searchController.text = name;
    _placeSuggestions = [];
    _isSearchingPlace = false;

    await fetchSharedTrips();
  }

  // ─── Destination Search / Autocomplete ───────────────────────────────────

  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      _selectedQuery = query.trim();

      if (_selectedQuery.length >= 2) {
        _isSearchingPlace = true;
        _emitLoadedState();

        final result = await _mapService.searchPlaces(_selectedQuery);
        result.fold(
          (failure) {
            _placeSuggestions = [];
          },
          (suggestions) {
            _placeSuggestions = suggestions;
          },
        );

        _isSearchingPlace = false;
        _emitLoadedState();
      } else {
        _placeSuggestions = [];
        _isSearchingPlace = false;
        _emitLoadedState();
      }
    });
  }

  /// Selects a Place suggestion, resolves its coordinates, and re-fetches trips
  /// using the destination coords as a geo-filter on the server.
  Future<void> selectSuggestion(PlaceSuggestion suggestion) async {
    searchController.text = suggestion.description;
    _selectedQuery = suggestion.description;
    _placeSuggestions = [];
    _isSearchingPlace = true;
    _emitLoadedState();

    // Resolve place → coordinates
    final detailResult = await _mapService.getPlaceDetails(suggestion.placeId);
    detailResult.fold(
      (failure) {
        log('Could not resolve place coords: ${failure.message}',
            name: 'PassengerSearchSharedTripsCubit');
        _destLat = null;
        _destLng = null;
      },
      (locationResult) {
        _destLat = locationResult.latitude;
        _destLng = locationResult.longitude;
      },
    );

    _isSearchingPlace = false;
    // Re-fetch with destination coords now set
    await fetchSharedTrips();
  }

  void selectSavedLocation(String locationName) {
    searchController.text = locationName;
    _selectedQuery = locationName.trim();
    _placeSuggestions = [];
    // Saved locations don't carry coords — clear dest and refetch without dest filter
    _destLat = null;
    _destLng = null;
    _filteredTrips = _allSharedTrips
        .where((t) =>
            t.toLocationName
                .toLowerCase()
                .contains(locationName.toLowerCase()) ||
            t.fromLocationName
                .toLowerCase()
                .contains(locationName.toLowerCase()))
        .toList();
    _emitLoadedState();
  }

  void clearSearch() {
    searchController.clear();
    _selectedQuery = '';
    _placeSuggestions = [];
    _isSearchingPlace = false;
    _destLat = null;
    _destLng = null;
    _filteredTrips = List.from(_allSharedTrips);
    fetchSharedTrips();
  }

  // ─── Time Filter ──────────────────────────────────────────────────────────

  /// Sets the optional time filter and re-fetches trips.
  Future<void> setTimeFilter(DateTime time) async {
    _selectedTime = time;
    await fetchSharedTrips();
  }

  /// Clears the time filter and re-fetches trips.
  Future<void> clearTimeFilter() async {
    _selectedTime = null;
    await fetchSharedTrips();
  }

  // ─── Emit ─────────────────────────────────────────────────────────────────

  void _emitLoadedState() {
    emit(PassengerSearchSharedTripsLoaded(
      allTrips: List<Trip>.from(_allSharedTrips),
      filteredTrips: List<Trip>.from(_filteredTrips),
      savedLocations: List<Map<String, dynamic>>.from(_savedLocations),
      placeSuggestions: List<PlaceSuggestion>.from(_placeSuggestions),
      originPlaceSuggestions:
          List<PlaceSuggestion>.from(_originPlaceSuggestions),
      isSearchingPlace: _isSearchingPlace,
      isSearchingOrigin: _isSearchingOrigin,
      selectedQuery: _selectedQuery,
      originLat: _originLat,
      originLng: _originLng,
      destLat: _destLat,
      destLng: _destLng,
      selectedTime: _selectedTime,
      isUsingCustomOrigin: _isUsingCustomOrigin,
      customOriginName: _customOriginName,
    ));
  }

  // ─── Refresh GPS ─────────────────────────────────────────────────────────

  Future<void> refreshLocation() async {
    await _resolveCurrentLocation();
    await fetchSharedTrips();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _originDebounceTimer?.cancel();
    searchController.dispose();
    originController.dispose();
    return super.close();
  }
}
