import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/features/suivi/presentation/providers/suivi_providers.dart';
import 'package:urban_alert/features/suivi/presentation/providers/suivi_state.dart';

class SuiviNotifier extends Notifier<SuiviState> {
  static const _pageSize = 10;

  @override
  SuiviState build() {
    Future.microtask(_loadInitial);
    return const SuiviLoading();
  }

  Future<void> _loadInitial() async {
    state = const SuiviLoading();
    try {
      final page = await ref
          .read(suiviRepositoryProvider)
          .getMyAlertProblems(page: 0, size: _pageSize);
      state = SuiviLoaded(
        problems: page.content,
        currentPage: 0,
        hasMore: !page.last,
      );
    } on AppException catch (e) {
      state = SuiviError(e.message);
    }
  }

  Future<void> refresh() => _loadInitial();

  Future<void> loadMore() async {
    final current = state;
    if (current is! SuiviLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }
    state = current.copyWith(isLoadingMore: true);
    try {
      final nextPage = current.currentPage + 1;
      final page = await ref
          .read(suiviRepositoryProvider)
          .getMyAlertProblems(page: nextPage, size: _pageSize);
      state = current.copyWith(
        problems: [...current.problems, ...page.content],
        currentPage: nextPage,
        hasMore: !page.last,
        isLoadingMore: false,
      );
    } on AppException {
      final s = state;
      if (s is SuiviLoaded) state = s.copyWith(isLoadingMore: false);
    }
  }
}
