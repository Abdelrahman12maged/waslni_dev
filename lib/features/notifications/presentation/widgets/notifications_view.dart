import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:car_app/core/di/injection_container.dart' as di;
import 'package:car_app/core/services/notification_routing_service.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:car_app/features/notifications/domain/entities/app_notification.dart';
import 'package:car_app/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:car_app/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:car_app/features/notifications/presentation/widgets/notification_card.dart';
import 'package:car_app/features/notifications/presentation/widgets/notification_skeleton.dart';
import 'package:car_app/generated/l10n.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _isLoading = true;
  final Set<int> _readNotificationIds = {};
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNotifications();
    });
  }

  void _fetchNotifications() {
    context.read<NotificationsCubit>().getUsersNotifications(
          stoploading: _stopLoading,
          isThisLoading: true,
        );
  }

  void _stopLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markAllAsRead(List<AppNotification> list) {
    setState(() {
      for (final n in list) {
        if (n.id != null) {
          _readNotificationIds.add(n.id!);
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          S.of(context).allNotificationsMarkedAsRead,
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool _isNotificationRead(AppNotification notification) {
    if (notification.isRead) return true;
    if (notification.id != null &&
        _readNotificationIds.contains(notification.id)) {
      return true;
    }
    return false;
  }

  String _formatNotificationTime(String? rawDate, bool isArabic) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final dateTime = DateTime.tryParse(rawDate)?.toLocal();
      if (dateTime == null) {
        if (rawDate.contains('T')) {
          final parts = rawDate.split('T');
          final timePart = parts.length > 1 && parts[1].length >= 5
              ? parts[1].substring(0, 5)
              : '';
          return '${parts[0]} $timePart'.trim();
        }
        return rawDate;
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return S.current.justNow;
      } else if (difference.inMinutes < 60) {
        final m = difference.inMinutes;
        return S.current.minutesAgo(m);
      } else if (difference.inHours < 24 && now.day == dateTime.day) {
        final timeStr =
            DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(dateTime);
        return S.current.todayAt(timeStr);
      } else if (difference.inDays < 2 ||
          (difference.inHours < 48 && now.day - dateTime.day == 1)) {
        final timeStr =
            DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(dateTime);
        return S.current.yesterdayAt(timeStr);
      } else {
        return DateFormat('yyyy/MM/dd - hh:mm a', isArabic ? 'ar' : 'en')
            .format(dateTime);
      }
    } catch (_) {
      return rawDate;
    }
  }

  NotificationCategory _categorizeNotification(
      String title, String description) {
    final combined = '$title $description'.toLowerCase();
    if (combined.contains('عرض') ||
        combined.contains('offer') ||
        combined.contains('سعر') ||
        combined.contains('price')) {
      return NotificationCategory.offer;
    }
    if (combined.contains('بدأت') ||
        combined.contains('started') ||
        combined.contains('وصول') ||
        combined.contains('arrived')) {
      return NotificationCategory.tripStarted;
    }
    if (combined.contains('اكتملت') ||
        combined.contains('completed') ||
        combined.contains('انتهت') ||
        combined.contains('finished')) {
      return NotificationCategory.tripCompleted;
    }
    if (combined.contains('إلغاء') ||
        combined.contains('الغاء') ||
        combined.contains('cancelled') ||
        combined.contains('canceled')) {
      return NotificationCategory.tripCanceled;
    }
    if (combined.contains('رسالة') ||
        combined.contains('message') ||
        combined.contains('chat') ||
        combined.contains('محادثة')) {
      return NotificationCategory.chat;
    }
    return NotificationCategory.general;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsSuccess || state is NotificationsError) {
          _stopLoading();
        }
      },
      builder: (context, state) {
        final cubit = NotificationsCubit.get(context);
        final allNotifications = cubit.notifications;
        final unreadCount =
            allNotifications.where((n) => !_isNotificationRead(n)).length;

        final filteredList = allNotifications.where((n) {
          final isRead = _isNotificationRead(n);
          final title = (isArabic ? n.titleAr : n.titleEn) ??
              n.titleAr ??
              n.titleEn ??
              '';
          final desc = (isArabic ? n.descriptionAr : n.descriptionEn) ??
              n.descriptionAr ??
              n.descriptionEn ??
              '';
          final category = _categorizeNotification(title, desc);

          if (_selectedFilterIndex == 1) {
            return !isRead;
          } else if (_selectedFilterIndex == 2) {
            return category == NotificationCategory.offer;
          } else if (_selectedFilterIndex == 3) {
            return category == NotificationCategory.tripStarted ||
                category == NotificationCategory.tripCompleted ||
                category == NotificationCategory.tripCanceled;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E293B), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.of(context).notifications,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (allNotifications.isNotEmpty)
                IconButton(
                  tooltip: S.of(context).markAllAsRead,
                  icon: const Icon(Icons.done_all_rounded,
                      color: AppColors.primary, size: 22),
                  onPressed: () => _markAllAsRead(allNotifications),
                ),
            ],
          ),
          body: Column(
            children: [
              if (!_isLoading && allNotifications.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                            index: 0,
                            label:
                                '${S.of(context).allNotificationsFilter} (${allNotifications.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            index: 1,
                            label:
                                '${S.of(context).unreadNotificationsFilter} ($unreadCount)'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            index: 2, label: S.of(context).offersFilter),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            index: 3, label: S.of(context).tripsFilter),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const NotificationSkeletonList()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async => _fetchNotifications(),
                        child: filteredList.isEmpty
                            ? _buildEmptyState(
                                context, _selectedFilterIndex > 0)
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                    16, 16, 16, 32),
                                itemCount: filteredList.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final notification = filteredList[index];
                                  final title = (isArabic
                                          ? notification.titleAr
                                          : notification.titleEn) ??
                                      notification.titleAr ??
                                      notification.titleEn ??
                                      '';
                                  final description = (isArabic
                                          ? notification.descriptionAr
                                          : notification.descriptionEn) ??
                                      notification.descriptionAr ??
                                      notification.descriptionEn ??
                                      '';
                                  final timeFormatted =
                                      _formatNotificationTime(
                                          notification.createdAt, isArabic);
                                  final isRead =
                                      _isNotificationRead(notification);
                                  final category = _categorizeNotification(
                                      title, description);

                                  return NotificationCard(
                                    notification: notification,
                                    title: title,
                                    description: description,
                                    time: timeFormatted,
                                    isRead: isRead,
                                    category: category,
                                    onTap: () {
                                      if (notification.id != null) {
                                        setState(() {
                                          _readNotificationIds
                                              .add(notification.id!);
                                        });
                                      }

                                      int? effectiveTripId =
                                          notification.tripId;
                                      if (effectiveTripId == null ||
                                          effectiveTripId <= 0) {
                                        if (notification.data != null) {
                                          effectiveTripId = int.tryParse(
                                                  notification
                                                          .data!['trip_id']
                                                          ?.toString() ??
                                                      '') ??
                                              int.tryParse(notification
                                                      .data!['tripId']
                                                      ?.toString() ??
                                                  '') ??
                                              int.tryParse(notification
                                                      .data!['id']
                                                      ?.toString() ??
                                                  '');
                                        }
                                      }
                                      if (effectiveTripId == null ||
                                          effectiveTripId <= 0) {
                                        final match = RegExp(r'#(\d+)')
                                            .firstMatch(
                                                '$title $description');
                                        if (match != null) {
                                          effectiveTripId = int.tryParse(
                                              match.group(1) ?? '');
                                        }
                                      }

                                      String deducedType =
                                          notification.type ?? 'general';
                                      switch (category) {
                                        case NotificationCategory.offer:
                                          deducedType = 'new_offer';
                                          break;
                                        case NotificationCategory.tripStarted:
                                          deducedType = 'trip_started';
                                          break;
                                        case NotificationCategory.tripCompleted:
                                          deducedType = 'trip_completed';
                                          break;
                                        case NotificationCategory.tripCanceled:
                                          deducedType = 'trip_canceled';
                                          break;
                                        case NotificationCategory.chat:
                                          deducedType = 'chat';
                                          break;
                                        case NotificationCategory.general:
                                          deducedType = 'general';
                                          break;
                                      }

                                      if (category ==
                                              NotificationCategory.general &&
                                          (effectiveTripId == null ||
                                              effectiveTripId <= 0)) {
                                        _showNotificationDetailsDialog(
                                            context,
                                            title,
                                            description,
                                            timeFormatted);
                                        return;
                                      }

                                      di.sl<NotificationRoutingService>()
                                          .handleNotificationTap({
                                        'type': deducedType,
                                        'trip_id': effectiveTripId,
                                        'title': title,
                                        'body': description,
                                        'description': description,
                                        if (notification.data != null)
                                          ...notification.data!,
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationDetailsDialog(
    BuildContext context,
    String title,
    String description,
    String time,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active_outlined,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title.isNotEmpty ? title : S.of(context).notifications,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (time.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              S.of(context).cancel,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required int index, required String label}) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFiltered) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isFiltered
                    ? S.of(context).noMatchingNotifications
                    : S.of(context).noNotificationsYet,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  isFiltered
                      ? S.of(context).tryAnotherCategory
                      : S.of(context).notificationsUpdatesHint,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  S.of(context).refreshAction,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
