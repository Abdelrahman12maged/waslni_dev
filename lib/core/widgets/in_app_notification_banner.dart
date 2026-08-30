import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:car_app/core/router/app_router.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/generated/l10n.dart';

/// Interactive In-App Heads-up Notification Banner that slides down from top.
class InAppNotificationBanner {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Shows the in-app notification banner at the top of the screen.
  static void show({
    BuildContext? context,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Dismiss any currently displayed banner first
    dismiss();

    final overlayState = AppRouter.rootNavigatorKey.currentState?.overlay ??
        (context != null ? Overlay.maybeOf(context, rootOverlay: true) : null);
    if (overlayState == null) return;

    _currentEntry = OverlayEntry(
      builder: (ctx) => _InAppNotificationWidget(
        title: title,
        body: body,
        data: data ?? {},
        onTap: () {
          dismiss();
          onTap?.call();
        },
        onDismiss: () => dismiss(),
      ),
    );

    overlayState.insert(_currentEntry!);

    _dismissTimer = Timer(duration, () {
      dismiss();
    });
  }

  /// Dismisses the currently visible banner.
  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    required this.title,
    required this.body,
    required this.data,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationWidget> createState() => _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  void _dismissWithAnimation() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _NotificationStyle _resolveStyle(String type) {
    switch (type.toLowerCase()) {
      case 'new_offer':
      case 'offer':
      case 'private_offer':
      case 'offer_submitted':
      case 'offer_accepted':
      case 'offer_rejected':
        return _NotificationStyle(
          icon: Icons.local_offer_rounded,
          color: const Color(0xFFF59E0B),
          badgeText: S.current.offersFilter,
        );
      case 'trip_started':
      case 'on_the_way':
      case 'driver_arrived':
        return _NotificationStyle(
          icon: Icons.directions_car_filled_rounded,
          color: AppColors.primary,
          badgeText: S.current.tripsFilter,
        );
      case 'trip_completed':
        return _NotificationStyle(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          badgeText: S.current.tripStatusCompleted,
        );
      case 'chat':
      case 'message':
      case 'new_message':
        return _NotificationStyle(
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFF6366F1),
          badgeText: S.current.newMessageBanner,
        );
      default:
        return _NotificationStyle(
          icon: Icons.notifications_active_rounded,
          color: AppColors.primary,
          badgeText: S.current.newNotificationTitle,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final type = widget.data['type']?.toString() ?? '';
    final style = _resolveStyle(type);

    return Positioned(
      top: topPadding + 6,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Dismissible(
            key: const Key('in_app_banner_dismissible'),
            direction: DismissDirection.up,
            onDismissed: (_) => widget.onDismiss(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: style.color.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: style.color.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Leading glowing icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            style.icon,
                            color: style.color,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Text Content
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title.isNotEmpty
                                        ? widget.title
                                        : style.badgeText,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: style.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    S.of(context).justNow,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: style.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.body,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: const Color(0xFF475569),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Trailing action / dismiss
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          S.of(context).viewNotificationAction,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color color;
  final String badgeText;

  _NotificationStyle({
    required this.icon,
    required this.color,
    required this.badgeText,
  });
}
