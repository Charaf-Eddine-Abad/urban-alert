import 'package:urban_alert/core/storage/secure_storage_service.dart';
import 'package:urban_alert/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:urban_alert/features/auth/data/models/auth_response_model.dart';
import 'package:urban_alert/features/auth/data/models/login_request_model.dart';
import 'package:urban_alert/features/auth/data/models/register_request_model.dart';
import 'package:urban_alert/features/auth/data/models/verify_phone_request_model.dart';
import 'package:urban_alert/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _remote.login(request);
    await _storage.saveToken(response.token);
    return response;
  }

  @override
  Future<void> register(RegisterRequestModel request) =>
      _remote.register(request);

  @override
  Future<AuthResponseModel?> verifyPhone(VerifyPhoneRequestModel request) async {
    final response = await _remote.verifyPhone(request);
    if (response != null) {
      await _storage.saveToken(response.token);
    }
    return response;
  }

  @override
  Future<void> logout() => _storage.deleteToken();
}
