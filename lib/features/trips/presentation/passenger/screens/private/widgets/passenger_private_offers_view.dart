import 'dart:async';
import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/router/navigation_manager.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/chat/presentation/screens/trip_chat_screen.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/domain/entities/offer.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/driver_bidding_card.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/radar_sonar_painter.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/route_simple_row.dart';
import 'package:car_app/generated/l10n.dart';

class PassengerPrivateOffersView extends StatefulWidget {
  final Trip? trip;
  final int? id;
  final double? proposed_fare;
  final bool? is_auto_accept;

  const PassengerPrivateOffersView({
    super.key,
    this.trip,
    this.id,
    this.proposed_fare,
    this.is_auto_accept,
  });

  @override
  State<PassengerPrivateOffersView> createState() =>
      _PassengerPrivateOffersViewState();
}

class _PassengerPrivateOffersViewState extends State<PassengerPrivateOffersView>
    with TickerProviderStateMixin {
  Trip? _trip;
  bool isOffersLoading = true;
  List<Offer> offersList = [];
  Map acceptedOffer = {};
  Timer? _pollTimer;

  final Set<String> _rejectedOfferIds = {};

  late double _currentFare;

  late AnimationController _radarCtrl;
  late Animation<double> _radarAnim;

  GoogleMapController? _mapController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  String get _resolvedDriverName =>
      _trip?.driver?.name ?? widget.trip?.driver?.name ?? '';
  String get _resolvedTripDatetime =>
      _trip?.tripDatetime ?? widget.trip?.tripDatetime ?? '';
  String get _resolvedFromLocation =>
      _trip?.fromLocationName ?? widget.trip?.fromLocationName ?? '';
  String get _resolvedToLocation =>
      _trip?.toLocationName ?? widget.trip?.toLocationName ?? '';
  String get _resolvedTotal =>
      _trip?.approvedPrice?.toString() ??
      _trip?.maximumPrice.toString() ??
      widget.trip?.approvedPrice?.toString() ??
      widget.trip?.maximumPrice.toString() ??
      '0';
  String get _resolvedId =>
      _trip?.id.toString() ??
      widget.trip?.id.toString() ??
      widget.id?.toString() ??
      '0';

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;

    final parsedFare = widget.proposed_fare ??
        widget.trip?.minimumPrice ??
        widget.trip?.maximumPrice ??
        15.0;
    _currentFare = parsedFare > 0 ? parsedFare : 15.0;

    final int numericTripId = int.tryParse(_resolvedId) ?? 0;
    if (_trip == null && numericTripId > 0) {
      try {
        final trips =
            PassengerTripsCubit.get(context).TripsListByTypeCurrentPrivete;
        _trip = trips.firstWhere((t) => t.id == numericTripId);
      } catch (_) {}
    }

    if (_trip != null &&
        (_trip!.status == TripStatus.canceled ||
            _trip!.status == TripStatus.completed ||
            _trip!.status == TripStatus.closed)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast(
          text: _trip!.status == TripStatus.canceled
              ? S.of(context).tripCancelledAlready
              : S.of(context).tripCompletedAndFinished,
          state: ToastStates.WARNING,
        );
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return;
    }

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
        infoWindow: InfoWindow(
            title: _resolvedFromLocation.isNotEmpty
                ? _resolvedFromLocation
                : S.current.originPoint),
      ),
      Marker(
        markerId: const MarkerId('dest_point'),
        position: destLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: _resolvedToLocation.isNotEmpty
                ? _resolvedToLocation
                : S.current.destinationPoint),
      ),
    };

    _fetchRoutePolyline(pickupLatLng, destLatLng);
  }

  Future<void> _fetchRoutePolyline(LatLng from, LatLng to) async {
    try {
      final routeRes =
          await sl<MapService>().getRoutePolyline(from: from, to: to);
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
      log('Error fetching road polyline: $e',
          name: 'PrivateCurrentScreenCleanoffers');
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

  void _stopLoading(dynamic newOffersList) {
    if (!mounted) return;
    final rawList = newOffersList ?? [];
    final List<Offer> parsed = [];
    for (final item in rawList) {
      if (item is Offer) {
        parsed.add(item);
      } else if (item is Map) {
        try {
          parsed.add(Offer.fromMap(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
    }
    final filtered = parsed.where((offer) {
      final id = offer.id.toString();
      if (_rejectedOfferIds.contains(id)) return false;
      if (offer.status == OfferStatus.rejected ||
          offer.status == OfferStatus.accepted) {
        return false;
      }
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
    final rawList = newOffersList ?? [];
    final List<Offer> parsed = [];
    for (final item in rawList) {
      if (item is Offer) {
        parsed.add(item);
      } else if (item is Map) {
        try {
          parsed.add(Offer.fromMap(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
    }
    final filtered = parsed.where((offer) {
      final id = offer.id.toString();
      if (_rejectedOfferIds.contains(id)) return false;
      if (offer.status == OfferStatus.rejected ||
          offer.status == OfferStatus.accepted) {
        return false;
      }
      return true;
    }).toList();

    setState(() {
      offersList = filtered;
      acceptedOffer = newAcceptedOffer is Map ? newAcceptedOffer : {};
      isOffersLoading = false;
    });
  }

  void _fetchOffers({bool showLoading = false}) {
    final effectiveId = _resolvedId;
    final int numericId = int.tryParse(effectiveId) ?? 0;
    if (numericId <= 0) {
      if (mounted) setState(() => isOffersLoading = false);
      return;
    }
    if (showLoading && mounted) setState(() => isOffersLoading = true);
    PassengerTripsCubit.get(context).getOffersByTripId(
      tripId: numericId,
      id: effectiveId,
      stoploading: _stopLoading,
      isLoading: true,
      forceRefresh: !showLoading,
    );
  }

  void _acceptOffer(Offer offer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).confirmAcceptOffer,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          S.of(context).confirmOfferQuestion(
              offer.price.toStringAsFixed(2), S.of(context).jod),
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel,
                style: GoogleFonts.cairo(color: Colors.grey)),
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
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    final tripId = _trip?.id ??
        widget.trip?.id ??
        widget.id ??
        int.tryParse(_resolvedId) ??
        0;
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

    final driverId =
        offer.driverId != 0 ? offer.driverId : (offer.driver?.id ?? 0);
    final updatedTrip = (_trip ?? widget.trip)?.copyWith(
          driver: offer.driver,
          driverId: driverId,
          status: TripStatus.accepted,
          onGoingStatus: 'on_the_way',
          approvedPrice: offer.price,
        ) ??
        Trip(
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
          numberOfSeats: 1,
          genderPreference: GenderPreference.noPreference,
          tripDatetime: widget.trip?.tripDatetime ?? '',
          status: TripStatus.accepted,
          type: TripType.private,
          minimumPrice: offer.price,
          maximumPrice: offer.price,
          approvedPrice: offer.price,
          onGoingStatus: 'on_the_way',
        );

    TripSecurityService.clearPendingTrip(sl<LocalStorage>());
    TripSecurityService.saveActiveTrip(sl<LocalStorage>(), updatedTrip);
    sl<LocalStorage>().saveString(key: 'ongoing_trip', value: 'private');

    if (mounted) {
      PassengerTripsCubit.get(context)
          .getPassengerTripsByTypes(isLoading: false);
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
          driverId:
              offer.driverId > 0 ? offer.driverId : (offer.driver?.id ?? 0),
          isOffersPhase: true,
          onPopGoRoute: AppRoutes.passengerCurrentPrivateTrip,
          onPopGoExtra: targetExtra,
          tripType: 'private',
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

  void _cancelTrip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).cancelOrder,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          S.of(context).cancelOrderConfirmMessage,
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).no,
                style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              TripSecurityService.clearPendingTrip(sl<LocalStorage>());
              TripSecurityService.clearActiveTrip(sl<LocalStorage>());
              PassengerTripsCubit.get(context).changeTripStatus(
                context: context,
                stoploading: _stopLoading,
                id: _resolvedId,
                status: 'canceled',
                PassState: _passState,
              );
              showToast(
                  text: S.of(context).orderCanceledSuccessfully,
                  state: ToastStates.SUCESS);
              context.go(AppRoutes.passengerHome);
            },
            child: Text(
              S.of(context).cancelOrder,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasOffers = offersList.isNotEmpty;
    final currency = S.of(context).jod;
    final mediaQuery = MediaQuery.of(context);

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
                        painter: RadarSonarPainter(progress: _radarAnim.value),
                      );
                    },
                  ),
                ),
              ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                  S
                                      .of(context)
                                      .chooseDriverWithCount(offersList.length),
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
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: mediaQuery.size.height * 0.46,
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: offersList.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, index) {
                            final offer = offersList[index];
                            return DriverBiddingCard(
                              key: ValueKey(offer.id),
                              offer: offer,
                              trip: _trip ?? widget.trip,
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
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.32,
              minChildSize: 0.16,
              maxChildSize: 0.50,
              snap: true,
              snapSizes: const [0.16, 0.32, 0.50],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28)),
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

  Widget _buildBottomSheetContent(BuildContext context, String currency) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
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
                S.of(context).privateTripPriorityBanner,
                textAlign: TextAlign.end,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF22273B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              RouteSimpleRow(
                icon: Icons.person_pin_circle_outlined,
                iconColor: AppColors.primary,
                text: _resolvedFromLocation.isNotEmpty
                    ? _resolvedFromLocation
                    : S.of(context).pickupPoint,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: DottedLine(
                  direction: Axis.horizontal,
                  lineLength: double.infinity,
                  dashColor: Colors.grey.shade300,
                ),
              ),
              RouteSimpleRow(
                icon: Icons.flag_outlined,
                iconColor: AppColors.success,
                text: _resolvedToLocation.isNotEmpty
                    ? _resolvedToLocation
                    : S.of(context).destinationPoint,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
    );
  }
}
