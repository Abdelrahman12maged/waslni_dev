import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/services/driver_location_tracker_service.dart';
import 'package:car_app/core/services/firebase_trip_location_service.dart';
import 'package:car_app/core/storage/local_storage.dart';
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
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/features/home/presentation/cubit/driver_layout_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Ongoing Shared Trip Tracking Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverOngoingSharedTripScreenClean extends StatefulWidget {
  /// Typed trip entity — provided when navigating from the trips list screen.
  final Trip? trip;

  /// Trip ID — provided when launched via FCM notification (cold start / app terminated).
  final int? tripId;

  const DriverOngoingSharedTripScreenClean({
    super.key,
    this.trip,
    this.tripId,
  });

  static const CameraPosition _kDefaultCamera = CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 15,
  );

  @override
  State<DriverOngoingSharedTripScreenClean> createState() =>
      _DriverOngoingSharedTripScreenCleanState();
}

class _DriverOngoingSharedTripScreenCleanState
    extends State<DriverOngoingSharedTripScreenClean>
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
  String onGoingStatus = 'on_the_way';

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
    final fromLat = _trip?.fromLatitude ?? 0.0;
    final fromLng = _trip?.fromLongitude ?? 0.0;
    final toLat = _trip?.toLatitude ?? 0.0;
    final toLng = _trip?.toLongitude ?? 0.0;

    final pickupPos = LatLng(fromLat, fromLng);
    final destPos = LatLng(toLat, toLng);

    // Determine phase: before pickup → route to passenger; after → route to destination
    final bool passengerOnBoard =
        onGoingStatus == 'start' || onGoingStatus == 'end';

    // Route origin: driver's current location if available, else pickup point
    final LatLng routeOrigin = driverLatLng ?? pickupPos;
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
            title: cleanLocationName(_trip?.toLocationName ?? '').isNotEmpty ? cleanLocationName(_trip!.toLocationName) : S.of(context).destinationPoint),
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
      (_) => [pickupPos, destPos], // fallback straight line
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

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        80,
      ),
    );
  }

  // ── Status updates ────────────────────────────────────────────────────────

  Future<void> _updateStatus(String newStatus) async {
    if (_isUpdatingStatus) return;
    final tripId = _trip?.id ?? 0;

    // 1. Geofence Validation (200m) for arrive_customer
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
            log('Error updating trip status: $e', name: 'OngoingSharedTripDriver');
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
            text: S.of(context).tripEndedSharedSuccess,
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
      log('Error updating status: $e', name: 'OngoingSharedTripDriver');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  void _showCancelByDriverDialog() {
    final tripId = _trip?.id ?? int.tryParse(tripDetails['id']?.toString() ?? '') ?? 0;
    if (tripId == 0) return;

    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).cancelSharedTripCompletely,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.red[700]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).sharedTripCancelConfirmDriver,
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
              final tripIdStr = tripId.toString();

              _gpsSub?.cancel();
              try {
                await DriverLocationTrackerService.instance.stopTracking(sl<LocalStorage>());
              } catch (_) {}
              TripSecurityService.clearActiveTrip(sl<LocalStorage>());
              await sl<LocalStorage>().remove(key: 'ongoing_trip');
              await sl<LocalStorage>().remove(key: 'trip_id');
              await sl<LocalStorage>().remove(key: 'active_trip');
              await sl<LocalStorage>().remove(key: 'ongoing_trip_${tripId}_status');
              await sl<LocalStorage>().remove(key: 'ongoing_trip_$tripId');
              await sl<LocalStorage>().remove(key: 'ongoing_trip_${tripIdStr}_status');
              await sl<LocalStorage>().remove(key: 'ongoing_trip_$tripIdStr');

              try {
                await _locationService.updateTripStatus(tripId: tripIdStr, onGoingStatus: 'canceled');
                _locationService.stopTripLocation(tripIdStr);
              } catch (_) {}

              await sl<DriverTripsCubit>().driverCancelTrip(
                tripId: tripId,
                isSharedCreator: true,
                reason: reasonCtrl.text.trim(),
              );

              if (mounted) {
                try {
                  sl<DriverTripsCubit>().getDriverTripsByTypes(isLoading: false);
                  DriverLayoutCubit.get(context).changeBottomScreen(1);
                } catch (_) {}
                showToast(
                  text: S.of(context).tripCancelledSuccessfully,
                  state: ToastStates.SUCESS,
                );
                Navigator.of(context, rootNavigator: true)
                    .popUntil((route) => route.isFirst);
                context.go(AppRoutes.driverHome, extra: 1);
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
    final passengerName = _trip?.creator?.name.isNotEmpty == true
        ? _trip!.creator!.name
        : (tripDetails['creator'] is Map ? tripDetails['creator']['name']?.toString() : null) ??
            tripDetails['passenger_name']?.toString() ??
            S.of(context).passengers;
    final passengerPhone = _trip?.creator?.phone?.isNotEmpty == true
        ? _trip!.creator!.phone!
        : (tripDetails['creator'] is Map ? tripDetails['creator']['phone']?.toString() : null) ??
            tripDetails['passenger_phone']?.toString() ??
            '';
    final pricePerSeat = _trip?.approvedPrice?.toString() ??
        _trip?.minimumPrice.toString() ??
        tripDetails['price_per_seat']?.toString() ??
        tripDetails['approved_price']?.toString() ??
        '--';

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
              BoxShadow(color: Colors.black.withValues(alpha:0.1), blurRadius: 10),
            ],
          ),
          child: Text(
            S.of(context).trackSharedTrip,
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
                DriverOngoingSharedTripScreenClean._kDefaultCamera,
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
              heroTag: 'recenter_driver_shared',
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

                        // Group Chat Button with Real-time Unread Badge
                        Builder(
                          builder: (context) {
                            final tripId = _trip?.id ??
                                widget.tripId ??
                                (int.tryParse(
                                        tripDetails['id']?.toString() ?? '') ??
                                    0);
                            final groupChatId =
                                ChatChannelHelper.sharedTripGroupChatId(
                                    tripId: tripId);
                            final currentDriverId = int.tryParse(
                                    sl<LocalStorage>()
                                            .read(key: 'userid')
                                            ?.toString() ??
                                        '') ??
                                0;
                            final passengersList =
                                (tripDetails['passengers'] as List?) ?? [];

                            return UnreadBadge(
                              chatId: groupChatId,
                              currentUserId: currentDriverId.toString(),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    navigateTo(
                                      context,
                                      TripChatScreenClean(
                                        driverName: S.of(context).tripPassengers,
                                        driverPhone: '',
                                        tripFrom: cleanLocationName(
                                            _trip?.fromLocationName ??
                                                tripDetails['from_location_name']
                                                    ?.toString() ??
                                                ''),
                                        tripTo: cleanLocationName(
                                            _trip?.toLocationName ??
                                                tripDetails['to_location_name']
                                                    ?.toString() ??
                                                ''),
                                        tripDatetime: _trip?.tripDatetime ??
                                            tripDetails['trip_datetime']
                                                ?.toString() ??
                                            '',
                                        acceptedPrice: double.tryParse(
                                                pricePerSeat.toString()) ??
                                            0.0,
                                        tripId: tripId,
                                        offerId: 0,
                                        chatId: groupChatId,
                                        tripType: 'shared',
                                        isInquiry: false,
                                        isOffersPhase: false,
                                        members: [
                                          if (_trip?.driver != null)
                                            _trip!.driver!.toMap(),
                                          ...passengersList,
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.groups_rounded,
                                      size: 22, color: Colors.white),
                                  label: Text(
                                    'الدردشة الجماعية للرحلة',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Passengers Roster Card (Call button only for each passenger)
                        _DriverPassengersRosterCard(
                          passengers: (tripDetails['passengers'] as List?) ?? [],
                          driverId: _trip?.driverId ??
                              _trip?.driver?.id ??
                              int.tryParse(tripDetails['driver_id']?.toString() ?? '') ??
                              int.tryParse(sl<LocalStorage>().read(key: 'userid')?.toString() ?? '') ??
                              0,
                          totalSeats: int.tryParse(
                                  tripDetails['total_seats']?.toString() ??
                                      tripDetails['seats']?.toString() ??
                                      tripDetails['number_of_seats']
                                          ?.toString() ??
                                      '4') ??
                              4,
                          onCallPassenger: (phone) => _makeCall(phone),
                        ),

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
                                (cleanLocationName(_trip?.toLocationName ?? '').isNotEmpty ? cleanLocationName(_trip!.toLocationName) : S.of(context).destinationPoint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

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
                                '${S.of(context).tripPricePerSeat} $pricePerSeat ${S.of(context).jod}',
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

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _showCancelByDriverDialog,
                            icon: Icon(Icons.cancel_outlined,
                                color: Colors.red[700], size: 18),
                            label: Text(
                              S.of(context).cancelSharedTripCompletely,
                              style: GoogleFonts.cairo(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red.shade200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
        return S.of(context).startMovingToPassengers;
      case 'on_the_way':
        return S.of(context).nearPassengerLocation;
      case 'close_to_customer':
        return S.of(context).confirmArrivalAtPassengers;
      case 'arrive_customer':
        return S.of(context).startSharedTripAction;
      case 'start':
        return S.of(context).endSharedTripAction;
      case 'end':
      default:
        return S.of(context).sharedTripCompleted;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Passengers Roster Card for Driver
// ─────────────────────────────────────────────────────────────────────────────
class _DriverPassengersRosterCard extends StatelessWidget {
  final List passengers;
  final int totalSeats;
  final int driverId;
  final Function(String phone) onCallPassenger;

  const _DriverPassengersRosterCard({
    required this.passengers,
    required this.totalSeats,
    this.driverId = 0,
    required this.onCallPassenger,
  });

  @override
  Widget build(BuildContext context) {
    final actualPassengers = passengers.where((p) {
      if (p is! Map) return false;
      final pid = int.tryParse((p['id'] ??
                  p['passenger_id'] ??
                  p['user_id'] ??
                  p['passenger']?['id'])
              ?.toString() ??
          '') ??
          0;
      final userType =
          (p['user_type'] ?? p['passenger']?['user_type'])?.toString().toLowerCase();
      if (userType == 'driver') return false;
      if (driverId > 0 && pid == driverId) return false;
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).currentPassengers,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${actualPassengers.length} ${S.of(context).passengers}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (actualPassengers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).noOtherPassengers,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
          else
            ...actualPassengers.map((p) {
              final name = p['passenger']?['name']?.toString() ??
                  p['name']?.toString() ??
                  S.of(context).passengerDefaultName;
              final phone = p['passenger']?['phone']?.toString() ??
                  p['passenger']?['mobile']?.toString() ??
                  p['phone']?.toString() ??
                  p['mobile']?.toString() ??
                  '';
              final seats = p['seats'] ?? p['pivot']?['seats'] ?? 1;

              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '$seats ${S.of(context).seatsUnit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (phone.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (phone.isNotEmpty)
                      IconButton(
                        onPressed: () => onCallPassenger(phone),
                        icon: const Icon(Icons.phone_rounded, color: Color(0xFF05A357), size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
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
        text = S.of(context).startMovingToPassengers;
        color = Colors.blue.shade700;
        break;
      case 'on_the_way':
        text = S.of(context).nearPassengerLocation;
        color = AppColors.primary;
        break;
      case 'close_to_customer':
        text = S.of(context).confirmArrivalAtPassengers;
        color = Colors.amber.shade800;
        break;
      case 'arrive_customer':
        text = S.of(context).confirmArrivalAtPassengers;
        color = Colors.orange.shade800;
        break;
      case 'start':
        text = S.of(context).startSharedTripAction;
        color = Colors.green.shade700;
        break;
      case 'end':
        text = S.of(context).sharedTripCompleted;
        color = Colors.grey.shade700;
        break;
      default:
        text = S.of(context).trackSharedTrip;
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
      color: color.withValues(alpha:0.1),
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
