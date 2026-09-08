import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/location_helper.dart';
import 'package:car_app/generated/l10n.dart';

/// Summary of pickup and destination locations for ongoing shared trip.
class DriverSharedRouteSummary extends StatelessWidget {
  final String? fromLocation;
  final String? toLocation;

  const DriverSharedRouteSummary({
    super.key,
    this.fromLocation,
    this.toLocation,
  });

  @override
  Widget build(BuildContext context) {
    final from = cleanLocationName(fromLocation ?? '');
    final to = cleanLocationName(toLocation ?? '');

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.trip_origin, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                from.isNotEmpty ? from : S.of(context).pickupPoint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 2,
                height: 16,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                to.isNotEmpty ? to : S.of(context).destinationPoint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
