import 'dart:io';
import 'package:car_app/core/error/failures.dart';
import 'package:car_app/core/storage/local_storage.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_documents_status.dart';
import 'package:car_app/features/driver_documents/domain/usecases/get_driver_documents_usecase.dart';
import 'package:car_app/features/driver_documents/domain/usecases/upload_driver_documents_usecase.dart';
import 'package:car_app/features/driver_documents/presentation/cubit/driver_documents_state.dart';
import 'package:car_app/core/usecases/usecase.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverDocumentsCubit extends Cubit<DriverDocumentsState> {
  final GetDriverDocumentsUseCase getDriverDocumentsUseCase;
  final UploadDriverDocumentsUseCase uploadDriverDocumentsUseCase;
  final LocalStorage localStorage;

  DriverDocumentsCubit({
    required this.getDriverDocumentsUseCase,
    required this.uploadDriverDocumentsUseCase,
    required this.localStorage,
  }) : super(const DriverDocumentsInitial());

  static DriverDocumentsCubit of(BuildContext context) => BlocProvider.of(context);

  // ── State caching ──────────────────────────────────────────────────────────
  DriverDocumentsStatus? currentStatus;

  // ── Local pending state ────────────────────────────────────────────────────

  File? pendingNationalId;
  File? pendingCriminalRecord;
  File? pendingVehicleLicense;

  bool get hasPendingFiles =>
      pendingNationalId != null ||
      pendingCriminalRecord != null ||
      pendingVehicleLicense != null;

  // ── Load documents ─────────────────────────────────────────────────────────

  Future<void> loadDocuments() async {
    debugPrint('🔄 [DriverDocsCubit] loadDocuments() called.');
    if (currentStatus == null) {
      emit(const DriverDocumentsLoading());
    }

    // 1. Auto-upload any pending documents saved during registration if they exist
    final nidPath = localStorage.read(key: 'pending_kyc_national_id') as String?;
    final crPath = localStorage.read(key: 'pending_kyc_criminal_record') as String?;
    final vlPath = localStorage.read(key: 'pending_kyc_vehicle_license') as String?;

    if ((nidPath != null && nidPath.isNotEmpty) ||
        (crPath != null && crPath.isNotEmpty) ||
        (vlPath != null && vlPath.isNotEmpty)) {
      debugPrint('📦 [DriverDocsCubit] Found pending registration KYC files in local storage:');
      debugPrint('   - nid: $nidPath');
      debugPrint('   - cr: $crPath');
      debugPrint('   - vl: $vlPath');

      final nid = (nidPath != null && nidPath.isNotEmpty) ? File(nidPath) : null;
      final cr = (crPath != null && crPath.isNotEmpty) ? File(crPath) : null;
      final vl = (vlPath != null && vlPath.isNotEmpty) ? File(vlPath) : null;

      final uploadResult = await uploadDriverDocumentsUseCase(
        UploadDocumentsParams(
          nationalId: nid,
          criminalRecord: cr,
          vehicleLicense: vl,
        ),
      );

      // Remove pending keys
      localStorage.remove(key: 'pending_kyc_national_id');
      localStorage.remove(key: 'pending_kyc_criminal_record');
      localStorage.remove(key: 'pending_kyc_vehicle_license');

      // If upload succeeded directly, emit loaded with returned status
      if (uploadResult.isRight()) {
        uploadResult.fold(
          (_) {},
          (status) {
            debugPrint('✅ [DriverDocsCubit] Pending registration KYC auto-uploaded successfully!');
            currentStatus = status;
            emit(DriverDocumentsLoaded(status));
          },
        );
        return;
      }
    }

    // 2. Fetch current documents from server
    debugPrint('📡 [DriverDocsCubit] Fetching driver documents from server...');
    final result = await getDriverDocumentsUseCase(NoParams());
    result.fold(
      (failure) {
        debugPrint('❌ [DriverDocsCubit] Failed to load documents: ${failure.message}');
        emit(DriverDocumentsError(
          failure.message,
          errorCode: failure is ServerFailure ? failure.errorCode : null,
        ));
      },
      (status) {
        debugPrint('✅ [DriverDocsCubit] Documents loaded successfully! (isActive: ${status.account.isActive}, missing: ${status.account.missingDocuments})');
        currentStatus = status;
        emit(DriverDocumentsLoaded(status));
      },
    );
  }

  // ── File picker ────────────────────────────────────────────────────────────

  /// Opens [file_picker] for a document of the given [type].
  /// Accepts: jpg, jpeg, png, webp, pdf — per backend spec (max 8 MB).
  Future<void> pickDocument(String type) async {
    try {
      debugPrint('📂 [DriverDocsCubit] Opening file picker for docType: $type');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('ℹ️ [DriverDocsCubit] User cancelled file picker.');
        return;
      }
      final picked = File(result.files.single.path!);
      final sizeKb = (picked.lengthSync() / 1024).toStringAsFixed(1);
      debugPrint('📌 [DriverDocsCubit] Picked file for $type: ${picked.path} ($sizeKb KB)');

      switch (type) {
        case 'national_id':
          pendingNationalId = picked;
          emit(DocumentFilePicked(type: type, file: picked));
          break;
        case 'criminal_record':
          pendingCriminalRecord = picked;
          emit(DocumentFilePicked(type: type, file: picked));
          break;
        case 'vehicle_license':
          pendingVehicleLicense = picked;
          emit(DocumentFilePicked(type: type, file: picked));
          break;
      }
    } catch (e) {
      debugPrint('💥 [DriverDocsCubit] Error picking document: $e');
      emit(DriverDocumentsUploadError(e.toString()));
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> uploadPendingDocuments() async {
    if (!hasPendingFiles) {
      debugPrint('⚠️ [DriverDocsCubit] uploadPendingDocuments called but no pending files selected!');
      return;
    }

    debugPrint('🚀 [DriverDocsCubit] Uploading selected documents:');
    debugPrint('   - nationalId: ${pendingNationalId?.path ?? "NONE"}');
    debugPrint('   - criminalRecord: ${pendingCriminalRecord?.path ?? "NONE"}');
    debugPrint('   - vehicleLicense: ${pendingVehicleLicense?.path ?? "NONE"}');

    emit(const DriverDocumentsUploading());

    final result = await uploadDriverDocumentsUseCase(
      UploadDocumentsParams(
        nationalId: pendingNationalId,
        criminalRecord: pendingCriminalRecord,
        vehicleLicense: pendingVehicleLicense,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [DriverDocsCubit] Upload failed: ${failure.message}');
        emit(DriverDocumentsUploadError(
          failure.message,
          errorCode: failure is ServerFailure ? failure.errorCode : null,
        ));
      },
      (status) {
        debugPrint('🎉 [DriverDocsCubit] Upload SUCCESS! (isActive: ${status.account.isActive}, missing: ${status.account.missingDocuments})');
        // Clear pending state after successful upload
        pendingNationalId = null;
        pendingCriminalRecord = null;
        pendingVehicleLicense = null;
        currentStatus = status;
        emit(DriverDocumentsUploadSuccess(status));
      },
    );
  }
}
