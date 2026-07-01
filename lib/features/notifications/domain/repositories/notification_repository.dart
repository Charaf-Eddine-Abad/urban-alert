import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/notifications/domain/entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<PageModel<AppNotification>> getNotifications({
    required int page,
    required int size,
  });

  Future<int> getUnreadCount();

  Future<void> markRead(int id);

  Future<void> markAllRead();
}
