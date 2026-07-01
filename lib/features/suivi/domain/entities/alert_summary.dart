import 'package:equatable/equatable.dart';

class AlertSummary extends Equatable {
  const AlertSummary({
    required this.id,
    required this.title,
    required this.status,
  });

  final int id;
  final String title;
  final String status;

  @override
  List<Object?> get props => [id, title, status];
}
