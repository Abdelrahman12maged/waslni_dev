/// Domain entity representing a single KYC document uploaded by a driver.
class DriverDocument {
  /// One of: national_id | criminal_record | vehicle_license
  final String type;

  /// Backend-localised label (Arabic or English depending on Accept-Language)
  final String typeLabel;

  final bool uploaded;

  /// Relative URL path — NOT a public link.
  /// Must be fetched via [ApiEndpoints.driverDocumentFile] with a Bearer token.
  final String? fileUrl;

  final String? originalName;
  final String? mimeType;

  /// File size in bytes.
  final int? size;

  final DateTime? expiresAt;
  final bool isExpired;
  final DateTime? uploadedAt;

  const DriverDocument({
    required this.type,
    required this.typeLabel,
    required this.uploaded,
    this.fileUrl,
    this.originalName,
    this.mimeType,
    this.size,
    this.expiresAt,
    required this.isExpired,
    this.uploadedAt,
  });
}
