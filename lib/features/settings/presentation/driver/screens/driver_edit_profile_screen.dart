import 'package:flutter/material.dart';
import 'package:car_app/features/settings/presentation/driver/screens/widgets/driver_edit_profile_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Driver Edit Profile Screen
// ─────────────────────────────────────────────────────────────────────────────
class DriverEditProfileScreen extends StatelessWidget {
  final VoidCallback updateStates;

  const DriverEditProfileScreen({super.key, required this.updateStates});

  @override
  Widget build(BuildContext context) {
    return DriverEditProfileView(updateStates: updateStates);
  }
}
