import 'package:urban_alert/features/auth/data/models/auth_response_model.dart';
import 'package:urban_alert/features/auth/data/models/login_request_model.dart';
import 'package:urban_alert/features/auth/data/models/register_request_model.dart';
import 'package:urban_alert/features/auth/data/models/verify_phone_request_model.dart';

/// Contract between the presentation and data layers for authentication.
abstract interface class AuthRepository {
  /// Returns the JWT response on success.
  /// Throws [AppException] on failure.
  Future<AuthResponseModel> login(LoginRequestModel request);

  /// Throws [AppException] on failure.
  Future<void> register(RegisterRequestModel request);

  /// Returns the JWT response for CITOYEN.
  /// Returns null when the server responds 202 (pending approval — other roles).
  /// Throws [AppException] on failure.
  Future<AuthResponseModel?> verifyPhone(VerifyPhoneRequestModel request);

  Future<void> logout();
}
