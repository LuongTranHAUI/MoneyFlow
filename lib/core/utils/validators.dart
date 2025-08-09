import 'package:flutter/material.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    
    if (value.length < minLength) {
      return 'Mật khẩu phải có ít nhất $minLength ký tự';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    
    return null;
  }

  // Full name validation
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    
    if (value.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }
    
    // Check for valid characters (letters, spaces, Vietnamese characters)
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Họ và tên chỉ được chứa chữ cái và khoảng trắng';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value, {bool isRequired = false}) {
    if (value == null || value.isEmpty) {
      return isRequired ? 'Vui lòng nhập số điện thoại' : null;
    }
    
    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check Vietnam phone number format
    final phoneRegex = RegExp(r'^(\+84|84|0)[3-9]\d{8}$');
    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số tiền';
    }
    
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Số tiền không hợp lệ';
    }
    
    if (amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }
    
    if (minAmount != null && amount < minAmount) {
      return 'Số tiền phải từ ${_formatCurrency(minAmount)} trở lên';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return 'Số tiền không được vượt quá ${_formatCurrency(maxAmount)}';
    }
    
    return null;
  }

  // Budget amount validation
  static String? validateBudgetAmount(String? value) {
    return validateAmount(value, minAmount: 1000);
  }

  // Goal amount validation
  static String? validateGoalAmount(String? value) {
    return validateAmount(value, minAmount: 10000);
  }

  // Category validation
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn danh mục';
    }
    return null;
  }

  // Description validation (optional but with length limit)
  static String? validateDescription(String? value, {int maxLength = 255}) {
    if (value != null && value.length > maxLength) {
      return 'Mô tả không được vượt quá $maxLength ký tự';
    }
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value, {DateTime? minDate, DateTime? maxDate}) {
    if (value == null) {
      return 'Vui lòng chọn ngày';
    }
    
    if (minDate != null && value.isBefore(minDate)) {
      return 'Ngày không được trước ${_formatDate(minDate)}';
    }
    
    if (maxDate != null && value.isAfter(maxDate)) {
      return 'Ngày không được sau ${_formatDate(maxDate)}';
    }
    
    return null;
  }

  // Goal target date validation
  static String? validateGoalTargetDate(DateTime? value) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    return validateDate(value, minDate: tomorrow);
  }

  // Budget period validation
  static String? validateBudgetPeriod(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) {
      return 'Vui lòng chọn ngày bắt đầu';
    }
    
    if (endDate == null) {
      return 'Vui lòng chọn ngày kết thúc';
    }
    
    if (endDate.isBefore(startDate) || endDate.isAtSameMomentAs(startDate)) {
      return 'Ngày kết thúc phải sau ngày bắt đầu';
    }
    
    return null;
  }

  // Helper methods
  static String _formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ₫';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Comprehensive form validation
  static bool isValidForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  // Check if string contains only numbers
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  // Check if string is empty or whitespace
  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // Sanitize input (remove extra spaces, etc.)
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}