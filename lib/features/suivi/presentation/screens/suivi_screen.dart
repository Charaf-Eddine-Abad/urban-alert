import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/features/suivi/presentation/providers/suivi_providers.dart';
import 'package:urban_alert/shared/widgets/shimmer_box.dart';
import 'package:urban_alert/features/suivi/presentation/providers/suivi_state.dart';
import 'package:urban_alert/features/suivi/presentation/widgets/problem_card.dart';
import 'package:urban_alert/features/suivi/presentation/widgets/problem_detail_sheet.dart';

class SuiviScreen extends ConsumerStatefulWidget {
  const SuiviScreen({super.key});

  @override
  ConsumerState<SuiviScreen> createState() => _SuiviScreenState();
}

class _SuiviScreenState extends ConsumerState<SuiviScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(suiviNotifierProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() =>
      ref.read(suiviNotifierProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suiviNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de mes problèmes'),
        centerTitle: false,
        scrolledUnderElevation: 1,
      ),
      body: switch (state) {
        SuiviLoading() => _SkeletonList(),
        SuiviError(:final message) => _ErrorView(
            message: message,
            onRetry: () => ref.read(suiviNotifierProvider.notifier).refresh(),
          ),
        SuiviLoaded(:final problems, :final hasMore) =>
          problems.isEmpty
              ? _EmptyView(onRefresh: _onRefresh)
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: problems.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == problems.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final problem = problems[index];
                      return ProblemCard(
                        problem: problem,
                        onTap: () => showProblemDetailSheet(
                          context,
                          ref,
                          problemId: problem.id,
                          initialProblem: problem,
                        ),
                      );
                    },
                  ),
                ),
      },
    );
  }
}

// ── Skeleton loading ──────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 6,
      itemBuilder: (_, _) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(width: 40, height: 40, radius: 8),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 14),
                      SizedBox(height: 6),
                      ShimmerBox(width: 80, height: 20, radius: 10),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ShimmerBox(height: 12),
            SizedBox(height: 4),
            ShimmerBox(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.track_changes_outlined,
                  size: 64,
                  color: colorScheme.outlineVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun problème en suivi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Les problèmes liés à vos signalements apparaîtront ici.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
