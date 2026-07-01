import 'package:dio/dio.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/features/auth/data/models/auth_response_model.dart';
import 'package:urban_alert/features/auth/data/models/login_request_model.dart';
import 'package:urban_alert/features/auth/data/models/register_request_model.dart';
import 'package:urban_alert/features/auth/data/models/verify_phone_request_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      if (res.statusCode == 200) {
        return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
      }
      throw DioClient.handleResponse(res);
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    } on AppException {
      rethrow;
    }
  }

  Future<void> register(RegisterRequestModel request) async {
    try {
      final res = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      if (res.statusCode == 201) return;
      throw DioClient.handleResponse(res);
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    } on AppException {
      rethrow;
    }
  }

  /// Returns [AuthResponseModel] on 200 (CITOYEN verified),
  /// or null on 202 (pending approval — other roles).
  Future<AuthResponseModel?> verifyPhone(VerifyPhoneRequestModel request) async {
    try {
      final res = await _dio.post(
        ApiConstants.verifyPhone,
        data: request.toJson(),
      );
      if (res.statusCode == 200) {
        return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
      }
      if (res.statusCode == 202) return null;
      throw DioClient.handleResponse(res);
    } on DioException catch (e) {
      throw DioClient.handleError(e);
    } on AppException {
      rethrow;
    }
  }
}
