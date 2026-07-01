import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:urban_alert/core/theme/app_colors.dart';
import 'package:urban_alert/features/feed/domain/entities/problem_type.dart';
import 'package:urban_alert/features/feed/domain/entities/user_summary.dart';

enum AlertStatus {
  newAlert,
  inProgress,
  resolved,
  rejected;

  static AlertStatus fromString(String value) => switch (value.toUpperCase()) {
        'IN_PROGRESS' => AlertStatus.inProgress,
        'RESOLVED' => AlertStatus.resolved,
        'REJECTED' => AlertStatus.rejected,
        _ => AlertStatus.newAlert,
      };

  String get label => switch (this) {
        AlertStatus.newAlert => 'Nouvelle',
        AlertStatus.inProgress => 'En cours',
        AlertStatus.resolved => 'Résolue',
        AlertStatus.rejected => 'Rejetée',
      };

  Color get color => switch (this) {
        AlertStatus.newAlert => AppColors.statusNew,
        AlertStatus.inProgress => AppColors.statusInProgress,
        AlertStatus.resolved => AppColors.statusResolved,
        AlertStatus.rejected => AppColors.statusRejected,
      };
}

enum AlertPriority {
  low,
  medium,
  high;

  static AlertPriority fromString(String value) => switch (value.toUpperCase()) {
        'MEDIUM' => AlertPriority.medium,
        'HIGH' => AlertPriority.high,
        _ => AlertPriority.low,
      };

  String get label => switch (this) {
        AlertPriority.low => 'Faible',
        AlertPriority.medium => 'Moyenne',
        AlertPriority.high => 'Haute',
      };

  Color get color => switch (this) {
        AlertPriority.low => AppColors.priorityLow,
        AlertPriority.medium => AppColors.priorityMedium,
        AlertPriority.high => AppColors.priorityHigh,
      };
}

class Alert extends Equatable {
  const Alert({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.status,
    required this.priority,
    required this.isAnonymous,
    required this.images,
    required this.videos,
    this.createdAt,
    this.user,
    this.category,
    this.ticketId,
  });

  final int id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final AlertStatus status;
  final AlertPriority priority;
  final bool isAnonymous;
  final List<String> images;
  final List<String> videos;
  final DateTime? createdAt;
  final UserSummary? user;
  final ProblemType? category;
  final int? ticketId;

  String get authorName {
    if (isAnonymous) return 'Anonyme';
    return user?.fullName ?? 'Citoyen';
  }

  @override
  List<Object?> get props => [id, title, status, priority, createdAt];
}
