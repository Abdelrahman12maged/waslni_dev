import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:car_app/features/home/presentation/cubit/driver_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/passenger_home_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit.dart';
import 'package:car_app/features/home/presentation/cubit/user_layout_cubit.dart';
import 'package:car_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:car_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/saved_locations_cubit.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/widgets/in_app_notification_banner.dart';
import 'package:car_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/utils/bloc_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/di/injection_container.dart' as di;
import 'package:car_app/core/router/app_router.dart';
import 'package:car_app/core/services/notification_routing_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_shared_trip_cubit.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/network/api_client.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/services/home_widget_service.dart';

import 'dart:async';
import 'package:car_app/features/auth/domain/usecases/update_device_token_usecase.dart';

// Background messages — only log, do NOT try to refresh the FCM token here.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    log('Background message received: ${message.messageId}', name: 'FCM');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }

  await di.initDI();

  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,

  );
  
  // To intialise the hive database

  await Hive.initFlutter();

  // CacheHelper is deprecated in favor of LocalStorage (DI)
  Bloc.observer = MyBlocObserver();

  // LocalStorage / GoRouter manages the initial page navigation automatically.
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    log('User granted permission: ${settings.authorizationStatus}',
        name: 'FCM');
  }

  // Background message handler (must be registered before runApp)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ── Home Widget initialisation ────────────────────────────────────────
  await HomeWidgetService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static StreamSubscription<String>? tokenRefreshSubscription;

  static void cancelTokenRefreshSubscription() {
    tokenRefreshSubscription?.cancel();
    tokenRefreshSubscription = null;
  }

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, String newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  String lang = 'en';
  GoRouter? _router;

  void changeLanguage(String newLocale) {
    setState(() {
      lang = newLocale;
    });
  }

  @override
  void initState() {
    super.initState();
    final cachedLang = di.sl<LocalStorage>().read(key: 'lang') as String?;
    if (cachedLang != null && (cachedLang == 'ar' || cachedLang == 'en')) {
      lang = cachedLang;
    }

    // Wire up FCM handlers and HomeWidget click listener after the first frame so GoRouter is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _router = di.sl<AppRouter>().router;
      _setupFcmToken(); // Register/refresh token with backend
      _setupFcmDeepLink(); // Handle tapped notifications
      HomeWidgetService.setupWidgetClickListener((route) {
        _safeWidgetNavigate(route);
      });
    });
  }

  void _safeWidgetNavigate(String targetRoute) {
    // Delay ensures GoRouter initial configuration & authentication checks are completed
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      try {
        final storage = di.sl<LocalStorage>();
        final userToken = storage.read(key: 'usertoken');
        if (userToken == null) {
          _router?.go(AppRoutes.login);
          return;
        }
        _router?.go(targetRoute);
      } catch (e) {
        log('Widget navigation go() failed, attempting push(): $e',
            name: 'HomeWidget');
        try {
          _router?.push(targetRoute);
        } catch (e2) {
          log('Widget navigation failed completely: $e2', name: 'HomeWidget');
        }
      }
    });
  }

  // ── FCM Token Registration ────────────────────────────────────────────────

  /// Saves [token] in LocalStorage and sends it to the backend via UpdateDeviceTokenUseCase
  /// and syncs with Firestore users collection for real-time chat push notifications.
  Future<void> _persistFcmToken(String token) async {
    final storage = di.sl<LocalStorage>();
    await storage.saveString(key: 'fcmToken', value: token);

    final userId = storage.read(key: 'userid')?.toString() ??
        storage.read(key: 'user_id')?.toString() ??
        '';

    if (userId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'fcm_token': token,
          'device_token': token,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        if (kDebugMode) {
          log('FCM token synced to Firestore users/$userId: $token',
              name: 'FCM');
        }
      } catch (e) {
        if (kDebugMode) {
          log('Failed to sync FCM token to Firestore: $e', name: 'FCM');
        }
      }
    }

    final userToken = storage.read(key: 'usertoken') as String?;
    if (userToken == null || userToken.isEmpty) {
      return; // Guard: not logged in yet
    }

    try {
      final updateDeviceTokenUseCase = di.sl<UpdateDeviceTokenUseCase>();
      await updateDeviceTokenUseCase(token);
      if (kDebugMode) {
        log('FCM token synced via UpdateDeviceTokenUseCase: $token',
            name: 'FCM');
      }
    } catch (e) {
      if (kDebugMode) {
        log('Failed to sync FCM token: $e', name: 'FCM');
      }
    }
  }

  /// Fetches the current FCM token and subscribes to future refreshes.
  void _setupFcmToken() {
    // Fetch current token and register it
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null && token.isNotEmpty) {
        if (kDebugMode) log('Current FCM token: $token', name: 'FCM');
        _persistFcmToken(token);
      }
    });

    // Listen for token refreshes (iOS token rotation, app reinstall, etc.)
    MyApp.tokenRefreshSubscription?.cancel();
    MyApp.tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (kDebugMode) log('FCM token refreshed: $newToken', name: 'FCM');
      _persistFcmToken(newToken);
    });
  }

  // ── Deep-Link on Notification Tap ────────────────────────────────────────

  /// Navigates to the correct screen based on notification [data].
  void _handleNotificationTap(Map<String, dynamic> data) {
    di.sl<NotificationRoutingService>().handleNotificationTap(data);
  }

  void _setupFcmDeepLink() {
    // Case 0 — Foreground message: show interactive In-App Notification Banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        log('Foreground FCM received: ${message.data}', name: 'FCM');
      }
      final title = message.notification?.title ??
          message.data['title']?.toString() ??
          '';
      final body = message.notification?.body ??
          message.data['body']?.toString() ??
          message.data['message']?.toString() ??
          '';

      if (title.isNotEmpty || body.isNotEmpty) {
        InAppNotificationBanner.show(
          title: title,
          body: body.isNotEmpty ? body : title,
          data: message.data,
          onTap: () => _handleNotificationTap(message.data),
        );
      }
    });

    // Case 1 — App was in background; user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        log('onMessageOpenedApp: ${message.data}', name: 'FCM');
      }
      _handleNotificationTap(message.data);
    });

    // Case 2 — App was terminated; user tapped the notification to launch it.
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          log('getInitialMessage: ${message.data}', name: 'FCM');
        }
        _handleNotificationTap(message.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserLayoutCubit(),
        ),
        BlocProvider(
          create: (context) => DriverLayoutCubit(),
        ),
        BlocProvider(
          create: (BuildContext context) => di.sl<AuthCubit>(),
        ),
        BlocProvider(
          create: (BuildContext context) => di.sl<NotificationsCubit>(),
        ),
        BlocProvider(
          create: (BuildContext context) => di.sl<DriverHomeCubit>(),
        ),
        BlocProvider(
          create: (BuildContext context) => di.sl<PassengerHomeCubit>(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              di.sl<PassengerAddPrivateTripCubit>(),
        ),
        BlocProvider(
          create: (BuildContext context) => di.sl<SavedLocationsCubit>(),
        ),
        BlocProvider(
          create: (BuildContext context) => di.sl<ProfileCubit>(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              di.sl<PassengerTripsCubit>()..loadPassengerTrips(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              di.sl<DriverTripsCubit>()..loadDriverTrips(),
        ),
        BlocProvider(
          create: (BuildContext context) =>
              di.sl<PassengerAddSharedTripCubit>(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: di.sl<AppRouter>().router,
        locale: Locale(lang),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        debugShowCheckedModeBanner: false,
        title: 'Car App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: buildMaterialColor(
              mainColor,
            ),
          ),
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            elevation: 0.0,
            scrolledUnderElevation: 0.0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
            ),
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.fixed,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}
