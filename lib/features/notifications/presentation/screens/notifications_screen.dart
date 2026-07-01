import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/features/notifications/presentation/providers/notification_providers.dart';
import 'package:urban_alert/shared/widgets/shimmer_box.dart';
import 'package:urban_alert/features/notifications/presentation/providers/notification_state.dart';
import 'package:urban_alert/features/notifications/presentation/widgets/notification_card.dart';
import 'package:urban_alert/features/shell/presentation/providers/shell_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Clear badge and mark all read when tab is opened
    Future.microtask(() async {
      ref.read(unreadNotificationCountProvider.notifier).state = 0;
      await ref.read(notificationNotifierProvider.notifier).markAllRead();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationNotifierProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() =>
      ref.read(notificationNotifierProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        scrolledUnderElevation: 1,
        actions: [
          if (state is NotificationLoaded && state.notifications.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(notificationNotifierProvider.notifier).markAllRead(),
              child: const Text('Tout lire'),
            ),
        ],
      ),
      body: switch (state) {
        NotificationLoading() => _SkeletonList(),
        NotificationError(:final message) => _ErrorView(
            message: message,
            onRetry: () =>
                ref.read(notificationNotifierProvider.notifier).refresh(),
          ),
        NotificationLoaded(:final notifications, :final hasMore) =>
          notifications.isEmpty
              ? _EmptyView(onRefresh: _onRefresh)
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final notification = notifications[index];
                      return NotificationCard(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            ref
                                .read(notificationNotifierProvider.notifier)
                                .markRead(notification.id);
                          }
                        },
                      );
                    },
                  ),
                ),
      },
    );
  }
}

// ── Skeleton loading ──────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, _) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 36, height: 36, radius: 18),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 13)),
                    SizedBox(width: 12),
                    ShimmerBox(width: 32, height: 11),
                  ],
                ),
                SizedBox(height: 6),
                ShimmerBox(height: 11),
                SizedBox(height: 3),
                ShimmerBox(width: 160, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune notification',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Vous serez notifié ici lorsque vos signalements seront mis à jour.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
