import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/auth/data/models/login_request_model.dart';
import 'package:urban_alert/features/auth/data/models/register_request_model.dart';
import 'package:urban_alert/features/auth/data/models/verify_phone_request_model.dart';
import 'package:urban_alert/features/auth/domain/repositories/auth_repository.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_providers.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_state.dart';
import 'package:urban_alert/shared/utils/phone_utils.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthIdle();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> login(String rawPhone, String password) async {
    state = const AuthLoading();
    try {
      final phone = PhoneUtils.normalize(rawPhone);
      await _repo.login(LoginRequestModel(phone: phone, password: password));
      // Invalidate the auth gate so the router re-evaluates and navigates to feed
      ref.invalidate(isAuthenticatedProvider);
      state = const AuthAuthenticated();
    } on AppException catch (e) {
      state = AuthFailure(e.message);
    }
  }

  Future<void> register({
    required String email,
    required String rawPhone,
    required String nom,
    required String prenom,
    required String dateNaissance,
    required String ville,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final phone = PhoneUtils.normalize(rawPhone);
      await _repo.register(RegisterRequestModel(
        email: email,
        phone: phone,
        nom: nom,
        prenom: prenom,
        dateNaissance: dateNaissance,
        ville: ville,
        password: password,
      ));
      // Pass the normalized phone so verify-phone sends the correct value
      state = AuthRegistered(phone);
    } on AppException catch (e) {
      state = AuthFailure(e.message);
    }
  }

  Future<void> verifyPhone(String normalizedPhone, String code) async {
    state = const AuthLoading();
    try {
      final response = await _repo.verifyPhone(
        VerifyPhoneRequestModel(phone: normalizedPhone, code: code),
      );
      if (response != null) {
        // CITOYEN: token received → invalidate auth gate, router navigates
        ref.invalidate(isAuthenticatedProvider);
        state = const AuthAuthenticated();
      } else {
        // 202: pending approval (shouldn't happen for CITOYEN, but handle gracefully)
        state = const AuthFailure(
          'Votre compte est en attente de validation. Contactez un administrateur.',
        );
      }
    } on AppException catch (e) {
      state = AuthFailure(e.message);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    ref.invalidate(isAuthenticatedProvider);
    state = const AuthIdle();
  }

  void reset() => state = const AuthIdle();
}
