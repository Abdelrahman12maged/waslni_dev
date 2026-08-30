import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trip_details_screen_content.dart';
import 'package:car_app/generated/l10n.dart';

class PassengerPrivateCompletedScreenClean extends StatelessWidget {
  const PassengerPrivateCompletedScreenClean({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context).completedTrips,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: TripDetailsScreenContent(
        trip: trip,
        isDriver: false,
      ),
    );
  }
}
