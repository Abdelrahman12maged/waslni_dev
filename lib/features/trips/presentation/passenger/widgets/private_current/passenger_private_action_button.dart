import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/features/trips/presentation/passenger/widgets/private_current/passenger_private_top_bar.dart';

/// Context-aware action button for passenger tracking screen.
class PassengerPrivateActionButton extends StatelessWidget {
  const PassengerPrivateActionButton({
    super.key,
    required this.phase,
    required this.phaseColor,
    required this.isInCar,
    required this.isLoading,
    required this.onArriveCar,
  });

  final PassengerTripPhase phase;
  final Color phaseColor;
  final bool isInCar;
  final bool isLoading;
  final VoidCallback onArriveCar;

  @override
  Widget build(BuildContext context) {
    // In trip — trip active indicator
    if (phase == PassengerTripPhase.inTrip) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FFF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF05A357).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_rounded,
                color: Color(0xFF05A357), size: 22),
            const SizedBox(width: 10),
            Text(
              S.of(context).tripInProgress,
              style: const TextStyle(
                color: Color(0xFF05A357),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Driver arrived — show "I'm in the car" button
    if (phase == PassengerTripPhase.driverArrived) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isInCar || isLoading ? null : onArriveCar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF05A357),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      isInCar
                          ? S.of(context).youAreInTheCar
                          : S.of(context).ArrivedCar,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    // Driver on way / near / pending — waiting state
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: phaseColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            S.of(context).waitingForDriver,
            style: TextStyle(
              color: phaseColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// Secondary action buttons row (Change driver / Cancel trip).
class PassengerPrivateSecondaryActions extends StatelessWidget {
  final VoidCallback? onChangeDriver;
  final VoidCallback? onCancelTrip;

  const PassengerPrivateSecondaryActions({
    super.key,
    this.onChangeDriver,
    this.onCancelTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onChangeDriver,
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: Text(
              S.of(context).changeDriverConfirmTitle,
              style: GoogleFonts.cairo(
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF276EF1),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancelTrip,
            icon: Icon(Icons.cancel_outlined,
                size: 16, color: Colors.red[700]),
            label: Text(
              S.of(context).confirmCancelTrip,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red.shade200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
