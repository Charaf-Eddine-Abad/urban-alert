/// Maps directly to the backend LoginResponseDTO:
/// { "token": "...", "role": "CITOYEN", "status": "ACTIVE" }
class AuthResponseModel {
  const AuthResponseModel({
    required this.token,
    required this.role,
    required this.status,
  });

  final String token;
  final String role;
  final String status;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        token: json['token'] as String,
        role: json['role'] as String,
        status: json['status'] as String,
      );
}
