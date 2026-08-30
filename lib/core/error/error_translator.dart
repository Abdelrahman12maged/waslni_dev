import 'package:flutter/material.dart';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/generated/l10n.dart';

/// Centralized Error Translator for converting any [Failure], error code,
/// or raw API message into a fully localized, user-friendly string
/// based on the active application language.
class ErrorTranslator {
  ErrorTranslator._();

  /// Translates a [Failure] into a localized string.
  /// If [context] is provided, uses [S.of(context)].
  /// Otherwise, falls back to [S.current].
  static String translateFailure(Failure failure, [BuildContext? context]) {
    final s = context != null ? S.of(context) : S.current;

    if (failure is ServerFailure) {
      // 1. Check by explicit error code from API
      if (failure.errorCode != null && failure.errorCode!.isNotEmpty) {
        final translated = _translateErrorCode(failure.errorCode!, s);
        if (translated != null) return translated;
      }

      // 2. Check by status code
      if (failure.statusCode == 401 || failure.statusCode == 403) {
        return s.unauthorizedError;
      }
      if (failure.statusCode == 404) {
        return s.tripNotFound;
      }
      if (failure.statusCode != null && failure.statusCode! >= 500) {
        return s.serverError;
      }

      // 3. Check by message string matching
      return translateRawMessage(failure.message, s);
    }

    if (failure is NetworkFailure) {
      if (failure.message.toLowerCase().contains('timeout')) {
        return s.connectionTimeout;
      }
      return s.noInternetConnection;
    }

    return translateRawMessage(failure.message, s);
  }

  /// Translates error codes from backend APIs.
  static String? _translateErrorCode(String errorCode, S s) {
    final code = errorCode.toUpperCase().trim();
    switch (code) {
      case 'OFFER_EXPIRED':
      case 'EXPIRED_OFFER':
        return s.offerExpired;
      case 'TRIP_ALREADY_ACCEPTED':
      case 'ALREADY_ACCEPTED':
      case 'OFFER_ALREADY_ACCEPTED':
        return s.tripAlreadyAccepted;
      case 'OFFER_ALREADY_SUBMITTED':
      case 'ALREADY_OFFERED':
        return s.offerAlreadySubmitted;
      case 'TRIP_NOT_FOUND':
      case 'NOT_FOUND':
        return s.tripNotFound;
      case 'INSUFFICIENT_SEATS':
      case 'NO_AVAILABLE_SEATS':
      case 'SEATS_FULL':
        return s.insufficientSeats;
      case 'TRIP_CANCELLED':
      case 'TRIP_CANCELED':
        return s.tripCancelled;
      case 'TRIP_COMPLETED':
        return s.tripCompleted;
      case 'UNAUTHENTICATED':
      case 'UNAUTHORIZED':
        return s.unauthorizedError;
      case 'SERVER_ERROR':
        return s.serverError;
      case 'NETWORK_ERROR':
      case 'NO_INTERNET':
        return s.noInternetConnection;
      case 'CONNECTION_TIMEOUT':
        return s.connectionTimeout;
      default:
        return null;
    }
  }

  /// Translates raw English server messages or exception messages to active locale.
  static String translateRawMessage(String rawMessage, [S? sInstance]) {
    final s = sInstance ?? S.current;
    final msgLower = rawMessage.toLowerCase().trim();

    if (msgLower.contains('offer has expired') || msgLower.contains('offer expired')) {
      return s.offerExpired;
    }
    if (msgLower.contains('already accepted') || msgLower.contains('trip accepted')) {
      return s.tripAlreadyAccepted;
    }
    if (msgLower.contains('already submitted') || msgLower.contains('already have an offer')) {
      return s.offerAlreadySubmitted;
    }
    if (msgLower.contains('trip not found') || msgLower.contains('not found')) {
      return s.tripNotFound;
    }
    if (msgLower.contains('seat') && (msgLower.contains('insufficient') || msgLower.contains('not enough') || msgLower.contains('full'))) {
      return s.insufficientSeats;
    }
    if (msgLower.contains('timed out') || msgLower.contains('timeout')) {
      return s.connectionTimeout;
    }
    if (msgLower.contains('no internet') || msgLower.contains('connection error') || msgLower.contains('network')) {
      return s.noInternetConnection;
    }
    if (msgLower.contains('unauthenticated') || msgLower.contains('unauthorized')) {
      return s.unauthorizedError;
    }
    if (msgLower.contains('server error') || msgLower.contains('internal error') || msgLower.contains('500')) {
      return s.serverError;
    }

    // If message is already translated or custom, return it directly
    return rawMessage.isNotEmpty ? rawMessage : s.unexpectedError;
  }
}

/// Extension on [Failure] for easy localized access.
extension LocalizedFailureX on Failure {
  String toLocalizedMessage([BuildContext? context]) =>
      ErrorTranslator.translateFailure(this, context);
}
