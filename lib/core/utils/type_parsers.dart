/// Safe type parsing utilities.
/// Prevents [type 'String' is not a subtype of type 'double'] crashes
/// that occur when an API returns numbers as strings.
abstract class TypeParsers {
  /// Safely converts any JSON value to [double].
  /// Returns null if the value is null or not parseable.
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Safely converts any JSON value to [int].
  /// Returns null if the value is null or not parseable.
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// Safely converts any JSON value to [String].
  /// Returns null if the value is null.
  static String? parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Safely converts any JSON value to [bool].
  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return value.toString().toLowerCase() == 'true';
  }
}
