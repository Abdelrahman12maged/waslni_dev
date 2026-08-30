import 'package:car_app/generated/l10n.dart';
import 'package:flutter/widgets.dart';

class AuthErrorMapper {
  static String getErrorMessage(
    BuildContext context, {
    String? errorCode,
    String? fallbackMessage,
  }) {
    if (errorCode != null && errorCode.isNotEmpty) {
      switch (errorCode) {
        case 'invalid_credentials':
        case 'invalid_login_credentials':
          return S.of(context).invalidLoginCredentials;
        case 'no_driver_image_selected':
          return S.of(context).noDriverImageSelected;
        case 'no_image_selected':
          return S.of(context).noImageSelected;
        case 'mobile_number_required':
          return S.of(context).mobileNumberRequired;
        case 'user_not_found':
          return S.of(context).userNotFound;
        case 'otp_invalid_or_expired':
          return S.of(context).otpCodeInvalidOrExpired;
        case 'server_error':
          return S.of(context).serverError;
        case 'network_error':
          return S.of(context).networkError;
        case 'unauthorized':
          return S.of(context).unauthorizedError;
      }
    }

    if (fallbackMessage != null && fallbackMessage.isNotEmpty) {
      final lower = fallbackMessage.toLowerCase();
      if (lower.contains('invalid login credentials') ||
          lower.contains('invalid credentials') ||
          lower.contains('credentials')) {
        return S.of(context).invalidLoginCredentials;
      }
      if (lower.contains('no driver image selected')) {
        return S.of(context).noDriverImageSelected;
      }
      if (lower.contains('no image selected')) {
        return S.of(context).noImageSelected;
      }
      if (lower.contains('user not found')) {
        return S.of(context).userNotFound;
      }
      if (lower.contains('unauthorized')) {
        return S.of(context).unauthorizedError;
      }
      return fallbackMessage;
    }

    return S.of(context).serverError;
  }
}
