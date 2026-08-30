import 'dart:async';
import 'dart:developer';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_cubit.dart';
import 'package:car_app/features/trips/presentation/driver/cubit/driver_add_private_trip_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:car_app/core/widgets/components.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Add Private Trip Screen
// ─────────────────────────────────────────────────────────────────────────────
class AddNewPriveteTripDriver extends StatelessWidget {
  const AddNewPriveteTripDriver({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.963158, 35.930359),
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DriverAddPrivateTripCubit>(
      create: (context) => di.sl<DriverAddPrivateTripCubit>(),
      child: const _AddNewPriveteTripDriverContent(),
    );
  }
}

class _AddNewPriveteTripDriverContent extends StatefulWidget {
  const _AddNewPriveteTripDriverContent();

  @override
  State<_AddNewPriveteTripDriverContent> createState() =>
      _AddNewPriveteTripDriverContentState();
}

class _AddNewPriveteTripDriverContentState
    extends State<_AddNewPriveteTripDriverContent>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  LatLng? _driverLocation;

  late AnimationController _pinController;
  late Animation<double> _pinOffset;

  final TextEditingController _priceController = TextEditingController();

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
        final cubit = DriverAddPrivateTripCubit.get(context);
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
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation || !mounted) return;
    setState(() => _isLoadingLocation = true);
    try {
      final cubit = DriverAddPrivateTripCubit.get(context);
      final latLng = await cubit.getCurrentLocation();
      if (latLng != null && mounted) {
        setState(() => _driverLocation = latLng);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 15),
          ),
        );
      }
    } catch (e) {
      log(e.toString(), name: 'DriverGetLocation');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _handleSearch() async {
    if (!mounted) return;
    final cubit = DriverAddPrivateTripCubit.get(context);
    final selectedResult = await showSearch<LocationResult?>(
      context: context,
      delegate: _LocationSearchDelegate(cubit: cubit),
    );

    if (selectedResult != null && mounted) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(selectedResult.latitude, selectedResult.longitude),
            zoom: 16,
          ),
        ),
      );
    }
  }

  void _showDriverTripDetailsSheet(
      BuildContext ctx, DriverAddPrivateTripCubit cubit) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final dateStr =
                DateFormat('yyyy-MM-dd').format(cubit.selectedDateTime);
            final timeStr = DateFormat('hh:mm a').format(cubit.selectedDateTime);

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(Icons.drive_eta,
                            color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).userlayouthomeprivatetrip,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date & Time Selectors
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: cubit.selectedDateTime,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 90)),
                              );
                              if (pickedDate != null) {
                                final newDt = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  cubit.selectedDateTime.hour,
                                  cubit.selectedDateTime.minute,
                                );
                                cubit.chooseTripDateTime(newDt);
                                setSheetState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(dateStr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    cubit.selectedDateTime),
                              );
                              if (pickedTime != null) {
                                final newDt = DateTime(
                                  cubit.selectedDateTime.year,
                                  cubit.selectedDateTime.month,
                                  cubit.selectedDateTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                cubit.chooseTripDateTime(newDt);
                                setSheetState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 18, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(timeStr,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Fare / Price Input
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: S.of(context).tripPriceExpected,
                        prefixIcon: const Icon(Icons.payments_outlined,
                            color: AppColors.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Notes Input
                    TextField(
                      controller: cubit.notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: S.of(context).notes,
                        prefixIcon: const Icon(Icons.note_alt_outlined,
                            color: AppColors.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          cubit.createTrip(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          S.of(context).addNewTrip,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _step(DriverAddPrivateTripCubit c) {
    if (c.startLatLng == null) return 0;
    if (c.destinationLatLng == null) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverAddPrivateTripCubit,
        DriverAddPrivateTripState>(
      listener: (ctx, state) {
        if (state is DriverAddPrivateTripErrorState) {
          showToast(text: state.error, state: ToastStates.ERROR);
        } else if (state is DriverAddPrivateTripSuccessState) {
          showToast(
            text: S.of(ctx).privateTripAnnouncedSuccess,
            state: ToastStates.SUCESS,
          );
          Navigator.pop(ctx);
        }
      },
      builder: (ctx, state) {
        final cubit = DriverAddPrivateTripCubit.get(ctx);
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
              child: _CircleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(ctx),
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
                    AddNewPriveteTripDriver._kGooglePlex,
                onMapCreated: (c) {
                  _mapController = c;
                  AppMapStyle.applyStyle(c);
                  if (_driverLocation != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(target: _driverLocation!, zoom: 15),
                      ),
                    );
                  }
                },
                onCameraMove: (pos) => cubit.destLocation = pos.target,
                onCameraIdle: () => cubit.getAddressFromLatLng(),
                markers: cubit.userMarkers,
              ),

                // Animated Pin
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

                // Top Instruction Card
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 66, 16, 0),
                    child: _DriverInstructionCard(cubit: cubit, step: step),
                  ),
                ),

                // Right Fab Buttons
                Positioned(
                  right: 14,
                  top: MediaQuery.of(context).size.height * 0.38,
                  child: Column(
                    children: [
                      _CircleButton(icon: Icons.search, onTap: _handleSearch),
                      const SizedBox(height: 10),
                      _CircleButton(
                        icon: Icons.my_location,
                        onTap: _getCurrentLocation,
                        isLoading: _isLoadingLocation,
                      ),
                    ],
                  ),
                ),

                // Bottom Panel
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _DriverBottomPanel(
                    cubit: cubit,
                    step: step,
                    onConfirm: () => cubit.setStartAndDestinationLocation(),
                    onDetails: () =>
                        _showDriverTripDetailsSheet(ctx, cubit),
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
                          CameraUpdate.newLatLng(cubit.destinationLatLng!),
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

// ─────────────────────────────────────────────────────────────────────────────
// Instruction Card
// ─────────────────────────────────────────────────────────────────────────────
class _DriverInstructionCard extends StatelessWidget {
  final DriverAddPrivateTripCubit cubit;
  final int step;

  const _DriverInstructionCard({required this.cubit, required this.step});

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
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Panel
// ─────────────────────────────────────────────────────────────────────────────
class _DriverBottomPanel extends StatelessWidget {
  final DriverAddPrivateTripCubit cubit;
  final int step;
  final VoidCallback onConfirm;
  final VoidCallback onDetails;
  final VoidCallback onEditStart;
  final VoidCallback onEditDestination;

  const _DriverBottomPanel({
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
          if (cubit.startLatLng != null) ...[
            _RouteRow(
              icon: Icons.trip_origin,
              color: AppColors.primary,
              text: cubit.startLocationController.text.isNotEmpty
                  ? cubit.startLocationController.text
                  : S.of(context).pickupSelected,
              onEdit: onEditStart,
            ),
            if (cubit.destinationLatLng != null) ...[
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
              _RouteRow(
                icon: Icons.flag_rounded,
                color: const Color(0xFF1B5E20),
                text: cubit.destinationLocationController.text.isNotEmpty
                    ? cubit.destinationLocationController.text
                    : S.of(context).destinationSelected,
                onEdit: onEditDestination,
              ),
            ],
            const SizedBox(height: 14),
          ],
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
                        disabledBackgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: Icon(
                        step == 0 ? Icons.trip_origin : Icons.flag_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        step == 0
                            ? S.of(context).confirmPickupLocation
                            : S.of(context).confirmDestinationLocation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('details'),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: onDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded,
                          color: Color(0xFF1A237E), size: 20),
                      label: Text(
                        S.of(context).tripDetails,
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
  final VoidCallback? onEdit;

  const _RouteRow({
    required this.icon,
    required this.color,
    required this.text,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: Colors.grey.shade600,
            onPressed: onEdit,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
      ],
    );
  }
}

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

// ─────────────────────────────────────────────────────────────────────────────
// Location Search Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _LocationSearchDelegate extends SearchDelegate<LocationResult?> {
  final DriverAddPrivateTripCubit cubit;

  _LocationSearchDelegate({required this.cubit});

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Text(
          S.of(context).searchLocationHint,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return FutureBuilder<List<PlaceSuggestion>>(
      future: cubit.searchPlaces(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final suggestions = snapshot.data ?? [];
        if (suggestions.isEmpty) {
          return Center(
            child: Text(
              S.of(context).noLocationFound,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        return ListView.separated(
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF5F5F5),
                child: Icon(Icons.location_on, color: AppColors.primary),
              ),
              title: Text(
                suggestion.mainText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: suggestion.secondaryText.isNotEmpty
                  ? Text(
                      suggestion.secondaryText,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    )
                  : null,
              onTap: () async {
                final details = await cubit.getPlaceDetails(suggestion.placeId);
                if (context.mounted) {
                  close(context, details);
                }
              },
            );
          },
        );
      },
    );
  }
}
