import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';
import 'package:car_app/features/trips/presentation/passenger/cubit/passenger_trips_cubit.dart';
import 'package:car_app/features/trips/presentation/shared_widgets/trip_details_screen_content.dart';
import 'package:car_app/generated/l10n.dart';

class PassengerSharedSuspendedScreenClean extends StatelessWidget {
  const PassengerSharedSuspendedScreenClean({
    super.key,
    required this.trip,
  });

  final Trip trip;

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          S.of(context).reasonForCanceling,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: S.of(context).enterYourReason,
            hintStyle: GoogleFonts.cairo(fontSize: 13, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(context).cancel, style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              PassengerTripsCubit.get(context).cancelTrip(trip.id);
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).cancelTrip, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
          S.of(context).suspendedTrips,
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
        bottomAction: OutlinedButton.icon(
          onPressed: () => _showCancelDialog(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 20),
          label: Text(
            S.of(context).cancelTrip,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEF4444),
            ),
          ),
        ),
      ),
    );
  }
}
