import 'dart:io';
import 'package:car_app/core/error/exceptions.dart' as app_ex;
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/driver_documents/data/datasources/driver_documents_remote_datasource.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_documents_status.dart';
import 'package:car_app/features/driver_documents/domain/repositories/driver_documents_repository.dart';
import 'package:dartz/dartz.dart';

class DriverDocumentsRepositoryImpl implements DriverDocumentsRepository {
  final DriverDocumentsRemoteDataSource remoteDataSource;
  final LocalStorage localStorage;

  DriverDocumentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String get _token {
    final val = localStorage.read(key: 'usertoken');
    return val is String ? val : '';
  }

  String get _language {
    final val = localStorage.read(key: 'lang');
    return val is String ? val : 'ar';
  }

  /// Caches the KYC active flag so the FAB gate can read it without a network call.
  void _cacheKycStatus(bool isActive) {
    localStorage.saveString(
      key: 'driver_kyc_active',
      value: isActive ? 'true' : 'false',
    );
  }

  // ── Repository Methods ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, DriverDocumentsStatus>> getDocuments() async {
    try {
      final result = await remoteDataSource.getDocuments(_token, _language);
      _cacheKycStatus(result.account.isActive);
      return Right(result);
    } on app_ex.ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error fetching documents'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DriverDocumentsStatus>> uploadDocuments({
    File? nationalId,
    DateTime? nationalIdExpiresAt,
    File? criminalRecord,
    DateTime? criminalRecordExpiresAt,
    File? vehicleLicense,
    DateTime? vehicleLicenseExpiresAt,
  }) async {
    try {
      final result = await remoteDataSource.uploadDocuments(
        token: _token,
        language: _language,
        nationalId: nationalId,
        nationalIdExpiresAt: nationalIdExpiresAt,
        criminalRecord: criminalRecord,
        criminalRecordExpiresAt: criminalRecordExpiresAt,
        vehicleLicense: vehicleLicense,
        vehicleLicenseExpiresAt: vehicleLicenseExpiresAt,
      );
      _cacheKycStatus(result.account.isActive);
      return Right(result);
    } on app_ex.ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error uploading documents'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
