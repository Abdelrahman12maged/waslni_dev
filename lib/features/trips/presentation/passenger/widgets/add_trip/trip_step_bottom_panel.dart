import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/generated/l10n.dart';

/// Step bottom panel for pickup -> destination -> trip details confirmation.
class TripStepBottomPanel extends StatelessWidget {
  final int step;
  final String startLocationText;
  final String destinationLocationText;
  final bool hasStartLocation;
  final bool hasDestinationLocation;
  final LocationResult? currentLocationResult;
  final VoidCallback onConfirm;
  final VoidCallback onDetails;
  final VoidCallback onEditStart;
  final VoidCallback onEditDestination;

  const TripStepBottomPanel({
    super.key,
    required this.step,
    required this.startLocationText,
    required this.destinationLocationText,
    required this.hasStartLocation,
    required this.hasDestinationLocation,
    required this.currentLocationResult,
    required this.onConfirm,
    required this.onDetails,
    required this.onEditStart,
    required this.onEditDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Route summary when locations are set
          if (hasStartLocation) ...[
            _RouteRow(
              icon: Icons.trip_origin,
              color: AppColors.primary,
              text: startLocationText.isNotEmpty
                  ? startLocationText
                  : S.of(context).pickupSelected,
              onEdit: onEditStart,
            ),
            if (hasDestinationLocation) ...[
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 2,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              _RouteRow(
                icon: Icons.flag_rounded,
                color: const Color(0xFF1B5E20),
                text: destinationLocationText.isNotEmpty
                    ? destinationLocationText
                    : S.of(context).destinationSelected,
                onEdit: onEditDestination,
              ),
            ],
            const SizedBox(height: 14),
          ],

          // Action button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: step < 2
                ? SizedBox(
                    key: ValueKey('step_$step'),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: currentLocationResult == null ? null : onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: step == 0
                            ? AppColors.primary
                            : const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      icon: Icon(
                        step == 0
                            ? Icons.my_location
                            : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        step == 0
                            ? S.of(context).confirmPickupLocation
                            : S.of(context).confirmDestinationLocation,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('step_done'),
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: onDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        S.of(context).tripDetails,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onEdit;

  const _RouteRow({
    required this.icon,
    required this.color,
    required this.text,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                S.of(context).edit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      );
}
