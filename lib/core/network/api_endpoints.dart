import 'package:flutter_dotenv/flutter_dotenv.dart';

/// All API endpoint paths in one place.
/// No magic strings scattered across Cubits.
abstract class ApiEndpoints {

  // ── Auth ────────────────────────────────────
  static const String register = 'api/register';
  static const String login = 'api/login';
  static const String logout = 'api/logout';
  static const String checkVerificationCode = 'api/chack-code-user-ajax';
  static const String resendVerificationCode = 'api/resend-code-user-ajax';
  static const String resetPasswordWithCode = 'api/reset-password-request-ajax';

  // ── Profile ─────────────────────────────────
  static const String myProfile = 'api/myprofile';
  static const String updateProfile = 'api/updateprofile';

  // ── Locations ───────────────────────────────
  static const String savedLocations = 'api/user-locations';
  static const String addLocation = 'api/user-locations';
  static const String deleteLocation = 'api/user-locations/delete/'; // {id}

  // ── Trips ───────────────────────────────────
  static const String tripsNearMe = 'api/trips/nearme';
  static const String nearbySharedTrips = 'api/trips/nearby-shared';
  static const String createTrip = 'api/trips/create';
  static const String tripDetails = 'api/trips/getTrip'; // ?id=1
  static const String tripsByType = 'api/trips';
  static const String tripTotals = 'api/trips/get-totals'; // ?driver_id=X
  static const String changeTripStatus = 'api/trips/changeStatus/'; // {id}?status=closed
  static const String subscribeTrip = 'api/trips/subscribe'; // ?trip_id=1
  static const String passengerInCarStatus = 'api/passenger/changeStatus/'; // {trip_id}/{in_car}

  // ── Offers ──────────────────────────────────
  static const String createOffer = 'api/offers/store';
  static const String getOffers = 'api/offers/'; // {trip_id}
  static const String changeOfferStatus = 'api/update-offer-status/'; // {id}?status=accepted
  // static const String offers = 'api/offers';

  // ── Notifications ───────────────────────────────
  static const String sendFcmNotification = 'api/send-fcm-notification';
  static const String getNotifications = 'api/get-notification';
  static const String updateDeviceToken = 'api/update-device-token';
  static const String updateFcmToken = 'api/update-device-token'; // Alias for backwards compatibility

  // ── Driver KYC Documents ─────────────────────────────────────────────────────
  /// GET  → fetch all document statuses + account.is_active
  /// POST → upload documents (multipart/form-data)
  static const String driverDocuments = 'api/driver/documents';

  /// GET → stream a single document file (auth required)
  /// [type] = national_id | criminal_record | vehicle_license
  static String driverDocumentFile(String type) => 'api/driver/documents/$type/file';

  // ── Ratings ─────────────────────────────────
  static const String ratingsStore = 'api/ratings/store';
  static const String ratingsPending = 'api/ratings/pending';
  static const String ratingsMine = 'api/ratings/mine';
  static String driverRatings(int driverId) => 'api/drivers/$driverId/ratings';

  // ── Wallet ──────────────────────────────────────────────────────────────────
  static const String updateWallet = 'api/update_wallet/'; // {trip_id}

  /// Resolves the base backend API URL from .env or compile-time environment.
  static String get baseUrl {
    if (dotenv.isInitialized) {
      final url = dotenv.maybeGet('BASE_URL');
      if (url != null && url.trim().isNotEmpty) {
        final trimmed = url.trim();
        return trimmed.endsWith('/') ? trimmed : '$trimmed/';
      }
    }
    const envDefineUrl = String.fromEnvironment('BASE_URL');
    if (envDefineUrl.isNotEmpty) {
      final trimmed = envDefineUrl.trim();
      return trimmed.endsWith('/') ? trimmed : '$trimmed/';
    }
    throw StateError(
      'BASE_URL is not set.\n'
      'Please configure BASE_URL in your .env file:\n'
      '  BASE_URL=https://your-api-domain.com/\n',
    );
  }

  /// Same origin as [baseUrl] but without the trailing slash.
  /// Use this when building media/image paths that already include a leading slash,
  /// e.g.  '$mediaBaseUrl/uploads/images/filename.jpg'
  static String get mediaBaseUrl {
    final base = baseUrl;
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  /// Resolves company website URL from .env
  static String get companyWebsite {
    if (dotenv.isInitialized) {
      final site = dotenv.maybeGet('COMPANY_WEBSITE');
      if (site != null && site.trim().isNotEmpty) return site.trim();
    }
    const envDefine = String.fromEnvironment('COMPANY_WEBSITE');
    if (envDefine.isNotEmpty) return envDefine;
    return '';
  }

  /// Resolves support email from .env
  static String get supportEmail {
    if (dotenv.isInitialized) {
      final email = dotenv.maybeGet('SUPPORT_EMAIL');
      if (email != null && email.trim().isNotEmpty) return email.trim();
    }
    const envDefine = String.fromEnvironment('SUPPORT_EMAIL');
    if (envDefine.isNotEmpty) return envDefine;
    return '';
  }

  /// Safely resolves any relative or absolute image path to a full URL.
  /// Handles null, empty, http/https, leading slashes (/storage/, /uploads/, etc.)
  /// and bare filenames.
  static String? buildImageUrl(String? imgPath) {
    if (imgPath == null) return null;
    final str = imgPath.trim();
    if (str.isEmpty || str.toLowerCase() == 'null' || str.toLowerCase() == 'undefined') return null;
    // Already a full URL
    if (str.startsWith('http://') || str.startsWith('https://')) return str;
    // Absolute path on the server (e.g. /storage/... or /uploads/...)
    if (str.startsWith('/')) return '$mediaBaseUrl$str';
    // Relative path that already contains a directory (e.g. profile_pictures/abc.jpg)
    if (str.contains('/')) return '$mediaBaseUrl/$str';
    // Bare filename — assume uploads/images directory
    return '$mediaBaseUrl/uploads/images/$str';
  }

  /// Returns the Google Maps API key from the .env file.
  ///
  /// Resolution order:
  ///   1. GOOGLE_MAPS_API_KEY in .env (flutter_dotenv)
  ///   2. --dart-define=GOOGLE_MAPS_API_KEY=... compile-time flag
  ///
  /// Throws [StateError] if neither source provides a non-empty value.
  /// There is intentionally NO hardcoded fallback — a missing key must be
  /// discovered and fixed at development time, not silently swallowed.
  static String get googleMapsApiKey {
    if (dotenv.isInitialized) {
      final key = dotenv.maybeGet('GOOGLE_MAPS_API_KEY');
      if (key != null && key.isNotEmpty) return key;
    }
    const envDefineKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (envDefineKey.isNotEmpty) return envDefineKey;
    throw StateError(
      'GOOGLE_MAPS_API_KEY is not set.\n'
      'Add it to your .env file:\n'
      '  GOOGLE_MAPS_API_KEY=<your-new-key>\n'
      'The old key has been rotated and must NOT be reused.',
    );
  }
}

