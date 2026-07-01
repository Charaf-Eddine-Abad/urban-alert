import 'package:dio/dio.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/suivi/data/models/problem_model.dart';

class SuiviRemoteDataSource {
  const SuiviRemoteDataSource(this._dio);

  final Dio _dio;

  Future<PageModel<ProblemModel>> getMyAlertProblems({
    required int page,
    required int size,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.myAlertProblems,
      queryParameters: {'page': page, 'size': size},
    );
    _assertOk(response);
    return PageModel.fromJson(response.data!, ProblemModel.fromJson);
  }

  Future<ProblemModel> getProblemById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.problemById(id),
    );
    _assertOk(response);
    return ProblemModel.fromJson(response.data!);
  }

  void _assertOk(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) throw DioClient.handleResponse(response);
  }
}
