/// Date and time formatting utilities.
/// Converts Arabic/Eastern-Arabic digits to Western digits and formats
/// datetime strings to the API-expected format (Y-m-d H:i:s).
abstract class DateFormatter {
  static const Map<String, String> _arabicToEnglish = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
  };

  /// Replaces Arabic/Eastern-Arabic digits with their Western equivalents.
  /// Prevents backend validation failures when the device locale uses
  /// Arabic numerals (e.g. "٢٠٢٦-٠٧-١٦" → "2026-07-16").
  static String normalizeDigits(String input) {
    String result = input;
    _arabicToEnglish.forEach((arabic, english) {
      result = result.replaceAll(arabic, english);
    });
    return result;
  }

  /// Formats a [DateTime] to the API-expected format: "yyyy-MM-dd HH:mm:ss"
  static String toApiFormat(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  /// Combines a date string and time string, normalizing all digits.
  /// Usage: DateFormatter.buildTripDatetime(tripFullDate, tripFullTime)
  static String buildTripDatetime(String date, String time) {
    return normalizeDigits('$date $time');
  }
}
