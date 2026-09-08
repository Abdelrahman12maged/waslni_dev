import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/generated/l10n.dart';

enum PassengerTripPhase {
  driverPending,
  driverOnWay,
  driverNear,
  driverArrived,
  inTrip,
}

/// Floating top status bar with dynamic phase badge, ETA, distance, and action menus.
class PassengerPrivateTopBar extends StatelessWidget {
  const PassengerPrivateTopBar({
    super.key,
    required this.phase,
    required this.phaseColor,
    required this.title,
    required this.subtitle,
    required this.pulseAnim,
    required this.onRefresh,
    this.onChangeDriver,
    this.onCancelTrip,
    this.etaMinutes = 0,
    this.distanceRemainingKm = 0.0,
  });

  final PassengerTripPhase phase;
  final Color phaseColor;
  final String title;
  final String subtitle;
  final Animation<double> pulseAnim;
  final VoidCallback onRefresh;
  final VoidCallback? onChangeDriver;
  final VoidCallback? onCancelTrip;
  final int etaMinutes;
  final double distanceRemainingKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Pulsing dot
              ScaleTransition(
                scale: pulseAnim,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: phaseColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: phaseColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh_rounded, color: phaseColor, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded,
                    color: Color(0xFF6B7280), size: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (val) {
                  if (val == 'change_driver') {
                    onChangeDriver?.call();
                  } else if (val == 'cancel') {
                    onCancelTrip?.call();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'change_driver',
                    child: Row(
                      children: [
                        const Icon(Icons.person_search_rounded,
                            color: Color(0xFF276EF1), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          S.of(context).changeDriverConfirmTitle,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined,
                            color: Colors.red[700], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          S.of(context).confirmCancelTrip,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (distanceRemainingKm > 0 || etaMinutes > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: phaseColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 15, color: phaseColor),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).minutesApprox(etaMinutes),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 12,
                    color: phaseColor.withOpacity(0.3),
                  ),
                  Row(
                    children: [
                      Icon(Icons.navigation_outlined,
                          size: 15, color: phaseColor),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).kmDistance(
                            distanceRemainingKm.toStringAsFixed(1)),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: phaseColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
