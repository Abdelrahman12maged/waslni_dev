import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/trip_security_service.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_add_private_trip_state.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/add_trip/passenger_private_trip_details_sheet.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/add_trip/trip_animated_center_pin.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/add_trip/trip_map_search_bar.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/add_trip/trip_step_bottom_panel.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/add_trip/trip_step_instruction_card.dart';
import 'package:car_app/generated/l10n.dart';

class PassengerAddPrivateTripView extends StatefulWidget {
  final String? presetDestinationName;
  final double? presetDestinationLat;
  final double? presetDestinationLng;

  const PassengerAddPrivateTripView({
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
  State<PassengerAddPrivateTripView> createState() =>
      _PassengerAddPrivateTripViewState();
}

class _PassengerAddPrivateTripViewState
    extends State<PassengerAddPrivateTripView> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;

  late AnimationController _pinController;
  late Animation<double> _pinOffset;

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
          destinationName: widget.presetDestinationName ??
              S.of(context).savedLocationDefault,
          destinationLat: widget.presetDestinationLat!,
          destinationLng: widget.presetDestinationLng!,
        );
      }
      _getCurrentLocation();
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
    setState(() => _isLoadingLocation = true);
    final res = await di.sl<MapService>().getCurrentLocation();
    res.fold(
      (failure) {
        if (mounted) {
          showToast(
            text: S.of(context).locationPermissionDenied,
            state: ToastStates.WARNING,
          );
        }
      },
      (pos) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: pos, zoom: 16),
          ),
        );
        if (mounted) {
          final cubit = PassengerAddPrivateTripCubit.get(context);
          cubit.destLocation = pos;
          cubit.getAddressFromLatLng();
        }
      },
    );
    if (mounted) setState(() => _isLoadingLocation = false);
  }

  void _onSearchQueryChanged(
      String query, PassengerAddPrivateTripCubit cubit) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isSearching = true);
      final res = await di.sl<MapService>().searchPlaces(query);
      if (mounted) {
        res.fold(
          (failure) {
            setState(() {
              _suggestions = [];
              _showSuggestions = false;
              _isSearching = false;
            });
          },
          (results) {
            setState(() {
              _suggestions = results;
              _showSuggestions = results.isNotEmpty;
              _isSearching = false;
            });
          },
        );
      }
    });
  }

  Future<void> _selectPlaceSuggestion(
      PlaceSuggestion suggestion, PassengerAddPrivateTripCubit cubit) async {
    _searchFocusNode.unfocus();
    _searchController.text = suggestion.mainText;
    setState(() {
      _showSuggestions = false;
      _isSearching = true;
    });

    final res =
        await di.sl<MapService>().getPlaceDetails(suggestion.placeId);
    if (mounted) {
      await res.fold(
        (failure) async {
          showToast(
            text: S.of(context).serverError,
            state: ToastStates.ERROR,
          );
        },
        (loc) async {
          final target = LatLng(loc.latitude, loc.longitude);
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: target, zoom: 16.5),
            ),
          );
          cubit.destLocation = target;
          await cubit.getAddressFromLatLng();
        },
      );
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showTripDetailsSheet(
      BuildContext context, PassengerAddPrivateTripCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrivateTripDetailsSheet(
        cubit: cubit,
        onEditStart: () {
          Navigator.pop(context);
          if (cubit.startLatLng != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(cubit.startLatLng!),
            );
          }
          cubit.editStartLocation();
          _searchController.clear();
        },
        onEditDestination: () {
          Navigator.pop(context);
          if (cubit.destinationLatLng != null) {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(cubit.destinationLatLng!),
            );
          }
          cubit.editDestinationLocation();
          _searchController.clear();
        },
      ),
    );
  }

  int _step(PassengerAddPrivateTripCubit c) {
    if (c.startLatLng == null) return 0;
    if (c.destinationLatLng == null) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerAddPrivateTripCubit,
        PassengerAddPrivateTripState>(
      listener: (ctx, state) {
        if (state is PassengerAddPrivateTripSuccessState) {
          showToast(
            text: S.of(ctx).tripCreatedSuccess,
            state: ToastStates.SUCESS,
          );
          final trip = state.trip;
          TripSecurityService.savePendingTrip(di.sl<LocalStorage>(), trip);
          ctx.go(
            AppRoutes.passengerCurrentPrivateTrip,
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
                S.of(context).privateTrip,
                style: const TextStyle(
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
              GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition:
                    PassengerAddPrivateTripView._kGooglePlex,
                onMapCreated: (c) {
                  _mapController = c;
                  AppMapStyle.applyStyle(c);
                },
                onCameraMove: (pos) => cubit.destLocation = pos.target,
                onCameraIdle: () => cubit.getAddressFromLatLng(),
                markers: cubit.userMarkers,
              ),
              if (step < 2)
                TripAnimatedCenterPin(
                  pinOffset: _pinOffset,
                  stepColor: stepColor,
                  step: step,
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TripMapSearchBar(
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                        isSearching: _isSearching,
                        showSuggestions: _showSuggestions,
                        suggestions: _suggestions,
                        step: step,
                        onQueryChanged: (val) =>
                            _onSearchQueryChanged(val, cubit),
                        onSelectSuggestion: (sugg) =>
                            _selectPlaceSuggestion(sugg, cubit),
                        onClear: () {
                          _searchController.clear();
                          setState(() {
                            _suggestions = [];
                            _showSuggestions = false;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TripStepInstructionCard(
                        step: step,
                        currentLocationResult: cubit.currentLocationResult,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 14,
                top: MediaQuery.of(context).size.height * 0.45,
                child: GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.13),
                            blurRadius: 8)
                      ],
                    ),
                    child: _isLoadingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          )
                        : const Icon(Icons.my_location,
                            color: AppColors.primary, size: 22),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TripStepBottomPanel(
                  step: step,
                  startLocationText: cubit.startLocationController.text,
                  destinationLocationText:
                      cubit.destinationLocationController.text,
                  hasStartLocation: cubit.startLatLng != null,
                  hasDestinationLocation: cubit.destinationLatLng != null,
                  currentLocationResult: cubit.currentLocationResult,
                  onConfirm: () {
                    if (step == 1 && cubit.startLatLng != null) {
                      final distance = Geolocator.distanceBetween(
                        cubit.startLatLng!.latitude,
                        cubit.startLatLng!.longitude,
                        cubit.destLocation.latitude,
                        cubit.destLocation.longitude,
                      );
                      if (distance < 80) {
                        showToast(
                          text: S
                              .of(context)
                              .originAndDestinationCannotBeSame,
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
                          text: S
                              .of(context)
                              .originAndDestinationCannotBeSame,
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
    );
  }
}
