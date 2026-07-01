import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/core/errors/app_exception.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/features/feed/presentation/widgets/alert_detail_sheet.dart';
import 'package:urban_alert/features/my_alerts/presentation/providers/my_alerts_providers.dart';
import 'package:urban_alert/features/my_alerts/presentation/providers/my_alerts_state.dart';
import 'package:urban_alert/features/my_alerts/presentation/widgets/create_alert_sheet.dart';
import 'package:urban_alert/features/my_alerts/presentation/widgets/my_alert_card.dart';
import 'package:urban_alert/shared/widgets/shimmer_box.dart';

class MyAlertsScreen extends ConsumerStatefulWidget {
  const MyAlertsScreen({super.key});

  @override
  ConsumerState<MyAlertsScreen> createState() => _MyAlertsScreenState();
}

class _MyAlertsScreenState extends ConsumerState<MyAlertsScreen> {
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
      ref.read(myAlertsNotifierProvider.notifier).loadMore();
    }
  }

  Future<void> _openCreate() async {
    final success = await showCreateAlertPage(context);
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement publié avec succès')),
      );
    }
  }

  Future<void> _openEdit(Alert alert) async {
    final success = await showCreateAlertPage(context, alertToEdit: alert);
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signalement mis à jour')),
      );
    }
  }

  Future<void> _confirmDelete(int id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le signalement ?'),
        content: Text(
          '"$title" sera supprimé définitivement.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(myAlertsNotifierProvider.notifier).deleteAlert(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signalement supprimé')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myAlertsNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Mes signalements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () =>
                ref.read(myAlertsNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Signaler'),
      ),
      body: switch (state) {
        MyAlertsLoading() => const _SkeletonList(),
        MyAlertsError(:final message) => _ErrorView(
            message: message,
            onRetry: () =>
                ref.read(myAlertsNotifierProvider.notifier).refresh(),
          ),
        MyAlertsLoaded() => _buildList(state),
      },
    );
  }

  Widget _buildList(MyAlertsLoaded state) {
    if (state.alerts.isEmpty) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myAlertsNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        itemCount: state.alerts.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (ctx, index) {
          if (index == state.alerts.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final alert = state.alerts[index];
          return MyAlertCard(
            alert: alert,
            onTap: () => showAlertDetailSheet(context, alert),
            onEdit: () => _openEdit(alert),
            onDelete: () => _confirmDelete(alert.id, alert.title),
          );
        },
      ),
    );
  }
}

// ── State views ───────────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            ShimmerBox(width: 64, height: 64, radius: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 10),
                  SizedBox(height: 8),
                  ShimmerBox(height: 14),
                  SizedBox(height: 8),
                  ShimmerBox(width: 60, height: 20, radius: 10),
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
            Icons.report_problem_outlined,
            size: 64,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun signalement pour l\'instant',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Appuyez sur « Signaler » pour en créer un',
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
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
