import 'package:dio/dio.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/notifications/data/models/notification_model.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PageModel<NotificationModel>> getNotifications({
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'size': size},
    );
    _assertOk(response);
    return PageModel.fromJson(response.data!, NotificationModel.fromJson);
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get<dynamic>(
      ApiConstants.notificationsUnreadCount,
    );
    _assertOk(response);
    final data = response.data;
    if (data is int) return data;
    if (data is Map<String, dynamic>) {
      return (data['count'] ?? data['unreadCount'] ?? 0) as int;
    }
    return 0;
  }

  Future<void> markRead(int id) async {
    final response = await _dio.put<dynamic>(
      ApiConstants.notificationMarkRead(id),
    );
    _assertOk(response);
  }

  Future<void> markAllRead() async {
    final response = await _dio.put<dynamic>(
      ApiConstants.notificationsReadAll,
    );
    _assertOk(response);
  }

  void _assertOk(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) throw DioClient.handleResponse(response);
  }
}
