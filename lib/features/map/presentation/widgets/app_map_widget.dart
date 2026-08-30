import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/features/map/presentation/cubit/map_cubit.dart';
import 'package:car_app/features/map/presentation/cubit/map_state.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';
import 'package:car_app/features/map/presentation/widgets/center_pin_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Modes of the map:
/// - [pin]: drag-center-pin to pick a location (used when adding a trip)
/// - [view]: view-only with markers (used for ongoing trip tracking)
enum AppMapMode { pin, view }

/// A reusable Google Map widget driven entirely by [MapCubit].
///
/// **pin mode**: Shows a floating animated pin at the center. When the camera
/// stops moving, the cubit resolves the address automatically.
///
/// **view mode**: Shows static markers (start/destination). No center pin.
///
/// Usage (pin mode — add trip):
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<MapCubit>()..loadCurrentLocation(),
///   child: AppMapWidget(
///     mode: AppMapMode.pin,
///     onConfirmLocation: (result) { /* use LocationResult */ },
///   ),
/// )
/// ```
class AppMapWidget extends StatelessWidget {
  const AppMapWidget({
    super.key,
    this.mode = AppMapMode.view,
    this.initialPosition = const LatLng(31.963158, 35.930359),
    this.onConfirmLocation,
    this.onMapCreated,
    this.markers = const {},
    this.polylines = const {},
    this.polylinePoints = const [],
    this.padding = EdgeInsets.zero,
    this.mapStyle,
    this.onCameraMove,
    this.onCameraIdle,
  });

  final void Function(CameraPosition)? onCameraMove;
  final VoidCallback? onCameraIdle;

  final AppMapMode mode;
  final LatLng initialPosition;

  /// Called when user confirms a pin location (pin mode only).
  final void Function(LocationResult)? onConfirmLocation;

  /// Optional callback when GoogleMapController is initialized.
  final void Function(GoogleMapController)? onMapCreated;

  /// External markers to show (view mode).
  final Set<Marker> markers;

  /// External polylines to show (view mode).
  final Set<Polyline> polylines;

  /// Route polyline points (view mode).
  final List<LatLng> polylinePoints;

  /// Map padding (e.g. for bottom sheet offsets).
  final EdgeInsets padding;

  /// Optional custom map style JSON string.
  final String? mapStyle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(
      builder: (context, state) {
        final cubit = MapCubit.of(context);

        // Merge external markers with cubit markers
        final allMarkers = {
          ...markers,
          if (state is MapMarkersUpdated) ...state.markers,
        };

        // Build polylines
        final allPolylines = <Polyline>{
          ...polylines,
          if (polylinePoints.isNotEmpty)
            Polyline(
              polylineId: const PolylineId('trip_route'),
              points: polylinePoints,
              color: Colors.blue.shade700,
              width: 4,
            ),
          if (state is MapRouteLoaded)
            Polyline(
              polylineId: const PolylineId('trip_route'),
              points: state.polylinePoints,
              color: Colors.blue.shade700,
              width: 4,
            ),
        };

        return Stack(
          alignment: Alignment.center,
          children: [
            // ── GoogleMap ────────────────────────────────────────────────
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: state is MapLocationLoaded
                    ? state.currentLocation
                    : initialPosition,
                zoom: 15,
              ),
              markers: allMarkers,
              polylines: allPolylines,
              padding: padding,
              myLocationEnabled: true,
              myLocationButtonEnabled: mode == AppMapMode.view,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                AppMapStyle.applyStyle(controller);
                cubit.onMapCreated(controller);
                onMapCreated?.call(controller);
              },
              onCameraMove: (camPos) {
                if (mode == AppMapMode.pin) {
                  cubit.onCameraMove(camPos);
                }
                onCameraMove?.call(camPos);
              },
              onCameraIdle: () async {
                if (mode == AppMapMode.pin) {
                  final pos = await BlocProvider.of<MapCubit>(context)
                      .getCurrentCameraPosition();
                  if (pos != null) {
                    cubit.onCameraIdle(pos);
                  }
                }
                onCameraIdle?.call();
              },
            ),

            // ── Center Pin (pin mode only) ────────────────────────────────
            if (mode == AppMapMode.pin) ...[
              const CenterPinAnimation(),
            ],

            // ── Loading Overlay ───────────────────────────────────────────
            if (state is MapLoading)
              const Center(child: CircularProgressIndicator()),

            // ── My Location FAB ───────────────────────────────────────────
            if (mode == AppMapMode.pin)
              Positioned(
                bottom: 100,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'map_my_location',
                  backgroundColor: Colors.white,
                  onPressed: cubit.loadCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),
          ],
        );
      },
    );
  }
}
