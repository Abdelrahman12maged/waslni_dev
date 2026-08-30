import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:car_app/core/error/exceptions.dart' as app_ex;
import 'package:car_app/core/network/api_endpoints.dart';
import 'package:car_app/features/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:car_app/features/driver_documents/data/models/driver_documents_models.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';

/// Uses a **dedicated** Dio instance (injected via DI) with clean options.
/// This ensures Dio can set `Content-Type: multipart/form-data; boundary=…`
/// without interference from any global ApiClient interceptors.
class DriverDocumentsRemoteDataSourceImpl
    implements DriverDocumentsRemoteDataSource {
  final Dio dio;

  DriverDocumentsRemoteDataSourceImpl(this.dio);

  void _log(String message) {
    dev.log(message, name: 'DriverDocuments');
    debugPrint(message);
  }

  // ── GET /api/driver/documents ──────────────────────────────────────────────

  @override
  Future<DriverDocumentsStatusModel> getDocuments(
    String token,
    String language,
  ) async {
    _log('🌐 [DriverDocs] GET ${ApiEndpoints.driverDocuments} (token: ${token.isNotEmpty ? "Available (${token.substring(0, token.length > 10 ? 10 : token.length)}...)" : "MISSING!"})');
    try {
      final response = await dio.get(
        ApiEndpoints.driverDocuments,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Accept-Language': language,
        }),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final model = DriverDocumentsStatusModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        _log('✅ [DriverDocs] GET OK — isActive=${model.account.isActive}, missing=${model.account.missingDocuments}');
        return model;
      }
      throw const app_ex.ServerException('Unexpected response from documents endpoint');
    } on DioException catch (e) {
      final msg = _dioMsg(e);
      _log('❌ [DriverDocs] GET Error (${e.response?.statusCode}): $msg\nResponse: ${e.response?.data}');
      throw app_ex.ServerException(msg);
    } catch (e) {
      if (e is app_ex.ServerException) rethrow;
      throw app_ex.ServerException(e.toString());
    }
  }

  // ── POST /api/driver/documents ─────────────────────────────────────────────
  // Uses FormData.fromMap with MultipartFile.fromBytes on a clean dedicated Dio instance.
  // This produces a standard multipart/form-data request with automatic boundary generation.

  @override
  Future<DriverDocumentsStatusModel> uploadDocuments({
    required String token,
    required String language,
    File? nationalId,
    DateTime? nationalIdExpiresAt,
    File? criminalRecord,
    DateTime? criminalRecordExpiresAt,
    File? vehicleLicense,
    DateTime? vehicleLicenseExpiresAt,
  }) async {
    _log('🚀 [DriverDocs] UPLOAD START — using dedicated Dio + FormData.fromMap');
    _log('🔑 Token: ${token.isNotEmpty ? "OK (${token.substring(0, token.length > 10 ? 10 : token.length)}...)" : "⚠️ MISSING!"}');

    try {
      final Map<String, dynamic> map = {};

      // ── Files ──────────────────────────────────────────────────────────────
      if (nationalId != null) {
        final fileName = _filename(nationalId.path);
        final mime = _mimeOf(_ext(nationalId.path));
        final bytes = await nationalId.readAsBytes();
        _log('📁 national_id: ${nationalId.path} (${bytes.length} bytes) -> $fileName, mime: $mime');
        map['national_id'] = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: mime,
        );
      }
      if (nationalIdExpiresAt != null) {
        final formatted = _fmt(nationalIdExpiresAt);
        _log('📅 national_id_expires_at: $formatted');
        map['national_id_expires_at'] = formatted;
      }

      if (criminalRecord != null) {
        final fileName = _filename(criminalRecord.path);
        final mime = _mimeOf(_ext(criminalRecord.path));
        final bytes = await criminalRecord.readAsBytes();
        _log('📁 criminal_record: ${criminalRecord.path} (${bytes.length} bytes) -> $fileName, mime: $mime');
        map['criminal_record'] = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: mime,
        );
      }
      if (criminalRecordExpiresAt != null) {
        final formatted = _fmt(criminalRecordExpiresAt);
        _log('📅 criminal_record_expires_at: $formatted');
        map['criminal_record_expires_at'] = formatted;
      }

      if (vehicleLicense != null) {
        final fileName = _filename(vehicleLicense.path);
        final mime = _mimeOf(_ext(vehicleLicense.path));
        final bytes = await vehicleLicense.readAsBytes();
        _log('📁 vehicle_license: ${vehicleLicense.path} (${bytes.length} bytes) -> $fileName, mime: $mime');
        map['vehicle_license'] = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: mime,
        );
      }
      if (vehicleLicenseExpiresAt != null) {
        final formatted = _fmt(vehicleLicenseExpiresAt);
        _log('📅 vehicle_license_expires_at: $formatted');
        map['vehicle_license_expires_at'] = formatted;
      }

      if (map.isEmpty) {
        _log('⚠️ [DriverDocs] No files or expiry dates attached!');
      }

      final formData = FormData.fromMap(map);
      _log('📋 Files: ${formData.files.map((e) => "${e.key}: ${e.value.filename} (${e.value.contentType})").toList()}');
      _log('📋 Fields: ${formData.fields.map((e) => "${e.key}=${e.value}").toList()}');
      _log('📡 POST ${ApiEndpoints.driverDocuments}...');

      // ── Send — do NOT set Content-Type header manually; Dio auto-generates it with boundary ──
      final response = await dio.post(
        ApiEndpoints.driverDocuments,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Accept-Language': language,
          },
        ),
      );

      _log('📨 Response (${response.statusCode}): ${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        final model = DriverDocumentsStatusModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        _log('✅ Upload OK — isActive=${model.account.isActive}, missing=${model.account.missingDocuments}');
        return model;
      }
      throw const app_ex.ServerException('Unexpected response from upload endpoint');
    } on DioException catch (e) {
      final msg = _dioMsg(e);
      _log('💥 Dio error (${e.response?.statusCode}): $msg\nBody: ${e.response?.data}');
      throw app_ex.ServerException(msg);
    } on app_ex.ServerException {
      rethrow;
    } catch (e) {
      _log('💥 Exception: $e');
      throw app_ex.ServerException(e.toString());
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _filename(String path) => path.split(RegExp(r'[/\\]')).last;

  String _ext(String path) {
    final name = _filename(path);
    return name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
  }

  MediaType _mimeOf(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  String _fmt(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  String _dioMsg(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString() ?? data['error']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.message ?? 'Network error';
  }
}
