import 'package:flutter/material.dart';
import 'package:car_app/generated/l10n.dart';

/// Detailed route summary card with pickup and destination points for passenger trip tracking.
class PassengerPrivateRouteRow extends StatelessWidget {
  const PassengerPrivateRouteRow({
    super.key,
    required this.from,
    required this.to,
  });

  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          _RoutePoint(
            icon: Icons.circle,
            iconColor: const Color(0xFF05A357),
            iconSize: 10,
            label: S.of(context).pickupLocation,
            value: from,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Column(
              children: List.generate(
                3,
                (i) => Container(
                  width: 1.5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
          _RoutePoint(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFE53E3E),
            iconSize: 18,
            label: S.of(context).destination,
            value: to,
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.isEmpty ? '---' : value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
