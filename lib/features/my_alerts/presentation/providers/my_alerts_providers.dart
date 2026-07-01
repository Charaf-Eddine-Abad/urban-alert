import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/my_alerts/data/datasources/my_alerts_remote_datasource.dart';
import 'package:urban_alert/features/my_alerts/data/repositories/my_alerts_repository_impl.dart';
import 'package:urban_alert/features/my_alerts/domain/repositories/my_alerts_repository.dart';
import 'package:urban_alert/features/my_alerts/presentation/providers/my_alerts_notifier.dart';
import 'package:urban_alert/features/my_alerts/presentation/providers/my_alerts_state.dart';

final myAlertsDataSourceProvider = Provider<MyAlertsRemoteDataSource>(
  (ref) => MyAlertsRemoteDataSource(ref.watch(dioProvider)),
);

final myAlertsRepositoryProvider = Provider<MyAlertsRepository>(
  (ref) => MyAlertsRepositoryImpl(ref.watch(myAlertsDataSourceProvider)),
);

final myAlertsNotifierProvider = NotifierProvider<MyAlertsNotifier, MyAlertsState>(
  MyAlertsNotifier.new,
);
