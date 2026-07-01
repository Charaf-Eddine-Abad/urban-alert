import 'package:equatable/equatable.dart';

class ProblemType extends Equatable {
  const ProblemType({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
