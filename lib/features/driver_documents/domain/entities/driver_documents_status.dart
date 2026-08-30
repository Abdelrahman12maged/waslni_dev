import 'driver_account_status.dart';
import 'driver_document.dart';

/// Composite entity modelling the full GET /api/driver/documents response.
class DriverDocumentsStatus {
  final DriverAccountStatus account;

  /// Always contains all 3 document types — uploaded or not.
  final List<DriverDocument> documents;

  const DriverDocumentsStatus({
    required this.account,
    required this.documents,
  });

  /// Convenience lookup — returns the document entry for the given [type].
  DriverDocument? documentFor(String type) {
    try {
      return documents.firstWhere((d) => d.type == type);
    } catch (_) {
      return null;
    }
  }
}
