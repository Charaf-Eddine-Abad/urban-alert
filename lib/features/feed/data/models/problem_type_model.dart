import 'package:urban_alert/features/feed/domain/entities/problem_type.dart';

class ProblemTypeModel {
  const ProblemTypeModel({required this.id, required this.name});

  final int id;
  final String name;

  factory ProblemTypeModel.fromJson(Map<String, dynamic> json) {
    return ProblemTypeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  ProblemType toDomain() => ProblemType(id: id, name: name);
}
