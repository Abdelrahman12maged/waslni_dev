import 'dart:developer';

import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/ratings/domain/usecases/get_driver_ratings_usecase.dart';
import 'package:car_app/features/ratings/domain/usecases/get_my_ratings_usecase.dart';
import 'package:car_app/features/ratings/domain/usecases/get_pending_ratings_usecase.dart';
import 'package:car_app/features/ratings/domain/usecases/submit_rating_usecase.dart';
import 'package:car_app/features/ratings/presentation/cubit/ratings_state.dart';
import 'package:car_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RatingsCubit extends Cubit<RatingsState> {
  final SubmitRatingUseCase submitRatingUseCase;
  final GetPendingRatingsUseCase getPendingRatingsUseCase;
  final GetMyRatingsUseCase getMyRatingsUseCase;
  final GetDriverRatingsUseCase getDriverRatingsUseCase;

  RatingsCubit({
    required this.submitRatingUseCase,
    required this.getPendingRatingsUseCase,
    required this.getMyRatingsUseCase,
    required this.getDriverRatingsUseCase,
  }) : super(const RatingsInitial());

  static RatingsCubit get(BuildContext context) => BlocProvider.of<RatingsCubit>(context);

  /// Submits or updates a trip rating.
  Future<void> submitRating({
    required int tripId,
    required int stars,
    String? comment,
    int? ratedUserId,
    bool isEdit = false,
  }) async {
    log('RatingsCubit.submitRating: tripId=$tripId stars=$stars ratedUserId=$ratedUserId isEdit=$isEdit');
    emit(const RatingSubmitting());
    final result = await submitRatingUseCase(
      tripId: tripId,
      stars: stars,
      comment: comment,
      ratedUserId: ratedUserId,
    );

    result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        log('RatingsCubit.submitRating failed: ${failure.message} (code: $errorCode)');
        emit(RatingSubmitError(failure.message, errorCode: errorCode));
      },
      (ratingResult) {
        log('RatingsCubit.submitRating success: ratingId=${ratingResult.rating.id}');
        emit(RatingSubmitSuccess(ratingResult, isEdit: isEdit));
      },
    );
  }

  /// Fetches trips pending rating by the current passenger.
  Future<void> getPendingRatings() async {
    emit(const RatingsLoading());
    final result = await getPendingRatingsUseCase();

    result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        log('RatingsCubit.getPendingRatings failed: ${failure.message}');
        emit(RatingsError(failure.message, errorCode: errorCode));
      },
      (trips) {
        log('RatingsCubit.getPendingRatings: found ${trips.length} trips');
        if (trips.isEmpty) {
          emit(const PendingRatingsEmpty());
        } else {
          emit(PendingRatingsLoaded(trips));
        }
      },
    );
  }

  /// Fetches passenger's submitted ratings.
  Future<void> getMyRatings({int page = 1, int perPage = 15}) async {
    emit(const RatingsLoading());
    final result = await getMyRatingsUseCase(page: page, perPage: perPage);

    result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        log('RatingsCubit.getMyRatings failed: ${failure.message}');
        emit(RatingsError(failure.message, errorCode: errorCode));
      },
      (pageData) {
        log('RatingsCubit.getMyRatings: loaded page ${pageData.currentPage}/${pageData.lastPage}');
        emit(MyRatingsLoaded(pageData));
      },
    );
  }

  /// Fetches public driver reviews and breakdown.
  Future<void> getDriverRatings({
    required int driverId,
    int page = 1,
    int perPage = 15,
  }) async {
    emit(const RatingsLoading());
    final result = await getDriverRatingsUseCase(
      driverId: driverId,
      page: page,
      perPage: perPage,
    );

    result.fold(
      (failure) {
        final errorCode = failure is ServerFailure ? failure.errorCode : null;
        log('RatingsCubit.getDriverRatings failed: ${failure.message}');
        emit(RatingsError(failure.message, errorCode: errorCode));
      },
      (pageData) {
        log('RatingsCubit.getDriverRatings: driver $driverId loaded');
        emit(DriverRatingsLoaded(pageData));
      },
    );
  }

  /// Maps known backend error codes to user-friendly localized messages.
  static String mapErrorCode(BuildContext context, String? errorCode, String fallbackMessage) {
    if (errorCode == null) return fallbackMessage;
    switch (errorCode.toUpperCase()) {
      case 'TRIP_NOT_FINISHED':
        return S.of(context).errorTripNotFinished;
      case 'DRIVER_NOT_ASSIGNED':
        return S.of(context).errorDriverNotAssigned;
      case 'CANNOT_RATE_SELF':
        return S.of(context).errorCannotRateSelf;
      case 'NOT_TRIP_PASSENGER':
        return S.of(context).errorNotTripPassenger;
      case 'RATING_LOCKED':
        return S.of(context).errorRatingLocked;
      case 'TRIP_NOT_FOUND':
        return S.of(context).errorTripNotFound;
      default:
        return fallbackMessage;
    }
  }
}
