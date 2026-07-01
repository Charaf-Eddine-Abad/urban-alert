import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/features/feed/presentation/providers/feed_providers.dart';
import 'package:urban_alert/features/feed/presentation/providers/feed_state.dart';

class FeedNotifier extends Notifier<FeedState> {
  static const _pageSize = 10;

  @override
  FeedState build() {
    Future.microtask(_loadInitial);
    return const FeedLoading();
  }

  Future<void> _loadInitial() async {
    state = const FeedLoading();
    try {
      final page = await ref
          .read(feedRepositoryProvider)
          .getAlerts(page: 0, size: _pageSize);
      state = FeedLoaded(
        alerts: page.content,
        currentPage: 0,
        hasMore: !page.last,
      );
    } on AppException catch (e) {
      state = FeedError(e.message);
    }
  }

  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    final current = state;
    if (current is! FeedLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = current.copyWith(isLoadingMore: true);
    try {
      final nextPage = current.currentPage + 1;
      final page = current.searchQuery.isEmpty
          ? await ref
              .read(feedRepositoryProvider)
              .getAlerts(page: nextPage, size: _pageSize)
          : await ref.read(feedRepositoryProvider).searchAlerts(
                keyword: current.searchQuery,
                page: nextPage,
                size: _pageSize,
              );
      state = current.copyWith(
        alerts: [...current.alerts, ...page.content],
        currentPage: nextPage,
        hasMore: !page.last,
        isLoadingMore: false,
      );
    } on AppException {
      // Restore state without spinner; the list stays intact.
      state = current.copyWith(isLoadingMore: false);
    }
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _loadInitial();
    }
    state = const FeedLoading();
    try {
      final page = await ref
          .read(feedRepositoryProvider)
          .searchAlerts(keyword: trimmed, page: 0, size: _pageSize);
      state = FeedLoaded(
        alerts: page.content,
        currentPage: 0,
        hasMore: !page.last,
        searchQuery: trimmed,
      );
    } on AppException catch (e) {
      state = FeedError(e.message);
    }
  }
}
