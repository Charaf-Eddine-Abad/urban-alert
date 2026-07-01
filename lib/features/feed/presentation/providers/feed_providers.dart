import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/providers/core_providers.dart';
import 'package:urban_alert/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:urban_alert/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:urban_alert/features/feed/domain/repositories/feed_repository.dart';
import 'package:urban_alert/features/feed/presentation/providers/feed_notifier.dart';
import 'package:urban_alert/features/feed/presentation/providers/feed_state.dart';

final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>(
  (ref) => FeedRemoteDataSource(ref.watch(dioProvider)),
);

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepositoryImpl(ref.watch(feedRemoteDataSourceProvider)),
);

final feedNotifierProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);
