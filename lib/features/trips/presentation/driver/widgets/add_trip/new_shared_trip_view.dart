import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_shared_trip_state.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/add_trip/driver_location_search_delegate.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/add_trip/driver_shared_pricing_modal.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/add_trip/driver_shared_trip_details_sheet.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/add_trip/driver_trip_step_bottom_panel.dart';
import 'package:car_app/features/trips/presentation/driver/widgets/add_trip/driver_trip_step_instruction_card.dart';
import 'package:car_app/generated/l10n.dart';

class NewSharedTripDriverView extends StatefulWidget {
  const NewSharedTripDriverView({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 15,
  );

  @override
  State<NewSharedTripDriverView> createState() =>
      _NewSharedTripDriverViewState();
}

class _NewSharedTripDriverViewState extends State<NewSharedTripDriverView>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  LatLng? _driverLocation;

  late AnimationController _pinController;
  late Animation<double> _pinOffset;

  final TextEditingController _notesController = TextEditingController();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = DriverAddSharedTripCubit.get(context);
        cubit.removeMarkers();
        cubit.chooseTripDateTime(DateTime.now());
        _getCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _mapController?.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation || !mounted) return;
    setState(() => _isLoadingLocation = true);
    final res = await di.sl<MapService>().getCurrentLocation();
    if (mounted) {
      res.fold(
        (failure) {},
        (pos) {
          _driverLocation = pos;
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _driverLocation!, zoom: 15),
            ),
          );
          final cubit = DriverAddSharedTripCubit.get(context);
          cubit.destLocation = _driverLocation!;
          cubit.getAddressFromLatLng();
        },
      );
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _handleSearch() async {
    final cubit = DriverAddSharedTripCubit.get(context);
    final selectedResult = await showSearch<LocationResult?>(
      context: context,
      delegate: DriverLocationSearchDelegate(cubit: cubit),
    );

    if (selectedResult != null && mounted) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
                selectedResult.latitude, selectedResult.longitude),
            zoom: 16,
          ),
        ),
      );
    }
  }

  int _step(DriverAddSharedTripCubit c) {
    if (c.startLatLng == null) return 0;
    if (c.destinationLatLng == null) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverAddSharedTripCubit, DriverAddSharedTripState>(
      listener: (ctx, state) {
        if (state is DriverAddSharedTripErrorState) {
          showToast(text: state.error, state: ToastStates.ERROR);
        } else if (state is DriverAddSharedTripSuccessState) {
          final cubit = DriverAddSharedTripCubit.get(ctx);
          final trip = state.trip;
          showDriverSharedPricingAndChatModal(
            ctx,
            trip,
            cubit,
            notesController: _notesController,
          );
        }
      },
      builder: (ctx, state) {
        final cubit = DriverAddSharedTripCubit.get(ctx);
        final step = _step(cubit);
        final stepColor =
            step == 0 ? AppColors.primary : const Color(0xFF1B5E20);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(ctx),
              ),
            ),
            title: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12),
                ],
              ),
              child: Text(
                S.of(context).userlayouthomesharedtrip,
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
                    NewSharedTripDriverView._kGooglePlex,
                onMapCreated: (c) {
                  _mapController = c;
                  AppMapStyle.applyStyle(c);
                  if (_driverLocation != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                            target: _driverLocation!, zoom: 15),
                      ),
                    );
                  }
                },
                onCameraMove: (pos) => cubit.destLocation = pos.target,
                onCameraIdle: () => cubit.getAddressFromLatLng(),
                markers: cubit.userMarkers,
              ),
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 66, 16, 0),
                  child: DriverInstructionCard(
                      cubit: cubit, step: step),
                ),
              ),
              Positioned(
                right: 14,
                top: MediaQuery.of(context).size.height * 0.38,
                child: Column(
                  children: [
                    _CircleIconButton(
                        icon: Icons.search, onTap: _handleSearch),
                    const SizedBox(height: 10),
                    _CircleIconButton(
                      icon: Icons.my_location,
                      onTap: _getCurrentLocation,
                      isLoading: _isLoadingLocation,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DriverTripStepBottomPanel(
                  cubit: cubit,
                  step: step,
                  onConfirm: () =>
                      cubit.setStartAndDestinationLocation(),
                  onDetails: () => showDriverSharedTripDetailsSheet(
                    ctx,
                    cubit,
                    notesController: _notesController,
                  ),
                  onEditStart: () {
                    if (cubit.startLatLng != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(cubit.startLatLng!),
                      );
                    }
                    cubit.editStartLocation();
                  },
                  onEditDestination: () {
                    if (cubit.destinationLatLng != null) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                            cubit.destinationLatLng!),
                      );
                    }
                    cubit.editDestinationLocation();
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, color: AppColors.primary, size: 20),
          ),
        ),
      ),
    );
  }
}
