import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/router/app_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:car_app/core/storage/secure_storage.dart';
import 'package:car_app/core/utils/fcm_notification_service.dart';
import 'package:car_app/core/services/notification_routing_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/storage/shared_prefs_storage.dart';

import 'package:car_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:car_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:car_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:car_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:car_app/features/auth/domain/usecases/check_verification_code_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/resend_verification_code_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/signup_usecase.dart';
import 'package:car_app/features/auth/domain/usecases/update_device_token_usecase.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';


// Map Feature
import 'package:car_app/features/map/data/services/map_service_impl.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/map/presentation/cubit/map_cubit.dart';

// Trips Feature
import 'package:car_app/features/trips/data/datasources/trips_remote_datasource.dart';
import 'package:car_app/features/trips/data/datasources/trips_remote_datasource_impl.dart';
import 'package:car_app/features/trips/data/repositories/trips_repository_impl.dart';
import 'package:car_app/features/trips/domain/repositories/trips_repository.dart';
import 'package:car_app/features/trips/domain/usecases/change_offer_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/change_trip_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/create_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_driver_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_offers_by_trip_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_passenger_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trip_details_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_trips_near_me_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/get_nearby_shared_trips_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/make_offer_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/change_passenger_status_usecase.dart';
import 'package:car_app/features/trips/domain/usecases/subscribe_trip_usecase.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_search_shared_trips_cubit.dart';

// Settings Feature
import 'package:car_app/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:car_app/features/settings/data/datasources/settings_remote_datasource_impl.dart';
import 'package:car_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:car_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:car_app/features/settings/domain/usecases/get_user_profile_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/update_user_profile_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/get_saved_locations_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/add_saved_location_usecase.dart';
import 'package:car_app/features/settings/domain/usecases/delete_saved_location_usecase.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/saved_locations_cubit.dart';

// Notifications Feature
import 'package:car_app/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:car_app/features/notifications/data/datasources/notifications_remote_datasource_impl.dart';
import 'package:car_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:car_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:car_app/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:car_app/features/notifications/presentation/cubit/notifications_cubit.dart';

// Home Feature
import 'package:car_app/features/home/domain/repositories/home_repository.dart';
import 'package:car_app/features/home/domain/usecases/get_nearby_trips_usecase.dart';
import 'package:car_app/features/home/domain/usecases/get_driver_trips_totals_usecase.dart';
import 'package:car_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/driver_home_cubit.dart';

// Driver Documents (KYC) Feature
import 'package:car_app/features/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:car_app/features/driver_documents/data/datasources/driver_documents_remote_datasource_impl.dart';
import 'package:car_app/features/driver_documents/data/repositories/driver_documents_repository_impl.dart';
import 'package:car_app/features/driver_documents/domain/repositories/driver_documents_repository.dart';
import 'package:car_app/features/driver_documents/domain/usecases/get_driver_documents_usecase.dart';
import 'package:car_app/features/driver_documents/domain/usecases/upload_driver_documents_usecase.dart';
import 'package:car_app/features/driver_documents/presentation/cubit/driver_documents_cubit.dart';
// Chat Feature
import 'package:car_app/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:car_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:car_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:car_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:car_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:car_app/features/chat/presentation/cubit/chat_cubit.dart';

