import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:urban_alert/core/theme/app_colors.dart';
import 'package:urban_alert/features/suivi/domain/entities/alert_summary.dart';
import 'package:urban_alert/features/suivi/domain/entities/problem_user_summary.dart';
import 'package:urban_alert/features/suivi/domain/entities/status_history_entry.dart';

enum ProblemStatus {
  newProblem,
  inProgress,
  resolved,
  rejected;

  static ProblemStatus fromString(String value) =>
      switch (value.toUpperCase()) {
        'IN_PROGRESS' => ProblemStatus.inProgress,
        'RESOLVED' => ProblemStatus.resolved,
        'REJECTED' => ProblemStatus.rejected,
        _ => ProblemStatus.newProblem,
      };

  String get label => switch (this) {
        ProblemStatus.newProblem => 'Nouveau',
        ProblemStatus.inProgress => 'En cours',
        ProblemStatus.resolved => 'Résolu',
        ProblemStatus.rejected => 'Rejeté',
      };

  Color get color => switch (this) {
        ProblemStatus.newProblem => AppColors.statusNew,
        ProblemStatus.inProgress => AppColors.statusInProgress,
        ProblemStatus.resolved => AppColors.statusResolved,
        ProblemStatus.rejected => AppColors.statusRejected,
      };

  IconData get icon => switch (this) {
        ProblemStatus.newProblem => Icons.fiber_new_rounded,
        ProblemStatus.inProgress => Icons.autorenew_rounded,
        ProblemStatus.resolved => Icons.check_circle_rounded,
        ProblemStatus.rejected => Icons.cancel_rounded,
      };
}

class Problem extends Equatable {
  const Problem({
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
  final ProblemStatus status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final ProblemUserSummary? assignedTo;
  final List<AlertSummary> alerts;
  final List<StatusHistoryEntry> statusHistory;

  @override
  List<Object?> get props => [id, title, status, createdAt];
}
