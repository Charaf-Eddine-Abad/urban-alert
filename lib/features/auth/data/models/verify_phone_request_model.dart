class VerifyPhoneRequestModel {
  const VerifyPhoneRequestModel({required this.phone, required this.code});

  /// Must be the normalized form (+212...) — the backend does NOT normalize here.
  final String phone;

  /// Exactly 6 digits.
  final String code;

  Map<String, dynamic> toJson() => {'phone': phone, 'code': code};
}
