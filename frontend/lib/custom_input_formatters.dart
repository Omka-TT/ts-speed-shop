import 'package:flutter/services.dart';

class CardNumberInputFormatter extends TextInputFormatter {
  static const int maxDigits = 16;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = _onlyDigits(newValue.text);
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    final formattedText = _formatWithSpaces(digits);
    final cursorPosition = _calculateCursorPosition(
      oldValue,
      newValue,
      formattedText,
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  String _onlyDigits(String input) => input.replaceAll(RegExp('[^0-9]'), '');

  String _formatWithSpaces(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i + 1) % 4 == 0 && i + 1 != digits.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  int _calculateCursorPosition(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    String formattedText,
  ) {
    final selectionIndex = newValue.selection.baseOffset;
    final rawBefore = _onlyDigits(newValue.text
        .substring(0, selectionIndex.clamp(0, newValue.text.length)));

    int digitPosition = rawBefore.length;

    int newCursorPosition = digitPosition + digitPosition ~/ 4;
    if (newCursorPosition > formattedText.length) {
      newCursorPosition = formattedText.length;
    }
    return newCursorPosition;
  }
}

/// Formats expiry date as MM/YY with intelligent validation
/// - Only allows digits
/// - Auto-inserts "/" after MM
/// - Validates month (01-12 only)
/// - Max 5 characters (MM/YY)
class ExpiryDateInputFormatter extends TextInputFormatter {
  static const int maxDigits = 4; // MMYY without slash

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Extract only digits from input
    String digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    // Limit to 4 digits max (MMYY)
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    // Validate and correct month if necessary
    if (digits.length >= 2) {
      String monthStr = digits.substring(0, 2);
      int month = int.tryParse(monthStr) ?? 0;

      // If month is invalid (> 12), restrict input intelligently
      if (month > 12) {
        // If first digit > 1, it's invalid month start
        final firstDigit = int.tryParse(digits[0]) ?? 0;
        if (firstDigit > 1) {
          // Invalid first digit for month, revert to old digits
          String oldDigits = oldValue.text.replaceAll(RegExp('[^0-9]'), '');
          if (oldDigits.isNotEmpty &&
              (int.tryParse(oldDigits.substring(0, min(2, oldDigits.length))) ?? 0) <= 12) {
            digits = oldDigits;
          } else {
            digits = digits[0];
          }
        } else if (monthStr[0] == '0') {
          // Keep 01-09 range only if valid
          if (month == 0 || month > 9) {
            digits = digits[0];
          }
        } else {
          // First digit is 1, check second digit
          if (month > 12) {
            digits = digits[0];
          }
        }
      }
    }

    // Format as MM/YY
    String formatted;
    if (digits.isEmpty) {
      formatted = '';
    } else if (digits.length <= 2) {
      formatted = digits;
    } else {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    // Calculate intelligent cursor position
    int cursorPos = formatted.length;
    if (newValue.selection.baseOffset <= newValue.text.length) {
      final oldCursorPos = newValue.selection.baseOffset;

      // If user is typing first two digits
      if (oldCursorPos <= 2 && formatted.length >= 3) {
        cursorPos = 2; // Position before the auto-inserted "/"
      } else {
        cursorPos = formatted.length;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: cursorPos.clamp(0, formatted.length),
      ),
    );
  }
}

/// Formatter for CVV field - limits to 3-4 digits
class CvvInputFormatter extends TextInputFormatter {
  static const int maxLength = 4;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    final clamped =
        digits.length > maxLength ? digits.substring(0, maxLength) : digits;
    return TextEditingValue(
      text: clamped,
      selection: TextSelection.collapsed(offset: clamped.length),
    );
  }
}

// Helper function for min
int min(int a, int b) => a < b ? a : b;
