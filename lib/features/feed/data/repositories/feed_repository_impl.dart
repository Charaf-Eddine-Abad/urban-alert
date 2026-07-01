import 'package:dio/dio.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  const FeedRepositoryImpl(this._dataSource);

  final FeedRemoteDataSource _dataSource;

  @override
  Future<PageModel<Alert>> getAlerts({
    required int page,
    required int size,
  }) async {
    try {
      final modelPage = await _dataSource.getAlerts(page: page, size: size);
      return PageModel(
        content: modelPage.content.map((m) => m.toDomain()).toList(),
        totalElements: modelPage.totalElements,
        totalPages: modelPage.totalPages,
        last: modelPage.last,
        number: modelPage.number,
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  @override
  Future<PageModel<Alert>> searchAlerts({
    required String keyword,
    required int page,
    required int size,
  }) async {
    try {
      final modelPage = await _dataSource.searchAlerts(
        keyword: keyword,
        page: page,
        size: size,
      );
      return PageModel(
        content: modelPage.content.map((m) => m.toDomain()).toList(),
        totalElements: modelPage.totalElements,
        totalPages: modelPage.totalPages,
        last: modelPage.last,
        number: modelPage.number,
      );
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  @override
  Future<Alert> getAlertById(int id) async {
    try {
      final model = await _dataSource.getAlertById(id);
      return model.toDomain();
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }
}
