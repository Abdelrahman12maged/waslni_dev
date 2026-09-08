import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/map/presentation/style/app_map_style.dart';

const CameraPosition kDefaultDriverMapCamera = CameraPosition(
  target: LatLng(31.963158, 35.930359),
  zoom: 15,
);

/// Pure GoogleMap view for driver shared trip tracking with custom styled markers & polylines.
class DriverSharedMapView extends StatelessWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final void Function(GoogleMapController controller) onMapCreated;
  final VoidCallback onRecenter;

  const DriverSharedMapView({
    super.key,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: kDefaultDriverMapCamera,
          onMapCreated: (c) {
            onMapCreated(c);
            AppMapStyle.applyStyle(c);
          },
          markers: markers,
          polylines: polylines,
        ),
        Positioned(
          bottom: 150,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'recenter_driver_shared',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 4,
            onPressed: onRecenter,
            child: const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}