// Ratings Feature
import 'package:car_app/features/ratings/data/datasources/ratings_remote_datasource.dart';
import 'package:car_app/features/ratings/data/datasources/ratings_remote_datasource_impl.dart';
import 'package:car_app/features/ratings/data/repositories/ratings_repository_impl.dart';
import 'package:car_app/features/ratings/domain/repositories/ratings_repository.dart';
import 'package:car_app/features/ratings/domain/usecases/submit_rating_usecase.dart';
import 'package:car_app/features/ratings/domain/usecases/get_pending_ratings_usecase.dart';
import 'package:car_app/features/ratings/domain/usecases/get_my_ratings_usecase.dart';
import 'package:car_app/features/ratings/domain/usecases/get_driver_ratings_usecase.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_cubit.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // ==========================================
  // External Libraries
  // ==========================================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<SecureStorage>(() => SecureStorageImpl(sl()));

  sl.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          receiveDataWhenStatusError: true,
        ),
      ));

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ==========================================
  // Core — Infrastructure
  // ==========================================

  // Storage
  sl.registerLazySingleton<LocalStorage>(
    () => SharedPrefsStorage(sl()),
  );

  // API Client
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl()),
  );

  // Router
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(sl()),
  );

  // FCM Notification Service
  sl.registerLazySingleton<FcmNotificationService>(
    () => FcmNotificationService(client: sl(), storage: sl()),
  );

  // Notification Routing Service
  sl.registerLazySingleton<NotificationRoutingService>(
    () => NotificationRoutingService(
      getRouter: () => sl<AppRouter>().router,
      storage: sl(),
      getTripDetails: sl(),
      getPassengerTrips: sl(),
      getDriverTrips: sl(),
      getTripsNearMe: sl(),
    ),
  );

  // ==========================================
  // Anti-Corruption Layer (Legacy Bridge)
  // ==========================================
  // sl.registerLazySingleton<LegacyBridge>(() => LegacyBridgeImpl());

  // ==========================================
  // Feature — Auth
  // ==========================================

  // Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl(),
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => CheckVerificationCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeviceTokenUseCase(sl()));

  // Cubit
  sl.registerFactory(() => AuthCubit(
        loginUseCase: sl(),
        signUpUseCase: sl(),
        checkVerificationCodeUseCase: sl(),
        resendVerificationCodeUseCase: sl(),
        resetPasswordUseCase: sl(),
        updateDeviceTokenUseCase: sl(),
        uploadDriverDocumentsUseCase: sl(),
        localStorage: sl(),
      ));

  // ==========================================
  // Feature — Map
  // ==========================================

  // Service
  sl.registerLazySingleton<MapService>(
    () => MapServiceImpl(googleApiKey: ApiEndpoints.googleMapsApiKey),
  );

  // Cubit (factory — new instance per screen that needs a fresh map state)
  sl.registerFactory(() => MapCubit(sl()));

  // ==========================================
  // Feature — Trips
  // ==========================================

  // Data Source
  sl.registerLazySingleton<TripsRemoteDataSource>(
    () => TripsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TripsRepository>(
    () => TripsRepositoryImpl(
      remoteDataSource: sl(),
      storage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetPassengerTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetOffersByTripUseCase(sl()));
  sl.registerLazySingleton(() => ChangeOfferStatusUseCase(sl()));
  sl.registerLazySingleton(() => ChangeTripStatusUseCase(sl()));
  sl.registerLazySingleton(() => CreateTripUseCase(sl()));
  sl.registerLazySingleton(() => GetTripDetailsUseCase(sl()));
  sl.registerLazySingleton(() => ChangePassengerStatusUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeTripUseCase(sl()));
  sl.registerLazySingleton(() => GetTripsNearMeUseCase(sl()));
  sl.registerLazySingleton(() => GetNearbySharedTripsUseCase(sl()));
  sl.registerLazySingleton(() => MakeOfferUseCase(sl()));

  // Cubits (factory — new instance per screen)
  sl.registerFactory(() => PassengerTripsCubit(
        getPassengerTrips: sl(),
        getOffersByTrip: sl(),
        changeOfferStatus: sl(),
        changeTripStatus: sl(),
        createTrip: sl(),
        getTripDetails: sl(),
        changePassengerStatus: sl(),
        subscribeTrip: sl(),
        makeOffer: sl(),
        storage: sl(),
        client: sl(),
        fcmNotificationService: sl(),
      ));


  sl.registerFactory(() => DriverTripsCubit(
        getDriverTrips: sl(),
        changeTripStatus: sl(),
        changeOfferStatus: sl(),
        getTripDetails: sl(),
        getTripsNearMe: sl(),
        createTrip: sl(),
        makeOffer: sl(),
        getOffersByTrip: sl(),
        storage: sl(),
        client: sl(),
      ));

  sl.registerFactory(() => PassengerAddPrivateTripCubit(
        client: sl(),
        storage: sl(),
        mapService: sl(),
        createTripUseCase: sl(),
        getTripDetailsUseCase: sl(),
        changePassengerStatusUseCase: sl(),
      ));

  sl.registerFactory(() => DriverAddPrivateTripCubit(
        client: sl(),
        storage: sl(),
        mapService: sl(),
        createTripUseCase: sl(),
        getTripDetailsUseCase: sl(),
        changePassengerStatusUseCase: sl(),
      ));

  sl.registerFactory(() => DriverAddSharedTripCubit(
        createTripUseCase: sl(),
        makeOfferUseCase: sl(),
        changeTripStatusUseCase: sl(),
        changeOfferStatusUseCase: sl(),
        getOffersByTripUseCase: sl(),
        storage: sl(),
        mapService: sl(),
      ));

  sl.registerFactory(() => PassengerAddSharedTripCubit(
        createTripUseCase: sl(),
        getNearbySharedTrips: sl(),
        getTripDetails: sl(),
        storage: sl(),
        mapService: sl(),
      ));

  // ==========================================
  // Feature — Settings
  // ==========================================

  // Data Source
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedLocationsUseCase(sl()));
  sl.registerLazySingleton(() => AddSavedLocationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSavedLocationUseCase(sl()));

  // Cubits (factory)
  sl.registerFactory(() => ProfileCubit(
        getUserProfileUseCase: sl(),
        updateUserProfileUseCase: sl(),
        localStorage: sl(),
      ));

  sl.registerFactory(() => SavedLocationsCubit(
        getSavedLocationsUseCase: sl(),
        addSavedLocationUseCase: sl(),
        deleteSavedLocationUseCase: sl(),
        localStorage: sl(),
      ));

  sl.registerFactory(() => PassengerSearchSharedTripsCubit(
        getNearbySharedTrips: sl(),
        getTripDetails: sl(),
        mapService: sl(),
        storage: sl(),
      ));

  // ==========================================
  // Feature — Notifications
  // ==========================================

  // Data Source
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );

  // Use Case
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));

  // Cubit (factory)
  sl.registerFactory(() => NotificationsCubit(
        getNotificationsUseCase: sl(),
        localStorage: sl(),
      ));

  // ==========================================
  // Feature — Home
  // ==========================================

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(client: sl(), storage: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNearbyTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverTripsTotalsUseCase(sl()));

  // Cubits
  sl.registerFactory(() => PassengerHomeCubit(
        getNearbyTrips: sl(),
        storage: sl(),
      ));

  sl.registerFactory(() => DriverHomeCubit(
        getDriverTripsTotals: sl(),
        storage: sl(),
        getUserProfile: sl(),
        getDriverDocuments: sl(),
        getTripsNearMe: sl(),
      ));

  // ==========================================
  // Feature — Chat
  // ==========================================
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  sl.registerFactory(() => ChatCubit(
        getMessages: sl(),
        sendMessage: sl(),
        storage: sl(),
        remoteDataSource: sl(),
      ));

  // ==========================================
  // Feature — Driver Documents (KYC)
  // ==========================================

  // Data Source — uses its own Dio instance to avoid Content-Type conflicts
  sl.registerLazySingleton<DriverDocumentsRemoteDataSource>(
    () => DriverDocumentsRemoteDataSourceImpl(
      Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl, receiveDataWhenStatusError: true)),
    ),
  );

  // Repository
  sl.registerLazySingleton<DriverDocumentsRepository>(
    () => DriverDocumentsRepositoryImpl(
      remoteDataSource: sl(),
      localStorage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDriverDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => UploadDriverDocumentsUseCase(sl()));

  // Cubit (factory — new instance per screen)
  sl.registerFactory(() => DriverDocumentsCubit(
        getDriverDocumentsUseCase: sl(),
        uploadDriverDocumentsUseCase: sl(),
        localStorage: sl(),
      ));

  // ==========================================
  // Feature — Ratings
  // ==========================================

  // Data Source
  sl.registerLazySingleton<RatingsRemoteDataSource>(
    () => RatingsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<RatingsRepository>(
    () => RatingsRepositoryImpl(
      remoteDataSource: sl(),
      storage: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SubmitRatingUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingRatingsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyRatingsUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverRatingsUseCase(sl()));

  // Cubit (factory)
  sl.registerFactory(() => RatingsCubit(
        submitRatingUseCase: sl(),
        getPendingRatingsUseCase: sl(),
        getMyRatingsUseCase: sl(),
        getDriverRatingsUseCase: sl(),
      ));
}
