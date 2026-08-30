import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/services/driver_location_tracker_service.dart';
import 'package:car_app/core/services/firebase_trip_location_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/offline_connectivity_banner.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_trips_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Ongoing Private Trip Tracking Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverOngoingPrivateTripScreenClean extends StatefulWidget {
  final Trip? trip;
  final int? tripId;
  final dynamic tripDetails;

  const DriverOngoingPrivateTripScreenClean({
    super.key,
    this.trip,
    this.tripId,
    this.tripDetails,
  });

  static const CameraPosition _kDefaultCamera = CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 15,
  );

  @override
  State<DriverOngoingPrivateTripScreenClean> createState() =>
      _DriverOngoingPrivateTripScreenCleanState();
}

class _DriverOngoingPrivateTripScreenCleanState
    extends State<DriverOngoingPrivateTripScreenClean>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _carIcon;
  double _driverBearing = 0.0;

  // Driver's current location (used to redraw route when status changes)
  LatLng? _currentDriverLatLng;
  LatLng? _lastRouteCalcPos;
  DateTime? _lastRouteCalcTime;

  // ── Firestore location broadcasting ──────────────────────────────────────
  final FirebaseTripLocationService _locationService =
      FirebaseTripLocationService();
  StreamSubscription<Map<String, dynamic>>? _gpsSub;

  Trip? _trip;
  Map tripDetails = {};
  String onGoingStatus = 'on_the_way'; // on_the_way / arrive_customer / start / end

  int _etaMinutes = 0;
  double _distanceRemainingKm = 0.0;

  late AnimationController _sheetCtrl;
  late Animation<Offset> _sheetAnim;

  // ── Deep-link loading state ───────────────────────────────────────────────
  bool _isFetchingTrip = false;
  String? _fetchError;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadCarIcon();

    if (widget.trip != null) {
      // Approach A: entity already provided — convert to map for local usage
      _trip = widget.trip;
      tripDetails = widget.trip!.toJson();
      _initFromTripDetails();
    } else {
      // Approach B: deep-link / FCM cold start — fetch by ID then init
      int? effectiveTripId = widget.tripId;
      if (effectiveTripId == null) {
        try {
          final storage = sl<LocalStorage>();
          final saved = storage.read(key: 'ongoing_trip') ?? storage.read(key: 'trip_id');
          if (saved is Map) {
            effectiveTripId = int.tryParse(saved['id']?.toString() ?? '');
          } else if (saved != null) {
            effectiveTripId = int.tryParse(saved.toString());
          }
        } catch (_) {}
      }

      if (effectiveTripId != null && effectiveTripId > 0) {
        setState(() => _isFetchingTrip = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<DriverTripsCubit>().refreshTripDetails(effectiveTripId!);
        });
      } else {
        setState(() {
          _fetchError = S.of(context).tripUnavailableOrDeleted;
          _isFetchingTrip = false;
        });
      }
    }

    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sheetAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));
  }

  Future<void> _loadCarIcon() async {
    try {
      final icon = await _createCustomCarMarker();
      if (mounted) {
        setState(() => _carIcon = icon);
      }
    } catch (_) {}
  }

  static Future<BitmapDescriptor> _createCustomCarMarker({
    Color carColor = const Color(0xFF1B2570),
    double width = 85,
    double height = 85,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double cx = width / 2;
    final double cy = height / 2;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 3), width: 34, height: 66),
      shadowPaint,
    );

    final Paint bodyPaint = Paint()..color = carColor..style = PaintingStyle.fill;
    final RRect bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 60),
      const Radius.circular(10),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    final Paint outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(bodyRect, outlinePaint);

    final Paint cabinPaint = Paint()..color = const Color(0xFF0D1236)..style = PaintingStyle.fill;
    final RRect cabinRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 22, height: 32),
      const Radius.circular(5),
    );
    canvas.drawRRect(cabinRect, cabinPaint);

    final Paint windshieldPaint = Paint()..color = const Color(0xFF64B5F6)..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - 11), width: 18, height: 8), const Radius.circular(3)),
      windshieldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + 9), width: 16, height: 6), const Radius.circular(2)),
      windshieldPaint,
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  void _initFromTripDetails() {
    onGoingStatus = _trip?.onGoingStatus ?? 'on_the_way';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMapAndLocation();
      _sheetCtrl.forward();
      _startLocationBroadcast();
    });
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _sheetCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Firestore GPS broadcast ──────────────────────────────────────────────

  void _startLocationBroadcast() {
    final storage = sl<LocalStorage>();
    final details = Map<String, dynamic>.from(tripDetails);
    details['is_driver'] = true;
    details['on_going_status'] = onGoingStatus;

    DriverLocationTrackerService.instance.startTracking(
      trip: _trip,
      tripDetails: details,
      storage: storage,
    );

    _gpsSub?.cancel();
    _gpsSub = DriverLocationTrackerService.instance.onLocationUpdate.listen((data) {
      if (!mounted) return;
      final lat = (data['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
      final bearing = (data['bearing'] as num?)?.toDouble() ?? _driverBearing;
      final autoStatus = data['on_going_status']?.toString();

      if (lat != 0.0 && lng != 0.0) {
        final bool passengerOnBoard = onGoingStatus == 'start' || onGoingStatus == 'end';
        final targetLat = passengerOnBoard ? (_trip?.toLatitude ?? 0.0) : (_trip?.fromLatitude ?? 0.0);
        final targetLng = passengerOnBoard ? (_trip?.toLongitude ?? 0.0) : (_trip?.fromLongitude ?? 0.0);
        double distKm = _distanceRemainingKm;
        int eta = _etaMinutes;
        if (targetLat != 0.0 && targetLng != 0.0) {
          final distMeters = Geolocator.distanceBetween(lat, lng, targetLat, targetLng);
          distKm = distMeters / 1000.0;
          eta = (distKm / 35.0 * 60).clamp(1, 120).round();
        }

        setState(() {
          _currentDriverLatLng = LatLng(lat, lng);
          _driverBearing = bearing;
          _distanceRemainingKm = distKm;
          _etaMinutes = eta;
          // Live update driver marker on map with rotation
          _markers = {
            for (final m in _markers)
              if (m.markerId.value != 'driver') m,
            Marker(
              markerId: const MarkerId('driver'),
              position: LatLng(lat, lng),
              icon: _carIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              rotation: _driverBearing,
              anchor: const Offset(0.5, 0.5),
              infoWindow: InfoWindow(title: mounted ? S.of(context).currentLocationFallback : 'My Location'),
            ),
          };
        });

        // Throttled real-street route recalculation as driver drives along the road
        final driverPos = LatLng(lat, lng);
        final now = DateTime.now();
        if (_lastRouteCalcPos == null ||
            now.difference(_lastRouteCalcTime ?? DateTime(0)).inSeconds >= 25 ||
            Geolocator.distanceBetween(_lastRouteCalcPos!.latitude, _lastRouteCalcPos!.longitude, lat, lng) >= 60) {
          _lastRouteCalcPos = driverPos;
          _lastRouteCalcTime = now;
          _buildMarkersAndRoute(driverPos);
        }
      }

      // Handle automatic geofence status transitions
      if (autoStatus != null && autoStatus.isNotEmpty && autoStatus != onGoingStatus) {
        if (autoStatus == 'end') {
          _updateStatus('end');
        } else {
          setState(() {
            onGoingStatus = autoStatus;
            tripDetails['on_going_status'] = autoStatus;
          });
        }
      }
    });
  }

  void _recenterCamera() {
    if (_currentDriverLatLng != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentDriverLatLng!,
            zoom: 16.5,
            tilt: 45.0,
            bearing: _driverBearing,
          ),
        ),
      );
    }
  }

  /// Entry point: get current location then draw everything.
  Future<void> _initMapAndLocation() async {
    final mapService = sl<MapService>();

    // 1. Get current driver location
    final locationResult = await mapService.getCurrentLocation();
    locationResult.fold(
      (failure) {
        // If we can't get location, still draw markers with trip coords
        _buildMarkersAndRoute(null);
      },
      (latLng) {
        if (mounted) setState(() => _currentDriverLatLng = latLng);
        // Move camera to driver's actual position first
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15),
          ),
        );
        _buildMarkersAndRoute(latLng);
      },
    );
  }

  /// Draw markers and fetch real route polyline based on trip phase.
  Future<void> _buildMarkersAndRoute(LatLng? driverLatLng) async {
    final pickupLat = _trip?.fromLatitude ?? 0.0;
    final pickupLng = _trip?.fromLongitude ?? 0.0;
    final destLat = _trip?.toLatitude ?? 0.0;
    final destLng = _trip?.toLongitude ?? 0.0;

    if (pickupLat == 0.0 && destLat == 0.0) return;

    final pickupPos = LatLng(pickupLat, pickupLng);
    final destPos = LatLng(destLat, destLng);
    final bool passengerOnBoard = onGoingStatus == 'start' || onGoingStatus == 'end';

    // Origin and destination for the active navigation route:
    final LatLng routeOrigin = driverLatLng ?? (passengerOnBoard ? pickupPos : pickupPos);
    final LatLng routeDestination = passengerOnBoard ? destPos : pickupPos;

    // Calculate distance & ETA
    final distMeters = Geolocator.distanceBetween(
      routeOrigin.latitude,
      routeOrigin.longitude,
      routeDestination.latitude,
      routeDestination.longitude,
    );
    final distKm = distMeters / 1000.0;
    final eta = (distKm / 35.0 * 60).clamp(1, 120).round();

    // Build markers
    final markers = <Marker>{
      // Pickup marker (always visible before boarding)
      if (!passengerOnBoard)
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickupPos,
          infoWindow: InfoWindow(
              title: cleanLocationName(_trip?.fromLocationName ?? '').isNotEmpty ? cleanLocationName(_trip!.fromLocationName) : (mounted ? S.of(context).pickupPoint : 'Pickup')),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      // Destination marker (always visible)
      Marker(
        markerId: const MarkerId('destination'),
        position: destPos,
        infoWindow: InfoWindow(
            title: cleanLocationName(_trip?.toLocationName ?? '').isNotEmpty ? cleanLocationName(_trip!.toLocationName) : (mounted ? S.of(context).destinationPoint : 'Destination')),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      // Driver marker (current location)
      if (driverLatLng != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLatLng,
          infoWindow: InfoWindow(title: mounted ? S.of(context).currentLocationFallback : 'My Location'),
          icon: _carIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          rotation: _driverBearing,
          anchor: const Offset(0.5, 0.5),
        ),
    };

    // Fetch real route from Google Directions API between pickup and destination ALWAYS
    final mapService = sl<MapService>();
    final routeResult = await mapService.getRoutePolyline(
      from: pickupPos,
      to: destPos,
    );

    final List<LatLng> tripRoutePoints = routeResult.fold(
      (_) => [pickupPos, destPos],
      (points) => points,
    );

    // If driver is on the way to pickup, also fetch approach route
    List<LatLng>? driverApproachPoints;
    if (!passengerOnBoard && driverLatLng != null) {
      final approachRes = await mapService.getRoutePolyline(
        from: driverLatLng,
        to: pickupPos,
      );
      driverApproachPoints = approachRes.fold(
        (_) => [driverLatLng, pickupPos],
        (pts) => pts,
      );
    }

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('trip_main_route'),
        points: tripRoutePoints,
        color: passengerOnBoard ? const Color(0xFF05A357) : const Color(0xFF276EF1),
        width: 6,
        jointType: JointType.round,
      ),
      if (driverApproachPoints != null && driverApproachPoints.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('driver_approach_route'),
          points: driverApproachPoints,
          color: const Color(0xFF276EF1).withValues(alpha: 0.7),
          width: 5,
          patterns: [PatternItem.dash(12), PatternItem.gap(6)],
          jointType: JointType.round,
        ),
    };

    if (mounted) {
      setState(() {
        _markers = markers;
        _polylines = polylines;
        _distanceRemainingKm = distKm;
        _etaMinutes = eta;
      });
      _fitBounds(pickupPos, destPos);
    }
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    final southWest = LatLng(
      math.min(p1.latitude, p2.latitude),
      math.min(p1.longitude, p2.longitude),
    );
    final northEast = LatLng(
      math.max(p1.latitude, p2.latitude),
      math.max(p1.longitude, p2.longitude),
    );
    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_isUpdatingStatus) return;
    final tripId = _trip?.id ?? 0;

    // ── GEOFENCING VALIDATION ──────────────────────────────────────────
    if (newStatus == 'arrive_customer') {
      final pickupLat = _trip?.fromLatitude ?? 0.0;
      final pickupLng = _trip?.fromLongitude ?? 0.0;

      if (_currentDriverLatLng != null && pickupLat != 0.0 && pickupLng != 0.0) {
        final geo = TripSecurityService.validateGeofence(
          driverLat: _currentDriverLatLng!.latitude,
          driverLng: _currentDriverLatLng!.longitude,
          pickupLat: pickupLat,
          pickupLng: pickupLng,
          maxDistanceMeters: 200.0,
        );
        if (!(geo['isValid'] as bool)) {
          final dist = (geo['distanceMeters'] as double).round();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context).distanceToPickupNotice(dist),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: Colors.red[800],
              ),
            );
          }
          return;
        }
      }
    }

    setState(() {
      _isUpdatingStatus = true;
      onGoingStatus = newStatus;
      tripDetails['on_going_status'] = newStatus;
    });

    final storage = sl<LocalStorage>();
    final tripIdStr = (_trip?.id ?? 0).toString();

    try {
      if (newStatus == 'end') {
        _gpsSub?.cancel();
        try {
          await DriverLocationTrackerService.instance.stopTracking(storage);
        } catch (_) {}
        TripSecurityService.clearActiveTrip(storage);
        await storage.remove(key: 'ongoing_trip');
        await storage.remove(key: 'trip_id');
        await storage.remove(key: 'active_trip');
        await storage.remove(key: 'ongoing_trip_${tripId}_status');
        await storage.remove(key: 'ongoing_trip_$tripId');
        await storage.remove(key: 'ongoing_trip_${tripIdStr}_status');
        await storage.remove(key: 'ongoing_trip_$tripIdStr');

        if (tripIdStr.isNotEmpty) {
          try {
            await _locationService.updateTripStatus(tripId: tripIdStr, onGoingStatus: 'end');
            _locationService.stopTripLocation(tripIdStr);
          } catch (_) {}
        }

        if (tripId > 0) {
          try {
            await sl<DriverTripsCubit>().changeTripStatusOnGoingTrip(
              tripId: tripId,
              status: 'completed',
              onGoingStatus: 'end',
            );
          } catch (e) {
            log('Error updating trip status: $e', name: 'OngoingPrivateTripDriver');
          }
          try {
            await sl<DriverAddPrivateTripCubit>().changePassengerStatus(
              context: null,
              trip_id: tripId,
              PassState: 'end',
              in_car: 1,
            );
          } catch (_) {}
        }

        if (mounted) {
          try {
            DriverLayoutCubit.get(context).changeBottomScreen(1); // 1 = Trips (صفحة الرحلات)
          } catch (_) {}
          showToast(
            text: S.of(context).tripEndedSuccess,
            state: ToastStates.SUCESS,
          );
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
          context.go(AppRoutes.driverHome, extra: 1);
        }
        return;
      }

      // Tracking updates for intermediate phases:
      final details = Map<String, dynamic>.from(tripDetails);
      details['is_driver'] = true;
      details['on_going_status'] = newStatus;
      DriverLocationTrackerService.instance.startTracking(
        trip: _trip,
        tripDetails: details,
        storage: storage,
      );

      _buildMarkersAndRoute(_currentDriverLatLng);

      if (tripIdStr.isNotEmpty) {
        _locationService.updateTripStatus(tripId: tripIdStr, onGoingStatus: newStatus);
      }

      if (tripId > 0) {
        await sl<DriverTripsCubit>().changeTripStatusOnGoingTrip(
          tripId: tripId,
          status: 'accepted',
          onGoingStatus: newStatus,
        );
      }

      final cubit = sl<DriverAddPrivateTripCubit>();
      if (newStatus == 'arrive_customer') {
        await cubit.changePassengerStatus(
          context: null,
          trip_id: tripId,
          PassState: 'arrive_customer',
          in_car: 0,
        );
      } else if (newStatus == 'start') {
        await cubit.changePassengerStatus(
          context: null,
          trip_id: tripId,
          PassState: 'start',
          in_car: 1,
        );
      }
    } catch (e) {
      log('Error updating status: $e', name: 'OngoingPrivateTrip');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  void _showCancelByDriverDialog() {
    final tripId = _trip?.id ?? 0;
    if (tripId == 0) return;

    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).tripCancelledByDriver,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.red[700]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).tripCancelledByDriverConfirm,
              style: GoogleFonts.cairo(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                hintText: S.of(context).cancellationReasonOptional,
                hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[400]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
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
              await sl<DriverTripsCubit>()
                  .cancelPickup(tripId, reason: reasonCtrl.text.trim());
              if (mounted) {
                showToast(
                  text: S.of(context).tripCancelledAndReturnedToPassenger,
                  state: ToastStates.SUCESS,
                );
                Navigator.of(context, rootNavigator: true)
                    .popUntil((route) => route.isFirst);
                context.go(AppRoutes.driverHome);
              }
            },
            child: Text(
              S.of(context).confirmCancel,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }


  void _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle deep-link (Approach B): listen for DriverTripDetailsLoaded and init screen
    return BlocConsumer<DriverTripsCubit, DriverTripsState>(
      listener: (context, state) {
        if (state is DriverTripDetailsLoaded && _isFetchingTrip) {
          setState(() {
            tripDetails = state.trip.toJson();
            _isFetchingTrip = false;
            _fetchError = null;
          });
          _initFromTripDetails();
        } else if (state is DriverTripsError && _isFetchingTrip) {
          setState(() {
            _fetchError = state.message;
            _isFetchingTrip = false;
          });
        }
      },
      builder: (context, state) {
        if (_isFetchingTrip) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (_fetchError != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_fetchError!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DriverTripsCubit>().refreshTripDetails(widget.tripId ?? 0),
                    child: Text(S.of(context).retry),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildTripBody(context);
      },
    );
  }

  Widget _buildTripBody(BuildContext context) {
    final tripId = _trip?.id ?? 0;
    final passengerName = _trip?.creator?.name.isNotEmpty == true
        ? _trip!.creator!.name
        : S.of(context).passenger;
    final passengerPhoto = ApiEndpoints.buildImageUrl(_trip?.creator?.photo);
    final passengerPhone = _trip?.creator?.phone ?? '';
    final approvedPrice = _trip?.approvedPrice?.toStringAsFixed(2) ?? _trip?.maximumPrice.toStringAsFixed(2) ?? '--';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.primary, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
            ],
          ),
          child: Text(
            S.of(context).trackPrivateTrip,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition:
                DriverOngoingPrivateTripScreenClean._kDefaultCamera,
            onMapCreated: (c) {
              _mapController = c;
              AppMapStyle.applyStyle(c);
            },
            markers: _markers,
            polylines: _polylines,
          ),

          // Offline connectivity indicator banner (P3-2)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: OfflineConnectivityBanner()),
          ),

          // Status Header Pill & ETA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
              child: _DriverStatusPill(
                status: onGoingStatus,
                etaMinutes: _etaMinutes,
                distanceRemainingKm: _distanceRemainingKm,
              ),
            ),
          ),

          // Recenter Button 🎯
          Positioned(
            bottom: 150,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'recenter_driver_private',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              onPressed: _recenterCamera,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // Draggable Bottom Sheet Panel
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.16,
            maxChildSize: 0.88,
            snap: false,
            builder: (context, scrollController) {
              return SlideTransition(
                position: _sheetAnim,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Passenger Card Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              backgroundImage: appCachedImageProvider(passengerPhoto),
                              child: (passengerPhoto == null || passengerPhoto.isEmpty)
                                  ? const Icon(Icons.person,
                                      color: AppColors.primary, size: 28)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    passengerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _CircleAction(
                                  icon: Icons.phone,
                                  color: Colors.green,
                                  onTap: () => _makeCall(passengerPhone),
                                ),
                                const SizedBox(width: 6),
                                Builder(
                                  builder: (context) {
                                    final driverId = _trip?.driverId ??
                                        _trip?.driver?.id ??
                                        int.tryParse(sl<LocalStorage>().read(key: 'userid')?.toString() ?? '') ??
                                        0;
                                    final chatId = ChatChannelHelper.privateTripChatId(
                                      tripId: _trip?.id ?? widget.tripId ?? 0,
                                      driverId: driverId,
                                    );

                                    return UnreadBadge(
                                      chatId: chatId,
                                      currentUserId: driverId.toString(),
                                      child: _CircleAction(
                                        icon: Icons.chat_bubble_outline,
                                        color: AppColors.primary,
                                        onTap: () {
                                          navigateTo(
                                            context,
                                            TripChatScreenClean(
                                              driverName: passengerName,
                                              driverPhone: passengerPhone,
                                              tripFrom: cleanLocationName(_trip?.fromLocationName ?? ''),
                                              tripTo: cleanLocationName(_trip?.toLocationName ?? ''),
                                              tripDatetime: _trip?.tripDatetime ?? '',
                                              acceptedPrice: _trip?.approvedPrice ?? _trip?.minimumPrice ?? 0.0,
                                              tripId: _trip?.id ?? widget.tripId ?? 0,
                                              offerId: 0,
                                              driverId: driverId,
                                              chatId: chatId,
                                              tripType: 'private',
                                              members: [
                                                if (_trip?.creator != null) _trip!.creator!.toMap(),
                                                if (_trip?.driver != null) _trip!.driver!.toMap(),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                _CircleAction(
                                  icon: Icons.cancel_outlined,
                                  color: Colors.red[700]!,
                                  onTap: _showCancelByDriverDialog,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Route Row
                        Row(
                          children: [
                            const Icon(Icons.trip_origin,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (cleanLocationName(_trip?.fromLocationName ?? '').isNotEmpty ? cleanLocationName(_trip!.fromLocationName) : S.of(context).pickupPoint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_forward,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            const Icon(Icons.flag_rounded,
                                color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (_trip?.toLocationName.isNotEmpty == true ? _trip!.toLocationName : S.of(context).destinationPoint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Fare Row
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payments_outlined,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${S.of(context).price}: $approvedPrice ${S.of(context).jod}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Driver Main Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isUpdatingStatus
                                ? null
                                : () {
                                    if (onGoingStatus == 'pending') {
                                      _updateStatus('on_the_way');
                                    } else if (onGoingStatus == 'on_the_way') {
                                      _updateStatus('close_to_customer');
                                    } else if (onGoingStatus == 'close_to_customer') {
                                      _updateStatus('arrive_customer');
                                    } else if (onGoingStatus == 'arrive_customer') {
                                      _updateStatus('start');
                                    } else if (onGoingStatus == 'start') {
                                      _updateStatus('end');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: onGoingStatus == 'start'
                                  ? Colors.green.shade600
                                  : AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isUpdatingStatus
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    _getActionButtonText(context, onGoingStatus),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getActionButtonText(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return S.of(context).startMovingToClient;
      case 'on_the_way':
        return S.of(context).nearClientLocation;
      case 'close_to_customer':
        return S.of(context).confirmArrivalAtClient;
      case 'arrive_customer':
        return S.of(context).startPrivateTripAction;
      case 'start':
        return S.of(context).endPrivateTripAction;
      case 'end':
      default:
        return S.of(context).tripCompleted;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Header Pill
// ─────────────────────────────────────────────────────────────────────────────
class _DriverStatusPill extends StatelessWidget {
  final String status;
  final int etaMinutes;
  final double distanceRemainingKm;

  const _DriverStatusPill({
    required this.status,
    this.etaMinutes = 0,
    this.distanceRemainingKm = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case 'pending':
        text = S.of(context).startMovingToClient;
        color = Colors.blue.shade700;
        break;
      case 'on_the_way':
        text = S.of(context).nearClientLocation;
        color = AppColors.primary;
        break;
      case 'close_to_customer':
        text = S.of(context).confirmArrivalAtClient;
        color = Colors.amber.shade800;
        break;
      case 'arrive_customer':
        text = S.of(context).confirmArrivalAtClient;
        color = Colors.orange.shade800;
        break;
      case 'start':
        text = S.of(context).startPrivateTripAction;
        color = Colors.green.shade700;
        break;
      case 'end':
        text = S.of(context).tripCompleted;
        color = Colors.grey.shade700;
        break;
      default:
        text = S.of(context).trackPrivateTrip;
        color = AppColors.primary;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (distanceRemainingKm > 0 || etaMinutes > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  S.of(context).minutesCount(etaMinutes),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey.shade400)),
                const SizedBox(width: 8),
                Icon(Icons.navigation_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  S.of(context).kmDistance(distanceRemainingKm.toStringAsFixed(1)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}
