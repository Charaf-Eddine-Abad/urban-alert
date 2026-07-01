import 'package:urban_alert/features/suivi/data/models/alert_summary_model.dart';
import 'package:urban_alert/features/suivi/data/models/problem_user_summary_model.dart';
import 'package:urban_alert/features/suivi/data/models/status_history_model.dart';
import 'package:urban_alert/features/suivi/domain/entities/problem.dart';

class ProblemModel {
  const ProblemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.createdAt,
    this.resolvedAt,
    this.assignedTo,
    required this.alerts,
    required this.statusHistory,
  });

  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final ProblemUserSummaryModel? assignedTo;
  final List<AlertSummaryModel> alerts;
  final List<StatusHistoryModel> statusHistory;

  factory ProblemModel.fromJson(Map<String, dynamic> json) {
    return ProblemModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'NEW',
      createdAt: _parseDateTime(json['createdAt']),
      resolvedAt: _parseDateTime(json['resolvedAt']),
      assignedTo: json['assignedTo'] != null
          ? ProblemUserSummaryModel.fromJson(
              json['assignedTo'] as Map<String, dynamic>)
          : null,
      alerts: (json['alerts'] as List<dynamic>? ?? [])
          .map((e) => AlertSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .map((e) => StatusHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Problem toDomain() => Problem(
        id: id,
        title: title,
        description: description,
        status: ProblemStatus.fromString(status),
        createdAt: createdAt,
        resolvedAt: resolvedAt,
        assignedTo: assignedTo?.toDomain(),
        alerts: alerts.map((a) => a.toDomain()).toList(),
        statusHistory: statusHistory.map((h) => h.toDomain()).toList(),
      );

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is List && value.isNotEmpty) {
      final v = value.map((e) => (e as num).toInt()).toList();
      return DateTime(v[0], v.length > 1 ? v[1] : 1, v.length > 2 ? v[2] : 1,
          v.length > 3 ? v[3] : 0, v.length > 4 ? v[4] : 0, v.length > 5 ? v[5] : 0);
    }
    return null;
  }
}
