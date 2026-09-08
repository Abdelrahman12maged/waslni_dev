import 'dart:async';
import 'dart:developer';
import 'package:car_app/core/services/firebase_trip_location_service.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/widgets/components.dart';

import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_state.dart';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/trip_passenger.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/shared_ongoing/passenger_shared_top_bar.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/shared_ongoing/passenger_shared_driver_card.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/shared_ongoing/passenger_shared_status_steps.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/shared_ongoing/passenger_shared_passengers_roster.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/shared_ongoing/passenger_shared_action_buttons.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/private_current/passenger_private_route_row.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/private_current/passenger_private_price_card.dart';

class PassengerOngoingSharedTripView extends StatefulWidget {
  final Trip? trip;
  final int? tripId;
  final dynamic tripDetails;
  final dynamic userData;

  const PassengerOngoingSharedTripView({
    super.key,
    this.trip,
    this.tripId,
    this.tripDetails,
    this.userData,
  });

  static const CameraPosition _kDefaultCamera = CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 15,
  );

  @override
  State<PassengerOngoingSharedTripView> createState() =>
      _PassengerOngoingSharedTripViewState();
}

class _PassengerOngoingSharedTripViewState
    extends State<PassengerOngoingSharedTripView>
    with TickerProviderStateMixin {
  // â”€â”€ Map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  GoogleMapController? _mapController;
  final Location _location = Location();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _carIcon;
  double _driverBearing = 0.0;

  AnimationController? _carAnimController;
  LatLng? _carAnimStart;
  LatLng? _carAnimEnd;
  double _carBearingStart = 0.0;
  double _carBearingEnd = 0.0;
  LatLng? _animatedDriverLatLng;
  double _animatedDriverBearing = 0.0;

  // â”€â”€ Firestore live location listener â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final FirebaseTripLocationService _locationService =
      FirebaseTripLocationService();
  StreamSubscription<Map<String, dynamic>?>? _locationSub;

  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (math.pi / 180.0);
    double lng1 = start.longitude * (math.pi / 180.0);
    double lat2 = end.latitude * (math.pi / 180.0);
    double lng2 = end.longitude * (math.pi / 180.0);

    double dLng = lng2 - lng1;
    double y = math.sin(dLng) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    double brng = math.atan2(y, x);
    return (brng * (180.0 / math.pi) + 360.0) % 360.0;
  }

  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Trip? _trip;
  Map tripDetails = {};
  bool isLoading = true;
  bool isInCar = false;
  bool _isSheetCollapsed = false;
  String onGoingStatus =
      'pending'; // pending / on_the_way / close_to_customer / arrive_customer / start / end

  int _etaMinutes = 0;
  double _distanceRemainingKm = 0.0;
  LatLng? _lastRouteCalcPos;
  DateTime? _lastRouteCalcTime;
  List<LatLng>? _cachedTripRoutePoints;

  // â”€â”€ Animations â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late AnimationController _sheetCtrl;
  late Animation<Offset> _sheetAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // â”€â”€ Timers & Simulation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  StreamSubscription? _fcmSub;
  Timer? _pollStatusTimer;

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  void initState() {
    super.initState();

    _loadCarIcon();

    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sheetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    if (widget.trip != null) {
      _trip = widget.trip;
      tripDetails = widget.trip!.toJson();
      _initTripFlow();
    } else if (widget.tripDetails != null) {
      if (widget.tripDetails is Trip) {
        _trip = widget.tripDetails as Trip;
        tripDetails = _trip!.toJson();
      } else if (widget.tripDetails is Map) {
        tripDetails = Map<String, dynamic>.from(widget.tripDetails);
        try {
          _trip = Trip.fromMap(Map<String, dynamic>.from(widget.tripDetails));
        } catch (_) {}
      }
      _initTripFlow();
    } else if (widget.tripId != null) {
      setState(() => isLoading = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PassengerTripsCubit.get(context).refreshTripDetails(widget.tripId!);
      });
    } else {
      final storage = di.sl<LocalStorage>();
      final savedTrip = TripSecurityService.getActiveTrip(storage);
      final savedTripId = int.tryParse(storage.read(key: 'trip_id')?.toString() ?? '');
      if (savedTrip != null) {
        _trip = savedTrip;
        tripDetails = savedTrip.toJson();
        _initTripFlow();
      } else if (savedTripId != null && savedTripId > 0) {
        setState(() => isLoading = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          PassengerTripsCubit.get(context).refreshTripDetails(savedTripId);
        });
      } else {
        TripSecurityService.clearActiveTrip(storage);
        storage.remove(key: 'ongoing_trip');
        storage.remove(key: 'trip_id');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(AppRoutes.passengerHome);
          }
        });
      }
    }
  }

  void _initTripFlow() {
    onGoingStatus = _trip?.onGoingStatus ??
        tripDetails['on_going_status']?.toString() ??
        'on_the_way';

    // Save ongoing trip
    di.sl<LocalStorage>().saveString(
      key: 'ongoing_trip',
      value: tripDetails['type'] ?? 'shared',
    );
    TripSecurityService.saveActiveTrip(
      di.sl<LocalStorage>(),
      _trip ?? Map<String, dynamic>.from(tripDetails),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMapMarkers();
      _initLocation();
      _sheetCtrl.forward();

      // Start periodic status polling
      _startStatusPolling();

      // Listen to cubit for trip updates
      final parsedId = _trip?.id ?? int.tryParse(tripDetails['id']?.toString() ?? '') ?? 0;
      if (parsedId != 0) {
        PassengerTripsCubit.get(context).refreshTripDetails(parsedId);
      }

      // Firebase foreground listener
      _fcmSub = FirebaseMessaging.onMessage.listen(_onFCM);

      // â”€â”€ Subscribe to real-time driver location via Firestore â”€â”€
      final rawId = _trip?.id ??
          widget.tripId ??
          tripDetails['id'] ??
          tripDetails['trip_id'] ??
          tripDetails['trip']?['id'] ??
          tripDetails['tripId'];
      final tripId = rawId?.toString() ?? '';
      log('Passenger listening to Firestore for tripId: "$tripId"',
          name: 'OngoingSharedTrip');
      if (tripId.isNotEmpty && tripId != '0') {
        _locationSub?.cancel();
        _locationSub = _locationService
            .streamDriverLocation(tripId)
            .listen(_onDriverLocationUpdate);
      }

      setState(() => isLoading = false);
    });
  }

  @override
  void dispose() {
    _pollStatusTimer?.cancel();
    _carAnimController?.dispose();
    _locationSub?.cancel();
    _sheetCtrl.dispose();
    _pulseCtrl.dispose();
    _fcmSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateDriverMarkerOnly() {
    if (!mounted || _animatedDriverLatLng == null) return;
    setState(() {
      _markers = {
        for (final m in _markers)
          if (m.markerId.value != 'driver') m,
        Marker(
          markerId: const MarkerId('driver'),
          position: _animatedDriverLatLng!,
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation: _animatedDriverBearing != 0.0
              ? _animatedDriverBearing
              : _driverBearing,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: mounted ? S.of(context).driverInfo : 'Driver'),
        ),
      };
    });
  }

  void _animateDriverTo(LatLng targetPos, double targetBearing) {
    if (_animatedDriverLatLng == null) {
      _animatedDriverLatLng = targetPos;
      _animatedDriverBearing = targetBearing;
      _initMapMarkers();
      return;
    }

    _carAnimStart = _animatedDriverLatLng;
    _carAnimEnd = targetPos;
    _carBearingStart = _animatedDriverBearing;

    double diff = (targetBearing - _carBearingStart + 180) % 360 - 180;
    _carBearingEnd = _carBearingStart + (diff < -180 ? diff + 360 : diff);

    _carAnimController?.stop();
    _carAnimController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        if (!mounted || _carAnimStart == null || _carAnimEnd == null) return;
        final t = Curves.easeInOut.transform(_carAnimController!.value);
        final lat = ui.lerpDouble(_carAnimStart!.latitude, _carAnimEnd!.latitude, t)!;
        final lng = ui.lerpDouble(_carAnimStart!.longitude, _carAnimEnd!.longitude, t)!;
        final bearing = ui.lerpDouble(_carBearingStart, _carBearingEnd, t)!;

        _animatedDriverLatLng = LatLng(lat, lng);
        _animatedDriverBearing = (bearing + 360) % 360;
        _updateDriverMarkerOnly();
      });

    _carAnimController!.forward(from: 0.0);
  }

  // â”€â”€ FCM â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _onFCM(RemoteMessage message) {
    if (!mounted) return;
    final data = message.data;

    if (data['message'] == 'state changed' ||
        data['title'] == 'state changed') {
      _refreshTrip();
    }

    if (data['title'] == 'end' || onGoingStatus == 'end') {
      _endTrip();
    }
  }

  // â”€â”€ Firestore location update handler â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _onDriverLocationUpdate(Map<String, dynamic>? data) {
    if (!mounted || data == null) return;

    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();

    final firestoreStatus = data['on_going_status']?.toString();
    if (firestoreStatus != null && firestoreStatus.isNotEmpty) {
      if (onGoingStatus != firestoreStatus) {
        setState(() {
          onGoingStatus = firestoreStatus;
          tripDetails['on_going_status'] = firestoreStatus;
          if (firestoreStatus == 'start') {
            isInCar = true;
          }
        });
        if (firestoreStatus == 'end') {
          _endTrip();
          return;
        }
      }
    }

    if (lat == null || lng == null) return;

    // â”€â”€ 1. Patch driver coords â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    setState(() {
      tripDetails['driver'] = {
        ...?tripDetails['driver'] as Map?,
        'latitude': lat,
        'longitude': lng,
      };
      _driverBearing = (data['bearing'] as num?)?.toDouble() ?? _driverBearing;
    });

    // â”€â”€ 2. Full smooth marker/polyline/bearing rebuild (runs on EVERY GPS update) â”€â”€
    final driverPos = LatLng(lat, lng);
    _animateDriverTo(driverPos, _driverBearing);

    // â”€â”€ 3. Throttled polyline & ETA recalculation (runs only when moved >= 60m or >= 20s) â”€â”€
    final now = DateTime.now();
    bool shouldRecalcRoute = false;
    if (_lastRouteCalcPos == null || _lastRouteCalcTime == null) {
      shouldRecalcRoute = true;
    } else {
      final distMoved = Geolocator.distanceBetween(
        _lastRouteCalcPos!.latitude,
        _lastRouteCalcPos!.longitude,
        lat,
        lng,
      );
      final elapsed = now.difference(_lastRouteCalcTime!).inSeconds;
      if (distMoved >= 60 || elapsed >= 20) {
        shouldRecalcRoute = true;
      }
    }

    if (shouldRecalcRoute) {
      _lastRouteCalcPos = driverPos;
      _lastRouteCalcTime = now;
      _fetchStreetRoute(driverPos);
    }
  }

  // â”€â”€ Update Trip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _updateTrip(dynamic newDetails) {
    if (!mounted || newDetails == null) return;

    final mainStatus = (newDetails is Trip ? newDetails.status.name : newDetails['status']?.toString() ?? '').toLowerCase();
    if (mainStatus == 'open') {
      _pollStatusTimer?.cancel();
      final tId = _trip?.id ?? int.tryParse(tripDetails['id']?.toString() ?? '') ?? 0;
      final openTrip = (_trip ?? Trip.fromMap(Map<String, dynamic>.from(tripDetails))).copyWith(
        status: TripStatus.open,
        driver: null,
        driverId: null,
        approvedPrice: null,
        onGoingStatus: null,
      );
      TripSecurityService.clearActiveTrip(di.sl<LocalStorage>());
      TripSecurityService.savePendingTrip(di.sl<LocalStorage>(), openTrip);
      showToast(
        text: S.of(context).driverCancelledSearchingNewDriver,
        state: ToastStates.WARNING,
      );
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      context.go(
        AppRoutes.passengerSharedCurrentTrip,
        extra: {'trip_id': tId, 'id': tId, 'trip': openTrip},
      );
      return;
    } else if (mainStatus == 'canceled' || mainStatus == 'closed') {
      _handleTripCancelled();
      return;
    }

    setState(() {
      if (newDetails is Trip) {
        _trip = newDetails;
        tripDetails = newDetails.toJson();
      } else if (newDetails is Map) {
        tripDetails = Map<String, dynamic>.from(newDetails);
        try {
          _trip = Trip.fromMap(Map<String, dynamic>.from(newDetails));
        } catch (_) {}
      }
      onGoingStatus = _trip?.onGoingStatus ??
          tripDetails['on_going_status']?.toString() ??
          onGoingStatus;
      isLoading = false;
    });
    _refreshMarkers();

    if (onGoingStatus == 'start') {
      isInCar = true;
    }

    if (onGoingStatus == 'end') _endTrip();
  }

  void _handleTripCancelled() async {
    _pollStatusTimer?.cancel();
    await di.sl<LocalStorage>().remove(key: 'ongoing_trip');
    await di.sl<LocalStorage>().remove(key: 'trip_id');
    await di.sl<LocalStorage>().remove(key: 'active_trip');
    TripSecurityService.clearActiveTrip(di.sl<LocalStorage>());
    if (!mounted) return;
    showToast(text: S.of(context).tripCanceledByDriver, state: ToastStates.ERROR);
    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
    context.go(AppRoutes.passengerHome);
  }

  void _startStatusPolling() {
    _pollStatusTimer?.cancel();
    _pollStatusTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || isLoading) return;
      final rawTripId = _trip?.id ?? int.tryParse(tripDetails['id']?.toString() ?? '') ?? 0;
      if (rawTripId > 0) {
        PassengerTripsCubit.get(context).refreshTripDetails(rawTripId);
      }
    });
  }

  void _refreshTrip() {
    if (!mounted) return;
    setState(() => isLoading = true);
    PassengerTripsCubit.get(context).refreshTripDetails(
        int.tryParse(tripDetails['id']?.toString() ?? '') ?? 0);
  }

  void _endTrip() async {
    await di.sl<LocalStorage>().remove(key: 'ongoing_trip');
    TripSecurityService.clearActiveTrip(di.sl<LocalStorage>());
    if (!mounted) return;

    final rawTripId = tripDetails['id'] ??
        tripDetails['trip_id'] ??
        tripDetails['trip']?['id'];
    final tripId = int.tryParse(rawTripId?.toString() ?? '') ?? 0;
    final driverId = int.tryParse(tripDetails['driver']?['id']?.toString() ?? '') ??
        int.tryParse(tripDetails['driver_id']?.toString() ?? '') ??
        0;
    final driverName = tripDetails['driver']?['name']?.toString() ?? '';

    if (tripId > 0) {
      context.go(
        AppRoutes.tripRating,
        extra: {
          'trip_id': tripId,
          'target_user_id': driverId,
          'target_user_name': driverName,
          'is_driver': false,
        },
      );
    } else {
      context.go(AppRoutes.passengerHome);
    }
  }

  // â”€â”€ Map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _initLocation() async {
    final svc = await _location.serviceEnabled();
    if (!svc) await _location.requestService();
    final perm = await _location.hasPermission();
    if (perm == PermissionStatus.denied) await _location.requestPermission();

    final pos = await _location.getLocation();
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude!, pos.longitude!),
          zoom: 15,
        ),
      ),
    );
  }

  void _recenterCamera() {
    final fromLat =
        double.tryParse(tripDetails['from_latitude']?.toString() ?? '0') ?? 0.0;
    final fromLng =
        double.tryParse(tripDetails['from_longitude']?.toString() ?? '0') ?? 0.0;
    final toLat =
        double.tryParse(tripDetails['to_latitude']?.toString() ?? '0') ?? 0.0;
    final toLng =
        double.tryParse(tripDetails['to_longitude']?.toString() ?? '0') ?? 0.0;

    double driverLat = _animatedDriverLatLng?.latitude ??
        double.tryParse(tripDetails['driver']?['latitude']?.toString() ?? '') ??
        0.0;
    double driverLng = _animatedDriverLatLng?.longitude ??
        double.tryParse(tripDetails['driver']?['longitude']?.toString() ?? '') ??
        0.0;

    final isInTripPhase = onGoingStatus == 'start';
    final targetLat = isInTripPhase ? toLat : fromLat;
    final targetLng = isInTripPhase ? toLng : fromLng;

    if (driverLat != 0 && targetLat != 0) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              math.min(driverLat, targetLat),
              math.min(driverLng, targetLng),
            ),
            northeast: LatLng(
              math.max(driverLat, targetLat),
              math.max(driverLng, targetLng),
            ),
          ),
          80,
        ),
      );
    } else if (driverLat != 0) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(driverLat, driverLng), 16),
      );
    }
  }

  Future<void> _fetchStreetRoute(LatLng driverPos) async {
    final fromLat = double.tryParse(tripDetails['from_latitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['from_lat']?.toString() ?? '') ??
        _trip?.fromLatitude ??
        0.0;
    final fromLng = double.tryParse(tripDetails['from_longitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['from_lng']?.toString() ?? '') ??
        _trip?.fromLongitude ??
        0.0;
    final toLat = double.tryParse(tripDetails['to_latitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['to_lat']?.toString() ?? '') ??
        _trip?.toLatitude ??
        0.0;
    final toLng = double.tryParse(tripDetails['to_longitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['to_lng']?.toString() ?? '') ??
        _trip?.toLongitude ??
        0.0;

    final isInTripPhase = onGoingStatus == 'start';
    final targetLat = isInTripPhase ? toLat : fromLat;
    final targetLng = isInTripPhase ? toLng : fromLng;

    if (targetLat == 0.0 || targetLng == 0.0) return;

    final targetPos = LatLng(targetLat, targetLng);

    // Calculate distance & ETA
    final distMeters = Geolocator.distanceBetween(
      driverPos.latitude,
      driverPos.longitude,
      targetPos.latitude,
      targetPos.longitude,
    );
    final distKm = distMeters / 1000.0;
    final eta = (distKm / 35.0 * 60).clamp(1, 120).round();

    if (mounted) {
      setState(() {
        _distanceRemainingKm = distKm;
        _etaMinutes = eta;
      });
    }

    try {
      final routeRes = await sl<MapService>().getRoutePolyline(
        from: driverPos,
        to: targetPos,
      );

      final List<LatLng> points = routeRes.fold(
        (_) => [driverPos, targetPos], // Fallback straight line if directions API fails
        (pts) => pts,
      );

      List<LatLng>? tripOverviewPoints = _cachedTripRoutePoints;
      if (tripOverviewPoints == null && fromLat != 0 && toLat != 0) {
        final overviewRes = await sl<MapService>().getRoutePolyline(
          from: LatLng(fromLat, fromLng),
          to: LatLng(toLat, toLng),
        );
        overviewRes.fold((_) {}, (pts) {
          _cachedTripRoutePoints = pts;
          tripOverviewPoints = pts;
        });
      }

      if (!mounted) return;
      setState(() {
        _polylines = {
          if (tripOverviewPoints != null && tripOverviewPoints!.isNotEmpty)
            Polyline(
              polylineId: const PolylineId('trip_dest_route'),
              points: tripOverviewPoints!,
              color: isInTripPhase
                  ? const Color(0xFF05A357)
                  : const Color(0xFF276EF1),
              width: 6,
              jointType: JointType.round,
            ),
          if (!isInTripPhase)
            Polyline(
              polylineId: const PolylineId('driver_active_route'),
              points: points,
              color: const Color(0xFF276EF1).withValues(alpha: 0.7),
              width: 5,
              patterns: [PatternItem.dash(12), PatternItem.gap(6)],
              jointType: JointType.round,
            ),
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('driver_active_route'),
            points: [driverPos, targetPos],
            color: isInTripPhase
                ? const Color(0xFF05A357)
                : const Color(0xFF276EF1),
            width: 6,
          ),
        };
      });
    }
  }

  Future<void> _fetchTripOverviewRoute(LatLng from, LatLng to) async {
    final distMeters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    final distKm = distMeters / 1000.0;
    final eta = (distKm / 35.0 * 60).clamp(1, 120).round();

    if (mounted) {
      setState(() {
        _distanceRemainingKm = distKm;
        _etaMinutes = eta;
      });
    }

    try {
      final routeRes = await sl<MapService>().getRoutePolyline(from: from, to: to);
      routeRes.fold(
        (_) {},
        (points) {
          if (!mounted || _animatedDriverLatLng != null) return;
          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('trip_dest_route'),
                points: points,
                color: const Color(0xFF276EF1),
                width: 6,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
          });
        },
      );
    } catch (_) {}
  }

  void _initMapMarkers() {
    final fromLat = double.tryParse(tripDetails['from_latitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['from_lat']?.toString() ?? '') ??
        _trip?.fromLatitude ??
        0.0;
    final fromLng = double.tryParse(tripDetails['from_longitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['from_lng']?.toString() ?? '') ??
        _trip?.fromLongitude ??
        0.0;
    final toLat = double.tryParse(tripDetails['to_latitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['to_lat']?.toString() ?? '') ??
        _trip?.toLatitude ??
        0.0;
    final toLng = double.tryParse(tripDetails['to_longitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['to_lng']?.toString() ?? '') ??
        _trip?.toLongitude ??
        0.0;

    double driverLat = _animatedDriverLatLng?.latitude ??
        double.tryParse(tripDetails['driver']?['latitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['driver']?['lat']?.toString() ?? '') ??
        0.0;
    double driverLng = _animatedDriverLatLng?.longitude ??
        double.tryParse(tripDetails['driver']?['longitude']?.toString() ?? '') ??
        double.tryParse(tripDetails['driver']?['lng']?.toString() ?? '') ??
        0.0;

    final isInTripPhase = onGoingStatus == 'start';

    // Calculate bearing
    if (driverLat != 0.0 && driverLng != 0.0) {
      final driverPos = LatLng(driverLat, driverLng);
      final targetPos =
          isInTripPhase ? LatLng(toLat, toLng) : LatLng(fromLat, fromLng);
      if (targetPos.latitude != 0.0 && targetPos.longitude != 0.0) {
        _driverBearing = _calculateBearing(driverPos, targetPos);
      }
    }

    setState(() {
      _markers = {
        if (fromLat != 0)
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(fromLat, fromLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
                title: _trip?.fromLocationName.isNotEmpty == true
                    ? _trip!.fromLocationName
                    : (mounted ? S.of(context).pickupLocation : 'Pickup')),
          ),
        if (toLat != 0)
          Marker(
            markerId: const MarkerId('dropoff'),
            position: LatLng(toLat, toLng),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
                title: _trip?.toLocationName.isNotEmpty == true
                    ? _trip!.toLocationName
                    : (mounted ? S.of(context).destination : 'Destination')),
          ),

        if (driverLat != 0)
          Marker(
            markerId: const MarkerId('driver'),
            position: _animatedDriverLatLng ?? LatLng(driverLat, driverLng),
            icon: _carIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            rotation: _animatedDriverBearing != 0.0
                ? _animatedDriverBearing
                : _driverBearing,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(title: mounted ? S.of(context).driverInfo : 'Driver'),
          ),
      };

      // Set initial polylines only if we do not already have a valid curved route loaded
      if (_polylines.isEmpty) {
        if (driverLat != 0 && driverLng != 0) {
          final targetLat = isInTripPhase ? toLat : fromLat;
          final targetLng = isInTripPhase ? toLng : fromLng;
          if (targetLat != 0 && targetLng != 0) {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('driver_active_route'),
                points: [LatLng(driverLat, driverLng), LatLng(targetLat, targetLng)],
                color: isInTripPhase ? const Color(0xFF05A357) : const Color(0xFF276EF1),
                width: 6,
                jointType: JointType.round,
              ),
            };
          }
        } else if (fromLat != 0 && toLat != 0) {
          // Driver coords not yet received -> show route between pickup and dropoff
          _polylines = {
            Polyline(
              polylineId: const PolylineId('trip_dest_route'),
              points: [LatLng(fromLat, fromLng), LatLng(toLat, toLng)],
              color: const Color(0xFF276EF1),
              width: 5,
              jointType: JointType.round,
            ),
          };
        }
      }
    });

    if (driverLat != 0 && driverLng != 0) {
      _fetchStreetRoute(LatLng(driverLat, driverLng));
    } else if (fromLat != 0 && toLat != 0) {
      // Fetch street route for pickup -> destination if driver coords not available yet
      _fetchTripOverviewRoute(LatLng(fromLat, fromLng), LatLng(toLat, toLng));
    }
  }

  void _refreshMarkers() {
    _initMapMarkers();
  }

  // â”€â”€ Arrive Car â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _onArriveCar() {
    try {
      context.read<PassengerTripsCubit>().changePassengerStatus(context,
          tripId: int.tryParse(tripDetails['id']?.toString() ?? '') ?? 0,
          inCar: 1,
          tripDetails: tripDetails as Map<String, dynamic>);
    } catch (e) {
      log('Error changing passenger status: $e', name: 'OngoingSharedTripPassenger');
    }
    if (mounted) {
      setState(() => isInCar = true);
      _refreshTrip();
    }
  }

  double _currentCarSize = 90.0;

  void _onCameraMove(CameraPosition pos) {
    final zoom = pos.zoom;
    final targetSize = (zoom * 5.5).clamp(45.0, 145.0);
    if ((targetSize - _currentCarSize).abs() > 8.0) {
      _currentCarSize = targetSize;
      _updateCarIconSize(_currentCarSize);
    }
  }

  void _updateCarIconSize(double size) async {
    try {
      final icon = await _createCustomCarMarker(
        carColor: const Color(0xFF1B2570),
        width: size,
        height: size,
      );
      if (mounted) {
        setState(() {
          _carIcon = icon;
        });
        _initMapMarkers();
      }
    } catch (e) {
      log('Error updating car icon size: $e', name: 'OngoingSharedTrip');
    }
  }

  Future<void> _loadCarIcon() async {
    _updateCarIconSize(_currentCarSize);
  }

  static Future<BitmapDescriptor> _createCustomCarMarker({
    Color carColor = const Color(0xFF1B2570),
    double width = 90,
    double height = 90,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double cx = width / 2;
    final double cy = height / 2;

    // 1. Soft Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 3), width: 34, height: 66),
      shadowPaint,
    );

    // 2. Main Car Body (Uber-style Top-Down Sedan)
    final Paint bodyPaint = Paint()
      ..color = carColor
      ..style = PaintingStyle.fill;
    final RRect bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 60),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // White Outer Outline
    final Paint outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(bodyRect, outlinePaint);

    // 3. Cabin / Roof
    final Paint cabinPaint = Paint()
      ..color = const Color(0xFF0D1236)
      ..style = PaintingStyle.fill;
    final RRect cabinRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 22, height: 32),
      const Radius.circular(5),
    );
    canvas.drawRRect(cabinRect, cabinPaint);

    // 4. Front Windshield (Glass Tint)
    final Paint windshieldPaint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..style = PaintingStyle.fill;
    final RRect windshield = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 11), width: 18, height: 8),
      const Radius.circular(3),
    );
    canvas.drawRRect(windshield, windshieldPaint);

    // 5. Rear Window
    final RRect rearWindow = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 9), width: 16, height: 6),
      const Radius.circular(2),
    );
    canvas.drawRRect(rearWindow, windshieldPaint);

    // 6. Side Mirrors
    final Paint mirrorPaint = Paint()..color = carColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 17, cy - 13, 4, 7),
        const Radius.circular(2),
      ),
      mirrorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 13, cy - 13, 4, 7),
        const Radius.circular(2),
      ),
      mirrorPaint,
    );

    // 7. Bright LED Headlights (Front direction indicator)
    final Paint headlightPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 9, cy - 28), 2.5, headlightPaint);
    canvas.drawCircle(Offset(cx + 9, cy - 28), 2.5, headlightPaint);

    // 8. Red Taillights
    final Paint taillightPaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(cx - 11, cy + 28, 5, 2), taillightPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 6, cy + 28, 5, 2), taillightPaint);

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  // â”€â”€ Phone â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _callDriver() async {
    final phone = _trip?.driver?.phone ??
        tripDetails['driver']?['mobile']?.toString() ??
        tripDetails['driver']?['phone']?.toString() ??
        '';

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanPhone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context).driverPhoneNotAvailable,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }

    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('Error launching call: $e', name: 'OngoingSharedTrip');
    }
  }

  void _onChat() {
    final String driverName = _trip?.driver?.name.isNotEmpty == true
        ? _trip!.driver!.name
        : (tripDetails['driver']?['name']?.toString() ?? S.of(context).driverDefaultName);
    final String driverPhone = _trip?.driver?.phone?.isNotEmpty == true
        ? _trip!.driver!.phone!
        : (tripDetails['driver']?['mobile']?.toString() ??
            tripDetails['driver']?['phone']?.toString() ??
            '');
    final price = _trip?.approvedPrice ??
        _trip?.minimumPrice ??
        double.tryParse(tripDetails['approved_price']?.toString() ?? '') ??
        double.tryParse(tripDetails['minimum_price']?.toString() ?? '') ??
        0.0;

    final int rawTripId = _trip?.id ?? int.tryParse(tripDetails['id']?.toString() ?? '') ?? 0;
    final groupChatId = ChatChannelHelper.sharedTripGroupChatId(tripId: rawTripId);

    final List<dynamic> membersList = [
      if (_trip?.driver != null)
        _trip!.driver!.toMap()
      else if (tripDetails['driver'] != null)
        tripDetails['driver'],
      if (_trip?.creator != null) {
        ..._trip!.creator!.toMap(),
        'is_creator': true,
      } else if (tripDetails['creator'] != null) {
        if (tripDetails['creator'] is Map) {
          ...tripDetails['creator'],
          'is_creator': true,
        } else {
          tripDetails['creator'],
        }
      },
      if (_trip?.passengers.isNotEmpty == true)
        ..._trip!.passengers.map((p) => p.toMap())
      else if (tripDetails['passengers'] is List)
        ...((tripDetails['passengers'] as List)),
    ];

    final creatorId = _trip?.createdBy ??
        int.tryParse(tripDetails['created_by']?.toString() ?? '') ??
        int.tryParse(tripDetails['creator_id']?.toString() ?? '') ??
        _trip?.creator?.id;

    context.push(
      AppRoutes.tripChat,
      extra: {
        'driverName': driverName,
        'driverPhone': driverPhone,
        'driverPhoto': _trip?.driver?.photo ?? (tripDetails['driver'] is Map ? tripDetails['driver']['photo'] : null),
        'tripFrom': cleanLocationName(_trip?.fromLocationName ?? tripDetails['from_location_name']?.toString() ?? ''),
        'tripTo': cleanLocationName(_trip?.toLocationName ?? tripDetails['to_location_name']?.toString() ?? ''),
        'tripDatetime': _trip?.tripDatetime ?? tripDetails['trip_datetime']?.toString() ?? '',
        'acceptedPrice': price,
        'tripId': rawTripId,
        'offerId': int.tryParse(tripDetails['accepted_offer_id']?.toString() ?? '0') ?? 0,
        'chatId': groupChatId,
        'tripType': 'shared',
        'isInquiry': false,
        'isOffersPhase': false,
        'isDm': false,
        'creatorId': creatorId,
        'members': membersList,
      },
    );
  }

  // â”€â”€ Passenger Cancellation / Withdrawal â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int get _currentUserId {
    final storage = di.sl<LocalStorage>();
    final raw = storage.read(key: 'userid') ??
        storage.read(key: 'user_id') ??
        storage.read(key: 'id');
    if (raw is int && raw > 0) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  bool get _isCreator {
    final creatorId = _trip?.createdBy ??
        int.tryParse(tripDetails['created_by']?.toString() ?? '') ??
        int.tryParse(tripDetails['creator_id']?.toString() ?? '') ??
        _trip?.creator?.id ??
        0;
    return creatorId != 0 && creatorId == _currentUserId;
  }

  List get _passengersList {
    if (_trip?.passengers.isNotEmpty == true) {
      return _trip!.passengers;
    }
    if (tripDetails['passengers'] is List) {
      return tripDetails['passengers'] as List;
    }
    return [];
  }

  List get _otherPassengers {
    final uid = _currentUserId;
    final list = _passengersList;
    return list.where((p) {
      int pid = 0;
      if (p is TripPassenger) {
        pid = p.id;
      } else if (p is Map) {
        pid = int.tryParse(p['id']?.toString() ?? '') ??
            int.tryParse(p['passenger_id']?.toString() ?? '') ??
            int.tryParse(p['user_id']?.toString() ?? '') ??
            int.tryParse(p['passenger']?['id']?.toString() ?? '') ??
            0;
      }
      return pid != 0 && pid != uid;
    }).toList();
  }

  void _cancelTrip() {
    if (!_isCreator) return;
    final intTripId = _trip?.id ??
        widget.tripId ??
        int.tryParse(tripDetails['id']?.toString() ?? '') ??
        int.tryParse(tripDetails['trip_id']?.toString() ?? '') ??
        0;

    if (intTripId == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).cancelSharedTripCompletely,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        content: Text(
          S.of(context).cancelSharedTripConfirmMessage,
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).no, style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              _pollStatusTimer?.cancel();
              _locationSub?.cancel();

              final ok = await context.read<PassengerTripsCubit>().cancelEntireTrip(intTripId);
              if (ok && mounted) {
                showToast(
                  text: S.of(context).orderCanceledSuccessfully,
                  state: ToastStates.SUCESS,
                );
                Navigator.of(context, rootNavigator: true)
                    .popUntil((route) => route.isFirst);
                context.go(AppRoutes.passengerHome);
              }
            },
            child: Text(
              S.of(context).confirmCancelTrip,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Status helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  PassengerSharedTripPhase get _phase {
    switch (onGoingStatus) {
      case 'pending':
        return PassengerSharedTripPhase.driverPending;
      case 'on_the_way':
        if (_distanceRemainingKm > 0 && _distanceRemainingKm <= 0.5) {
          return PassengerSharedTripPhase.driverNear;
        }
        return PassengerSharedTripPhase.driverOnWay;
      case 'close_to_customer':
        return PassengerSharedTripPhase.driverNear;
      case 'arrive_customer':
        return PassengerSharedTripPhase.driverArrived;
      case 'start':
      case 'end':
        return PassengerSharedTripPhase.inTrip;
      default:
        return PassengerSharedTripPhase.driverPending;
    }
  }

  String get _statusTitle {
    switch (_phase) {
      case PassengerSharedTripPhase.driverPending:
        return S.of(context).waitingDriverStartMoving;
      case PassengerSharedTripPhase.driverOnWay:
        return S.of(context).driverOnTheWay;
      case PassengerSharedTripPhase.driverNear:
        return S.of(context).driverIsNear;
      case PassengerSharedTripPhase.driverArrived:
        return S.of(context).driverArrived;
      case PassengerSharedTripPhase.inTrip:
        return S.of(context).tripInProgress;
    }
  }

  String get _statusSubtitle {
    switch (_phase) {
      case PassengerSharedTripPhase.driverPending:
        return S.of(context).driverApprovedWaitingMovement;
      case PassengerSharedTripPhase.driverOnWay:
        return S.of(context).driverComingToPickYouUp;
      case PassengerSharedTripPhase.driverNear:
        return S.of(context).driverAlmostThere;
      case PassengerSharedTripPhase.driverArrived:
        return S.of(context).driverWaitingForYou;
      case PassengerSharedTripPhase.inTrip:
        return S.of(context).enjoyYourTrip;
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case PassengerSharedTripPhase.driverPending:
        return const Color(0xFF6B7280);
      case PassengerSharedTripPhase.driverOnWay:
        return const Color(0xFF276EF1);
      case PassengerSharedTripPhase.driverNear:
        return const Color(0xFFF5A623);
      case PassengerSharedTripPhase.driverArrived:
        return const Color(0xFF05A357);
      case PassengerSharedTripPhase.inTrip:
        return AppColors.primary;
    }
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerTripsCubit, PassengerTripsState>(
      listener: (context, state) {
        if (state is PassengerTripDetailsLoaded) {
          _updateTrip(state.trip.toJson());
        }
      },
      bloc: PassengerTripsCubit.get(context),
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // â”€â”€ 1. Fullscreen Map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Positioned.fill(
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    initialCameraPosition:
                        PassengerOngoingSharedTripView._kDefaultCamera,
                    markers: _markers,
                    polylines: _polylines,
                    padding: EdgeInsets.only(
                        bottom: _isSheetCollapsed ? 120 : 390, top: 100),
                    onMapCreated: (ctrl) {
                      _mapController = ctrl;
                      AppMapStyle.applyStyle(ctrl);
                      _initMapMarkers();
                    },
                    onCameraMove: _onCameraMove,
                  ),
                ),

                // â”€â”€ 2. Top Status Bar with ETA & Distance â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: PassengerSharedTopBar(
                    phase: _phase,
                    phaseColor: _phaseColor,
                    title: _statusTitle,
                    subtitle: _statusSubtitle,
                    pulseAnim: _pulseAnim,
                    etaMinutes: _etaMinutes,
                    distanceRemainingKm: _distanceRemainingKm,
                    onRefresh: _refreshTrip,
                  ),
                ),

                // â”€â”€ 2.5 Recenter Button ðŸŽ¯ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Positioned(
                  bottom: _isSheetCollapsed ? 140 : 230,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_passenger_shared',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 4,
                    onPressed: _recenterCamera,
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),

                // â”€â”€ 3. Bottom Driver Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.15,
                  maxChildSize: 0.85,
                  snap: false,
                  builder: (context, scrollController) {
                    return SlideTransition(
                      position: _sheetAnim,
                      child: _DriverBottomSheet(
                        trip: _trip,
                        scrollController: scrollController,
                        tripDetails: tripDetails,
                        phase: _phase,
                        phaseColor: _phaseColor,
                        isInCar: isInCar,
                        isLoading: isLoading,
                        isCreator: _isCreator,
                        onArriveCar: _onArriveCar,
                        onCallDriver: _callDriver,
                        onChatDriver: _onChat,
                        onRefresh: _refreshTrip,
                        onCancelTrip: _cancelTrip,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Driver Bottom Sheet
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DriverBottomSheet extends StatelessWidget {
  const _DriverBottomSheet({
    this.trip,
    required this.tripDetails,
    required this.phase,
    required this.phaseColor,
    required this.isInCar,
    required this.isLoading,
    required this.isCreator,
    required this.onArriveCar,
    required this.onCallDriver,
    required this.onChatDriver,
    required this.onRefresh,
    required this.onCancelTrip,
    this.scrollController,
  });

  final Trip? trip;
  final Map tripDetails;
  final PassengerSharedTripPhase phase;
  final Color phaseColor;
  final bool isInCar;
  final bool isLoading;
  final bool isCreator;
  final VoidCallback onArriveCar;
  final VoidCallback onCallDriver;
  final VoidCallback onChatDriver;
  final VoidCallback onRefresh;
  final VoidCallback onCancelTrip;
  final ScrollController? scrollController;

  String get _driverName {
    if (trip?.driver?.name.isNotEmpty == true) return trip!.driver!.name;
    if (tripDetails['driver'] is Map && tripDetails['driver']['name'] != null) {
      return tripDetails['driver']['name'].toString();
    }
    if (tripDetails['driver_name'] != null &&
        tripDetails['driver_name'].toString().isNotEmpty) {
      return tripDetails['driver_name'].toString();
    }
    return '---';
  }

  String? get _driverRating {
    if (trip?.driver?.rating?.isNotEmpty == true) return trip!.driver!.rating;
    if (trip?.driver?.ratingAvg != null) {
      return trip!.driver!.ratingAvg!.toStringAsFixed(1);
    }
    if (tripDetails['driver'] is Map) {
      final r = tripDetails['driver']['rating'] ??
          tripDetails['driver']['rating_avg'];
      if (r != null) return r.toString();
    }
    return null;
  }

  String get _carModel {
    if (trip?.driver?.car?.model.isNotEmpty == true) {
      return trip!.driver!.car!.model;
    }
    if (tripDetails['driver'] is Map && tripDetails['driver']['car'] is Map) {
      return tripDetails['driver']['car']['model']?.toString() ?? '';
    }
    if (tripDetails['car_model'] != null) {
      return tripDetails['car_model'].toString();
    }
    return '';
  }

  String get _plateNumber {
    if (trip?.driver?.car?.plateNumber.isNotEmpty == true) {
      return trip!.driver!.car!.plateNumber;
    }
    if (tripDetails['driver'] is Map && tripDetails['driver']['car'] is Map) {
      return tripDetails['driver']['car']['plate_number']?.toString() ?? '';
    }
    if (tripDetails['plate_number'] != null) {
      return tripDetails['plate_number'].toString();
    }
    return '';
  }

  String get _price {
    final p = trip?.approvedPrice ??
        trip?.minimumPrice ??
        double.tryParse(tripDetails['approved_price']?.toString() ?? '') ??
        double.tryParse(tripDetails['price']?.toString() ?? '');
    return p != null ? p.toStringAsFixed(2) : '---';
  }

  String get _from =>
      trip?.fromLocationName ??
      tripDetails['from_location_name']?.toString() ??
      '';
  String get _to =>
      trip?.toLocationName ??
      tripDetails['to_location_name']?.toString() ??
      '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Steps
                  PassengerSharedStatusSteps(
                      phase: phase, phaseColor: phaseColor),
                  const SizedBox(height: 20),

                  // Passengers Roster Card
                  PassengerSharedPassengersRosterCard(
                    passengers: trip?.passengers.isNotEmpty == true
                        ? trip!.passengers
                        : ((tripDetails['passengers'] as List?) ?? []),
                    totalSeats: trip?.totalSeats ??
                        int.tryParse(
                            tripDetails['total_seats']?.toString() ??
                                tripDetails['seats']?.toString() ??
                                tripDetails['number_of_seats']?.toString() ??
                                '4') ??
                        4,
                  ),
                  const SizedBox(height: 16),

                  // Driver Card
                  PassengerSharedDriverCard(
                    driverName: _driverName,
                    rating: _driverRating,
                    carModel: _carModel,
                    plateNumber: _plateNumber,
                    onCall: onCallDriver,
                    onChat: onChatDriver,
                  ),
                  const SizedBox(height: 16),

                  // Route
                  PassengerPrivateRouteRow(from: _from, to: _to),
                  const SizedBox(height: 16),

                  // Price
                  PassengerPrivatePriceCard(price: _price),
                  const SizedBox(height: 20),

                  // Action Button
                  PassengerSharedActionButton(
                    phase: phase,
                    phaseColor: phaseColor,
                    isInCar: isInCar,
                    isLoading: isLoading,
                    onArriveCar: onArriveCar,
                  ),

                  // Cancel Button (Only for Trip Owner/Creator before inTrip phase)
                  if (isCreator &&
                      phase != PassengerSharedTripPhase.inTrip) ...[
                    const SizedBox(height: 12),
                    PassengerCancelSharedTripButton(
                      isLoading: isLoading,
                      onCancelTrip: onCancelTrip,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

