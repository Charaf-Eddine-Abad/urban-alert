import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';

abstract interface class FeedRepository {
  Future<PageModel<Alert>> getAlerts({required int page, required int size});
  Future<PageModel<Alert>> searchAlerts({
    required String keyword,
    required int page,
    required int size,
  });
  Future<Alert> getAlertById(int id);
}
