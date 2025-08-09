import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayMonth = DateFormat('dd/MM');
  static final DateFormat _monthYear = DateFormat('MM/yyyy');
  static final DateFormat _fullDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _fullDateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dayName = DateFormat('EEEE', 'vi_VN');
  
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
  
  static String formatMonthYear(DateTime date) => _monthYear.format(date);
  
  static String formatFullDate(DateTime date) => _fullDate.format(date);
  
  static String formatFullDateTime(DateTime date) => _fullDateTime.format(date);
  
  static String formatTime(DateTime date) => _time.format(date);
  
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    }
    
    return formatFullDate(date);
  }
  
  static String formatDayName(DateTime date) => _dayName.format(date);
  
  static String formatRelativeTime(DateTime date) => formatRelative(date);
  
  static String formatDateTime(DateTime date) => formatFullDateTime(date);
  
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
}