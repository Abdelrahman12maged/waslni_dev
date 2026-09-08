import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/features/onboarding/presentation/screens/choose_lang_screen.dart';
import 'package:car_app/features/auth/domain/entities/driver_signup_initial_data.dart';
import 'package:car_app/features/auth/presentation/screens/driver_signup_info_screen.dart';
import 'package:car_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:car_app/features/auth/presentation/screens/login_screen.dart';
import 'package:car_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:car_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:car_app/features/auth/presentation/screens/signup_confirm_screen.dart';
import 'package:car_app/features/auth/presentation/screens/signup_driver_screen.dart';
import 'package:car_app/features/auth/presentation/screens/signup_user_screen.dart';
import 'package:car_app/features/home/presentation/screens/driver/driver_layout.dart';
import 'package:car_app/features/home/presentation/screens/passenger/user_layout.dart';

// New Clean Screens & Providers
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/data/models/trip_model.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/trips_list_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/add_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/current_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/private/private_current_screen_offers.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/passenger_add_shared_trip_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/passenger_search_shared_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/shared_current_trips_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/passenger_shared_trip_details_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/passenger_shared_trip_details_passengers_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/trips_list_screen.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/private/ongoing_private_trip_screen.dart';
import 'package:car_app/features/trips/presentation/screens/trip_rating_screen.dart';
import 'package:car_app/features/ratings/presentation/screens/pending_ratings_screen.dart';
import 'package:car_app/features/ratings/presentation/screens/my_ratings_screen.dart';
import 'package:car_app/features/ratings/presentation/screens/driver_ratings_screen.dart';
import 'package:car_app/features/trips/presentation/driver/screens/shared/ongoing_shared_trip.dart';
import 'package:car_app/features/trips/presentation/driver/screens/driver_new_trips_accept_screen.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Central router for the entire app.
/// Uses [LocalStorage] for authentication state — no static globals.
Map<String, dynamic> _parseExtra(dynamic extra) {
  if (extra == null) return <String, dynamic>{};
  if (extra is Map<String, dynamic>) return extra;
  if (extra is Map) return Map<String, dynamic>.from(extra);
  if (extra is Trip) return extra.toJson();
  return <String, dynamic>{};
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

class AppRouter {
  final LocalStorage _storage;
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  AppRouter(this._storage);

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    redirect: _globalRedirect,
    errorBuilder: (context, state) {
      final userType = _storage.read(key: 'usertype')?.toString();
      final userToken = _storage.read(key: 'usertoken');
      if (userToken == null) {
        return const LoginScreen();
      }
      return userType == 'driver' ? const DriverLayout() : const UserLayout();
    },
    routes: [
      // ── Widget Deep Link Aliases ──────────────────────────
      GoRoute(
        path: '/passenger_add_private',
        redirect: (context, state) => AppRoutes.passengerAddPrivateTrip,
      ),
      GoRoute(
        path: '/passenger_add_shared',
        redirect: (context, state) => AppRoutes.passengerAddSharedTrip,
      ),
      GoRoute(
        path: '/driver_new_trips',
        redirect: (context, state) => AppRoutes.availableTrips,
      ),
      GoRoute(
        path: '/passenger/trips/private/chat',
        redirect: (context, state) => AppRoutes.tripChat,
      ),
      GoRoute(
        path: '/open',
        redirect: (context, state) => null,
      ),

      // ── Splash / initial redirect ──────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SizedBox.shrink(),
      ),

      // ── Auth ────────────────────────────────────
      GoRoute(
        path: AppRoutes.onBoarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseLang,
        builder: (context, state) => const ChooseLangScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final extraMobile = state.extra is String
              ? state.extra as String
              : (state.extra is Map
                  ? (state.extra as Map)['mobile'] as String?
                  : null);
          return LoginScreen(initialMobile: extraMobile);
        },
      ),
      GoRoute(
        path: AppRoutes.passengerSignup,
        builder: (context, state) => const SignupUserScreen(),
      ),
      GoRoute(
        path: AppRoutes.passengerSignupConfirm,
        builder: (context, state) {
          final mobile = state.extra as String? ?? '';
          return SignupConfirmScreen(mobile: mobile);
        },
      ),
      GoRoute(
        path: AppRoutes.driverSignup,
        builder: (context, state) => const SignupDriverScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverSignupInfo,
        builder: (context, state) {
          final extra = state.extra;
          final initialData = extra is DriverSignupInitialData
              ? extra
              : const DriverSignupInitialData(
                  name: '',
                  mobile: '',
                  password: '',
                );
          return DriverSignupInfoScreen(initialData: initialData);
        },
      ),
      GoRoute(
        path: AppRoutes.driverSignupConfirm,
        builder: (context, state) {
          final mobile = state.extra as String? ?? '';
          return SignupConfirmScreen(mobile: mobile);
        },
      ),
      GoRoute(
        path: AppRoutes.forgetPassword,
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgetPasswordConfirm,
        builder: (context, state) {
          final extra = state.extra;
          final mobile = extra is Map<String, dynamic>
              ? (extra['mobile'] ?? extra['emailOrPhone'] ?? '')
              : (extra as String? ?? '');
          return ResetPasswordScreen(mobile: mobile);
        },
      ),

      GoRoute(
        path: AppRoutes.tripChat,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TripChatScreenClean(
            driverName: extra['driverName']?.toString() ?? '',
            driverPhone: extra['driverPhone']?.toString() ?? '',
            driverPhoto: extra['driverPhoto']?.toString() ?? extra['driver_photo']?.toString(),
            tripFrom: extra['tripFrom']?.toString() ?? '',
            tripTo: extra['tripTo']?.toString() ?? '',
            tripDatetime: extra['tripDatetime']?.toString() ?? '',
            acceptedPrice:
                double.tryParse(extra['acceptedPrice']?.toString() ?? '0') ??
                    0.0,
            tripId: _parseInt(extra['tripId'] ?? extra['trip_id']) ?? 0,
            offerId: _parseInt(extra['offerId'] ?? extra['offer_id']) ?? 0,
            driverId: _parseInt(extra['driverId'] ?? extra['driver_id']),
            passengerId: _parseInt(extra['passengerId'] ?? extra['passenger_id']),
            creatorId: _parseInt(extra['creatorId'] ?? extra['creator_id']),
            chatId: extra['chatId']?.toString() ?? extra['chat_id']?.toString(),
            isInquiry: extra['isInquiry'] == true || extra['is_inquiry'] == true,
            isDm: extra['isDm'] == true || extra['is_dm'] == true,
            isOffersPhase: extra['isOffersPhase'] == true || extra['is_offers_phase'] == true,
            members: extra['members'] as List<dynamic>?,
            tripType: extra['tripType']?.toString() ?? 'private',
          );
        },
      ),

      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const CleanNotificationsScreen(),
      ),

      // ── Passenger Layout ────────────────────────
      GoRoute(
        path: AppRoutes.passengerHome,
        builder: (context, state) => UserLayout(),
        routes: [
          GoRoute(
            path: AppRoutes.passengerTrips
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) => PassengerTripsListScreenClean(),
          ),
          GoRoute(
            path: AppRoutes.passengerAddPrivateTrip
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) {
              final extra = state.extra;
              String? destName;
              double? destLat;
              double? destLng;
              if (extra is Map) {
                destName = extra['preset_destination_name']?.toString();
                destLat = double.tryParse(
                    extra['preset_destination_lat']?.toString() ?? '');
                destLng = double.tryParse(
                    extra['preset_destination_lng']?.toString() ?? '');
              }
              return AddPrivateTripScreenClean(
                presetDestinationName: destName,
                presetDestinationLat: destLat,
                presetDestinationLng: destLng,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.passengerAddSharedTrip
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) =>
                const PassengerAddSharedTripScreenClean(),
          ),
          GoRoute(
            path: AppRoutes.passengerSearchSharedTrips
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) =>
                const PassengerSearchSharedTripsScreen(),
          ),
          GoRoute(
            path: AppRoutes.passengerSharedTripDetails
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) {
              final extra = state.extra;
              final trip = extra is Trip
                  ? extra
                  : (extra is Map && extra['trip'] is Trip
                      ? extra['trip'] as Trip
                      : (extra is Map && (extra.containsKey('id') || extra.containsKey('trip_id'))
                          ? TripModel.fromJson(Map<String, dynamic>.from(extra))
                          : null));
              final tripId = trip?.id ??
                  (extra is int
                      ? extra
                      : (extra is Map
                          ? _parseInt(extra['trip_id'] ?? extra['id'])
                          : null));
              return PassengerSharedTripDetailsScreenClean(
                trip: trip,
                tripId: tripId,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.passengerSharedTripDetailsPassengers
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) {
              final extra = state.extra;
              final trip = extra is Trip
                  ? extra
                  : (extra is Map && extra['trip'] is Trip
                      ? extra['trip'] as Trip
                      : (extra is Map && (extra.containsKey('id') || extra.containsKey('trip_id'))
                          ? TripModel.fromJson(Map<String, dynamic>.from(extra))
                          : null));
              final tripId = trip?.id ??
                  (extra is int
                      ? extra
                      : (extra is Map
                          ? _parseInt(extra['trip_id'] ?? extra['id'])
                          : null));
              return PassengerSharedTripDetailsPassengersScreenClean(
                trip: trip,
                tripId: tripId,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.passengerCurrentPrivateTrip
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) {
              final extra = state.extra;
              final storedTrip = TripSecurityService.getActiveTrip(_storage);
              final trip = extra is Trip
                  ? extra
                  : (extra is Map<String, dynamic> && extra['trip'] is Trip
                      ? extra['trip'] as Trip
                      : storedTrip);
              final tripId = trip?.id ??
                  (extra is Map
                      ? (_parseInt(extra['trip_id'] ??
                          extra['tripId'] ??
                          extra['id'] ??
                          (extra['trip'] is Map ? extra['trip']['id'] : null) ??
                          extra['tripDetails']?['id'] ??
                          extra['tripDetails']?['trip_id']))
                      : _parseInt(extra)) ??
                  storedTrip?.id ??
                  _parseInt(_storage.read(key: 'trip_id'));
              final rawMap = extra is Map<String, dynamic>
                  ? (extra['tripDetails'] ?? extra)
                  : storedTrip?.toJson();

              if (trip == null && tripId == null && rawMap == null) {
                TripSecurityService.clearActiveTrip(_storage);
                _storage.remove(key: 'ongoing_trip');
                _storage.remove(key: 'trip_id');
                return const UserLayout();
              }

              return PassengerCurrentPrivateTripScreenClean(
                trip: trip,
                tripId: tripId,
                tripDetails: rawMap,
                userData:
                    extra is Map<String, dynamic> ? extra['userData'] : null,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.passengerPrivateOffers
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) {
              final extra = _parseExtra(state.extra);
              final storedTrip = TripSecurityService.getPendingTrip(_storage);
              final trip = extra['trip'] is Trip
                  ? extra['trip'] as Trip
                  : (state.extra is Trip ? state.extra as Trip : storedTrip);
              final tripId = trip?.id ??
                  _parseInt(extra['trip_id'] ??
                      extra['tripId'] ??
                      extra['id']) ??
                  storedTrip?.id;
              return PrivateCurrentScreenCleanoffers(
                trip: trip,
                id: tripId,
                proposed_fare: extra['proposed_fare'] != null
                    ? double.tryParse(extra['proposed_fare'].toString())
                    : storedTrip?.minimumPrice,
                is_auto_accept: extra['is_auto_accept'] == true,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.passengerOngoingSharedTrip
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) {
              final extra = state.extra;
              final storedTrip = TripSecurityService.getActiveTrip(_storage);
              final trip = extra is Trip
                  ? extra
                  : (extra is Map<String, dynamic> && extra['trip'] is Trip
                      ? extra['trip'] as Trip
                      : storedTrip);
              final tripId = trip?.id ??
                  (extra is Map
                      ? (_parseInt(extra['trip_id'] ??
                          extra['tripId'] ??
                          extra['id'] ??
                          (extra['trip'] is Map ? extra['trip']['id'] : null) ??
                          extra['tripDetails']?['id'] ??
                          extra['tripDetails']?['trip_id']))
                      : _parseInt(extra)) ??
                  storedTrip?.id ??
                  _parseInt(_storage.read(key: 'trip_id'));
              final rawMap = extra is Map<String, dynamic>
                  ? (extra['tripDetails'] ?? extra)
                  : storedTrip?.toJson();

              if (trip == null && tripId == null && rawMap == null) {
                TripSecurityService.clearActiveTrip(_storage);
                _storage.remove(key: 'ongoing_trip');
                _storage.remove(key: 'trip_id');
                return const UserLayout();
              }

              return PassengerOngoingSharedTripScreenClean(
                trip: trip,
                tripId: tripId,
                tripDetails: rawMap,
                userData:
                    extra is Map<String, dynamic> ? extra['userData'] : null,
              );
            },
          ),
          GoRoute(
            path: AppRoutes.passengerSharedCurrentTrip
                .substring(AppRoutes.passengerHome.length + 1),
            builder: (context, state) {
              final extra = _parseExtra(state.extra);
              final storedTrip = TripSecurityService.getPendingTrip(_storage);
              final trip = extra['trip'] is Trip
                  ? extra['trip'] as Trip
                  : (state.extra is Trip ? state.extra as Trip : storedTrip);
              final tripId = trip?.id ??
                  _parseInt(extra['trip_id'] ??
                      extra['tripId'] ??
                      extra['id'] ??
                      extra['tripDetails']?['id'] ??
                      extra['tripDetails']?['trip_id']) ??
                  storedTrip?.id;
              return SharedCurrentTripsScreenClean(
                trip: trip,
                id: tripId,
                proposed_fare: extra['proposed_fare'] != null
                    ? double.tryParse(extra['proposed_fare'].toString())
                    : storedTrip?.minimumPrice,
                is_auto_accept: extra['is_auto_accept'] == true,
              );
            },
          ),
        ],
      ),

      // ── Driver Layout ────────────────────────────
      GoRoute(
        path: AppRoutes.driverHome,
        builder: (context, state) {
          final extra = state.extra;
          final int? tab = extra is int
              ? extra
              : (extra is Map ? _parseInt(extra['tab']) : null);
          return DriverLayout(currentIndex: tab);
        },
        routes: [
          GoRoute(
            path: AppRoutes.driverTrips
                .substring(AppRoutes.driverHome.length + 1),
            builder: (context, state) => DriverTripsListScreenClean(),
          ),
          GoRoute(
            path: AppRoutes.driverOngoingPrivateTrip
                .substring(AppRoutes.driverHome.length + 1),
            builder: (context, state) {
              final extra = state.extra;
              final storedTrip = TripSecurityService.getActiveTrip(_storage);
              final Trip? trip = extra is Trip
                  ? extra
                  : (extra is Map
                      ? (extra['trip'] is Trip ? extra['trip'] as Trip : null)
                      : storedTrip);
              final int? tripId = trip?.id ??
                  (extra is Map
                      ? (_parseInt(extra['trip_id'] ??
                          extra['id'] ??
                          (extra['trip'] is Map ? extra['trip']['id'] : null)))
                      : _parseInt(extra)) ??
                  storedTrip?.id ??
                  _parseInt(_storage.read(key: 'trip_id'));

              if (trip == null && tripId == null) {
                TripSecurityService.clearActiveTrip(_storage);
                _storage.remove(key: 'ongoing_trip');
                _storage.remove(key: 'trip_id');
                return const DriverLayout();
              }

              return BlocProvider(
                create: (_) => sl<DriverAddPrivateTripCubit>(),
                child: DriverOngoingPrivateTripScreenClean(
                  trip: trip,
                  tripId: tripId,
                ),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.driverOngoingSharedTrip
                .substring(AppRoutes.driverHome.length + 1),
            builder: (context, state) {
              final extra = state.extra;
              final storedTrip = TripSecurityService.getActiveTrip(_storage);
              final Trip? trip = extra is Trip
                  ? extra
                  : (extra is Map
                      ? (extra['trip'] is Trip ? extra['trip'] as Trip : null)
                      : storedTrip);
              final int? tripId = trip?.id ??
                  (extra is Map
                      ? (_parseInt(extra['trip_id'] ??
                          extra['id'] ??
                          (extra['trip'] is Map ? extra['trip']['id'] : null)))
                      : _parseInt(extra)) ??
                  storedTrip?.id ??
                  _parseInt(_storage.read(key: 'trip_id'));

              if (trip == null && tripId == null) {
                TripSecurityService.clearActiveTrip(_storage);
                _storage.remove(key: 'ongoing_trip');
                _storage.remove(key: 'trip_id');
                return const DriverLayout();
              }

              return BlocProvider(
                create: (_) => sl<DriverAddPrivateTripCubit>(),
                child: DriverOngoingSharedTripScreenClean(
                  trip: trip,
                  tripId: tripId,
                ),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.availableTrips
                .substring(AppRoutes.driverHome.length + 1),
            builder: (context, state) =>
                const DriverNewTripsAcceptScreenClean(),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.tripRating,
        builder: (context, state) {
          final extra = _parseExtra(state.extra);
          return TripRatingScreen(
            tripId: _parseInt(extra['trip_id']) ?? 0,
            targetUserId: _parseInt(extra['target_user_id']) ?? 0,
            targetUserName: extra['target_user_name']?.toString() ?? '',
            isDriverRatingPassenger: extra['is_driver'] == true,
            initialStars: _parseInt(extra['initial_stars']),
            initialComment: extra['initial_comment']?.toString(),
            isEdit: extra['is_edit'] == true,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pendingRatings,
        builder: (context, state) => const PendingRatingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.myRatings,
        builder: (context, state) => const MyRatingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverRatings,
        builder: (context, state) {
          final extra = _parseExtra(state.extra);
          final driverId = _parseInt(extra['driver_id']) ??
              _parseInt(extra['userid']) ??
              _parseInt(extra['user_id']) ??
              _parseInt(state.uri.queryParameters['driver_id']) ??
              _parseInt(_storage.read(key: 'userid')) ??
              _parseInt(_storage.read(key: 'user_id')) ??
              0;
          final driverName = extra['driver_name']?.toString() ??
              state.uri.queryParameters['driver_name'] ??
              _storage.read(key: 'username')?.toString();
          return DriverRatingsScreen(
            driverId: driverId,
            driverName: driverName,
          );
        },
      ),
    ],
  );

  // ──────────────────────────────────────────────
  //  Global Redirect Logic
  // ──────────────────────────────────────────────
  Future<String?> _globalRedirect(
      BuildContext context, GoRouterState state) async {
    final onBoarding = _storage.read(key: 'onboarding') as bool?;
    final userToken = _storage.read(key: 'usertoken') as String?;
    final userType = _storage.read(key: 'usertype') as String?;
    final ongoingTrip = _storage.read(key: 'ongoing_trip') as String?;
    final activeTripData = TripSecurityService.getActiveTrip(_storage);
    final pendingTripData = TripSecurityService.getPendingTrip(_storage);

    // Allow user to navigate freely between onboarding, choose language, login, and registration screens
    final isAuthRoute = state.matchedLocation == AppRoutes.onBoarding ||
        state.matchedLocation == AppRoutes.chooseLang ||
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.passengerSignup ||
        state.matchedLocation == AppRoutes.passengerSignupConfirm ||
        state.matchedLocation == AppRoutes.driverSignup ||
        state.matchedLocation == AppRoutes.driverSignupInfo ||
        state.matchedLocation == AppRoutes.driverSignupConfirm ||
        state.matchedLocation == AppRoutes.forgetPassword ||
        state.matchedLocation == AppRoutes.forgetPasswordConfirm;

    // 1. If user is logged in (has valid token and userType)
    if (userToken != null && userType != null) {
      // Never allow a logged-in user on splash or auth routes (onboarding, login, signup)
      if (state.matchedLocation == AppRoutes.splash || isAuthRoute) {
        if (userType == 'passenger') {
          // 1. If passenger has an active tracking trip -> go directly to tracking
          if (activeTripData != null ||
              (ongoingTrip != null &&
                  (ongoingTrip == 'shared' || ongoingTrip == 'private'))) {
            final isShared = (activeTripData?.type == TripType.shared) ||
                ongoingTrip == 'shared';
            return isShared
                ? AppRoutes.passengerOngoingSharedTrip
                : AppRoutes.passengerCurrentPrivateTrip;
          }
          // 2. If passenger has a pending trip waiting for offers -> go to waiting for offers
          if (pendingTripData != null) {
            return pendingTripData.type == TripType.shared
                ? AppRoutes.passengerSharedCurrentTrip
                : AppRoutes.passengerPrivateOffers;
          }
          return AppRoutes.passengerHome;
        } else {
          // Driver
          if (ongoingTrip != null) {
            return ongoingTrip == 'shared'
                ? AppRoutes.driverOngoingSharedTrip
                : AppRoutes.driverOngoingPrivateTrip;
          }
          return AppRoutes.driverHome;
        }
      }

      // Role guard: prevent passenger from accessing driver routes and vice-versa
      // Shared routes (chat, notifications, ratings) are accessible to both roles
      final isSharedRoute = state.matchedLocation == AppRoutes.tripChat ||
          state.matchedLocation == AppRoutes.notifications ||
          state.matchedLocation == AppRoutes.tripRating ||
          state.matchedLocation == AppRoutes.pendingRatings ||
          state.matchedLocation == AppRoutes.myRatings ||
          state.matchedLocation == AppRoutes.driverRatings ||
          state.matchedLocation == '/passenger/trips/private/chat';

      if (isSharedRoute) {
        return null; // Access granted to both roles
      }

      final isDriverRoute =
          state.matchedLocation.startsWith(AppRoutes.driverHome);
      final isPassengerRoute =
          state.matchedLocation.startsWith(AppRoutes.passengerHome);

      if (userType == 'passenger' && isDriverRoute) {
        return AppRoutes.passengerHome;
      }
      if (userType == 'driver' && isPassengerRoute) {
        return AppRoutes.driverHome;
      }

      return null; // Access granted
    }

    // 2. User is NOT logged in:
    // First launch (onboarding not completed yet)
    if (onBoarding == null) {
      if (state.matchedLocation == AppRoutes.onBoarding ||
          state.matchedLocation == AppRoutes.chooseLang) {
        return null;
      }
      return AppRoutes.onBoarding;
    }

    // 3. User is NOT logged in and onboarding is already completed:
    // Allow any auth route (login, signups, forget password)
    if (isAuthRoute) {
      return null;
    }

    // Any attempt to access protected pages while not logged in -> redirect to login
    return AppRoutes.login;
  }
}
