import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/feed/data/models/problem_type_model.dart';
import 'package:urban_alert/features/feed/domain/entities/problem_type.dart';

/// List of all problem-type categories. Fetched once per session.
final categoriesProvider = FutureProvider<List<ProblemType>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get<List<dynamic>>(ApiConstants.problemTypes);
  final status = response.statusCode ?? 0;
  if (status < 200 || status >= 300) {
    throw DioClient.handleResponse(response);
  }
  return (response.data ?? [])
      .map((e) => ProblemTypeModel.fromJson(e as Map<String, dynamic>).toDomain())
      .toList();
});
