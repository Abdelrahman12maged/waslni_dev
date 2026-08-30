import 'dart:developer';

import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:car_app/features/driver_documents/domain/usecases/get_driver_documents_usecase.dart';
import 'package:car_app/features/home/domain/entities/driver_trips_summary.dart';
import 'package:car_app/features/home/domain/usecases/get_driver_trips_totals_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/get_user_profile_usecase.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/usecases/get_trips_near_me_usecase.dart';
import 'package:geolocator/geolocator.dart';
import 'package:car_app/features/home/presentation/cubit/driver_home_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages driver home screen state.
///
/// ✅ Uses UseCases — never Dio/CacheHelper directly
/// ✅ Reads user identity from LocalStorage and Hive box
/// ✅ Fetches live profile to ensure name & photo are always fresh
/// ✅ Fetches driver KYC / account activation status
/// ✅ Emits states — no navigation inside
class DriverHomeCubit extends Cubit<DriverHomeState> {
  final GetDriverTripsTotalsUseCase _getDriverTripsTotals;
  final LocalStorage _storage;
  final GetUserProfileUseCase? _getUserProfile;
  final GetDriverDocumentsUseCase? _getDriverDocuments;
  final GetTripsNearMeUseCase? _getTripsNearMe;

  DriverHomeCubit({
    required GetDriverTripsTotalsUseCase getDriverTripsTotals,
    required LocalStorage storage,
    GetUserProfileUseCase? getUserProfile,
    GetDriverDocumentsUseCase? getDriverDocuments,
    GetTripsNearMeUseCase? getTripsNearMe,
  })  : _getDriverTripsTotals = getDriverTripsTotals,
        _storage = storage,
        _getUserProfile = getUserProfile,
        _getDriverDocuments = getDriverDocuments,
        _getTripsNearMe = getTripsNearMe,
        super(const DriverHomeInitial());

  static DriverHomeCubit of(BuildContext context) =>
      BlocProvider.of<DriverHomeCubit>(context);

  // ── User Data ─────────────────────────────────────────────────────────────

  int get _userId =>
      int.tryParse(_storage.read(key: 'userid')?.toString() ?? '') ?? 0;

  // ── Load ──────────────────────────────────────────────────────────────────

  bool _isLoadingHome = false;

