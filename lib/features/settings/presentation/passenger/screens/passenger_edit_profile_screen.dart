import 'package:flutter/material.dart';
import 'package:car_app/features/settings/presentation/passenger/screens/widgets/passenger_edit_profile_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passenger Edit Profile Screen
// ─────────────────────────────────────────────────────────────────────────────
class PassengerEditProfileScreen extends StatelessWidget {
  final VoidCallback updateStates;

  const PassengerEditProfileScreen({super.key, required this.updateStates});

  @override
  Widget build(BuildContext context) {
    return PassengerEditProfileView(updateStates: updateStates);
  }
}
