import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/notification_model.dart';
import '../providers/database_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final database = ref.watch(databaseProvider);
  return NotificationService(database);
});

final notificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(limit: 50);
});

final unreadNotificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadNotifications();
});

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount();
});

final notificationsByTypeProvider = FutureProvider.autoDispose.family<List<NotificationModel>, NotificationType>((ref, type) {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotificationsByType(type);
});

final scheduledNotificationsProvider = FutureProvider.autoDispose<List<NotificationModel>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.getScheduledNotifications();
});

class NotificationController extends StateNotifier<AsyncValue<void>> {
  final NotificationService _service;
  final Ref _ref;

  NotificationController(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? data,
    DateTime? scheduledTime,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.createNotification(
        title: title,
        message: message,
        type: type,
        data: data,
        scheduledTime: scheduledTime,
      );
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAsRead(int id) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.markAsRead(id);
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    
    try {
      await _service.markAllAsRead();
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteNotification(int id) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deleteNotification(id);
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteAllNotifications() async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deleteAllNotifications();
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteReadNotifications() async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deleteReadNotifications();
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createBudgetAlertNotification({
    required String category,
    required double percentage,
    required double spent,
    required double budget,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.createBudgetAlertNotification(
        category: category,
        percentage: percentage,
        spent: spent,
        budget: budget,
      );
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createGoalProgressNotification({
    required String goalName,
    required double percentage,
    required double current,
    required double target,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.createGoalProgressNotification(
        goalName: goalName,
        percentage: percentage,
        current: current,
        target: target,
      );
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createTransactionReminderNotification({
    required String reminderText,
    DateTime? scheduledTime,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.createTransactionReminderNotification(
        reminderText: reminderText,
        scheduledTime: scheduledTime,
      );
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      _ref.invalidate(scheduledNotificationsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createBillReminderNotification({
    required String billName,
    required double amount,
    required DateTime dueDate,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.createBillReminderNotification(
        billName: billName,
        amount: amount,
        dueDate: dueDate,
      );
      
      _ref.invalidate(notificationsProvider);
      _ref.invalidate(unreadNotificationsProvider);
      _ref.invalidate(unreadNotificationCountProvider);
      _ref.invalidate(scheduledNotificationsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshNotifications() async {
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(unreadNotificationsProvider);
    _ref.invalidate(unreadNotificationCountProvider);
    _ref.invalidate(scheduledNotificationsProvider);
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationController(service, ref);
});