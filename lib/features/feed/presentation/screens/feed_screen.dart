import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/features/auth/presentation/providers/auth_providers.dart';
import 'package:urban_alert/features/feed/presentation/providers/feed_providers.dart';
import 'package:urban_alert/features/feed/presentation/providers/feed_state.dart';
import 'package:urban_alert/features/feed/presentation/widgets/alert_card.dart';
import 'package:urban_alert/features/feed/presentation/widgets/alert_detail_sheet.dart';
import 'package:urban_alert/shared/widgets/shimmer_box.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      ref.read(feedNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(feedNotifierProvider.notifier).search(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    ref.read(feedNotifierProvider.notifier).refresh();
    setState(() => _showSearch = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feedState = ref.watch(feedNotifierProvider);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: _buildAppBar(context, scheme),
      body: switch (feedState) {
        FeedLoading() => const _LoadingView(),
        FeedError(:final message) => _ErrorView(
            message: message,
            onRetry: () => ref.read(feedNotifierProvider.notifier).refresh(),
          ),
        FeedLoaded() => _buildList(feedState),
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme scheme) {
    if (_showSearch) {
      return AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _clearSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Rechercher une alerte…',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: _clearSearch,
            ),
        ],
      );
    }

    return AppBar(
      title: const Text('UrbanAlert'),
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.primary,
          ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Rechercher',
          onPressed: () => setState(() => _showSearch = true),
        ),
        _LogoutButton(),
      ],
    );
  }

  Widget _buildList(FeedLoaded state) {
    if (state.alerts.isEmpty) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.alerts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (ctx, index) {
          if (index == state.alerts.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final alert = state.alerts[index];
          return AlertCard(
            alert: alert,
            onTap: () => showAlertDetailSheet(context, alert),
          );
        },
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: 'Se déconnecter',
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Se déconnecter ?'),
            content: const Text(
              'Votre session sera fermée et vous serez redirigé vers la page de connexion.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          ref.read(authNotifierProvider.notifier).logout();
        }
      },
    );
  }
}

// ── State views ───────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (ctx, _) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 72, height: 72, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 80, height: 10),
                  SizedBox(height: 8),
                  ShimmerBox(height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: 160, height: 14),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ShimmerBox(width: 56, height: 20, radius: 10),
                      SizedBox(width: 6),
                      ShimmerBox(width: 56, height: 20, radius: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune alerte pour le moment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Revenez plus tard ou signalez un problème',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: scheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
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
