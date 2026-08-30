import 'dart:io';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_documents_status.dart';
import 'package:dartz/dartz.dart';

abstract class DriverDocumentsRepository {
  /// Fetches all 3 document statuses + account activation info.
  Future<Either<Failure, DriverDocumentsStatus>> getDocuments();

  /// Uploads one or more documents in a single multipart/form-data request.
  /// At least one of [nationalId], [criminalRecord], or [vehicleLicense] must be non-null.
  Future<Either<Failure, DriverDocumentsStatus>> uploadDocuments({
    File? nationalId,
    DateTime? nationalIdExpiresAt,
    File? criminalRecord,
    DateTime? criminalRecordExpiresAt,
    File? vehicleLicense,
    DateTime? vehicleLicenseExpiresAt,
  });
}
