import 'package:flutter/material.dart';
import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/chat/data/datasources/chat_remote_datasource.dart';

/// Builder widget that streams real-time unread messages count for a specific [chatId].
class UnreadCountBuilder extends StatelessWidget {
  final String chatId;
  final String? currentUserId;
  final Widget Function(BuildContext context, int unreadCount) builder;

  const UnreadCountBuilder({
    super.key,
    required this.chatId,
    this.currentUserId,
    required this.builder,
  });

  String _resolveUserId() {
    if (currentUserId != null && currentUserId!.isNotEmpty) {
      return currentUserId!;
    }
    final storage = sl<LocalStorage>();
    return storage.read(key: 'userid')?.toString() ??
        storage.read(key: 'user_id')?.toString() ??
        storage.read(key: 'id')?.toString() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final uid = _resolveUserId();
    if (chatId.isEmpty || uid.isEmpty) {
      return builder(context, 0);
    }

    return StreamBuilder<int>(
      stream: sl<ChatRemoteDataSource>().getUnreadCount(
        chatId: chatId,
        currentUserId: uid,
      ),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return builder(context, count);
      },
    );
  }
}

/// A badge that automatically overlays on [child] with the real-time unread count.
class UnreadBadge extends StatelessWidget {
  final String chatId;
  final String? currentUserId;
  final Widget child;
  final double top;
  final double end;
  final Color badgeColor;
  final Color textColor;
  final double fontSize;

  const UnreadBadge({
    super.key,
    required this.chatId,
    this.currentUserId,
    required this.child,
    this.top = -4,
    this.end = -4,
    this.badgeColor = const Color(0xFFEF4444),
    this.textColor = Colors.white,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return UnreadCountBuilder(
      chatId: chatId,
      currentUserId: currentUserId,
      builder: (context, count) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (count > 0)
              PositionedDirectional(
                top: top,
                end: end,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
