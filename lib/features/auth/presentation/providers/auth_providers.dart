import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:urban_alert/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:urban_alert/features/auth/domain/repositories/auth_repository.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_notifier.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
  name: 'authRemoteDataSourceProvider',
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  ),
  name: 'authRepositoryProvider',
);

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
