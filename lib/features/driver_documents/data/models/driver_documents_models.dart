import 'package:car_app/features/driver_documents/domain/entities/driver_account_status.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_document.dart';
import 'package:car_app/features/driver_documents/domain/entities/driver_documents_status.dart';

class DriverDocumentModel extends DriverDocument {
  const DriverDocumentModel({
    required super.type,
    required super.typeLabel,
    required super.uploaded,
    super.fileUrl,
    super.originalName,
    super.mimeType,
    super.size,
    super.expiresAt,
    required super.isExpired,
    super.uploadedAt,
  });

  factory DriverDocumentModel.fromJson(Map<String, dynamic> json) {
    final fileUrl = json['file_url'] ??
        json['url'] ??
        json['file_path'] ??
        json['document_url'] ??
        json['path'];
    final uploaded = json['uploaded'] as bool? ??
        (fileUrl != null && fileUrl.toString().isNotEmpty);

    return DriverDocumentModel(
      type: json['type'] as String? ??
          json['document_type']?.toString() ??
          '',
      typeLabel: json['type_label'] as String? ??
          json['title']?.toString() ??
          '',
      uploaded: uploaded,
      fileUrl: fileUrl?.toString(),
      originalName: json['original_name']?.toString() ??
          json['file_name']?.toString(),
      mimeType: json['mime_type']?.toString(),
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse(json['size']?.toString() ?? ''),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      isExpired: json['is_expired'] as bool? ?? false,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
    );
  }
}

class DriverAccountStatusModel extends DriverAccountStatus {
  const DriverAccountStatusModel({
    required super.isActive,
    super.activatedAt,
    required super.missingDocuments,
    required super.message,
  });

  factory DriverAccountStatusModel.fromJson(Map<String, dynamic> json) {
    return DriverAccountStatusModel(
      isActive: json['is_active'] as bool? ??
          (json['status'] == 'active' || json['status'] == 1 || json['status'] == '1'),
      activatedAt: json['activated_at'] != null
          ? DateTime.tryParse(json['activated_at'].toString())
          : null,
      missingDocuments: (json['missing_documents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      message: json['message'] as String? ?? '',
    );
  }
}

class DriverDocumentsStatusModel extends DriverDocumentsStatus {
  const DriverDocumentsStatusModel({
    required super.account,
    required super.documents,
  });

  factory DriverDocumentsStatusModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> root = json;
    if (json['data'] is Map<String, dynamic>) {
      root = json['data'] as Map<String, dynamic>;
    } else if (json['result'] is Map<String, dynamic>) {
      root = json['result'] as Map<String, dynamic>;
    }

    final accountJson = root['account'] as Map<String, dynamic>? ??
        (json['account'] as Map<String, dynamic>?) ??
        {};

    dynamic docsRaw = root['documents'] ??
        json['documents'] ??
        root['docs'] ??
        (json['data'] is List ? json['data'] : null);
    final List<dynamic> docsJson = docsRaw is List ? docsRaw : [];

    return DriverDocumentsStatusModel(
      account: DriverAccountStatusModel.fromJson(accountJson),
      documents: docsJson
          .whereType<Map<String, dynamic>>()
          .map((d) => DriverDocumentModel.fromJson(d))
          .toList(),
    );
  }
}
