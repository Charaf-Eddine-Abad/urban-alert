import 'package:urban_alert/features/suivi/domain/entities/alert_summary.dart';

class AlertSummaryModel {
  const AlertSummaryModel({
    required this.id,
    required this.title,
    required this.status,
    this.userId,
  });

  final int id;
  final String title;
  final String status;
  final int? userId;

  factory AlertSummaryModel.fromJson(Map<String, dynamic> json) {
    return AlertSummaryModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'NEW',
      userId: json['userId'] as int?,
    );
  }

  AlertSummary toDomain() => AlertSummary(id: id, title: title, status: status);
}
