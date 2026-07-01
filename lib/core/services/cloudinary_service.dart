import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_alert/core/constants/api_constants.dart';
import 'package:urban_alert/core/errors/app_exception.dart';

/// Uploads media directly to Cloudinary using an unsigned upload preset.
/// Uses a plain Dio instance (no JWT needed — Cloudinary has its own auth).
class CloudinaryService {
  CloudinaryService() : _dio = Dio();

  final Dio _dio;

  Future<String> uploadImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
      'upload_preset': ApiConstants.cloudinaryUploadPreset,
    });
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.cloudinaryUploadUrl('image'),
        data: formData,
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw ServerException('Échec de l\'upload', statusCode: status);
      }
      return response.data!['secure_url'] as String;
    } on DioException catch (_) {
      throw const NetworkException();
    }
  }
}
