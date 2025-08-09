import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';
import '../../core/utils/date_formatter.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: () {
              ref.read(notificationControllerProvider.notifier).markAllAsRead();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Xóa tất cả',
            onPressed: () => _showDeleteAllDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
        },
        child: notificationsAsyncValue.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildNotificationsList(notifications, ref, context);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState('Lỗi: $error', ref),
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationControllerProvider.notifier).deleteAllNotifications();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}

// New notification list implementation with date grouping
Widget _buildNotificationsList(List<NotificationModel> notifications, WidgetRef ref, BuildContext context) {
  // Group notifications by date
  final Map<String, List<NotificationModel>> groupedNotifications = {};
  
  for (final notification in notifications) {
    final dateKey = _getDateKey(notification.createdAt);
    groupedNotifications[dateKey] ??= [];
    groupedNotifications[dateKey]!.add(notification);
  }
  
  // Sort groups by date (newest first)
  final sortedKeys = groupedNotifications.keys.toList()
    ..sort((a, b) => b.compareTo(a));
  
  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      for (final dateKey in sortedKeys) ...[
        // Date header
        SliverToBoxAdapter(
          child: _buildDateHeader(dateKey, context: context),
        ),
        // Notifications for this date
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final notification = groupedNotifications[dateKey]![index];
              return _buildNotificationItem(notification, ref, context);
            },
            childCount: groupedNotifications[dateKey]!.length,
          ),
        ),
      ],
    ],
  );
}

Widget _buildDateHeader(String dateKey, {required BuildContext context}) {
  final date = DateTime.parse(dateKey);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final notificationDate = DateTime(date.year, date.month, date.day);
  
  String displayText;
  if (notificationDate == today) {
    displayText = 'Hôm nay';
  } else if (notificationDate == yesterday) {
    displayText = 'Hôm qua';
  } else {
    displayText = DateFormatter.formatDayMonth(date);
  }
  
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      displayText,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

String _getDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Widget _buildEmptyState(BuildContext context) {
  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'Chưa có thông báo nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thông báo sẽ xuất hiện khi có hoạt động quan trọng\ntrong tài chính của bạn',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildErrorState(String message, WidgetRef ref) {
  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(message),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(notificationControllerProvider.notifier).refreshNotifications();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


Widget _buildNotificationItem(NotificationModel notification, WidgetRef ref, BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => ref.read(notificationControllerProvider.notifier).deleteNotification(notification.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      child: Material(
        color: notification.isRead 
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        elevation: notification.isRead ? 1 : 2,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              ref.read(notificationControllerProvider.notifier).markAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: notification.isRead 
                ? Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  )
                : Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Notification icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationTypeColor(notification.type).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _getNotificationTypeIcon(notification.type),
                    color: _getNotificationTypeColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and unread indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                fontSize: 16,
                                color: notification.isRead 
                                    ? Theme.of(context).colorScheme.onSurfaceVariant
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.isRead 
                              ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      
                      // Type and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getNotificationTypeColor(notification.type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getNotificationTypeLabel(notification.type),
                              style: TextStyle(
                                color: _getNotificationTypeColor(notification.type),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            DateFormatter.formatTime(notification.createdAt),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Removed bottom sheet detail view - notifications are marked as read on tap

IconData _getNotificationTypeIcon(NotificationType type) {
  switch (type) {
    case NotificationType.budgetAlert:
      return Icons.account_balance_wallet;
    case NotificationType.goalProgress:
      return Icons.flag;
    case NotificationType.transactionReminder:
      return Icons.receipt;
    case NotificationType.billReminder:
      return Icons.payment;
    case NotificationType.achievement:
      return Icons.celebration;
    case NotificationType.general:
      return Icons.info;
  }
}

Color _getNotificationTypeColor(NotificationType type) {
  switch (type) {
    case NotificationType.budgetAlert:
      return Colors.orange;
    case NotificationType.goalProgress:
      return Colors.green;
    case NotificationType.transactionReminder:
      return Colors.blue;
    case NotificationType.billReminder:
      return Colors.red;
    case NotificationType.achievement:
      return Colors.purple;
    case NotificationType.general:
      return Colors.grey;
  }
}

String _getNotificationTypeLabel(NotificationType type) {
  switch (type) {
    case NotificationType.budgetAlert:
      return 'Cảnh báo ngân sách';
    case NotificationType.goalProgress:
      return 'Tiến độ mục tiêu';
    case NotificationType.transactionReminder:
      return 'Nhắc nhở giao dịch';
    case NotificationType.billReminder:
      return 'Nhắc nhở hóa đơn';
    case NotificationType.achievement:
      return 'Thành tích';
    case NotificationType.general:
      return 'Thông báo chung';
  }
}

