import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../screens/notification_screen.dart';

class NotificationIconWithBadge extends ConsumerWidget {
  const NotificationIconWithBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadNotificationsAsyncValue = ref.watch(unreadNotificationsProvider);

    return unreadNotificationsAsyncValue.when(
      data: (unreadNotifications) {
        final unreadCount = unreadNotifications.length;
        
        return Stack(
          children: [
            // Notification icon
            IconButton(
              icon: Icon(
                unreadCount > 0 ? Icons.notifications : Icons.notifications_none,
                color: unreadCount > 0 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
            
            // Badge for unread count
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => IconButton(
        icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationScreen(),
            ),
          );
        },
      ),
      error: (_, __) => IconButton(
        icon: Icon(Icons.notifications_off, color: Theme.of(context).colorScheme.error),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationScreen(),
            ),
          );
        },
      ),
    );
  }
}

// Alternative compact version for limited space
class CompactNotificationIcon extends ConsumerWidget {
  final double? size;
  final VoidCallback? onTap;
  
  const CompactNotificationIcon({
    super.key,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadNotificationsAsyncValue = ref.watch(unreadNotificationsProvider);

    return unreadNotificationsAsyncValue.when(
      data: (unreadNotifications) {
        final unreadCount = unreadNotifications.length;
        
        return InkWell(
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  unreadCount > 0 ? Icons.notifications : Icons.notifications_none,
                  color: unreadCount > 0 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: (size ?? 40) * 0.6,
                ),
                
                if (unreadCount > 0)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Icon(
        Icons.notifications_none, 
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: (size ?? 40) * 0.6,
      ),
      error: (_, __) => Icon(
        Icons.notifications_off, 
        color: Theme.of(context).colorScheme.error,
        size: (size ?? 40) * 0.6,
      ),
    );
  }
}