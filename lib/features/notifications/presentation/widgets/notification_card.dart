import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/notifications/domain/entities/app_notification.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum NotificationCategory {
  offer,
  tripStarted,
  tripCompleted,
  tripCanceled,
  chat,
  general,
}

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final NotificationCategory category;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.category,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (category) {
      case NotificationCategory.offer:
        return const Color(0xFFF59E0B); // Amber
      case NotificationCategory.tripStarted:
        return const Color(0xFF3B82F6); // Blue
      case NotificationCategory.tripCompleted:
        return const Color(0xFF10B981); // Emerald
      case NotificationCategory.tripCanceled:
        return const Color(0xFFEF4444); // Red
      case NotificationCategory.chat:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationCategory.general:
        return AppColors.primary;
    }
  }

  IconData get _categoryIcon {
    switch (category) {
      case NotificationCategory.offer:
        return Icons.local_offer_rounded;
      case NotificationCategory.tripStarted:
        return Icons.directions_car_rounded;
      case NotificationCategory.tripCompleted:
        return Icons.check_circle_rounded;
      case NotificationCategory.tripCanceled:
        return Icons.cancel_rounded;
      case NotificationCategory.chat:
        return Icons.chat_bubble_rounded;
      case NotificationCategory.general:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? const Color(0xFFE2E8F0)
                : AppColors.primary.withOpacity(0.35),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isRead
                  ? Colors.black.withOpacity(0.02)
                  : AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_categoryIcon, color: _categoryColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title.isNotEmpty
                              ? title
                              : S.of(context).newNotificationTitle,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: isRead
                            ? const Color(0xFF64748B)
                            : const Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
