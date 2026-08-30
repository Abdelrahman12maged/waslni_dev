import 'package:car_app/features/ratings/domain/entities/driver_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/my_ratings_page.dart';
import 'package:car_app/features/ratings/domain/entities/pending_rating_trip.dart';
import 'package:car_app/features/ratings/domain/entities/rating_result.dart';

abstract class RatingsState {
  const RatingsState();
}

class RatingsInitial extends RatingsState {
  const RatingsInitial();
}

class RatingsLoading extends RatingsState {
  const RatingsLoading();
}

class PendingRatingsLoaded extends RatingsState {
  final List<PendingRatingTrip> trips;
  const PendingRatingsLoaded(this.trips);
}

class PendingRatingsEmpty extends RatingsState {
  const PendingRatingsEmpty();
}

class RatingSubmitting extends RatingsState {
  const RatingSubmitting();
}

class RatingSubmitSuccess extends RatingsState {
  final RatingResult result;
  final bool isEdit;
  const RatingSubmitSuccess(this.result, {this.isEdit = false});
}

class RatingSubmitError extends RatingsState {
  final String message;
  final String? errorCode;
  const RatingSubmitError(this.message, {this.errorCode});
}

class MyRatingsLoaded extends RatingsState {
  final MyRatingsPage page;
  const MyRatingsLoaded(this.page);
}

class DriverRatingsLoaded extends RatingsState {
  final DriverRatingsPage page;
  const DriverRatingsLoaded(this.page);
}

class RatingsError extends RatingsState {
  final String message;
  final String? errorCode;
  const RatingsError(this.message, {this.errorCode});
}
