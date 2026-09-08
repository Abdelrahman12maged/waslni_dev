import 'package:flutter/material.dart';
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/widgets/app_cached_image.dart';
import 'package:car_app/core/widgets/unread_badge.dart';

class CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CircleActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Passenger profile card with call, chat (with badge), and cancel actions.
class DriverPrivatePassengerCard extends StatelessWidget {
  final String passengerName;
  final String passengerPhone;
  final String? passengerPhoto;
  final String chatId;
  final String currentDriverId;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  const DriverPrivatePassengerCard({
    super.key,
    required this.passengerName,
    required this.passengerPhone,
    this.passengerPhoto,
    required this.chatId,
    required this.currentDriverId,
    required this.onCall,
    required this.onChat,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          backgroundImage: appCachedImageProvider(passengerPhoto),
          child: (passengerPhoto == null || passengerPhoto!.isEmpty)
              ? const Icon(Icons.person, color: AppColors.primary, size: 28)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                passengerName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            CircleActionButton(
              icon: Icons.phone,
              color: Colors.green,
              onTap: onCall,
            ),
            const SizedBox(width: 6),
            UnreadBadge(
              chatId: chatId,
              currentUserId: currentDriverId,
              child: CircleActionButton(
                icon: Icons.chat_bubble_outline,
                color: AppColors.primary,
                onTap: onChat,
              ),
            ),
            const SizedBox(width: 6),
            CircleActionButton(
              icon: Icons.cancel_outlined,
              color: Colors.red[700]!,
              onTap: onCancel,
            ),
          ],
        ),
      ],
    );
  }
}
