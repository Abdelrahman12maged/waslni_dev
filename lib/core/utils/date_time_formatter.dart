/// Centralized utility for consistent date and time string formatting across the app.
class DateTimeFormatter {
  const DateTimeFormatter._();

  /// Formats raw API or ISO-8601 trip datetime strings into standard 'YYYY-MM-DD HH:mm'.
  static String formatTripDateTime(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString().trim();
    if (str.isEmpty) return '';

    if (str.contains('T')) {
      final parts = str.split('T');
      if (parts.length > 1) {
        final date = parts[0];
        final time = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
        return '$date $time';
      }
      return parts[0];
    } else if (str.contains(' ')) {
      final parts = str.split(' ');
      if (parts.length > 1) {
        final date = parts[0];
        final time = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
        return '$date $time';
      }
      return parts[0];
    }
    return str;
  }
}
