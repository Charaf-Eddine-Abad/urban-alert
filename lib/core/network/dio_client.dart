import 'package:dio/dio.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/storage/secure_storage_service.dart';
import 'package:urban_alert/core/network/auth_interceptor.dart';

/// Factory that builds a fully-configured [Dio] instance.
/// Feature repositories use this as their HTTP client.
class DioClient {
  DioClient._();

  static Dio create(
    SecureStorageService storage, {
    void Function()? onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        // Let the error interceptor decide what to do on 4xx/5xx
        validateStatus: (_) => true,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storage, onUnauthorized: onUnauthorized),
      // Uncomment in development to see full request/response logs
      // LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return dio;
  }

  /// Converts a [DioException] to a typed [AppException].
  static AppException handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return const UnauthorizedException();
        if (status == 403) return const ForbiddenException();
        if (status == 404) return const NotFoundException();
        final body = e.response?.data;
        final message = _extractMessage(body);
        return ServerException(message, statusCode: status);

      default:
        return const UnexpectedException();
    }
  }

  /// Also handles raw non-2xx responses that Dio did not throw (validateStatus: always true).
  static AppException handleResponse(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status == 401) return const UnauthorizedException();
    if (status == 403) return const ForbiddenException();
    if (status == 404) return const NotFoundException();
    final message = _extractMessage(response.data);
    return ServerException(message, statusCode: status);
  }

  static String _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return (body['message'] ?? body['error'] ?? 'Erreur serveur').toString();
    }
    if (body is String && body.isNotEmpty) return body;
    return 'Erreur serveur';
  }
}
