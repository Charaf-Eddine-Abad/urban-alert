import 'package:dio/dio.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/models/alert_model.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';

class FeedRemoteDataSource {
  const FeedRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PageModel<AlertModel>> getAlerts({
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.alerts,
      queryParameters: {'page': page, 'size': size},
    );
    _assertOk(response);
    return PageModel.fromJson(response.data!, AlertModel.fromJson);
  }

  Future<PageModel<AlertModel>> searchAlerts({
    required String keyword,
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.alertsSearch,
      queryParameters: {'keyword': keyword, 'page': page, 'size': size},
    );
    _assertOk(response);
    return PageModel.fromJson(response.data!, AlertModel.fromJson);
  }

  Future<AlertModel> getAlertById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.alertById(id),
    );
    _assertOk(response);
    return AlertModel.fromJson(response.data!);
  }

  /// Throws the appropriate [AppException] for any non-2xx response.
  void _assertOk(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw DioClient.handleResponse(response);
    }
  }
}
