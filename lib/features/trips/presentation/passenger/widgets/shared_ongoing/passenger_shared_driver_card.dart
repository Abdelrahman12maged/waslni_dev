import 'package:flutter/material.dart';
import 'package:car_app/core/formatters/plate_number_formatter.dart';
import 'package:car_app/core/theme/app_colors.dart';

/// Driver profile & actions card for passenger ongoing shared trip.
class PassengerSharedDriverCard extends StatelessWidget {
  const PassengerSharedDriverCard({
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
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Name & car info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (rating != null) ...[
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFF5A623), size: 14),
                      const SizedBox(width: 3),
                      Text(
                        rating!,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF666666)),
                      ),
                    ],
                    if (carModel.isNotEmpty) ...[
                      if (rating != null) ...[
                        const SizedBox(width: 10),
                        const Text('•',
                            style: TextStyle(
                                color: Color(0xFFCCCCCC), fontSize: 12)),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          carModel,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF666666)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (plateNumber.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        PlateNumberFormatter.format(plateNumber),
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Chat button
          GestureDetector(
            onTap: onChat,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Color(0xFF276EF1),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Call button
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Color(0xFF05A357),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
