import 'package:equatable/equatable.dart';

class StatusHistoryEntry extends Equatable {
  const StatusHistoryEntry({
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

  @override
  List<Object?> get props => [id, newStatus, changedAt];
}
