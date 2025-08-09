// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
import '../../data/models/notification_model.dart';
import '../../presentation/providers/notification_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  // static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    // Tạm thời vô hiệu hóa notification plugin
    print('NotificationService initialized (without push notifications)');
    _initialized = true;
  }

  static Future<void> _requestPermissions() async {
    // Tạm thời vô hiệu hóa permission request
    print('Permission request bypassed');
  }

  // Hiển thị thông báo ngay lập tức (tạm thời vô hiệu hóa push notification)
  static Future<void> showNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? data,
  }) async {
    // Tạm thời bỏ qua push notification để tránh lỗi plugin
    // Chỉ lưu vào database
    print('Notification: $title - $message');
  }

  // Tạo thông báo cảnh báo vượt ngân sách
  static Future<void> createBudgetOverAlert({
    required Ref ref,
    required String category,
    required double budgetAmount,
    required double spentAmount,
  }) async {
    final overAmount = spentAmount - budgetAmount;
    final title = 'Vượt ngân sách: $category';
    final message = 'Bạn đã chi vượt ${_formatCurrency(overAmount)} so với ngân sách ${_formatCurrency(budgetAmount)}';

    // Hiển thị push notification
    await showNotification(
      title: title,
      message: message,
      type: NotificationType.budgetAlert,
    );

    // Lưu vào database
    await ref.read(notificationControllerProvider.notifier).createNotification(
      title: title,
      message: message,
      type: NotificationType.budgetAlert,
      data: '{"category": "$category", "budgetAmount": $budgetAmount, "spentAmount": $spentAmount}',
    );
  }

  // Tạo thông báo cảnh báo sắp vượt ngân sách
  static Future<void> createBudgetWarning({
    required Ref ref,
    required String category,
    required double budgetAmount,
    required double spentAmount,
  }) async {
    final percentage = (spentAmount / budgetAmount * 100).round();
    final remaining = budgetAmount - spentAmount;
    final title = 'Cảnh báo ngân sách: $category';
    final message = 'Đã sử dụng $percentage% ngân sách. Còn lại ${_formatCurrency(remaining)}';

    await showNotification(
      title: title,
      message: message,
      type: NotificationType.budgetAlert,
    );

    await ref.read(notificationControllerProvider.notifier).createNotification(
      title: title,
      message: message,
      type: NotificationType.budgetAlert,
      data: '{"category": "$category", "budgetAmount": $budgetAmount, "spentAmount": $spentAmount, "percentage": $percentage}',
    );
  }

  // Tạo thông báo hoàn thành mục tiêu
  static Future<void> createGoalAchieved({
    required Ref ref,
    required String goalName,
    required double targetAmount,
  }) async {
    final title = 'Chúc mừng! 🎉';
    final message = 'Bạn đã hoàn thành mục tiêu "$goalName" với số tiền ${_formatCurrency(targetAmount)}';

    await showNotification(
      title: title,
      message: message,
      type: NotificationType.achievement,
    );

    await ref.read(notificationControllerProvider.notifier).createNotification(
      title: title,
      message: message,
      type: NotificationType.achievement,
      data: '{"goalName": "$goalName", "targetAmount": $targetAmount}',
    );
  }

  // Tạo thông báo tiến độ mục tiêu
  static Future<void> createGoalProgress({
    required Ref ref,
    required String goalName,
    required double currentAmount,
    required double targetAmount,
    required int milestonePercent, // 25%, 50%, 75%
  }) async {
    final title = 'Tiến độ mục tiêu: $goalName';
    final message = 'Bạn đã đạt $milestonePercent% mục tiêu (${_formatCurrency(currentAmount)}/${_formatCurrency(targetAmount)})';

    await showNotification(
      title: title,
      message: message,
      type: NotificationType.goalProgress,
    );

    await ref.read(notificationControllerProvider.notifier).createNotification(
      title: title,
      message: message,
      type: NotificationType.goalProgress,
      data: '{"goalName": "$goalName", "currentAmount": $currentAmount, "targetAmount": $targetAmount, "percentage": $milestonePercent}',
    );
  }

  // Tạo thông báo chi tiêu lớn
  static Future<void> createLargeExpenseAlert({
    required Ref ref,
    required double amount,
    required String category,
    required double monthlyAverage,
  }) async {
    final title = 'Chi tiêu lớn được ghi nhận';
    final message = 'Giao dịch ${_formatCurrency(amount)} cho $category vượt mức trung bình tháng (${_formatCurrency(monthlyAverage)})';

    await showNotification(
      title: title,
      message: message,
      type: NotificationType.transactionReminder,
    );

    await ref.read(notificationControllerProvider.notifier).createNotification(
      title: title,
      message: message,
      type: NotificationType.transactionReminder,
      data: '{"amount": $amount, "category": "$category", "monthlyAverage": $monthlyAverage}',
    );
  }

  // Tạo thông báo nhắc nhở cuối tháng
  static Future<void> createMonthlyReminder({
    required Ref ref,
    required double totalIncome,
    required double totalExpense,
    required double savings,
  }) async {
    final title = 'Tổng kết tháng';
    final message = 'Thu nhập: ${_formatCurrency(totalIncome)}, Chi tiêu: ${_formatCurrency(totalExpense)}, Tiết kiệm: ${_formatCurrency(savings)}';

    await showNotification(
      title: title,
      message: message,
      type: NotificationType.general,
    );

    await ref.read(notificationControllerProvider.notifier).createNotification(
      title: title,
      message: message,
      type: NotificationType.general,
      data: '{"totalIncome": $totalIncome, "totalExpense": $totalExpense, "savings": $savings}',
    );
  }

  // Tạo thông báo khuyến khích tiết kiệm
  static Future<void> createSavingEncouragement({
    required Ref ref,
    required int daysWithoutExpense,
    required double savedAmount,
  }) async {
    final title = 'Tuyệt vời! 💪';
    final message = 'Bạn đã tiết kiệm được ${_formatCurrency(savedAmount)} trong $daysWithoutExpense ngày qua';

    await showNotification(
      title: title,
      message: message,
      type: NotificationType.achievement,
    );

    await ref.read(notificationControllerProvider.notifier).createNotification(
      title: title,
      message: message,
      type: NotificationType.achievement,
      data: '{"daysWithoutExpense": $daysWithoutExpense, "savedAmount": $savedAmount}',
    );
  }

  // Helper method để format currency
  static String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K₫';
    } else {
      return '${amount.toStringAsFixed(0)}₫';
    }
  }

  // Kiểm tra quyền thông báo (tạm thời trả về true)
  static Future<bool> hasNotificationPermission() async {
    return true;
  }

  // Yêu cầu quyền thông báo (tạm thời trả về true)
  static Future<bool> requestNotificationPermission() async {
    return true;
  }
}