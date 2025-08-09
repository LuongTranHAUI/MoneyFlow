import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _vnCurrency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );
  
  static final NumberFormat _usdCurrency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );
  
  static String formatVND(double amount) {
    return _vnCurrency.format(amount);
  }
  
  static String formatUSD(double amount) {
    return _usdCurrency.format(amount);
  }
  
  static String format(double amount, {String currency = 'VND'}) {
    switch (currency) {
      case 'USD':
        return formatUSD(amount);
      case 'VND':
      default:
        return formatVND(amount);
    }
  }
  
  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
  
  // Add thousands separator to string
  static String addThousandsSeparator(String numericString) {
    if (numericString.isEmpty) return '';
    
    final number = int.tryParse(numericString);
    if (number == null) return numericString;
    
    return NumberFormat('#,###').format(number);
  }
}