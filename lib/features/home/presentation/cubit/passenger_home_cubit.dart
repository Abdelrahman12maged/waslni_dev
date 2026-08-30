import 'dart:developer';

import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/home/domain/usecases/get_nearby_trips_usecase.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/generated/l10n.dart';

/// Manages passenger home screen state.
///
/// ✅ Uses UseCases — never Dio/CacheHelper directly
/// ✅ Reads user identity from LocalStorage only
/// ✅ Emits states — no navigation inside
class PassengerHomeCubit extends Cubit<PassengerHomeState> {
  final GetNearbyTripsUseCase _getNearbyTrips;
  final LocalStorage _storage;

  PassengerHomeCubit({
    required GetNearbyTripsUseCase getNearbyTrips,
    required LocalStorage storage,
  })  : _getNearbyTrips = getNearbyTrips,
        _storage = storage,
        super(const PassengerHomeInitial());

  static PassengerHomeCubit of(BuildContext context) =>
      BlocProvider.of<PassengerHomeCubit>(context);

  // ── Carousel ──────────────────────────────────────────────────────────────

  void onCarouselPageChanged(int index) {
    if (state is PassengerHomeLoaded) {
      emit((state as PassengerHomeLoaded).copyWith(carouselIndex: index));
    }
  }

  // ── Nearby Trips ──────────────────────────────────────────────────────────

  Future<void> loadNearbyTrips() async {
    emit(const PassengerHomeLoading());

    final position = await _getCurrentPosition();
    if (position == null) {
      emit(const PassengerHomeLoaded(nearbyTrips: []));
      return;
    }

    final result = await _getNearbyTrips(
      lat: position.latitude,
      lng: position.longitude,
      radius: 5000,
    );

    result.fold(
      (failure) {
        log(failure.message, name: 'PassengerHomeCubit.loadNearbyTrips');
        emit(PassengerHomeError(failure.message));
      },
      (trips) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);

        final validTrips = trips.where((trip) {
          if (trip.tripDatetime.isEmpty) return true;
          try {
            final parsedDate = DateTime.tryParse(
              trip.tripDatetime.contains('T')
                  ? trip.tripDatetime
                  : trip.tripDatetime.replaceAll(' ', 'T'),
            );
            if (parsedDate != null && parsedDate.isBefore(todayStart)) {
              return false; // Filter old trips from previous years/days
            }
          } catch (_) {}
          return true;
        }).toList();

        // Sort newest trips first
        validTrips.sort((a, b) => b.id.compareTo(a.id));

        emit(PassengerHomeLoaded(nearbyTrips: validTrips));
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          showToast(
            text: S.current.locationPermissionDeniedWarning,
            state: ToastStates.WARNING,
          );
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 4),
      );
    } catch (e) {
      log(e.toString(), name: 'PassengerHomeCubit._getCurrentPosition');
      return null;
    }
  }
}
