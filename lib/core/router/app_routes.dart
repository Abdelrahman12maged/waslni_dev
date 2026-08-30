/// Defines all named route paths used with [AppRouter].
/// Use these constants everywhere instead of hardcoded strings.
abstract class AppRoutes {
  // ── Auth ────────────────────────────────────
  static const String splash = '/';
  static const String onBoarding = '/onboarding';
  static const String chooseLang = '/choose-lang';
  static const String login = '/login';
  static const String passengerSignup = '/passenger-signup';
  static const String passengerSignupConfirm = '/passenger-signup-confirm';
  static const String driverSignup = '/driver-signup';
  static const String driverSignupInfo = '/driver-signup-info';
  static const String driverSignupConfirm = '/driver-signup-confirm';
  static const String forgetPassword = '/forget-password';
  static const String forgetPasswordConfirm = '/forget-password-confirm';

  // ── Passenger Layout ────────────────────────
  static const String passengerHome = '/passenger';
  static const String passengerTrips = '/passenger/trips';
  static const String passengerAddPrivateTrip = '/passenger/trips/add-private';
  static const String passengerAddSharedTrip = '/passenger/trips/add-shared';
  static const String passengerSearchSharedTrips = '/passenger/trips/search-shared';
  static const String passengerCurrentPrivateTrip = '/passenger/trips/private/current';
  static const String passengerPrivateOffers = '/passenger/trips/private/offers';
  static const String passengerSharedCurrentTrip = '/passenger/trips/shared/current';
  static const String passengerOngoingSharedTrip = '/passenger/trips/shared/ongoing';
  static const String tripChat = '/trip-chat';
  static const String passengerSharedTripDetails = '/passenger/trips/shared/details';
  static const String passengerSharedTripDetailsPassengers = '/passenger/trips/shared/details/passengers';
  static const String savedLocations = '/passenger/locations';
  static const String passengerSettings = '/passenger/settings';
  static const String notifications = '/notifications';

  // ── Driver Layout ────────────────────────────
  static const String driverHome = '/driver';
  static const String driverTrips = '/driver/trips';
  static const String driverOngoingPrivateTrip = '/driver/trips/private/ongoing';
  static const String driverOngoingSharedTrip = '/driver/trips/shared/ongoing';
  static const String availableTrips = '/driver/trips/available';
  static const String makeOffer = '/driver/trips/offer';
  static const String driverActiveTrip = '/driver/trips/active';
  static const String driverSettings = '/driver/settings';
  static const String tripRating = '/trip-rating';
  static const String pendingRatings = '/ratings/pending';
  static const String myRatings = '/ratings/mine';
  static const String driverRatings = '/ratings/driver';
}
