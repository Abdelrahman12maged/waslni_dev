import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_state.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:geolocator/geolocator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddPrivateTripScreenClean extends StatefulWidget {
  final String? presetDestinationName;
  final double? presetDestinationLat;
  final double? presetDestinationLng;

  const AddPrivateTripScreenClean({
    super.key,
    this.presetDestinationName,
    this.presetDestinationLat,
    this.presetDestinationLng,
  });

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 15,
  );

  @override
  State<AddPrivateTripScreenClean> createState() =>
      _AddPrivateTripScreenCleanState();
}

class _AddPrivateTripScreenCleanState extends State<AddPrivateTripScreenClean>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;

  // Animated center pin
  late AnimationController _pinController;
  late Animation<double> _pinOffset;

  // Inline Google Maps Search & Suggestions
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();

    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pinOffset = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _pinController, curve: Curves.easeInOut),
    );
    _pinController.repeat(reverse: true);

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cubit = PassengerAddPrivateTripCubit.get(context);
      cubit.removeMarkers();
      cubit.chooseTripDateTime(DateTime.now());

      if (widget.presetDestinationLat != null &&
          widget.presetDestinationLng != null &&
          widget.presetDestinationLat != 0.0) {
        await cubit.setupTripWithPresetDestination(
          destinationName: widget.presetDestinationName ?? S.of(context).savedLocationDefault,
          destinationLat: widget.presetDestinationLat!,
          destinationLng: widget.presetDestinationLng!,
        );

        if (cubit.startLatLng != null && cubit.destinationLatLng != null) {
          final bounds = LatLngBounds(
            southwest: LatLng(
              math.min(cubit.startLatLng!.latitude,
                  cubit.destinationLatLng!.latitude),
              math.min(cubit.startLatLng!.longitude,
                  cubit.destinationLatLng!.longitude),
            ),
            northeast: LatLng(
              math.max(cubit.startLatLng!.latitude,
                  cubit.destinationLatLng!.latitude),
              math.max(cubit.startLatLng!.longitude,
                  cubit.destinationLatLng!.longitude),
            ),
          );
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 90),
          );
        }
      } else {
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _pinController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;
    setState(() => _isLoadingLocation = true);
    try {
      final cubit = PassengerAddPrivateTripCubit.get(context);
      final latLng = await cubit.getCurrentLocation();
      if (latLng != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15),
          ),
        );
      }
    } catch (e) {
      log(e.toString(), name: 'GetLocation');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _onSearchQueryChanged(String query, PassengerAddPrivateTripCubit cubit) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final results = await cubit.searchPlaces(query.trim());
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _selectPlaceSuggestion(
      PlaceSuggestion suggestion, PassengerAddPrivateTripCubit cubit) async {
    setState(() {
      _showSuggestions = false;
      _searchController.text = suggestion.mainText;
    });
    _searchFocusNode.unfocus();

    final details = await cubit.getPlaceDetails(suggestion.placeId);
    if (details != null && mounted) {
      final latLng = LatLng(details.latitude, details.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );
      cubit.destLocation = latLng;
      cubit.currentLocationResult = details;
      if (cubit.currentLocationChooseIndex == 0) {
        cubit.startLocationController.text = details.displayName;
        cubit.startLocationResult = details;
      } else {
        cubit.destinationLocationController.text = details.displayName;
        cubit.destinationLocationResult = details;
      }
    }
  }

  void _showTripDetailsSheet(
      BuildContext parentCtx, PassengerAddPrivateTripCubit cubit) {
    showModalBottomSheet(
      context: parentCtx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BlocProvider.value(
        value: cubit,
        child: _TripDetailsSheet(
          cubit: cubit,
          onEditStart: () {
            Navigator.pop(sheetCtx);
            if (cubit.startLatLng != null) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(cubit.startLatLng!),
              );
            }
            cubit.editStartLocation();
            _searchController.clear();
          },
          onEditDestination: () {
            Navigator.pop(sheetCtx);
            if (cubit.destinationLatLng != null) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(cubit.destinationLatLng!),
              );
            }
            cubit.editDestinationLocation();
            _searchController.clear();
          },
        ),
      ),
    );
  }

  /// 0 = picking start, 1 = picking destination, 2 = both done
  int _step(PassengerAddPrivateTripCubit c) {
    if (c.startLatLng == null) return 0;
    if (c.destinationLatLng == null) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PassengerAddPrivateTripCubit>(
      create: (_) => di.sl<PassengerAddPrivateTripCubit>(),
      child: BlocConsumer<PassengerAddPrivateTripCubit,
          PassengerAddPrivateTripState>(
        listener: (ctx, state) {
          if (state is PassengerAddPrivateTripSuccessState) {
            showToast(
              text: S.of(context).tripCreatedSuccess,
              state: ToastStates.SUCESS,
            );
            final trip = state.trip;
            TripSecurityService.savePendingTrip(di.sl<LocalStorage>(), trip);
            ctx.go(
              AppRoutes.passengerPrivateOffers,
              extra: {
                'id': trip.id,
                'trip': trip,
                'tripDetails': trip.toJson(),
              },
            );
          }
          if (state is PassengerAddPrivateTripErrorState) {
            showToast(text: state.error, state: ToastStates.ERROR);
          }
        },
        builder: (ctx, state) {
          final cubit = PassengerAddPrivateTripCubit.get(ctx);
          final step = _step(cubit);

          final stepColors = [
            AppColors.primary,
            const Color(0xFF1B5E20),
            Colors.orange.shade800,
          ];
          final stepColor = stepColors[step.clamp(0, 2)];

          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.black, size: 18),
                    onPressed: () {
                      if (step == 1) {
                        cubit.editStartLocation();
                        _searchController.clear();
                      } else if (step == 2) {
                        cubit.editDestinationLocation();
                        _searchController.clear();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 12),
                  ],
                ),
                child: Text(
                  S.of(context).userlayouthomeprivatetrip,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              centerTitle: true,
            ),
            body: Stack(
              children: [
                // ── Google Map ──────────────────────────────────────
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: AddPrivateTripScreenClean._kGooglePlex,
                  onMapCreated: (c) {
                    _mapController = c;
                    AppMapStyle.applyStyle(c);
                  },
                  onCameraMove: (pos) => cubit.destLocation = pos.target,
                  onCameraIdle: () => cubit.getAddressFromLatLng(),
                  markers: cubit.userMarkers,
                ),

                // ── Animated Center Pin ─────────────────────────────
                if (step < 2)
                  Center(
                    child: AnimatedBuilder(
                      animation: _pinOffset,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _pinOffset.value - 28),
                        child: child,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: stepColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: stepColor.withOpacity(0.45),
                                  blurRadius: 16,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Icon(
                              step == 0
                                  ? Icons.my_location
                                  : Icons.flag_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          Container(width: 2, height: 18, color: stepColor),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: stepColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Top Search Bar & Instruction Card ────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Google Maps Style Inline Search Bar
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: (val) => _onSearchQueryChanged(val, cubit),
                            decoration: InputDecoration(
                              hintText: step == 0
                                  ? S.of(context).searchOriginHint
                                  : S.of(context).searchDestHint,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13.5,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              suffixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close,
                                              size: 18, color: Colors.grey),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _suggestions = [];
                                              _showSuggestions = false;
                                            });
                                          },
                                        )
                                      : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),

                        // Suggestions Dropdown Overlay
                        if (_showSuggestions && _suggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            constraints: const BoxConstraints(maxHeight: 270),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 1, color: Colors.grey.shade200),
                                itemBuilder: (context, idx) {
                                  final item = _suggestions[idx];
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () =>
                                          _selectPlaceSuggestion(item, cubit),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.location_on_rounded,
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.mainText,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF1E2235),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (item.secondaryText.isNotEmpty) ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      item.secondaryText,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.grey.shade600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),
                        _InstructionCard(cubit: cubit, step: step),
                      ],
                    ),
                  ),
                ),

                // ── Right Fab Buttons ───────────────────────────────
                Positioned(
                  right: 14,
                  top: MediaQuery.of(context).size.height * 0.45,
                  child: Column(
                    children: [
                      _CircleButton(
                        icon: Icons.my_location,
                        onTap: _getCurrentLocation,
                        isLoading: _isLoadingLocation,
                      ),
                    ],
                  ),
                ),

                // ── Bottom Panel ────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomPanel(
                    cubit: cubit,
                    step: step,
                    onConfirm: () {
                      // Prevent pickup point being the same as destination
                      if (step == 1 && cubit.startLatLng != null) {
                        final distance = Geolocator.distanceBetween(
                          cubit.startLatLng!.latitude,
                          cubit.startLatLng!.longitude,
                          cubit.destLocation.latitude,
                          cubit.destLocation.longitude,
                        );
                        if (distance < 80) {
                          showToast(
                            text: S.of(context).originAndDestinationCannotBeSame,
                            state: ToastStates.WARNING,
                          );
                          return;
                        }
                      }
                      cubit.setStartAndDestinationLocation();
                      _searchController.clear();
                      _pinController.reset();
                      _pinController.repeat(reverse: true);
                    },
                    onDetails: () {
                      // Final validation before opening details
                      if (cubit.startLatLng != null &&
                          cubit.destinationLatLng != null) {
                        final distance = Geolocator.distanceBetween(
                          cubit.startLatLng!.latitude,
                          cubit.startLatLng!.longitude,
                          cubit.destinationLatLng!.latitude,
                          cubit.destinationLatLng!.longitude,
                        );
                        if (distance < 80) {
                          showToast(
                            text: S.of(context).originAndDestinationCannotBeSame,
                            state: ToastStates.WARNING,
                          );
                          return;
                        }
                      }
                      _showTripDetailsSheet(ctx, cubit);
                    },
                    onEditStart: () {
                      if (cubit.startLatLng != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(cubit.startLatLng!),
                        );
                      }
                      cubit.editStartLocation();
                      _searchController.clear();
                    },
                    onEditDestination: () {
                      if (cubit.destinationLatLng != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(cubit.destinationLatLng!),
                        );
                      }
                      cubit.editDestinationLocation();
                      _searchController.clear();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Instruction Card
