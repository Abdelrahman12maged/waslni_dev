import 'dart:developer';
import 'package:home_widget/home_widget.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/features/trips/domain/entities/trip.dart';

/// Service responsible for keeping the Android Home Widget in sync
/// with the current app state.
///
/// Call the appropriate method after each state change so the Widget
/// always reflects fresh data without the user having to open the app.
class HomeWidgetService {
  static const String _appGroupId = 'com.abdo.carapp';
  static const String _widgetName = 'TripWidgetProvider';

  // ─── Initialisation ──────────────────────────────────────────────────────

  /// Call once in [main()] before [runApp()] to register the widget group.
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.registerBackgroundCallback(_backgroundCallback);
    } catch (e) {
      log('HomeWidgetService.init error: $e', name: 'HomeWidget');
    }
  }

  /// Listens for widget click events and navigates to the target route.
  static void setupWidgetClickListener(void Function(String route) onNavigate) {
    try {
      HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
        if (uri != null) {
          _handleWidgetUri(uri, onNavigate);
        }
      });

      HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) {
          _handleWidgetUri(uri, onNavigate);
        }
      });
    } catch (e) {
      log('setupWidgetClickListener error: $e', name: 'HomeWidget');
    }
  }

  static void _handleWidgetUri(
      Uri uri, void Function(String route) onNavigate) {
    final uriStr = uri.toString();
    log('Widget clicked with URI: $uriStr', name: 'HomeWidget');
    if (uriStr.contains('driver/trips/shared/ongoing')) {
      onNavigate(AppRoutes.driverOngoingSharedTrip);
    } else if (uriStr.contains('driver/trips/private/ongoing')) {
      onNavigate(AppRoutes.driverOngoingPrivateTrip);
    } else if (uriStr.contains('passenger/trips/shared/ongoing')) {
      onNavigate(AppRoutes.passengerOngoingSharedTrip);
    } else if (uriStr.contains('passenger/trips/private/current')) {
      onNavigate(AppRoutes.passengerCurrentPrivateTrip);
    } else if (uriStr.contains('driver/trips/available') ||
        uriStr.contains('driver_new_trips')) {
      onNavigate(AppRoutes.availableTrips);
    } else if (uriStr.contains('passenger/trips/add-private') ||
        uriStr.contains('passenger_add_private')) {
      onNavigate(AppRoutes.passengerAddPrivateTrip);
    } else if (uriStr.contains('passenger/trips/add-shared') ||
        uriStr.contains('passenger_add_shared')) {
      onNavigate(AppRoutes.passengerAddSharedTrip);
    }
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Call after a successful login.
  static Future<void> updateAfterLogin({
    required String userName,
    required String userType, // 'driver' or 'passenger'
  }) async {
    try {
      await _saveAll({
        'widget_is_logged_in': true,
        'widget_user_type': userType,
        'widget_user_name': userName,
        'widget_info_text': userType == 'driver'
            ? 'جاري تحميل الرحلات المتاحة…'
            : 'جاري تحميل آخر رحلة…',
        'widget_btn_primary_label': 'عرض الرحلات',
        'widget_btn_secondary_label': '',
        'widget_show_secondary_btn': false,
      });
      await _refresh();
    } catch (e) {
      log('HomeWidgetService.updateAfterLogin error: $e', name: 'HomeWidget');
    }
  }

  /// Call when the driver's available trips count is updated.
  static Future<void> updateDriverTripsCount(int count) async {
    try {
      final info = count == 0
          ? 'لا توجد رحلات قريبة منك الآن'
          : 'يوجد $count رحل${count == 1 ? 'ة' : 'ات'} متاح${count == 1 ? 'ة' : 'ة'} بالقرب منك';
      await _saveAll({
        'widget_info_text': info,
        'widget_btn_primary_label': count == 0 ? 'تحديث' : '🗺️ عرض الرحلات',
        'widget_show_secondary_btn': false,
      });
      await _refresh();
    } catch (e) {
      log('HomeWidgetService.updateDriverTripsCount error: $e',
          name: 'HomeWidget');
    }
  }

  /// Call when the passenger's last trip is known.
  static Future<void> updatePassengerLastTrip(Trip? lastTrip) async {
    try {
      final String info;
      if (lastTrip == null) {
        info = 'لم تقم بأي رحلة بعد';
      } else {
        final from = _shortName(lastTrip.fromLocationName);
        final to = _shortName(lastTrip.toLocationName);
        info = 'آخر رحلة: $from ← $to';
      }
      await _saveAll({
        'widget_info_text': info,
        'widget_btn_primary_label': '🚗 رحلة خاصة',
        'widget_btn_secondary_label': '🚌 رحلة مشتركة',
        'widget_show_secondary_btn': true,
      });
      await _refresh();
    } catch (e) {
      log('HomeWidgetService.updatePassengerLastTrip error: $e',
          name: 'HomeWidget');
    }
  }

  /// Call when the user has an active ongoing trip (Live tracking).
  static Future<void> updateActiveTrip({
    required Trip trip,
    required bool isDriver,
  }) async {
    try {
      final isShared = trip.type == TripType.shared;
      final dest = _shortName(trip.toLocationName);
      final info = '⚡ متوجه إلى: $dest';

      final actionUri = isDriver
          ? (isShared
              ? 'carapp://app/driver/trips/shared/ongoing'
              : 'carapp://app/driver/trips/private/ongoing')
          : (isShared
              ? 'carapp://app/passenger/trips/shared/ongoing'
              : 'carapp://app/passenger/trips/private/current');

      await _saveAll({
        'widget_has_active_trip': true,
        'widget_active_trip_uri': actionUri,
        'widget_info_text': info,
        'widget_btn_primary_label': '📍 تتبع الرحلة المباشر',
        'widget_btn_secondary_label': '',
        'widget_show_secondary_btn': false,
      });
      await _refresh();
    } catch (e) {
      log('HomeWidgetService.updateActiveTrip error: $e', name: 'HomeWidget');
    }
  }

  /// Call when an active trip ends or is cleared.
  static Future<void> clearActiveTrip() async {
    try {
      await HomeWidget.saveWidgetData<bool>('widget_has_active_trip', false);
      await HomeWidget.saveWidgetData<String>('widget_active_trip_uri', '');
      await _refresh();
    } catch (e) {
      log('HomeWidgetService.clearActiveTrip error: $e', name: 'HomeWidget');
    }
  }

  /// Call on logout to reset the widget to the default state.
  static Future<void> clearOnLogout() async {
    try {
      await _saveAll({
        'widget_is_logged_in': false,
        'widget_user_type': '',
        'widget_user_name': '',
        'widget_has_active_trip': false,
        'widget_active_trip_uri': '',
        'widget_info_text': 'سجّل دخولك للاستمتاع بالتطبيق',
        'widget_btn_primary_label': 'تسجيل الدخول',
        'widget_btn_secondary_label': '',
        'widget_show_secondary_btn': false,
      });
      await _refresh();
    } catch (e) {
      log('HomeWidgetService.clearOnLogout error: $e', name: 'HomeWidget');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static Future<void> _saveAll(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is bool) {
        await HomeWidget.saveWidgetData<bool>(entry.key, value);
      } else if (value is int) {
        await HomeWidget.saveWidgetData<int>(entry.key, value);
      } else if (value is double) {
        await HomeWidget.saveWidgetData<double>(entry.key, value);
      } else {
        await HomeWidget.saveWidgetData<String>(entry.key, value.toString());
      }
    }
  }

  static Future<void> _refresh() async {
    await HomeWidget.updateWidget(
      androidName: _widgetName,
    );
  }

  /// Truncate long location names so they fit in one line.
  static String _shortName(String name) {
    if (name.length <= 20) return name;
    return '${name.substring(0, 18)}…';
  }
}

/// Background callback required by home_widget — keeps widget alive
/// even when the app is in the background.
@pragma('vm:entry-point')
Future<void> _backgroundCallback(Uri? uri) async {
  log('HomeWidget background callback: $uri', name: 'HomeWidget');
}
