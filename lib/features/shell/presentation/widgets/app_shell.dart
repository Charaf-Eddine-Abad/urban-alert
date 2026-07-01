import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/notifications/domain/entities/app_notification.dart';
import 'package:urban_alert/features/notifications/presentation/providers/notification_providers.dart';
import 'package:urban_alert/features/shell/presentation/providers/shell_providers.dart';

/// Root shell widget that wraps all authenticated tab screens.
/// Owns the [NavigationBar], the notification badge counter, and
/// the STOMP WebSocket connection that drives real-time notifications.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_initNotifications);
  }

  Future<void> _initNotifications() async {
    // Fetch initial unread count from REST so the badge is correct on launch.
    try {
      final count = await ref
          .read(notificationRepositoryProvider)
          .getUnreadCount();
      if (mounted) {
        ref.read(unreadNotificationCountProvider.notifier).state = count;
      }
    } catch (_) {
      // Non-fatal — badge stays at 0 until the next STOMP push.
    }

    // Connect STOMP WebSocket for real-time notifications.
    final token = await ref.read(secureStorageProvider).getToken();
    if (token == null || !mounted) return;

    ref.read(stompServiceProvider).connect(
      token: token,
      onNotification: _onPushNotification,
    );
  }

  void _onPushNotification(AppNotification notification) {
    if (!mounted) return;

    // Increment badge.
    ref
        .read(unreadNotificationCountProvider.notifier)
        .update((s) => s + 1);

    // Prepend to the list if the notifier is already loaded.
    ref
        .read(notificationNotifierProvider.notifier)
        .prependFromPush(notification);

    // Show in-app toast.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              notification.type.icon,
              color: notification.type.color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    notification.body,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ref.read(stompServiceProvider).disconnect();
    super.dispose();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Actualité',
          ),
          const NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem_rounded),
            label: 'Signalements',
          ),
          const NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes_rounded),
            label: 'Suivi',
          ),
          NavigationDestination(
            icon: _BadgedIcon(
              count: unread,
              icon: Icons.notifications_outlined,
            ),
            selectedIcon: _BadgedIcon(
              count: unread,
              icon: Icons.notifications_rounded,
            ),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.count, required this.icon});

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(icon),
    );
  }
}
