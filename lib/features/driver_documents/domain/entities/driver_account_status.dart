/// Domain entity for the driver's KYC account activation status.
///
/// [isActive] — true = admin has activated the account; driver can make offers.
/// [missingDocuments] — list of document types not yet uploaded.
/// [message] — pre-localised message from backend; render directly in UI.
class DriverAccountStatus {
  final bool isActive;
  final DateTime? activatedAt;
  final List<String> missingDocuments;
  final String message;

  const DriverAccountStatus({
    required this.isActive,
    this.activatedAt,
    required this.missingDocuments,
    required this.message,
  });
}
