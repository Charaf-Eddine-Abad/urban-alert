import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/core/services/stomp_service.dart';
import 'package:urban_alert/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:urban_alert/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:urban_alert/features/notifications/domain/repositories/notification_repository.dart';
import 'package:urban_alert/features/notifications/presentation/providers/notification_notifier.dart';
import 'package:urban_alert/features/notifications/presentation/providers/notification_state.dart';

final notificationDataSourceProvider = Provider<NotificationRemoteDataSource>(
  (ref) => NotificationRemoteDataSource(ref.watch(dioProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(ref.watch(notificationDataSourceProvider)),
);

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);

final stompServiceProvider = Provider<StompService>((ref) {
  final service = StompService();
  ref.onDispose(service.disconnect);
  return service;
});
