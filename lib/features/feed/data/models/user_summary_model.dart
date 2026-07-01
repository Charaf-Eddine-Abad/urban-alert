import 'package:urban_alert/features/feed/domain/entities/user_summary.dart';

class UserSummaryModel {
  const UserSummaryModel({
    required this.id,
    required this.prenom,
    required this.nom,
    this.phone,
    this.ville,
  });

  final int id;
  final String prenom;
  final String nom;
  final String? phone;
  final String? ville;

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      id: json['id'] as int? ?? 0,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      phone: json['phone'] as String?,
      ville: json['ville'] as String?,
    );
  }

  UserSummary toDomain() => UserSummary(
        id: id,
        prenom: prenom,
        nom: nom,
        ville: ville,
      );
}
