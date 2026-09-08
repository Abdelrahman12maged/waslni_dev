import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';

/// Floating Status Header Pill for driver ongoing private trip.
class DriverPrivateStatusPill extends StatelessWidget {
  final String status;
  final int etaMinutes;
  final double distanceRemainingKm;

  const DriverPrivateStatusPill({
    super.key,
    required this.status,
    this.etaMinutes = 0,
    this.distanceRemainingKm = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case 'pending':
        text = S.of(context).startMovingToClient;
        color = Colors.blue.shade700;
        break;
      case 'on_the_way':
        text = S.of(context).nearClientLocation;
        color = AppColors.primary;
        break;
      case 'close_to_customer':
        text = S.of(context).confirmArrivalAtClient;
        color = Colors.amber.shade800;
        break;
      case 'arrive_customer':
        text = S.of(context).confirmArrivalAtClient;
        color = Colors.orange.shade800;
        break;
      case 'start':
        text = S.of(context).startPrivateTripAction;
        color = Colors.green.shade700;
        break;
      case 'end':
        text = S.of(context).tripCompleted;
        color = Colors.grey.shade700;
        break;
      default:
        text = S.of(context).trackPrivateTrip;
        color = AppColors.primary;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (distanceRemainingKm > 0 || etaMinutes > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  S.of(context).minutesCount(etaMinutes),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey.shade400)),
                const SizedBox(width: 8),
                Icon(Icons.navigation_outlined, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  S.of(context).kmDistance(distanceRemainingKm.toStringAsFixed(1)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
