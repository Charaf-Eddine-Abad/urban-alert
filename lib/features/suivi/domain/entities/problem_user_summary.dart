import 'package:equatable/equatable.dart';

class ProblemUserSummary extends Equatable {
  const ProblemUserSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  final int id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName];
}
