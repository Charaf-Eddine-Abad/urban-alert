import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/features/notifications/domain/entities/app_notification.dart';
import 'package:urban_alert/features/notifications/presentation/providers/notification_providers.dart';
import 'package:urban_alert/features/notifications/presentation/providers/notification_state.dart';

class NotificationNotifier extends Notifier<NotificationState> {
  static const _pageSize = 20;

  @override
  NotificationState build() {
    Future.microtask(_loadInitial);
    return const NotificationLoading();
  }

  Future<void> _loadInitial() async {
    state = const NotificationLoading();
    try {
      final page = await ref
          .read(notificationRepositoryProvider)
          .getNotifications(page: 0, size: _pageSize);
      state = NotificationLoaded(
        notifications: page.content,
        currentPage: 0,
        hasMore: !page.last,
      );
    } on AppException catch (e) {
      state = NotificationError(e.message);
    }
  }

  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    final current = state;
    if (current is! NotificationLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    state = current.copyWith(isLoadingMore: true);
    try {
      final nextPage = current.currentPage + 1;
      final page = await ref
          .read(notificationRepositoryProvider)
          .getNotifications(page: nextPage, size: _pageSize);
      state = current.copyWith(
        notifications: [...current.notifications, ...page.content],
        currentPage: nextPage,
        hasMore: !page.last,
        isLoadingMore: false,
      );
    } on AppException {
      final s = state;
      if (s is NotificationLoaded) state = s.copyWith(isLoadingMore: false);
    }
  }

  Future<void> markRead(int id) async {
    try {
      await ref.read(notificationRepositoryProvider).markRead(id);
      final current = state;
      if (current is NotificationLoaded) {
        state = current.copyWith(
          notifications: current.notifications
              .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
              .toList(),
        );
      }
    } on AppException {
      // silent — read state is cosmetic
    }
  }

  Future<void> markAllRead() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      final current = state;
      if (current is NotificationLoaded) {
        state = current.copyWith(
          notifications:
              current.notifications.map((n) => n.copyWith(isRead: true)).toList(),
        );
      }
    } on AppException {
      // silent
    }
  }

  void prependFromPush(AppNotification notification) {
    final current = state;
    if (current is NotificationLoaded) {
      state = current.copyWith(
        notifications: [notification, ...current.notifications],
      );
    }
  }
}
