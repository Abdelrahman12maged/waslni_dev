import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';

String getDriverPrivateActionButtonText(BuildContext context, String status) {
  switch (status) {
    case 'pending':
      return S.of(context).startMovingToClient;
    case 'on_the_way':
      return S.of(context).nearClientLocation;
    case 'close_to_customer':
      return S.of(context).confirmArrivalAtClient;
    case 'arrive_customer':
      return S.of(context).startPrivateTripAction;
    case 'start':
      return S.of(context).endPrivateTripAction;
    case 'end':
    default:
      return S.of(context).tripCompleted;
  }
}

class DriverPrivateActionButton extends StatelessWidget {
  final String onGoingStatus;
  final bool isUpdatingStatus;
  final VoidCallback onPressed;

  const DriverPrivateActionButton({
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
                getDriverPrivateActionButtonText(context, onGoingStatus),
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
