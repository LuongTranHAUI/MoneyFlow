import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (newText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse the number
    final number = int.tryParse(newText);
    if (number == null) {
      return oldValue;
    }

    // Format with thousand separators
    final formatted = _formatter.format(number);

    // Calculate new cursor position
    int cursorPosition = formatted.length;
    
    // If user is typing in the middle, try to maintain relative position
    if (newValue.selection.baseOffset < newValue.text.length) {
      // Count digits before cursor in original text
      String beforeCursor = newValue.text.substring(0, newValue.selection.baseOffset);
      int digitsBeforeCursor = beforeCursor.replaceAll(RegExp(r'[^\d]'), '').length;
      
      // Find position in formatted text with same number of digits
      int digitCount = 0;
      for (int i = 0; i < formatted.length; i++) {
        if (RegExp(r'\d').hasMatch(formatted[i])) {
          digitCount++;
          if (digitCount == digitsBeforeCursor) {
            cursorPosition = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

// Helper to parse formatted text back to number
class ThousandSeparatorParser {
  static double? parse(String text) {
    if (text.isEmpty) return null;
    
    // Remove all non-digit characters (including commas used as thousand separators)
    String cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    
    return double.tryParse(cleanText);
  }
  
  static String parseToString(String text) {
    if (text.isEmpty) return '';
    
    // Remove all formatting, keep only digits
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }
}