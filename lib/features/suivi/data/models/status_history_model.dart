import 'package:urban_alert/features/suivi/domain/entities/status_history_entry.dart';

class StatusHistoryModel {
  const StatusHistoryModel({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    this.changedBy,
    this.comment,
    this.changedAt,
  });

  final int id;
  final String? previousStatus;
  final String newStatus;
  final String? changedBy;
  final String? comment;
  final DateTime? changedAt;

  factory StatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryModel(
      id: json['id'] as int? ?? 0,
      previousStatus: json['previousStatus'] as String?,
      newStatus: json['newStatus'] as String? ?? '',
      changedBy: json['changedBy'] as String?,
      comment: json['comment'] as String?,
      changedAt: _parseDateTime(json['changedAt']),
    );
  }

  StatusHistoryEntry toDomain() => StatusHistoryEntry(
        id: id,
        previousStatus: previousStatus,
        newStatus: newStatus,
        changedBy: changedBy,
        comment: comment,
        changedAt: changedAt,
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
