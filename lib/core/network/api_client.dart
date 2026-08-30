import 'dart:developer';

import 'package:car_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:car_app/core/di/injection_container.dart';
import 'package:car_app/core/router/app_router.dart';
import 'package:car_app/core/router/app_routes.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/core/widgets/components.dart';

/// A clean, injectable HTTP client that wraps Dio.
/// Every method returns [Either<Failure, T>] — no exceptions propagate upward.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            log('401 Unauthorized detected. Clearing usertoken and redirecting to login.', name: 'ApiClient.401Interceptor');
            try {
              if (sl.isRegistered<LocalStorage>()) {
                final storage = sl<LocalStorage>();
                await storage.remove(key: 'usertoken');
              }
              showToast(
                text: 'Session expired. Please log in again to resume.',
                state: ToastStates.ERROR,
              );
              if (sl.isRegistered<AppRouter>()) {
                sl<AppRouter>().router.go(AppRoutes.login);
              }
            } catch (e) {
              log('Error handling 401 interceptor: $e', name: 'ApiClient.401Interceptor');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  GET
  // ──────────────────────────────────────────────
  Future<Either<Failure, Response>> get({
    required String url,
    required String token,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      _setAuthHeader(token);
      final response = await _dio.get(
        url,
        queryParameters: query,
        data: data,
      );
      return Right(response);
    } on DioException catch (e) {
      log(e.toString(), name: 'ApiClient.get');
      return Left(_handleDioError(e));
    } catch (e) {
      log(e.toString(), name: 'ApiClient.get.unknown');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ──────────────────────────────────────────────
  //  POST
  // ──────────────────────────────────────────────
  Future<Either<Failure, Response>> post({
    required String url,
    required String token,
    required Map<String, dynamic> data,
    Map<String, dynamic>? query,
  }) async {
    try {
      _setAuthHeader(token);
      final response = await _dio.post(
        url,
        queryParameters: query,
        data: data,
      );
      return Right(response);
    } on DioException catch (e) {
      log(e.toString(), name: 'ApiClient.post');
      return Left(_handleDioError(e));
    } catch (e) {
      log(e.toString(), name: 'ApiClient.post.unknown');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ──────────────────────────────────────────────
  //  PUT
  // ──────────────────────────────────────────────
  Future<Either<Failure, Response>> put({
    required String url,
    required String token,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      _setAuthHeader(token);
      final response = await _dio.put(
        url,
        queryParameters: query,
        data: data,
      );
      return Right(response);
    } on DioException catch (e) {
      log(e.toString(), name: 'ApiClient.put');
      return Left(_handleDioError(e));
    } catch (e) {
      log(e.toString(), name: 'ApiClient.put.unknown');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ──────────────────────────────────────────────
  //  DELETE
  // ──────────────────────────────────────────────
  Future<Either<Failure, Response>> delete({
    required String url,
    required String token,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      _setAuthHeader(token);
      final response = await _dio.delete(
        url,
        queryParameters: query,
        data: data,
      );
      return Right(response);
    } on DioException catch (e) {
      log(e.toString(), name: 'ApiClient.delete');
      return Left(_handleDioError(e));
    } catch (e) {
      log(e.toString(), name: 'ApiClient.delete.unknown');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ──────────────────────────────────────────────
  //  Helpers
  // ──────────────────────────────────────────────
  void _setAuthHeader(String token) {
    _dio.options.headers['Accept'] = 'application/json';
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        log('badResponse [$statusCode] data: ${e.response?.data}', name: 'ApiClient._handleDioError');
        final responseData = e.response?.data;
        String? message;
        String? errorCode;
        if (responseData is Map<String, dynamic>) {
          errorCode = responseData['error_code']?.toString();
          message = responseData['message']?.toString() ??
              responseData['error']?.toString();
          if (message == null && responseData['errors'] is Map) {
            final errors = responseData['errors'] as Map;
            message = errors.values
                .map((v) => v is List ? v.join(', ') : v.toString())
                .join('\n');
          }
        }
        message ??= e.message ?? 'Server error ($statusCode)';
        return ServerFailure(message: message, statusCode: statusCode, errorCode: errorCode);
      default:
        return ServerFailure(message: e.message ?? 'Unexpected error');
    }
  }
}
