import 'dart:convert';
import 'package:urban_alert/core/storage/secure_storage_service.dart';

/// Decodes the stored JWT and exposes claims needed by the app.
/// Does NOT validate the signature — trust the server for that.
class TokenService {
  const TokenService(this._storage);

  final SecureStorageService _storage;

  Future<Map<String, dynamic>?> _getClaims() async {
    final token = await _storage.getToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      // Base64url → Base64 padding
      final payload = base64Url.decode(
        base64Url.normalize(parts[1]),
      );
      return jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final claims = await _getClaims();
    if (claims == null) return false;
    final exp = claims['exp'];
    if (exp == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return expiry.isAfter(DateTime.now());
  }

  Future<String?> getPhone() async {
    final claims = await _getClaims();
    // Spring Security sets `sub` to the username (phone in our case)
    return claims?['sub'] as String?;
  }

  Future<String?> getRole() async {
    final claims = await _getClaims();
    if (claims == null) return null;
    // Standard Spring JWT puts roles in `roles` list or `role` string
    final roles = claims['roles'];
    if (roles is List && roles.isNotEmpty) {
      // Strip ROLE_ prefix if present
      return (roles.first as String).replaceFirst('ROLE_', '');
    }
    final role = claims['role'];
    if (role is String) return role.replaceFirst('ROLE_', '');
    return null;
  }

  Future<int?> getUserId() async {
    final claims = await _getClaims();
    return claims?['userId'] as int?;
  }
}
