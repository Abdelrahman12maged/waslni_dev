import 'package:flutter/material.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/core/utils/chat_channel_helper.dart';
import 'package:car_app/core/widgets/unread_badge.dart';
import 'package:car_app/core/di/injection_container.dart';

/// Group chat navigation button with unread messages counter badge.
class DriverSharedGroupChatButton extends StatelessWidget {
  final int tripId;
  final VoidCallback onTap;

  const DriverSharedGroupChatButton({
    super.key,
    required this.tripId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final groupChatId =
        ChatChannelHelper.sharedTripGroupChatId(tripId: tripId);
    final currentUserId =
        sl<LocalStorage>().read(key: 'userid')?.toString() ??
            sl<LocalStorage>().read(key: 'user_id')?.toString() ??
            '';

    return UnreadBadge(
      chatId: groupChatId,
      currentUserId: currentUserId,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onTap,
          icon: const Icon(Icons.groups_rounded, size: 22, color: Colors.white),
          label: const Text(
            'الدردشة الجماعية للرحلة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
