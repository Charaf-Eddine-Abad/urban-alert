import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/suivi/domain/entities/problem.dart';

abstract interface class SuiviRepository {
  Future<PageModel<Problem>> getMyAlertProblems({
    required int page,
    required int size,
  });

  Future<Problem> getProblemById(int id);
}
