import 'package:dio/dio.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/models/alert_model.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';

class MyAlertsRemoteDataSource {
  const MyAlertsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PageModel<AlertModel>> getMyAlerts({
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.myAlerts,
      queryParameters: {'page': page, 'size': size},
    );
    _assertOk(response);
    return PageModel.fromJson(response.data!, AlertModel.fromJson);
  }

  Future<AlertModel> createAlert(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.alerts,
      data: body,
    );
    _assertCreated(response);
    return AlertModel.fromJson(response.data!);
  }

  Future<AlertModel> updateAlert(int id, Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.alertById(id),
      data: body,
    );
    _assertOk(response);
    return AlertModel.fromJson(response.data!);
  }

  Future<void> deleteAlert(int id) async {
    final response = await _dio.delete<dynamic>(ApiConstants.alertById(id));
    final status = response.statusCode ?? 0;
    if (status != 204 && (status < 200 || status >= 300)) {
      throw DioClient.handleResponse(response);
    }
  }

  Future<AlertModel> addImage(int alertId, String imageUrl) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.alertImages(alertId),
      data: {'mediaUrl': imageUrl},
    );
    _assertCreated(response);
    return AlertModel.fromJson(response.data!);
  }

  void _assertOk(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) throw DioClient.handleResponse(response);
  }

  void _assertCreated(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status != 201 && (status < 200 || status >= 300)) {
      throw DioClient.handleResponse(response);
    }
  }
}
