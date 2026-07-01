import 'package:equatable/equatable.dart';

class UserSummary extends Equatable {
  const UserSummary({
    required this.id,
    required this.prenom,
    required this.nom,
    this.ville,
  });

  final int id;
  final String prenom;
  final String nom;
  final String? ville;

  String get fullName => '$prenom $nom'.trim();

  @override
  List<Object?> get props => [id, prenom, nom, ville];
}
