import 'package:drift/drift.dart';

class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get type => text()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get data => text().nullable()();
  DateTimeColumn get scheduledTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

enum NotificationType {
  budgetAlert,
  goalProgress,
  transactionReminder,
  billReminder,
  achievement,
  general
}

class NotificationModel {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? data;
  final DateTime? scheduledTime;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.data,
    this.scheduledTime,
    required this.createdAt,
  });

  String get typeString {
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

  static NotificationType typeFromString(String type) {
    switch (type) {
      case 'budget_alert':
        return NotificationType.budgetAlert;
      case 'goal_progress':
        return NotificationType.goalProgress;
      case 'transaction_reminder':
        return NotificationType.transactionReminder;
      case 'bill_reminder':
        return NotificationType.billReminder;
      case 'achievement':
        return NotificationType.achievement;
      default:
        return NotificationType.general;
    }
  }
}