import 'dart:io';
import 'package:car_app/features/driver_documents/data/models/driver_documents_models.dart';

abstract class DriverDocumentsRemoteDataSource {
  /// GET /api/driver/documents — returns full status with all 3 doc types.
  Future<DriverDocumentsStatusModel> getDocuments(String token, String language);

  /// POST /api/driver/documents — uploads 1-3 documents.
  Future<DriverDocumentsStatusModel> uploadDocuments({
    required String token,
    required String language,
    File? nationalId,
    DateTime? nationalIdExpiresAt,
    File? criminalRecord,
    DateTime? criminalRecordExpiresAt,
    File? vehicleLicense,
    DateTime? vehicleLicenseExpiresAt,
  });
}
