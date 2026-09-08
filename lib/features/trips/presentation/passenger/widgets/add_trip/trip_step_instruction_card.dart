import 'package:flutter/material.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/map/domain/entities/location_result.dart';
import 'package:car_app/generated/l10n.dart';

/// Instruction card displaying step progression and current address on map.
class TripStepInstructionCard extends StatelessWidget {
  final int step;
  final LocationResult? currentLocationResult;

  const TripStepInstructionCard({
    super.key,
    required this.step,
    required this.currentLocationResult,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      S.of(context).pickupPoint,
      S.of(context).destinationPoint,
      S.of(context).pickupSelected,
    ];
    final subs = [
      S.of(context).moveMapAndConfirm,
      S.of(context).moveMapAndSelectDestination,
      S.of(context).tapTripDetailsToContinue,
    ];
    const icons = [
      Icons.trip_origin,
      Icons.flag_rounded,
      Icons.check_circle_outline,
    ];
    final colors = [
      AppColors.primary,
      const Color(0xFF1B5E20),
      Colors.orange.shade800,
    ];

    final s = step.clamp(0, 2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Step Dots ──────────────────────────────────────────
          Row(
            children: List.generate(3, (i) {
              final active = i == s;
              final done = i < s;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 6,
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFF1B5E20)
                              : active
                                  ? colors[s]
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 4),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // ── Icon + Text ────────────────────────────────────────
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors[s].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icons[s], color: colors[s], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[s],
                      style: TextStyle(
                        color: colors[s],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subs[s],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Live Address ───────────────────────────────────────
          if (currentLocationResult != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade400, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    currentLocationResult!.displayName,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
