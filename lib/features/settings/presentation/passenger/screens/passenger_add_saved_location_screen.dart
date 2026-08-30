import 'dart:async';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/settings/presentation/cubit/saved_locations_cubit.dart';
import 'package:car_app/features/settings/presentation/cubit/saved_locations_state.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/core/di/injection_container.dart' as di;

class PassengerAddSavedLocationScreen extends StatefulWidget {
  const PassengerAddSavedLocationScreen({super.key});

  @override
  State<PassengerAddSavedLocationScreen> createState() =>
      _PassengerAddSavedLocationScreenState();
}

class _PassengerAddSavedLocationScreenState
    extends State<PassengerAddSavedLocationScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final TextEditingController _nameController = TextEditingController();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.9535, 35.9112), // Amman / Default
    zoom: 15.5,
  );

  String _selectedPresetKey = 'home';
  bool _isMovingMap = false;
  String _discoveredAddress = '';

  List<Map<String, dynamic>> _getPresets(BuildContext context) => [
    {
      'key': 'home',
      'name': S.of(context).presetHome,
      'icon': Icons.home_rounded,
      'color': const Color(0xFF2563EB),
    },
    {
      'key': 'work',
      'name': S.of(context).presetWork,
      'icon': Icons.business_rounded,
      'color': const Color(0xFFD97706),
    },
    {
      'key': 'university',
      'name': S.of(context).presetUniversity,
      'icon': Icons.school_rounded,
      'color': const Color(0xFF059669),
    },
    {
      'key': 'custom',
      'name': S.of(context).presetCustom,
      'icon': Icons.edit_location_alt_rounded,
      'color': AppColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedPresetKey == 'home') {
        _nameController.text = S.of(context).presetHome;
      }
    });
    _goToCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16.5),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SavedLocationsCubit>(
      create: (context) => di.sl<SavedLocationsCubit>(),
      child: BlocConsumer<SavedLocationsCubit, SavedLocationsState>(
        listener: (context, state) {
          if (state is SaveLocationSuccessSnackBarState) {
            showToast(
              text: S.of(context).addressAddedSuccessfully,
              state: ToastStates.SUCESS,
            );
            Navigator.of(context).pop();
          }
          if (state is SaveLocationError) {
            showToast(text: state.message, state: ToastStates.ERROR);
          }
        },
        builder: (context, state) {
          final cubit = SavedLocationsCubit.get(context);

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                // ── Google Map ───────────────────────────────────────
                GoogleMap(
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    AppMapStyle.applyStyle(controller);
                  },
                  onCameraMoveStarted: () {
                    setState(() {
                      _isMovingMap = true;
                    });
                  },
                  onCameraMove: (CameraPosition position) {
                    cubit.destLocation = position.target;
                  },
                  onCameraIdle: () async {
                    setState(() {
                      _isMovingMap = false;
                    });
                    await cubit.getAddressFromLatLng();
                    if (cubit.userAddLocationplacemarks.isNotEmpty) {
                      final p = cubit.userAddLocationplacemarks.first;
                      final addr = [p.subLocality, p.thoroughfare, p.street]
                          .where((s) => s != null && s.isNotEmpty)
                          .join('، ');
                      if (mounted) {
                        setState(() {
                          _discoveredAddress =
                              addr.isNotEmpty ? addr : S.of(context).specifiedMapLocation;
                        });
                      }
                    }
                  },
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                ),

                // ── Center Pin with Ripple Animation ─────────────────
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 38),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.translationValues(
                              0, _isMovingMap ? -10 : 0, 0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Top Navigation Bar ───────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            S.of(context).addNewLocation,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),

                // ── GPS My Location Floating Button ──────────────────
                Positioned(
                  bottom: 310,
                  left: 20,
                  child: FloatingActionButton.small(
                    heroTag: 'gps_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onPressed: _goToCurrentLocation,
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),

                // ── Bottom Sheet Form Container ──────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Preset Category Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _getPresets(context).map((p) {
                              final isSel = _selectedPresetKey == p['key'];
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ChoiceChip(
                                  showCheckmark: false,
                                  avatar: Icon(
                                    p['icon'] as IconData,
                                    size: 16,
                                    color: isSel
                                        ? Colors.white
                                        : (p['color'] as Color),
                                  ),
                                  label: Text(
                                    p['name'] as String,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSel
                                          ? Colors.white
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: p['color'] as Color,
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: isSel
                                        ? (p['color'] as Color)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (val) {
                                    if (val) {
                                      setState(() {
                                        _selectedPresetKey = p['key'] as String;
                                        if (_selectedPresetKey != 'custom') {
                                          _nameController.text =
                                              p['name'] as String;
                                        } else {
                                          _nameController.clear();
                                        }
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Name Input Field
                        TextField(
                          controller: _nameController,
                          style: GoogleFonts.cairo(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            labelText: S.of(context).locationLabelText,
                            labelStyle: GoogleFonts.cairo(
                                color: const Color(0xFF64748B)),
                            hintText: S.of(context).locationHintText,
                            hintStyle: GoogleFonts.cairo(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.drive_file_rename_outline_rounded,
                              color: AppColors.primary,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Address Preview Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.near_me_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _isMovingMap
                                      ? S.of(context).determiningAddress
                                      : (_discoveredAddress.isNotEmpty
                                          ? _discoveredAddress
                                          : S.of(context).determiningAddress),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (state is SaveLocationLoading)
                                ? null
                                : () {
                                    final name = _nameController.text.trim();
                                    if (name.isEmpty) {
                                      showToast(
                                        text: S.of(context).pleaseEnterLocationName,
                                        state: ToastStates.WARNING,
                                      );
                                      return;
                                    }
                                    cubit.userSaveLocation(customName: name);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: (state is SaveLocationLoading)
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        S.of(context).saveLocationButton,
                                        style: GoogleFonts.cairo(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
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
