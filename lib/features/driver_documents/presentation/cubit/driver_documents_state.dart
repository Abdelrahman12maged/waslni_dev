import 'dart:io';
import 'package:car_app/features/driver_documents/domain/entities/driver_documents_status.dart';
import 'package:equatable/equatable.dart';

abstract class DriverDocumentsState extends Equatable {
  const DriverDocumentsState();

  @override
  List<Object?> get props => [];
}

// ── Network states ────────────────────────────────────────────────────────────

class DriverDocumentsInitial extends DriverDocumentsState {
  const DriverDocumentsInitial();
}

class DriverDocumentsLoading extends DriverDocumentsState {
  const DriverDocumentsLoading();
}

class DriverDocumentsLoaded extends DriverDocumentsState {
  final DriverDocumentsStatus status;
  const DriverDocumentsLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

class DriverDocumentsError extends DriverDocumentsState {
  final String message;
  final String? errorCode;
  const DriverDocumentsError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class DriverDocumentsUploading extends DriverDocumentsState {
  const DriverDocumentsUploading();
}

class DriverDocumentsUploadSuccess extends DriverDocumentsState {
  final DriverDocumentsStatus status;
  const DriverDocumentsUploadSuccess(this.status);

  @override
  List<Object?> get props => [status];
}

class DriverDocumentsUploadError extends DriverDocumentsState {
  final String message;
  final String? errorCode;
  const DriverDocumentsUploadError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// ── Local UI states (file selected, not yet uploaded) ─────────────────────────

/// Emitted when the user picks a file for a document type locally (pre-upload).
class DocumentFilePicked extends DriverDocumentsState {
  /// One of: national_id | criminal_record | vehicle_license
  final String type;
  final File file;
  final DateTime? expiresAt;
  const DocumentFilePicked({required this.type, required this.file, this.expiresAt});

  @override
  List<Object?> get props => [type, file.path, expiresAt];
}

/// Emitted when the user updates the expiry date for a pending document.
class DocumentExpiryDateUpdated extends DriverDocumentsState {
  final String type;
  final DateTime expiresAt;
  const DocumentExpiryDateUpdated({required this.type, required this.expiresAt});

  @override
  List<Object?> get props => [type, expiresAt];
}
