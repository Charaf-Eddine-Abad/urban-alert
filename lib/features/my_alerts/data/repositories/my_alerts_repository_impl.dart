import 'package:dio/dio.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/features/my_alerts/data/datasources/my_alerts_remote_datasource.dart';
import 'package:urban_alert/features/my_alerts/domain/repositories/my_alerts_repository.dart';

class MyAlertsRepositoryImpl implements MyAlertsRepository {
  const MyAlertsRepositoryImpl(this._ds);
  final MyAlertsRemoteDataSource _ds;

  @override
  Future<PageModel<Alert>> getMyAlerts({
    required int page,
    required int size,
  }) =>
      _wrap(() async {
        final page0 = await _ds.getMyAlerts(page: page, size: size);
        return PageModel(
          content: page0.content.map((m) => m.toDomain()).toList(),
          totalElements: page0.totalElements,
          totalPages: page0.totalPages,
          last: page0.last,
          number: page0.number,
        );
      });

  @override
  Future<Alert> createAlert({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    required int categoryId,
    required String priority,
    required bool isAnonymous,
  }) =>
      _wrap(() async {
        final body = <String, dynamic>{
          'title': title,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'categoryId': categoryId,
          'priority': priority,
          'isAnonymous': isAnonymous,
        };
        if (address != null) body['address'] = address;
        final model = await _ds.createAlert(body);
        return model.toDomain();
      });

  @override
  Future<Alert> updateAlert(
    int id, {
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    int? categoryId,
    String? priority,
    bool? isAnonymous,
  }) =>
      _wrap(() async {
        final body = <String, dynamic>{};
        if (title != null) body['title'] = title;
        if (description != null) body['description'] = description;
        if (latitude != null) body['latitude'] = latitude;
        if (longitude != null) body['longitude'] = longitude;
        if (address != null) body['address'] = address;
        if (categoryId != null) body['categoryId'] = categoryId;
        if (priority != null) body['priority'] = priority;
        if (isAnonymous != null) body['isAnonymous'] = isAnonymous;
        final model = await _ds.updateAlert(id, body);
        return model.toDomain();
      });

  @override
  Future<void> deleteAlert(int id) => _wrap(() => _ds.deleteAlert(id));

  @override
  Future<Alert> addImage(int alertId, String imageUrl) => _wrap(() async {
        final model = await _ds.addImage(alertId, imageUrl);
        return model.toDomain();
      });

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
