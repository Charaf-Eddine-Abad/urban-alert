import 'package:urban_alert/features/feed/data/models/page_model.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';

abstract interface class MyAlertsRepository {
  Future<PageModel<Alert>> getMyAlerts({required int page, required int size});

  Future<Alert> createAlert({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    required int categoryId,
    required String priority,
    required bool isAnonymous,
  });

  Future<Alert> updateAlert(int id, {
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    int? categoryId,
    String? priority,
    bool? isAnonymous,
  });

  Future<void> deleteAlert(int id);

  Future<Alert> addImage(int alertId, String imageUrl);
}
