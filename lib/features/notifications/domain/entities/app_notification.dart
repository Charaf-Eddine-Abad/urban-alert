import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  alertStatusChanged,
  alertAssigned,
  problemCreated,
  problemStatusChanged,
  general;

  static NotificationType fromString(String value) =>
      switch (value.toUpperCase()) {
        'ALERT_STATUS_CHANGED' => NotificationType.alertStatusChanged,
        'ALERT_ASSIGNED' => NotificationType.alertAssigned,
        'PROBLEM_CREATED' => NotificationType.problemCreated,
        'PROBLEM_STATUS_CHANGED' => NotificationType.problemStatusChanged,
        _ => NotificationType.general,
      };

  IconData get icon => switch (this) {
        NotificationType.alertStatusChanged => Icons.update_rounded,
        NotificationType.alertAssigned => Icons.assignment_ind_rounded,
        NotificationType.problemCreated => Icons.track_changes_rounded,
        NotificationType.problemStatusChanged =>
          Icons.published_with_changes_rounded,
        NotificationType.general => Icons.notifications_rounded,
      };

  Color get color => switch (this) {
        NotificationType.alertStatusChanged => const Color(0xFF3B82F6),
        NotificationType.alertAssigned => const Color(0xFF8B5CF6),
        NotificationType.problemCreated => const Color(0xFF10B981),
        NotificationType.problemStatusChanged => const Color(0xFFF59E0B),
        NotificationType.general => const Color(0xFF6B7280),
      };
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
    this.relatedAlertId,
    this.relatedProblemId,
  });

  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final int? relatedAlertId;
  final int? relatedProblemId;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        relatedAlertId: relatedAlertId,
        relatedProblemId: relatedProblemId,
      );

  @override
  List<Object?> get props =>
      [id, type, title, body, isRead, createdAt, relatedAlertId, relatedProblemId];
}
