class RegisterRequestModel {
  const RegisterRequestModel({
    required this.email,
    required this.phone,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.ville,
    required this.password,
  });

  final String email;
  final String phone;
  final String nom;
  final String prenom;

  /// ISO-8601 date string: "YYYY-MM-DD" — matches Java LocalDate.
  final String dateNaissance;

  final String ville;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'nom': nom,
        'prenom': prenom,
        'dateNaissance': dateNaissance,
        'ville': ville,
        'password': password,
        'role': 'CITOYEN', // hardcoded — this app is citizens-only
      };
}
