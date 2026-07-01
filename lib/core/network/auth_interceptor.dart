import 'package:dio/dio.dart';
import 'package:urban_alert/core/storage/secure_storage_service.dart';

/// Attaches the JWT to every outgoing request.
/// On 401, clears the token so the router redirects to login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, {this.onUnauthorized});

  final SecureStorageService _storage;

  /// Called when the server returns 401. Inject navigation/logout logic here.
  final void Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.deleteToken();
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