  Future<void> loadHomeData({bool silent = false, double? radius}) async {
    if (_isLoadingHome) return;
    _isLoadingHome = true;

    if (!silent && state is! DriverHomeLoaded) {
      emit(const DriverHomeLoading());
    }

    // 1. Initial cached reading from LocalStorage
    String driverName = _storage.read(key: 'driver_name')?.toString() ??
        _storage.read(key: 'username')?.toString() ??
        _storage.read(key: 'name')?.toString() ??
        '';
    String? driverPhotoUrl = _storage.read(key: 'profile_picture_url')?.toString() ??
        _storage.read(key: 'driver_image')?.toString() ??
        _storage.read(key: 'photo')?.toString();
    String walletBalance = _storage.read(key: 'wallet_balance')?.toString() ?? '0.0';
    bool isKycActive = (_storage.read(key: 'driver_kyc_active') as String?) == 'true';

    // 2. Read from Hive box (only if not silent)
    if (!silent) {
      try {
        final box = await Hive.openBox('hive_box');
        final userData = box.get('user_data');
        if (userData is Map) {
          final userObj = userData['user'] is Map
              ? userData['user']
              : (userData['data'] is Map ? userData['data'] : userData);
          if (userObj is Map) {
            final hName = userObj['name']?.toString();
            if (hName != null && hName.trim().isNotEmpty) {
              driverName = hName.trim().toUpperCase();
            }
            walletBalance = userObj['summary']?.toString() ??
                userObj['wallet_balance']?.toString() ??
                walletBalance;
            final rawPhoto = userObj['profile_picture_url'] ??
                userData['profile_picture_url'] ??
                userObj['profile_picture'] ??
                userData['profile_picture'] ??
                userObj['photo'] ??
                userData['photo'] ??
                userObj['image'] ??
                userObj['avatar'];
            if (rawPhoto != null && rawPhoto.toString().trim().isNotEmpty) {
              driverPhotoUrl = rawPhoto.toString();
            }
          }
        }
      } catch (e) {
        log(e.toString(), name: 'DriverHomeCubit.loadHomeData (hive)');
      }
    }

    final token = _storage.read(key: 'usertoken')?.toString();

    // 3. Fetch data: Only fetch static profile & KYC docs on initial/manual load (!silent)
    final List<Future<void>> futures = [];

    if (!silent && token != null && token.isNotEmpty) {
      final getUserProfile = _getUserProfile;
      if (getUserProfile != null) {
        futures.add(() async {
          try {
            final profileResult = await getUserProfile(token).timeout(
              const Duration(seconds: 4),
              onTimeout: () => Left(ServerFailure(message: 'Profile timeout')),
            );
            profileResult.fold(
              (err) {
                log('Profile fetch failed: ${err.message}', name: 'DriverHomeCubit.loadHomeData');
              },
              (profile) {
                if (profile.name != null && profile.name!.trim().isNotEmpty) {
                  driverName = profile.name!.trim().toUpperCase();
                  _storage.saveString(key: 'driver_name', value: driverName);
                  _storage.saveString(key: 'username', value: driverName);
                }
                if (profile.photo != null && profile.photo!.trim().isNotEmpty) {
                  driverPhotoUrl = profile.photo;
                  _storage.saveString(key: 'profile_picture_url', value: driverPhotoUrl!);
                }
              },
            );
          } catch (e) {
            log(e.toString(), name: 'DriverHomeCubit.loadHomeData (getUserProfile)');
          }
        }());
      }

      final getDriverDocs = _getDriverDocuments;
      if (getDriverDocs != null) {
        futures.add(() async {
          try {
            final docsResult = await getDriverDocs(NoParams()).timeout(
              const Duration(seconds: 4),
              onTimeout: () => Left(ServerFailure(message: 'Docs timeout')),
            );
            docsResult.fold(
              (err) {
                log('Driver docs status fetch failed: ${err.message}', name: 'DriverHomeCubit.loadHomeData');
              },
              (status) {
                final active = status.account.isActive;
                _storage.saveString(
                  key: 'driver_kyc_active',
                  value: active ? 'true' : 'false',
                );
                isKycActive = active;
              },
            );
          } catch (e) {
            log(e.toString(), name: 'DriverHomeCubit.loadHomeData (getDriverDocs)');
          }
        }());
      }
    }

    // Always fetch trip totals
    DriverTripsSummary summary = const DriverTripsSummary();
    if (state is DriverHomeLoaded) {
      summary = (state as DriverHomeLoaded).summary;
    }

    futures.add(() async {
      try {
        final result = await _getDriverTripsTotals(driverId: _userId).timeout(
          const Duration(seconds: 4),
          onTimeout: () => Left(ServerFailure(message: 'Timeout')),
        );

        result.fold(
          (failure) {
            log(failure.message, name: 'DriverHomeCubit.loadHomeData');
          },
          (data) {
            summary = data;
          },
        );
      } catch (e) {
        log(e.toString(), name: 'DriverHomeCubit.loadHomeData (totals)');
      }
    }());

    // Fetch live nearby open passenger trips to populate newTrips count
    int nearbyOpenCount = 0;
    final getTripsNearMe = _getTripsNearMe;
    if (getTripsNearMe != null) {
      futures.add(() async {
        try {
          double? lat;
          double? lng;
          final lastLat = _storage.read(key: 'driver_last_latitude') ??
              _storage.read(key: 'driver_latitude') ??
              _storage.read(key: 'latitude');
          final lastLng = _storage.read(key: 'driver_last_longitude') ??
              _storage.read(key: 'driver_longitude') ??
              _storage.read(key: 'longitude');
          if (lastLat != null && lastLng != null) {
            lat = double.tryParse(lastLat.toString());
            lng = double.tryParse(lastLng.toString());
          }

          if (lat == null || lng == null) {
            try {
              Position? pos = await Geolocator.getLastKnownPosition();
              pos ??= await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.medium,
                timeLimit: const Duration(seconds: 4),
              );
              lat = pos.latitude;
              lng = pos.longitude;
              _storage.saveString(key: 'driver_last_latitude', value: lat.toString());
              _storage.saveString(key: 'driver_last_longitude', value: lng.toString());
            } catch (_) {}
          }

          // If location is not available yet, do not query dummy coordinates
          if (lat == null || lng == null) {
            return;
          }

          final effectiveRadius = radius != null
              ? radius.toInt().toString()
              : (_storage.read(key: 'driver_search_radius')?.toString() ?? '5');

          final result = await getTripsNearMe(
            lat: lat,
            lng: lng,
            creationType: 'passenger',
            radius: effectiveRadius,
            status: 'open',
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () => Left(ServerFailure(message: 'Timeout')),
          );

          result.fold(
            (_) => null,
            (trips) {
              final rejectedList =
                  _storage.readStringList(key: 'driver_rejected_trips') ?? [];
              final validOpen = trips.where((t) {
                if (t.isStale || t.status != TripStatus.open) return false;
                if (rejectedList.contains(t.id.toString())) return false;
                if (t.offers.isNotEmpty) {
                  final isAccepted = t.offers.any((o) => o.isAccepted);
                  if (isAccepted) return false;
                }
                return true;
              }).length;
              nearbyOpenCount = validOpen;
            },
          );
        } catch (e) {
          log(e.toString(), name: 'DriverHomeCubit.loadHomeData (open trips count)');
        }
      }());
    }

    try {
      await Future.wait(futures);
    } finally {
      _isLoadingHome = false;
    }

    summary = summary.copyWith(openCount: nearbyOpenCount);

    emit(DriverHomeLoaded(
      summary: summary,
      driverName: driverName,
      walletBalance: walletBalance,
      driverPhotoUrl: driverPhotoUrl,
      isKycActive: isKycActive,
    ));
  }
}
