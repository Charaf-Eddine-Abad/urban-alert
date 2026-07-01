import 'package:dio/dio.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:urban_alert/features/notifications/domain/entities/app_notification.dart';
import 'package:urban_alert/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._ds);

  final NotificationRemoteDataSource _ds;

  @override
  Future<PageModel<AppNotification>> getNotifications({
    required int page,
    required int size,
  }) =>
      _wrap(() async {
        final p = await _ds.getNotifications(page: page, size: size);
        return PageModel(
          content: p.content.map((m) => m.toDomain()).toList(),
          totalElements: p.totalElements,
          totalPages: p.totalPages,
          last: p.last,
          number: p.number,
        );
      });

  @override
  Future<int> getUnreadCount() => _wrap(() => _ds.getUnreadCount());

  @override
  Future<void> markRead(int id) => _wrap(() => _ds.markRead(id));

  @override
  Future<void> markAllRead() => _wrap(() => _ds.markAllRead());

  Future<T> _wrap<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }
}
