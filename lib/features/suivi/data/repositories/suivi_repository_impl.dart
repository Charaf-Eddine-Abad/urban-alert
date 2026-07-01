import 'package:dio/dio.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/suivi/data/datasources/suivi_remote_datasource.dart';
import 'package:urban_alert/features/suivi/domain/entities/problem.dart';
import 'package:urban_alert/features/suivi/domain/repositories/suivi_repository.dart';

class SuiviRepositoryImpl implements SuiviRepository {
  const SuiviRepositoryImpl(this._ds);

  final SuiviRemoteDataSource _ds;

  @override
  Future<PageModel<Problem>> getMyAlertProblems({
    required int page,
    required int size,
  }) =>
      _wrap(() async {
        final p = await _ds.getMyAlertProblems(page: page, size: size);
        return PageModel(
          content: p.content.map((m) => m.toDomain()).toList(),
          totalElements: p.totalElements,
          totalPages: p.totalPages,
          last: p.last,
          number: p.number,
        );
      });

  @override
  Future<Problem> getProblemById(int id) =>
      _wrap(() async => (await _ds.getProblemById(id)).toDomain());

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
