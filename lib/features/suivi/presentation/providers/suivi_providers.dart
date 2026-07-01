import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/suivi/data/datasources/suivi_remote_datasource.dart';
import 'package:urban_alert/features/suivi/data/repositories/suivi_repository_impl.dart';
import 'package:urban_alert/features/suivi/domain/repositories/suivi_repository.dart';
import 'package:urban_alert/features/suivi/presentation/providers/suivi_notifier.dart';
import 'package:urban_alert/features/suivi/presentation/providers/suivi_state.dart';

final suiviDataSourceProvider = Provider<SuiviRemoteDataSource>(
  (ref) => SuiviRemoteDataSource(ref.watch(dioProvider)),
);

final suiviRepositoryProvider = Provider<SuiviRepository>(
  (ref) => SuiviRepositoryImpl(ref.watch(suiviDataSourceProvider)),
);

final suiviNotifierProvider = NotifierProvider<SuiviNotifier, SuiviState>(
  SuiviNotifier.new,
);
