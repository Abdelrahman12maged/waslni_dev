/// Utility for cleaning and formatting location names across the app.
/// Removes Google Plus Codes (e.g., "HP2C+W55"), postal codes / standalone numbers,
/// unwanted symbols, and duplicate tokens.
String cleanLocationName(String? raw) {
  if (raw == null) return '';
  var text = raw.trim();
  if (text.isEmpty) return '';

  // 1. Remove Google Plus Codes (e.g. "Hp2c+w55", "HP2C+W55", "7G7M+X4", "8G4P+3M")
  text = text.replaceAll(
    RegExp(r'\b[A-Za-z0-9]{2,8}\+[A-Za-z0-9]{2,8}\b', caseSensitive: false),
    '',
  );

  // 2. Remove standalone numbers and postal codes (e.g. "2142654", "11181", "123")
  text = text.replaceAll(RegExp(r'\b\d+\b'), '');

  // 3. Normalize delimiters
  text = text.replaceAll('،', ',');
  text = text.replaceAll(';', ',');
  final parts = text.split(',');

  final cleanedTokens = <String>[];
  for (var part in parts) {
    // Remove unwanted symbols while keeping letters, arabic characters, and spaces
    var p = part
        .replaceAll(RegExp(r'[#@$%^&*_+=\/\\|~<>{}\[\]\(\)]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Avoid empty, 1-char tokens, or duplicate tokens (case-insensitive & trimmed)
    if (p.isNotEmpty && p.length > 1) {
      final isDuplicate = cleanedTokens.any(
        (existing) => existing.trim().toLowerCase() == p.toLowerCase(),
      );
      if (!isDuplicate) {
        cleanedTokens.add(p);
      }
    }
  }

  if (cleanedTokens.isEmpty) {
    final fallback = raw
        .replaceAll(
          RegExp(r'[A-Za-z0-9]{2,8}\+[A-Za-z0-9]{2,8}', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\b\d+\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return fallback.isNotEmpty ? fallback : raw.trim();
  }

  return cleanedTokens.join('، ');
}

extension LocationCleanerExtension on String? {
  /// Returns the cleaned, human-readable version of the location name.
  String get cleanLocation => cleanLocationName(this);
}
