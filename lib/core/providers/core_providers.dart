import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:urban_alert/core/network/dio_client.dart';
import 'package:urban_alert/core/services/cloudinary_service.dart';
import 'package:urban_alert/core/services/token_service.dart';
import 'package:urban_alert/core/storage/secure_storage_service.dart';

// ── Low-level singletons ──────────────────────────────────────────────────────

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    // Using default AndroidOptions — flutter_secure_storage v10 auto-migrates
    // to custom ciphers without needing encryptedSharedPreferences flag.
  ),
  name: 'flutterSecureStorageProvider',
);

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(ref.watch(flutterSecureStorageProvider)),
  name: 'secureStorageProvider',
);

final tokenServiceProvider = Provider<TokenService>(
  (ref) => TokenService(ref.watch(secureStorageProvider)),
  name: 'tokenServiceProvider',
);

// ── Dio ───────────────────────────────────────────────────────────────────────
//
// The [onUnauthorized] callback is intentionally left null here.
// The router observes [isAuthenticatedProvider] and handles the redirect when
// [SecureStorageService.deleteToken()] is called by the AuthInterceptor.

final dioProvider = Provider<Dio>(
  (ref) => DioClient.create(ref.watch(secureStorageProvider)),
  name: 'dioProvider',
);

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (_) => CloudinaryService(),
  name: 'cloudinaryServiceProvider',
);

// ── Auth state ────────────────────────────────────────────────────────────────
//
// A FutureProvider so it's computed asynchronously (storage read).
// Invalidated by AuthNotifier after login / logout so the router refreshes.

final isAuthenticatedProvider = FutureProvider<bool>(
  (ref) => ref.watch(tokenServiceProvider).isTokenValid(),
  name: 'isAuthenticatedProvider',
);
