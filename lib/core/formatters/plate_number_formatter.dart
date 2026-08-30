import 'package:flutter/services.dart';

/// Auto-formats a vehicle plate number as the user types.
///
/// Target format: `NN - NNNNN`
/// - 2-digit series code
/// - space-dash-space separator (` - `)
/// - variable-length remaining digits
///
/// Behaviour:
/// - Only digits are accepted; all other characters (except the separator as
///   it is auto-inserted) are silently dropped.
/// - Typing past the 2nd digit auto-inserts ` - `.
/// - Backspacing through the separator removes it cleanly so the user can
///   correct the first 2 digits without friction.
///
/// Value sent to backend: the formatted string as typed (`"30 - 12345"`).
/// ⚠️ Backend confirmation pending — if raw digits are required instead,
///    strip the separator in the submit handler before sending.
class PlateNumberFormatter extends TextInputFormatter {
  static const String _separator = ' - ';
  static const int _prefixDigits = 2;

  /// Normalises an existing plate string (raw digits or already formatted)
  /// into `NN - NNNNN` form for pre-populating controllers.
  static String format(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= _prefixDigits) return digits;
    final prefix = digits.substring(0, _prefixDigits);
    final rest = digits.substring(_prefixDigits);
    return '$prefix$_separator$rest';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Extract only raw digits from the new value
    final rawDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Build the formatted string
    final formatted = _format(rawDigits);

    // 3. Clamp cursor to end of formatted string
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String digits) {
    if (digits.length <= _prefixDigits) {
      return digits;
    }
    final prefix = digits.substring(0, _prefixDigits);
    final rest = digits.substring(_prefixDigits);
    return '$prefix$_separator$rest';
  }
}
