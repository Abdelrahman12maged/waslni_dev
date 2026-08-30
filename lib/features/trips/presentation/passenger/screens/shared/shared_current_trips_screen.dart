import 'dart:async';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/data/models/offer_model.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip_driver.dart';

import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/driver_details_modal.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SharedCurrentTripsScreenClean
// ─────────────────────────────────────────────────────────────────────────────
class SharedCurrentTripsScreenClean extends StatefulWidget {
  const SharedCurrentTripsScreenClean({
    super.key,
    this.trip,
    this.id,
    this.proposed_fare,
    this.is_auto_accept,
  });

  final Trip? trip;
  final int? id;
  final double? proposed_fare;
  final bool? is_auto_accept;

  @override
  State<SharedCurrentTripsScreenClean> createState() =>
      _SharedCurrentTripsScreenCleanState();
}

class _SharedCurrentTripsScreenCleanState
    extends State<SharedCurrentTripsScreenClean>
    with TickerProviderStateMixin {
  bool isOffersLoading = true;
  List<Offer> offersList = [];
  Map acceptedOffer = {};
  Timer? _pollTimer;

  // Track rejected offer IDs
  final Set<String> _rejectedOfferIds = {};

  // Current proposed fare
  late double _currentFare;
  late int _seatsCount;

  // Animation controllers for Radar Sonar
  late AnimationController _radarCtrl;
  late Animation<double> _radarAnim;

  // Google Map controller
  GoogleMapController? _mapController;

  // Markers and Polylines
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Draggable sheet controller
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // ── Helpers & Initializers ──────────────────────────────────
  String get _resolvedDriverName =>
      widget.trip?.driver?.name ?? '';
  String get _resolvedTripDatetime =>
      widget.trip?.tripDatetime ?? '';
  String get _resolvedFromLocation =>
      cleanLocationName(widget.trip?.fromLocationName ?? '');
  String get _resolvedToLocation =>
      cleanLocationName(widget.trip?.toLocationName ?? '');
  String get _resolvedTotal =>
      widget.trip?.approvedPrice?.toString() ??
      widget.trip?.maximumPrice.toString() ??
      '0';
  String get _resolvedId =>
      widget.trip?.id.toString() ?? widget.id?.toString() ?? '0';

  @override
  void initState() {
    super.initState();

    final parsedFare =
        widget.proposed_fare ??
        widget.trip?.minimumPrice ??
        widget.trip?.maximumPrice ??
        15.0;
    _currentFare = parsedFare > 0 ? parsedFare : 15.0;

    _seatsCount = widget.trip?.numberOfSeats ?? 1;

    // Radar Sonar Animation
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _radarAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarCtrl, curve: Curves.easeOut),
    );

    _initMapElements();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOffers(showLoading: true);
    });

    // Polling driver offers every 3 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchOffers();
    });
  }

  void _initMapElements() {
    final fromLat = widget.trip?.fromLatitude ?? 31.963158;
    final fromLng = widget.trip?.fromLongitude ?? 35.930359;
    final toLat = widget.trip?.toLatitude ?? (fromLat + 0.015);
    final toLng = widget.trip?.toLongitude ?? (fromLng + 0.015);

    final pickupLatLng = LatLng(fromLat, fromLng);
    final destLatLng = LatLng(toLat, toLng);

    _markers = {
      Marker(
        markerId: const MarkerId('pickup_point'),
        position: pickupLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: _resolvedFromLocation.isNotEmpty ? _resolvedFromLocation : S.of(context).pickupLocation),
      ),
      Marker(
        markerId: const MarkerId('dest_point'),
        position: destLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: _resolvedToLocation.isNotEmpty ? _resolvedToLocation : S.of(context).destination),
      ),
    };

    // Fetch actual road route polyline from MapService
    _fetchRoutePolyline(pickupLatLng, destLatLng);
  }

  Future<void> _fetchRoutePolyline(LatLng from, LatLng to) async {
    try {
      final routeRes = await sl<MapService>().getRoutePolyline(from: from, to: to);
      routeRes.fold(
        (failure) {
          if (!mounted) return;
          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route_line'),
                points: [from, to],
                color: AppColors.primary,
                width: 5,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
          });
        },
        (points) {
          if (!mounted || points.isEmpty) return;
          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route_line'),
                points: points,
                color: AppColors.primary,
                width: 5,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            };
          });
          _fitMapBoundsWithPoints(points);
        },
      );
    } catch (e) {
      debugPrint('Error fetching road polyline: $e');
    }
  }

  void _fitMapBoundsWithPoints(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    });
  }

  void _fitMapBounds() {
    if (_mapController == null) return;
    final fromLat = widget.trip?.fromLatitude ?? 31.963158;
    final fromLng = widget.trip?.fromLongitude ?? 35.930359;
    final toLat = widget.trip?.toLatitude ?? (fromLat + 0.015);
    final toLng = widget.trip?.toLongitude ?? (fromLng + 0.015);

    final southWest = LatLng(
      fromLat < toLat ? fromLat : toLat,
      fromLng < toLng ? fromLng : toLng,
    );
    final northEast = LatLng(
      fromLat > toLat ? fromLat : toLat,
      fromLng > toLng ? fromLng : toLng,
    );

    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);
    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _radarCtrl.dispose();
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }


  // ── Network Callbacks ───────────────────────────────────────
  void _stopLoading(dynamic newOffersList) {
    if (!mounted) return;
    final List<Offer> parsedOffers = [];
    if (newOffersList is List) {
      for (final item in newOffersList) {
        if (item is Offer) {
          parsedOffers.add(item);
        } else if (item is Map<String, dynamic>) {
          try {
            parsedOffers.add(OfferModel.fromJson(item));
          } catch (_) {}
        } else if (item is Map) {
          try {
            parsedOffers.add(OfferModel.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
    }
    final filtered = parsedOffers.where((offer) {
      final id = offer.id.toString();
      if (_rejectedOfferIds.contains(id)) return false;
      if (offer.status == OfferStatus.rejected || offer.status == OfferStatus.accepted) return false;
      return true;
    }).toList();

    if (filtered.length > offersList.length) {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      offersList = filtered;
      isOffersLoading = false;
    });
  }

  void _passState(newOffersList, newAcceptedOffer) {
    if (!mounted) return;
    _stopLoading(newOffersList);
  }

  void _fetchOffers({bool showLoading = false}) {
    if (showLoading && mounted) setState(() => isOffersLoading = true);
    PassengerTripsCubit.get(context).getOffersByTripId(
      stoploading: _stopLoading,
      id: _resolvedId,
      isLoading: true,
      forceRefresh: !showLoading,
    );
  }

  // ── Accept & Reject Offer ──────────────────────────────────
  void _acceptOffer(Offer offer) {
    final priceStr = offer.price.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).confirmAcceptOffer,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          S.of(context).confirmOfferQuestion(priceStr, S.of(context).jod),
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel, style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _doAcceptOffer(offer);
            },
            child: Text(
              S.of(context).confirmAccept,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doAcceptOffer(Offer offer) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                S.of(context).confirmAcceptOfferLoading,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    final tripId = widget.trip?.id ?? widget.id ?? int.tryParse(_resolvedId) ?? 0;
    final success = await PassengerTripsCubit.get(context).changeOfferStatus(
      id: offer.id,
      status: 'accepted',
      tripId: tripId,
      PassState: _passState,
      stoploading: _stopLoading,
    );

    if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!success) {
      _fetchOffers(showLoading: true);
      return;
    }

    final driverId = offer.driverId != 0 ? offer.driverId : (offer.driver?.id ?? 0);
    final updatedTrip = widget.trip?.copyWith(
      driver: offer.driver,
      driverId: driverId,
      status: TripStatus.accepted,
      onGoingStatus: 'on_the_way',
      approvedPrice: offer.price,
    ) ?? Trip(
      id: tripId,
      driver: offer.driver,
      driverId: driverId,
      createdBy: 0,
      fromLatitude: widget.trip?.fromLatitude ?? 31.963158,
      fromLongitude: widget.trip?.fromLongitude ?? 35.930359,
      toLatitude: widget.trip?.toLatitude ?? 31.963158,
      toLongitude: widget.trip?.toLongitude ?? 35.930359,
      fromLocationName: _resolvedFromLocation,
      toLocationName: _resolvedToLocation,
      numberOfSeats: widget.trip?.numberOfSeats ?? 1,
      genderPreference: widget.trip?.genderPreference ?? GenderPreference.noPreference,
      tripDatetime: widget.trip?.tripDatetime ?? '',
      status: TripStatus.accepted,
      type: TripType.shared,
      minimumPrice: offer.price,
      maximumPrice: offer.price,
      approvedPrice: offer.price,
      onGoingStatus: 'on_the_way',
    );

    TripSecurityService.clearPendingTrip(sl<LocalStorage>());
    TripSecurityService.saveActiveTrip(sl<LocalStorage>(), updatedTrip);
    sl<LocalStorage>().saveString(key: 'ongoing_trip', value: 'shared');

    if (mounted) {
      PassengerTripsCubit.get(context).getPassengerTripsByTypes(isLoading: false);
    }

    final targetExtra = {
      'id': tripId,
      'trip_id': tripId,
      'trip': updatedTrip,
      'tripDetails': updatedTrip.toJson(),
    };

    if (mounted) {
      navigateTo(
        context,
        TripChatScreenClean(
          driverName: offer.driver?.name ?? S.of(context).driverLabel,
          driverPhone: offer.driver?.phone ?? '',
          driverPhoto: offer.driver?.photo,
          tripFrom: updatedTrip.fromLocationName,
          tripTo: updatedTrip.toLocationName,
          tripDatetime: updatedTrip.tripDatetime,
          acceptedPrice: offer.price,
          tripId: tripId,
          offerId: offer.id,
          onPopGoRoute: AppRoutes.passengerOngoingSharedTrip,
          onPopGoExtra: targetExtra,
          tripType: 'shared',
          members: [
            if (offer.driver != null)
              {
                'id': offer.driver!.id,
                'name': offer.driver!.name,
                'phone': offer.driver!.phone,
                'fcm_token': offer.driver!.fcmToken,
                'photo': offer.driver!.photo,
                'is_driver': true,
              },
          ],
        ),
      );
    }
  }

  void _rejectOffer(Offer offer) {
    final offerId = offer.id.toString();
    if (offerId.isNotEmpty) {
      _rejectedOfferIds.add(offerId);
    }
    HapticFeedback.lightImpact();
    setState(() {
      offersList.removeWhere((o) => o.id.toString() == offerId);
    });
    PassengerTripsCubit.get(context).changeOfferStatus(
      id: offer.id,
      status: 'rejected',
      stoploading: _stopLoading,
      PassState: _passState,
    );
  }

  bool get _isCreator {
    final currentUid = sl<LocalStorage>().read(key: 'userid')?.toString() ??
        sl<LocalStorage>().read(key: 'user_id')?.toString() ??
        '';
    final createdBy = widget.trip?.createdBy.toString();
    if (createdBy != null && createdBy.isNotEmpty) {
      return createdBy == currentUid;
    }
    return (widget.trip?.passengers.length ?? 0) <= 1;
  }

  int get _passengerCount =>
      widget.trip?.passengers.length ??
      widget.trip?.joinedPassengersCount ??
      0;

  void _changeDriver() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).changeDriverConfirmTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          S.of(context).changeDriverSharedConfirmMessage,
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).no, style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final intTripId = widget.trip?.id ?? widget.id ?? int.tryParse(_resolvedId) ?? 0;
              final ok = await sl<PassengerTripsCubit>()
                  .cancelAcceptedOfferAndReopen(tripId: intTripId);
              if (ok && mounted) {
                showToast(
                    text: S.of(context).driverCancelledSearchingNewDriver,
                    state: ToastStates.SUCESS);
                _fetchOffers(showLoading: true);
              }
            },
            child: Text(
              S.of(context).confirm,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelTrip() {
    if (!_isCreator) return;
    final intTripId = widget.trip?.id ?? widget.id ?? int.tryParse(_resolvedId) ?? 0;
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
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await sl<PassengerTripsCubit>()
                  .cancelEntireTrip(intTripId);
              if (ok && mounted) {
                showToast(
                    text: S.of(context).orderCanceledSuccessfully,
                    state: ToastStates.SUCESS);
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

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hasOffers = offersList.isNotEmpty;
    final mediaQuery = MediaQuery.of(context);
    final currency = S.of(context).jod;

    final fromLat = widget.trip?.fromLatitude ?? 31.963158;
    final fromLng = widget.trip?.fromLongitude ?? 35.930359;
    final pickupLatLng = LatLng(fromLat, fromLng);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutes.passengerHome);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // ── 1. Full Screen Google Map with Markers & Polylines ───
          Positioned.fill(
            child: GoogleMap(
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              initialCameraPosition: CameraPosition(
                target: pickupLatLng,
                zoom: 15.0,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (ctrl) {
                _mapController = ctrl;
                AppMapStyle.applyStyle(ctrl);
                _fitMapBounds();
              },
            ),
          ),

          // ── 2. Concentric Sonar Radar Waves on Map ────────
          if (!hasOffers)
            Positioned(
              top: mediaQuery.size.height * 0.30 - 110,
              left: mediaQuery.size.width * 0.5 - 110,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _radarAnim,
                  builder: (ctx, child) {
                    return CustomPaint(
                      size: const Size(220, 220),
                      painter: _RadarSonarPainter(progress: _radarAnim.value),
                    );
                  },
                ),
              ),
            ),

          // ── 3. Compact Floating Driver Offer Cards Over Screen ───
          if (hasOffers)
            Positioned(
              top: mediaQuery.padding.top + 6,
              left: 12,
              right: 12,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Row: Cancel Button & Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Red Pill Cancel Button
                        Material(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                          elevation: 2,
                          child: InkWell(
                            onTap: _cancelTrip,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.close,
                                      color: Colors.white, size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    S.of(context).cancelOrder,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Header Title & Verification Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  color: AppColors.primaryLight, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                S.of(context).chooseDriverWithCount(offersList.length),
                                style: GoogleFonts.cairo(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Floating Cards List (Responsive Max Height)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: mediaQuery.size.height * 0.46,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: offersList.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                        itemBuilder: (ctx, index) {
                          final offer = offersList[index];
                          final offerId = offer.id;
                          return _DriverBiddingCardShared(
                            key: ValueKey(offerId),
                            offer: offer,
                            trip: widget.trip,
                            index: index,
                            currency: currency,
                            onAccept: () => _acceptOffer(offer),
                            onReject: () => _rejectOffer(offer),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── 4. White Bottom Sheet (Cleaned: No Timer, No Auto-Accept, Shows Requested Seats) ──
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.36,
            minChildSize: 0.18,
            maxChildSize: 0.54,
            snap: true,
            snapSizes: const [0.18, 0.36, 0.54],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  children: [
                    // Drag Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Content of the Sheet
                    _buildBottomSheetContent(context, currency),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  // ─────────────────────────────────────────────────────────
  //  White Bottom Sheet Content (Cleaned)
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomSheetContent(BuildContext context, String currency) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Text: Priority Banner
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  S.of(context).searchingForCaptains,
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                S.of(context).sharedTrip,
                textAlign: TextAlign.end,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF22273B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Point 10: Requested Number of Seats Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.airline_seat_recline_extra_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).requestedNumberOfSeats,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF1E2235),
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_seatsCount',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Route Summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _RouteSimpleRow(
                icon: Icons.person_pin_circle_outlined,
                iconColor: AppColors.primary,
                text: _resolvedFromLocation.isNotEmpty ? _resolvedFromLocation : S.of(context).pickupPoint,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: DottedLine(
                  direction: Axis.horizontal,
                  lineLength: double.infinity,
                  dashColor: Colors.grey.shade300,
                ),
              ),
              _RouteSimpleRow(
                icon: Icons.flag_outlined,
                iconColor: AppColors.success,
                text: _resolvedToLocation.isNotEmpty ? _resolvedToLocation : S.of(context).destinationPoint,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Cancel Button (Only for creator)
        if (_isCreator) ...[
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _cancelTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                S.of(context).cancelOrder,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Driver Bidding Offer Card for Shared Trips (Clean - No Auto-Dismiss Timer)
// ─────────────────────────────────────────────────────────────────────────────
// Top-level price formatter: removes trailing zeros (5.50 → "5.5", 5.00 → "5")
String _formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toStringAsFixed(0);
  }
  final s = price.toStringAsFixed(2);
  return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

class _DriverBiddingCardShared extends StatelessWidget {
  final Offer offer;
  final Trip? trip;
  final int index;
  final String currency;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _DriverBiddingCardShared({
    super.key,
    required this.offer,
    this.trip,
    required this.index,
    required this.currency,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final TripDriver? driver = offer.driver;
    final driverName = driver?.name.isNotEmpty == true
        ? driver!.name
        : S.of(context).driverDefaultName;

    final photoUrl = ApiEndpoints.buildImageUrl(driver?.photo);
    final rating = driver?.rating ?? (driver?.ratingAvg != null ? driver!.ratingAvg!.toStringAsFixed(1) : null);
    final car = driver?.car;
    final carParts = [
      if (car != null && car.type.isNotEmpty) car.type,
      if (car != null && car.model.isNotEmpty) car.model,
    ];
    final carModel = carParts.isNotEmpty
        ? carParts.join(' ')
        : (car?.plateNumber.isNotEmpty == true ? PlateNumberFormatter.format(car!.plateNumber) : S.of(context).driverCar);
    final tripsCountStr = (driver?.tripsCount != null && driver!.tripsCount! > 0)
        ? S.of(context).tripsCountLabel(driver!.tripsCount!)
        : '';
    final price = _formatPrice(offer.price);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDriverDetailsModal(
            context,
            offer: offer,
            trip: trip,
            currency: currency,
            onAccept: onAccept,
            onReject: onReject,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          // ── Top Header Row: Driver Avatar, Info, and Price Badge ────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Row(
              children: [
                // Driver Avatar with Rating Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: appCachedImageProvider(photoUrl?.toString()),
                      child: photoUrl == null || photoUrl.toString().isEmpty
                          ? const Icon(Icons.person,
                              size: 22, color: Colors.grey)
                          : null,
                    ),
                    if (rating != null)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2235),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 10),
                              const SizedBox(width: 1),
                              Text(
                                rating,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),

                // Driver Details & Car Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        driverName.toString(),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: const Color(0xFF1E2235),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$carModel$tripsCountStr',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Price Tag
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$price $currency',
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action Buttons: Reject, Chat with Badge & Accept ───────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
            child: Row(
              children: [
                // Reject Button
                Material(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onReject,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        S.of(context).reject,
                        style: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Direct Chat Button with Unread Badge
                Builder(
                  builder: (context) {
                    final targetChatId = ChatChannelHelper.privateTripChatId(
                      tripId: trip?.id ?? offer.tripId,
                      driverId: offer.driverId > 0 ? offer.driverId : (driver?.id ?? 0),
                    );
                    final currentUid = sl<LocalStorage>().read(key: 'userid')?.toString() ??
                        sl<LocalStorage>().read(key: 'user_id')?.toString() ??
                        '';
                    return UnreadBadge(
                      chatId: targetChatId,
                      currentUserId: currentUid,
                      child: Material(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            final tripId = trip?.id ?? offer.tripId;
                            navigateTo(
                              context,
                              TripChatScreenClean(
                                driverName: driverName,
                                driverPhone: driver?.phone ?? '',
                                driverPhoto: driver?.photo,
                                tripFrom: trip?.fromLocationName ?? '',
                                tripTo: trip?.toLocationName ?? '',
                                tripDatetime: trip?.tripDatetime ?? '',
                                acceptedPrice: offer.price,
                                tripId: tripId,
                                offerId: offer.id,
                                driverId: offer.driverId > 0 ? offer.driverId : (driver?.id ?? 0),
                                isOffersPhase: true,
                                tripType: 'shared',
                                members: [
                                  if (driver != null)
                                    {
                                      'id': driver.id,
                                      'name': driver.name,
                                      'phone': driver.phone,
                                      'photo': driver.photo,
                                      'fcm_token': driver.fcmToken,
                                      'is_driver': true,
                                    },
                                ],
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),

                // Accept Button with Green Accent
                Expanded(
                  child: Material(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: onAccept,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 34,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              S.of(context).acceptOffer,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

class _RouteSimpleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _RouteSimpleRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22273B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Radar Sonar Custom Painter
// ─────────────────────────────────────────────────────────────────────────────
class _RadarSonarPainter extends CustomPainter {
  final double progress;

  _RadarSonarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final currentProgress = (progress + (i * 0.33)) % 1.0;
      final radius = currentProgress * maxRadius;
      final opacity = (1.0 - currentProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = AppColors.primary.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);

      final fillPaint = Paint()
        ..color = AppColors.primary.withOpacity(opacity * 0.08)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarSonarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
