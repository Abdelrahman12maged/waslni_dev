import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';

String getDriverSharedActionButtonText(BuildContext context, String status) {
  switch (status) {
    case 'pending':
      return S.of(context).startMovingToPassengers;
    case 'on_the_way':
      return S.of(context).nearPassengerLocation;
    case 'close_to_customer':
      return S.of(context).confirmArrivalAtPassengers;
    case 'arrive_customer':
      return S.of(context).startSharedTripAction;
    case 'start':
      return S.of(context).endSharedTripAction;
    case 'end':
    default:
      return S.of(context).sharedTripCompleted;
  }
}

class DriverSharedActionButton extends StatelessWidget {
  final String onGoingStatus;
  final bool isUpdatingStatus;
  final VoidCallback onPressed;

  const DriverSharedActionButton({
    super.key,
    required this.onGoingStatus,
    required this.isUpdatingStatus,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isUpdatingStatus ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onGoingStatus == 'start'
              ? Colors.green.shade600
              : AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isUpdatingStatus
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                getDriverSharedActionButtonText(context, onGoingStatus),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class DriverCancelSharedTripButton extends StatelessWidget {
  final VoidCallback onCancel;

  const DriverCancelSharedTripButton({
    super.key,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onCancel,
        icon: Icon(Icons.cancel_outlined, color: Colors.red[700], size: 18),
        label: Text(
          S.of(context).cancelSharedTripCompletely,
          style: GoogleFonts.cairo(
            color: Colors.red[700],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
