import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:car_app/features/trips/presentation/passenger/screens/shared/widgets/shared_trip_map_picker_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared Trip Map Picker Screen
// ─────────────────────────────────────────────────────────────────────────────
class SharedTripMapPickerScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SharedTripMapPickerView(
      initialOrigin: initialOrigin,
      initialOriginName: initialOriginName,
      initialDestination: initialDestination,
      initialDestinationName: initialDestinationName,
      pickDestinationOnly: pickDestinationOnly,
      pickOriginOnly: pickOriginOnly,
    );
  }
}
