import 'package:flutter/material.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/theme/app_colors.dart';

class PassengerPrivateDriverCard extends StatelessWidget {
  const PassengerPrivateDriverCard({
    super.key,
    required this.driverName,
    this.rating,
    required this.carModel,
    required this.plateNumber,
    required this.onCall,
    required this.onChat,
  });

  final String driverName;
  final String? rating;
  final String carModel;
  final String plateNumber;
  final VoidCallback onCall;
  final Widget onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person,
                    size: 30, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (rating != null && rating!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Color(0xFFFFB800)),
                          const SizedBox(width: 4),
                          Text(
                            rating!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF555555),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              onChat,
              const SizedBox(width: 8),
              _CircleButton(
                icon: Icons.phone_rounded,
                color: const Color(0xFF05A357),
                onTap: onCall,
              ),
            ],
          ),
          if (carModel.isNotEmpty || plateNumber.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (carModel.isNotEmpty) ...[
                  const Icon(Icons.directions_car_rounded,
                      size: 16, color: Color(0xFF888888)),
                  const SizedBox(width: 6),
                  Text(
                    carModel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const Spacer(),
                if (plateNumber.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                    ),
                    child: Text(
                      PlateNumberFormatter.format(plateNumber),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFF1A1A1A),
                      ),
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
