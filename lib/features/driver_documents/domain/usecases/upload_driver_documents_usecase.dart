import 'dart:io';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_documents_status.dart';
import 'package:car_app/features/driver_documents/domain/repositories/driver_documents_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UploadDriverDocumentsUseCase {
  final DriverDocumentsRepository repository;

  UploadDriverDocumentsUseCase(this.repository);

  Future<Either<Failure, DriverDocumentsStatus>> call(UploadDocumentsParams params) {
    return repository.uploadDocuments(
      nationalId: params.nationalId,
      nationalIdExpiresAt: params.nationalIdExpiresAt,
      criminalRecord: params.criminalRecord,
      criminalRecordExpiresAt: params.criminalRecordExpiresAt,
      vehicleLicense: params.vehicleLicense,
      vehicleLicenseExpiresAt: params.vehicleLicenseExpiresAt,
    );
  }
}

class UploadDocumentsParams extends Equatable {
  final File? nationalId;
  final DateTime? nationalIdExpiresAt;
  final File? criminalRecord;
  final DateTime? criminalRecordExpiresAt;
  final File? vehicleLicense;
  final DateTime? vehicleLicenseExpiresAt;

  const UploadDocumentsParams({
    this.nationalId,
    this.nationalIdExpiresAt,
    this.criminalRecord,
    this.criminalRecordExpiresAt,
    this.vehicleLicense,
    this.vehicleLicenseExpiresAt,
  });

  @override
  List<Object?> get props => [
        nationalId,
        nationalIdExpiresAt,
        criminalRecord,
        criminalRecordExpiresAt,
        vehicleLicense,
        vehicleLicenseExpiresAt,
      ];
}
