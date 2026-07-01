import 'package:urban_alert/features/suivi/domain/entities/problem_user_summary.dart';

class ProblemUserSummaryModel {
  const ProblemUserSummaryModel({
    required this.id,
    this.firstName,
    this.lastName,
  });

  final int id;
  final String? firstName;
  final String? lastName;

  factory ProblemUserSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProblemUserSummaryModel(
      id: json['id'] as int? ?? 0,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  ProblemUserSummary toDomain() => ProblemUserSummary(
        id: id,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
      );
}
