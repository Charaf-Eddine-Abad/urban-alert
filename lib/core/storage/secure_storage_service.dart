import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:urban_alert/core/constants/api_constants.dart';

/// Thin wrapper over [FlutterSecureStorage].
/// Only this class should know about the storage keys.
class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) =>
      _storage.write(key: ApiConstants.tokenKey, value: token);

  Future<String?> getToken() =>
      _storage.read(key: ApiConstants.tokenKey);

  Future<void> deleteToken() =>
      _storage.delete(key: ApiConstants.tokenKey);

  Future<bool> hasToken() async =>
      (await _storage.read(key: ApiConstants.tokenKey)) != null;
}
