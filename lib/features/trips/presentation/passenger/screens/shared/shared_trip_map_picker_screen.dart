import 'dart:async';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/map/domain/entities/place_suggestion.dart';
import 'package:car_app/features/map/domain/services/map_service.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapPickerStep { origin, destination, routeReview }

class SharedTripMapPickerScreen extends StatefulWidget {
  final LatLng? initialOrigin;
  final String? initialOriginName;
  final LatLng? initialDestination;
  final String? initialDestinationName;
  final bool pickDestinationOnly;
  final bool pickOriginOnly;

  const SharedTripMapPickerScreen({
    super.key,
    this.initialOrigin,
    this.initialOriginName,
    this.initialDestination,
    this.initialDestinationName,
    this.pickDestinationOnly = false,
    this.pickOriginOnly = false,
  });

  @override
  State<SharedTripMapPickerScreen> createState() =>
      _SharedTripMapPickerScreenState();
}

class _SharedTripMapPickerScreenState extends State<SharedTripMapPickerScreen>
    with SingleTickerProviderStateMixin {
  late final MapService _mapService;
  GoogleMapController? _mapController;

  MapPickerStep _currentStep = MapPickerStep.origin;

  LatLng? _originLatLng;
  String _originName = '';

  LatLng? _destLatLng;
  String _destName = '';

  LatLng _currentCameraTarget = const LatLng(31.9539, 35.9106); // Amman default
  String _currentResolvedAddress = '';
  bool _isResolvingAddress = false;
  Timer? _cameraIdleDebounce;

  final TextEditingController _searchController = TextEditingController();
  List<PlaceSuggestion> _searchSuggestions = [];
  bool _isSearchingPlaces = false;
  Timer? _searchDebounce;

  List<LatLng> _routePolyline = [];
  bool _isLoadingRoute = false;

  late AnimationController _pinAnimController;
  late Animation<double> _pinBounceAnim;

  @override
  void initState() {
    super.initState();
    _mapService = sl<MapService>();

    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _pinBounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _pinAnimController, curve: Curves.easeOut),
    );

    if (widget.pickDestinationOnly) {
      _currentStep = MapPickerStep.destination;
    } else if (widget.pickOriginOnly) {
      _currentStep = MapPickerStep.origin;
    }

    if (widget.initialOrigin != null) {
      _originLatLng = widget.initialOrigin;
      _originName = widget.initialOriginName ?? '';
    }
    if (widget.initialDestination != null) {
      _destLatLng = widget.initialDestination;
      _destName = widget.initialDestinationName ?? '';
    }

    _initPosition();
  }

  Future<void> _initPosition() async {
    if (_currentStep == MapPickerStep.destination &&
        _destLatLng != null) {
      _currentCameraTarget = _destLatLng!;
    } else if (_originLatLng != null) {
      _currentCameraTarget = _originLatLng!;
    } else {
      final locResult = await _mapService.getCurrentLocation();
      locResult.fold((_) {}, (latLng) {
        if (mounted) {
          setState(() {
            _currentCameraTarget = latLng;
            if (_originLatLng == null && !widget.pickDestinationOnly) {
              _originLatLng = latLng;
              _originName = S.current.currentGpsLocation;
            }
          });
          _animateToLocation(latLng);
        }
      });
    }
    _resolveAddressForTarget(_currentCameraTarget);
  }

  @override
  void dispose() {
    _cameraIdleDebounce?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    _pinAnimController.dispose();
    super.dispose();
  }

  void _animateToLocation(LatLng target, {double zoom = 15.5}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    _currentCameraTarget = position.target;
    if (!_pinAnimController.isAnimating && _pinAnimController.value == 0) {
      _pinAnimController.forward();
    }
  }

  void _onCameraIdle() {
    _pinAnimController.reverse();
    _cameraIdleDebounce?.cancel();
    _cameraIdleDebounce = Timer(const Duration(milliseconds: 400), () {
      _resolveAddressForTarget(_currentCameraTarget);
    });
  }

  Future<void> _resolveAddressForTarget(LatLng target) async {
    if (!mounted) return;
    setState(() {
      _isResolvingAddress = true;
    });

    final result = await _mapService.getAddressFromLatLng(target);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _currentResolvedAddress =
              '${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)}';
          _isResolvingAddress = false;
        });
      },
      (locResult) {
        setState(() {
          _currentResolvedAddress = locResult.displayName.isNotEmpty
              ? locResult.displayName
              : locResult.address;
          _isResolvingAddress = false;
        });
      },
    );
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final q = query.trim();
      if (q.length >= 2) {
        setState(() {
          _isSearchingPlaces = true;
        });
        final res = await _mapService.searchPlaces(q);
        if (!mounted) return;
        res.fold(
          (_) => setState(() => _searchSuggestions = []),
          (list) => setState(() => _searchSuggestions = list),
        );
        setState(() {
          _isSearchingPlaces = false;
        });
      } else {
        setState(() {
          _searchSuggestions = [];
          _isSearchingPlaces = false;
        });
      }
    });
  }

  Future<void> _selectSearchSuggestion(PlaceSuggestion suggestion) async {
    _searchController.text = suggestion.description;
    setState(() {
      _searchSuggestions = [];
      _isResolvingAddress = true;
    });
    FocusScope.of(context).unfocus();

    final details = await _mapService.getPlaceDetails(suggestion.placeId);
    details.fold((_) {}, (loc) {
      if (mounted) {
        final target = LatLng(loc.latitude, loc.longitude);
        _currentCameraTarget = target;
        _currentResolvedAddress =
            loc.displayName.isNotEmpty ? loc.displayName : loc.address;
        _isResolvingAddress = false;
        _animateToLocation(target, zoom: 16);
      }
    });
  }

  Future<void> _fetchRoutePolyline() async {
    if (_originLatLng == null || _destLatLng == null) return;
    setState(() {
      _isLoadingRoute = true;
    });

    final res = await _mapService.getRoutePolyline(
      from: _originLatLng!,
      to: _destLatLng!,
    );

    if (!mounted) return;
    res.fold(
      (_) {
        setState(() {
          _routePolyline = [_originLatLng!, _destLatLng!];
          _isLoadingRoute = false;
        });
      },
      (points) {
        setState(() {
          _routePolyline = points;
          _isLoadingRoute = false;
        });
        _fitBounds();
      },
    );
  }

  void _fitBounds() {
    if (_originLatLng == null || _destLatLng == null || _mapController == null) {
      return;
    }
    final southWest = LatLng(
      _originLatLng!.latitude < _destLatLng!.latitude
          ? _originLatLng!.latitude
          : _destLatLng!.latitude,
      _originLatLng!.longitude < _destLatLng!.longitude
          ? _originLatLng!.longitude
          : _destLatLng!.longitude,
    );
    final northEast = LatLng(
      _originLatLng!.latitude > _destLatLng!.latitude
          ? _originLatLng!.latitude
          : _destLatLng!.latitude,
      _originLatLng!.longitude > _destLatLng!.longitude
          ? _originLatLng!.longitude
          : _destLatLng!.longitude,
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        70,
      ),
    );
  }

  void _confirmCurrentStep() {
    if (_currentStep == MapPickerStep.origin) {
      _originLatLng = _currentCameraTarget;
      _originName = _currentResolvedAddress.isNotEmpty
          ? _currentResolvedAddress
          : S.of(context).pickupLocation;

      if (widget.pickOriginOnly) {
        _returnResult();
        return;
      }

      setState(() {
        _currentStep = MapPickerStep.destination;
        _searchController.clear();
        _searchSuggestions = [];
      });

      if (_destLatLng != null) {
        _animateToLocation(_destLatLng!);
        _resolveAddressForTarget(_destLatLng!);
      }
    } else if (_currentStep == MapPickerStep.destination) {
      _destLatLng = _currentCameraTarget;
      _destName = _currentResolvedAddress.isNotEmpty
          ? _currentResolvedAddress
          : S.of(context).destination;

      if (widget.pickDestinationOnly) {
        _returnResult();
        return;
      }

      setState(() {
        _currentStep = MapPickerStep.routeReview;
      });
      _fetchRoutePolyline();
    } else {
      _returnResult();
    }
  }

  void _returnResult() {
    Navigator.of(context).pop({
      'originLat': _originLatLng?.latitude,
      'originLng': _originLatLng?.longitude,
      'originName': _originName.isNotEmpty ? _originName : S.of(context).pickupLocation,
      'destLat': _destLatLng?.latitude,
      'destLng': _destLatLng?.longitude,
      'destName': _destName.isNotEmpty ? _destName : S.of(context).destination,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOriginStep = _currentStep == MapPickerStep.origin;
    final isDestStep = _currentStep == MapPickerStep.destination;
    final isReviewStep = _currentStep == MapPickerStep.routeReview;

    final markers = <Marker>{};
    if (_originLatLng != null && !isOriginStep) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin_marker'),
          position: _originLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: '${S.of(context).pickupLocation}: $_originName'),
        ),
      );
    }
    if (_destLatLng != null && !isDestStep) {
      markers.add(
        Marker(
          markerId: const MarkerId('dest_marker'),
          position: _destLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: '${S.of(context).destination}: $_destName'),
        ),
      );
    }

    final polylines = <Polyline>{};
    if (isReviewStep && _routePolyline.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_preview'),
          points: _routePolyline,
          color: AppColors.primary,
          width: 5,
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentCameraTarget,
              zoom: 15,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              AppMapStyle.applyStyle(controller);
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
          ),

          // ── Center Pin Animation (when selecting point) ─────────────────
          if (!isReviewStep)
            Center(
              child: AnimatedBuilder(
                animation: _pinBounceAnim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _pinBounceAnim.value - 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOriginStep
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            isOriginStep
                                ? S.of(context).pinOriginTag
                                : S.of(context).pinDestinationTag,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.location_pin,
                          size: 44,
                          color: isOriginStep
                              ? Colors.green.shade600
                              : Colors.red.shade600,
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
                  );
                },
              ),
            ),

          // ── Top Bar & Autocomplete ──────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step Switcher Tabs
                  if (!widget.pickOriginOnly && !widget.pickDestinationOnly)
                    _buildStepTabs(),

                  const SizedBox(height: 8),

                  // Search Field
                  if (!isReviewStep) _buildSearchField(),

                  // Search Suggestions List
                  if (_searchSuggestions.isNotEmpty)
                    _buildSuggestionsList(),
                ],
              ),
            ),
          ),

          // ── GPS FAB ─────────────────────────────────────────────────────
          if (!isReviewStep)
            Positioned(
              left: 16,
              bottom: 220,
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onPressed: () async {
                  final loc = await _mapService.getCurrentLocation();
                  loc.fold((_) {}, (latLng) {
                    _animateToLocation(latLng, zoom: 16);
                  });
                },
                child: const Icon(Icons.my_location_rounded, size: 20),
              ),
            ),

          // ── Bottom Panel ────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(isOriginStep, isDestStep, isReviewStep),
          ),
        ],
      ),
    );
  }

  // ─── Step Switcher Tabs ─────────────────────────────────────────────────

  Widget _buildStepTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: _buildTabButton(
              step: MapPickerStep.origin,
              title: S.of(context).stepOrigin,
              icon: Icons.trip_origin,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabButton(
              step: MapPickerStep.destination,
              title: S.of(context).stepDestination,
              icon: Icons.flag_rounded,
              color: Colors.red,
            ),
          ),
          if (_originLatLng != null && _destLatLng != null) ...[
            const SizedBox(width: 4),
            Expanded(
              child: _buildTabButton(
                step: MapPickerStep.routeReview,
                title: S.of(context).stepRoute,
                icon: Icons.alt_route_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required MapPickerStep step,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _currentStep == step;
    return InkWell(
      onTap: () {
        setState(() {
          _currentStep = step;
          _searchController.clear();
          _searchSuggestions = [];
        });
        if (step == MapPickerStep.origin && _originLatLng != null) {
          _animateToLocation(_originLatLng!);
          _resolveAddressForTarget(_originLatLng!);
        } else if (step == MapPickerStep.destination && _destLatLng != null) {
          _animateToLocation(_destLatLng!);
          _resolveAddressForTarget(_destLatLng!);
        } else if (step == MapPickerStep.routeReview) {
          _fetchRoutePolyline();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.5), width: 1.2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Field ───────────────────────────────────────────────────────

  Widget _buildSearchField() {
    final isOrigin = _currentStep == MapPickerStep.origin;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: 13),
        decoration: InputDecoration(
          hintText: isOrigin
              ? S.of(context).searchPickupHint
              : S.of(context).searchDestinationHint,
          hintStyle:
              GoogleFonts.cairo(fontSize: 12, color: Colors.grey.shade400),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isOrigin ? Colors.green.shade600 : Colors.red.shade400,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchSuggestions = []);
                  },
                )
              : (_isSearchingPlaces
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchSuggestions.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final s = _searchSuggestions[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.place_outlined,
                color: AppColors.primary, size: 18),
            title: Text(s.description, style: GoogleFonts.cairo(fontSize: 12)),
            onTap: () => _selectSearchSuggestion(s),
          );
        },
      ),
    );
  }

  // ─── Bottom Panel ───────────────────────────────────────────────────────

  Widget _buildBottomPanel(
      bool isOrigin, bool isDest, bool isReview) {
    final displayResolvedAddress = _currentResolvedAddress.isNotEmpty
        ? _currentResolvedAddress
        : S.of(context).resolvingAddress;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReview) ...[
            // Route Summary
            _buildRouteReviewRow(
              icon: Icons.trip_origin,
              color: Colors.green,
              title: '${S.of(context).pickupLocation}:',
              address: _originName,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 11, top: 2, bottom: 2),
              child: Container(
                  width: 1.5, height: 16, color: Colors.grey.shade300),
            ),
            _buildRouteReviewRow(
              icon: Icons.flag_rounded,
              color: Colors.red,
              title: '${S.of(context).destination}:',
              address: _destName,
            ),
            const SizedBox(height: 16),
          ] else ...[
            // Live Selected Address
            Row(
              children: [
                Icon(
                  isOrigin ? Icons.trip_origin : Icons.flag_rounded,
                  size: 18,
                  color: isOrigin ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isOrigin
                      ? S.of(context).selectedPickupLocation
                      : S.of(context).selectedDestinationLocation,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isOrigin ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                const Spacer(),
                if (_isResolvingAddress)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                displayResolvedAddress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Confirm Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isReview
                    ? AppColors.primary
                    : (isOrigin ? Colors.green.shade600 : Colors.red.shade600),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _isLoadingRoute ? null : _confirmCurrentStep,
              icon: _isLoadingRoute
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isReview
                          ? Icons.search_rounded
                          : (isOrigin
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_outline_rounded),
                      size: 20,
                    ),
              label: Text(
                isReview
                    ? S.of(context).confirmRouteAndSearch
                    : (isOrigin
                        ? (widget.pickOriginOnly
                            ? S.of(context).confirmPickupLocation
                            : S.of(context).setPickupAndPickDestination)
                        : (widget.pickDestinationOnly
                            ? S.of(context).confirmDestination
                            : S.of(context).setDestinationAndReviewRoute)),
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteReviewRow({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