// ─────────────────────────────────────────────────────────────────────────────
class _InstructionCard extends StatelessWidget {
  final PassengerAddPrivateTripCubit cubit;
  final int step;

  const _InstructionCard({required this.cubit, required this.step});

  @override
  Widget build(BuildContext context) {
    final labels = [
      S.of(context).pickupPoint,
      S.of(context).destinationPoint,
      S.of(context).pickupSelected
    ];
    final subs = [
      S.of(context).moveMapAndConfirm,
      S.of(context).moveMapAndSelectDestination,
      S.of(context).tapTripDetailsToContinue
    ];
    const icons = [
      Icons.trip_origin,
      Icons.flag_rounded,
      Icons.check_circle_outline
    ];
    final colors = [
      AppColors.primary,
      const Color(0xFF1B5E20),
      Colors.orange.shade800
    ];

    final s = step.clamp(0, 2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Step Dots ──────────────────────────────────────────
          Row(
            children: List.generate(3, (i) {
              final active = i == s;
              final done = i < s;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFF1B5E20)
                              : active
                                  ? colors[s]
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // ── Icon + Text ────────────────────────────────────────
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors[s].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icons[s], color: colors[s], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[s],
                      style: TextStyle(
                        color: colors[s],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subs[s],
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Live Address ───────────────────────────────────────
          if (cubit.currentLocationResult != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade400, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cubit.currentLocationResult!.displayName,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Panel (Estimated Price Removed)
// ─────────────────────────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final PassengerAddPrivateTripCubit cubit;
  final int step;
  final VoidCallback onConfirm;
  final VoidCallback onDetails;
  final VoidCallback onEditStart;
  final VoidCallback onEditDestination;

  const _BottomPanel({
    required this.cubit,
    required this.step,
    required this.onConfirm,
    required this.onDetails,
    required this.onEditStart,
    required this.onEditDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Route summary when locations are set
          if (cubit.startLatLng != null || cubit.destinationLatLng != null) ...[
            if (cubit.startLatLng != null)
              _RouteRow(
                icon: Icons.trip_origin,
                color: AppColors.primary,
                text: cubit.startLocationController.text.isNotEmpty
                    ? cubit.startLocationController.text
                    : S.of(context).pickupSelected,
                onEdit: onEditStart,
              ),
            if (cubit.startLatLng != null && cubit.destinationLatLng != null)
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 2,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            if (cubit.destinationLatLng != null)
              _RouteRow(
                icon: Icons.flag_rounded,
                color: const Color(0xFF1B5E20),
                text: cubit.destinationLocationController.text.isNotEmpty
                    ? cubit.destinationLocationController.text
                    : S.of(context).destinationSelected,
                onEdit: onEditDestination,
              ),
            const SizedBox(height: 14),
          ],

          // Action button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: step < 2
                ? SizedBox(
                    key: ValueKey('step_$step'),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: cubit.currentLocationResult == null
                          ? null
                          : onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: step == 0
                            ? AppColors.primary
                            : const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      icon: Icon(
                        step == 0
                            ? Icons.my_location
                            : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        step == 0
                            ? S.of(context).confirmPickupLocation
                            : S.of(context).confirmDestinationLocation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('step_done'),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: onDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        S.of(context).tripDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onEdit;

  const _RouteRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                S.of(context).edit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Circle Button (my location)
// ─────────────────────────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.13), blurRadius: 8)
          ],
        ),
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            : Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip Details Bottom Sheet (Cleaned: No Notes, No Proposed Fare, No Auto Accept)
// ─────────────────────────────────────────────────────────────────────────────
class _TripDetailsSheet extends StatefulWidget {
  final PassengerAddPrivateTripCubit cubit;
  final VoidCallback onEditStart;
  final VoidCallback onEditDestination;

  const _TripDetailsSheet({
    required this.cubit,
    required this.onEditStart,
    required this.onEditDestination,
  });

  @override
  State<_TripDetailsSheet> createState() => _TripDetailsSheetState();
}

class _TripDetailsSheetState extends State<_TripDetailsSheet> {
  bool _dateTimeSelected = true;
  bool _isSubmitting = false;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.cubit.selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.cubit.selectedDateTime),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    widget.cubit.chooseTripDateTime(combinedDateTime);
    setState(() => _dateTimeSelected = true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerAddPrivateTripCubit,
        PassengerAddPrivateTripState>(
      listener: (ctx, state) {
        if (state is PassengerAddPrivateTripErrorState) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
          showToast(text: state.error, state: ToastStates.ERROR);
        }
      },
      builder: (ctx, state) {
        final cubit = widget.cubit;

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.90,
          builder: (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                  child: Row(
                    children: [
                      Text(
                        S.of(context).tripDetails,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.grey.shade500,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      // ── Route Summary ─────────────────────────────
                      _RouteSummaryCard(
                        cubit: cubit,
                        onEditStart: widget.onEditStart,
                        onEditDestination: widget.onEditDestination,
                      ),
                      const SizedBox(height: 22),

                      // ── Date & Time ───────────────────────────────
                      _SectionLabel(
                          label: S.of(context).dateTimeLabel,
                          icon: Icons.calendar_month),
                      const SizedBox(height: 10),
                      _DateTimeTile(
                        selected: _dateTimeSelected,
                        day: cubit.selectedDay,
                        date: cubit.selecteddate,
                        time: _dateTimeSelected
                            ? '${cubit.hourController.text}:${cubit.minutesController.text} ${cubit.periodController.text}'
                            : null,
                        onTap: _pickDateTime,
                      ),
                      const SizedBox(height: 22),

                      // ── Gender Preference ─────────────────────────
                      _SectionLabel(
                          label: S.of(context).genderPreferenceLabel,
                          icon: Icons.people_alt_outlined),
                      const SizedBox(height: 10),
                      _GenderSelector(cubit: cubit),
                      const SizedBox(height: 28),

                      // ── Confirm / Search For Offers Button ─────────
                      ConditionalBuilder(
                        condition:
                            state is! PassengerAddPrivateTripLoadingState &&
                                !_isSubmitting,
                        fallback: (_) => Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                        ),
                        builder: (_) => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (state is PassengerAddPrivateTripLoadingState ||
                                    _isSubmitting)
                                ? null
                                : () {
                                    if (!_dateTimeSelected) {
                                      showToast(
                                        text: S.of(ctx).pleaseSelectDateTime,
                                        state: ToastStates.WARNING,
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _isSubmitting = true;
                                    });
                                    cubit.createTrip(ctx);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  S.of(context).searchForOffersButton,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom + 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ],
      );
}

class _RouteSummaryCard extends StatelessWidget {
  final PassengerAddPrivateTripCubit cubit;
  final VoidCallback? onEditStart;
  final VoidCallback? onEditDestination;

  const _RouteSummaryCard({
    required this.cubit,
    this.onEditStart,
    this.onEditDestination,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            _RouteDetailRow(
              icon: Icons.trip_origin,
              color: AppColors.primary,
              title: S.of(context).startingLocation,
              subtitle:
                  (cubit.startLocationResult?.displayName.isNotEmpty == true)
                      ? cubit.startLocationResult!.displayName
                      : (cubit.startLocationController.text.isNotEmpty
                          ? cubit.startLocationController.text
                          : S.of(context).pickupPoint),
              onEdit: onEditStart,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Column(
                children: List.generate(
                  4,
                  (_) => Container(
                    width: 2,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            _RouteDetailRow(
              icon: Icons.flag_rounded,
              color: const Color(0xFF1B5E20),
              title: S.of(context).destinationLocation,
              subtitle:
                  (cubit.destinationLocationResult?.displayName.isNotEmpty ==
                          true)
                      ? cubit.destinationLocationResult!.displayName
                      : (cubit.destinationLocationController.text.isNotEmpty
                          ? cubit.destinationLocationController.text
                          : S.of(context).destinationPoint),
              onEdit: onEditDestination,
            ),
          ],
        ),
      );
}

class _RouteDetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;

  const _RouteDetailRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: color,
              onPressed: onEdit,
              tooltip: S.of(context).edit,
            ),
        ],
      );
}

class _DateTimeTile extends StatelessWidget {
  final bool selected;
  final String day;
  final String date;
  final String? time;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.selected,
    required this.day,
    required this.date,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.access_time_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: selected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$day, $date',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF222222),
                            ),
                          ),
                          if (time != null)
                            Text(
                              time!,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      )
                    : Text(
                        S.of(context).pleaseSelectDateTime,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                      ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.grey.shade400, size: 15),
            ],
          ),
        ),
      );
}

class _GenderSelector extends StatelessWidget {
  final PassengerAddPrivateTripCubit cubit;
  const _GenderSelector({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final opts = [
      {
        'key': 'no_preference',
        'label': S.of(context).noPreference,
        'icon': Icons.people_rounded
      },
      {
        'key': 'male',
        'label': S.of(context).maleOnly,
        'icon': Icons.male_rounded
      },
      {
        'key': 'female',
        'label': S.of(context).femaleOnly,
        'icon': Icons.female_rounded
      },
    ];

    return Row(
      children: opts
          .map(
            (o) => Expanded(
              child: GestureDetector(
                onTap: () => cubit.changeGender(o['key'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: o == opts.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: cubit.gender == o['key']
                        ? AppColors.primary
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cubit.gender == o['key']
                          ? AppColors.primary
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        o['icon'] as IconData,
                        color: cubit.gender == o['key']
                            ? Colors.white
                            : Colors.grey.shade500,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o['label'] as String,
                        style: TextStyle(
                          color: cubit.gender == o['key']
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: cubit.gender == o['key']
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
