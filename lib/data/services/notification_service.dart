import 'package:drift/drift.dart';
import '../datasources/local/database.dart';
import '../models/notification_model.dart';
import '../../core/errors/app_exception.dart';

class NotificationService {
  final AppDatabase _database;

  NotificationService(this._database);

  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _database.select(_database.notifications);
      
      if (isRead != null) {
        query = query..where((n) => n.isRead.equals(isRead));
      }
      
      query = query..orderBy([(n) => OrderingTerm.desc(n.createdAt)]);
      
      if (limit != null) {
        query = query..limit(limit, offset: offset);
      }

      final notificationEntries = await query.get();

      return notificationEntries.map((entry) => NotificationModel(
        id: entry.id,
        title: entry.title,
        message: entry.message,
        type: NotificationModel.typeFromString(entry.type),
        isRead: entry.isRead,
        data: entry.data,
        scheduledTime: entry.scheduledTime,
        createdAt: entry.createdAt,
      )).toList();
    } catch (e) {
      throw AppException(message: 'Không thể tải danh sách thông báo: $e');
    }
  }

  Future<NotificationModel?> getNotificationById(int id) async {
    try {
      final notificationEntry = await (_database.select(_database.notifications)
            ..where((n) => n.id.equals(id)))
          .getSingleOrNull();

      if (notificationEntry == null) return null;

      return NotificationModel(
        id: notificationEntry.id,
        title: notificationEntry.title,
        message: notificationEntry.message,
        type: NotificationModel.typeFromString(notificationEntry.type),
        isRead: notificationEntry.isRead,
        data: notificationEntry.data,
        scheduledTime: notificationEntry.scheduledTime,
        createdAt: notificationEntry.createdAt,
      );
    } catch (e) {
      throw AppException(message: 'Không thể tải thông báo: $e');
    }
  }

  Future<NotificationModel> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? data,
    DateTime? scheduledTime,
  }) async {
    try {
      final notificationEntry = await _database.into(_database.notifications).insertReturning(
            NotificationsCompanion(
              title: Value(title),
              message: Value(message),
              type: Value(_getTypeString(type)),
              data: Value(data),
              scheduledTime: Value(scheduledTime),
            ),
          );

      return NotificationModel(
        id: notificationEntry.id,
        title: notificationEntry.title,
        message: notificationEntry.message,
        type: NotificationModel.typeFromString(notificationEntry.type),
        isRead: notificationEntry.isRead,
        data: notificationEntry.data,
        scheduledTime: notificationEntry.scheduledTime,
        createdAt: notificationEntry.createdAt,
      );
    } catch (e) {
      throw AppException(message: 'Không thể tạo thông báo: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await (_database.update(_database.notifications)
            ..where((n) => n.id.equals(id)))
          .write(const NotificationsCompanion(isRead: Value(true)));
    } catch (e) {
      throw AppException(message: 'Không thể đánh dấu thông báo đã đọc: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await (_database.update(_database.notifications)
            ..where((n) => n.isRead.equals(false)))
          .write(const NotificationsCompanion(isRead: Value(true)));
    } catch (e) {
      throw AppException(message: 'Không thể đánh dấu tất cả thông báo đã đọc: $e');
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await (_database.delete(_database.notifications)
            ..where((n) => n.id.equals(id)))
          .go();
    } catch (e) {
      throw AppException(message: 'Không thể xóa thông báo: $e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await _database.delete(_database.notifications).go();
    } catch (e) {
      throw AppException(message: 'Không thể xóa tất cả thông báo: $e');
    }
  }

  Future<void> deleteReadNotifications() async {
    try {
      await (_database.delete(_database.notifications)
            ..where((n) => n.isRead.equals(true)))
          .go();
    } catch (e) {
      throw AppException(message: 'Không thể xóa các thông báo đã đọc: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final result = await (_database.selectOnly(_database.notifications)
            ..where(_database.notifications.isRead.equals(false))
            ..addColumns([_database.notifications.id.count()]))
          .getSingle();
      
      return result.read(_database.notifications.id.count()) ?? 0;
    } catch (e) {
      throw AppException(message: 'Không thể đếm số thông báo chưa đọc: $e');
    }
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    return getNotifications(isRead: false);
  }

  Future<List<NotificationModel>> getNotificationsByType(NotificationType type) async {
    try {
      final notificationEntries = await (_database.select(_database.notifications)
            ..where((n) => n.type.equals(_getTypeString(type)))
            ..orderBy([(n) => OrderingTerm.desc(n.createdAt)]))
          .get();

      return notificationEntries.map((entry) => NotificationModel(
        id: entry.id,
        title: entry.title,
        message: entry.message,
        type: NotificationModel.typeFromString(entry.type),
        isRead: entry.isRead,
        data: entry.data,
        scheduledTime: entry.scheduledTime,
        createdAt: entry.createdAt,
      )).toList();
    } catch (e) {
      throw AppException(message: 'Không thể tải thông báo theo loại: $e');
    }
  }

  Future<List<NotificationModel>> getScheduledNotifications() async {
    try {
      final now = DateTime.now();
      final notificationEntries = await (_database.select(_database.notifications)
            ..where((n) => n.scheduledTime.isNotNull() & 
                          n.scheduledTime.isBiggerThanValue(now))
            ..orderBy([(n) => OrderingTerm.asc(n.scheduledTime)]))
          .get();

      return notificationEntries.map((entry) => NotificationModel(
        id: entry.id,
        title: entry.title,
        message: entry.message,
        type: NotificationModel.typeFromString(entry.type),
        isRead: entry.isRead,
        data: entry.data,
        scheduledTime: entry.scheduledTime,
        createdAt: entry.createdAt,
      )).toList();
    } catch (e) {
      throw AppException(message: 'Không thể tải thông báo đã lên lịch: $e');
    }
  }

  Future<NotificationModel> createBudgetAlertNotification({
    required String category,
    required double percentage,
    required double spent,
    required double budget,
  }) async {
    final title = percentage >= 100
        ? 'Vượt ngân sách $category'
        : 'Cảnh báo ngân sách $category';
    
    final message = percentage >= 100
        ? 'Bạn đã vượt ngân sách $category ${percentage.toStringAsFixed(1)}%. Đã chi ${spent.toStringAsFixed(0)}đ/${budget.toStringAsFixed(0)}đ.'
        : 'Bạn đã sử dụng ${percentage.toStringAsFixed(1)}% ngân sách $category. Đã chi ${spent.toStringAsFixed(0)}đ/${budget.toStringAsFixed(0)}đ.';

    return createNotification(
      title: title,
      message: message,
      type: NotificationType.budgetAlert,
      data: '{"category": "$category", "percentage": $percentage, "spent": $spent, "budget": $budget}',
    );
  }

  Future<NotificationModel> createGoalProgressNotification({
    required String goalName,
    required double percentage,
    required double current,
    required double target,
  }) async {
    final title = percentage >= 100
        ? 'Hoàn thành mục tiêu $goalName'
        : 'Tiến độ mục tiêu $goalName';
    
    final message = percentage >= 100
        ? 'Chúc mừng! Bạn đã hoàn thành mục tiêu $goalName.'
        : 'Bạn đã đạt ${percentage.toStringAsFixed(1)}% mục tiêu $goalName. ${current.toStringAsFixed(0)}đ/${target.toStringAsFixed(0)}đ.';

    return createNotification(
      title: title,
      message: message,
      type: NotificationType.goalProgress,
      data: '{"goalName": "$goalName", "percentage": $percentage, "current": $current, "target": $target}',
    );
  }

  Future<NotificationModel> createTransactionReminderNotification({
    required String reminderText,
    DateTime? scheduledTime,
  }) async {
    return createNotification(
      title: 'Nhắc nhở giao dịch',
      message: reminderText,
      type: NotificationType.transactionReminder,
      scheduledTime: scheduledTime,
    );
  }

  Future<NotificationModel> createBillReminderNotification({
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    return createNotification(
      title: 'Nhắc nhở hóa đơn',
      message: 'Hóa đơn $billName (${amount.toStringAsFixed(0)}đ) sẽ đến hạn vào ${dueDate.day}/${dueDate.month}.',
      type: NotificationType.billReminder,
      scheduledTime: dueDate.subtract(const Duration(days: 1)),
      data: '{"billName": "$billName", "amount": $amount, "dueDate": "${dueDate.toIso8601String()}"}',
    );
  }

  String _getTypeString(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return 'budget_alert';
      case NotificationType.goalProgress:
        return 'goal_progress';
      case NotificationType.transactionReminder:
        return 'transaction_reminder';
      case NotificationType.billReminder:
        return 'bill_reminder';
      case NotificationType.achievement:
        return 'achievement';
      case NotificationType.general:
        return 'general';
    }
  }
}