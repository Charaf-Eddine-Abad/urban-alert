import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_alert/features/suivi/domain/entities/problem.dart';
import 'package:urban_alert/features/suivi/domain/entities/status_history_entry.dart';
import 'package:urban_alert/features/suivi/presentation/providers/suivi_providers.dart';
import 'package:urban_alert/shared/widgets/status_chip.dart';

Future<void> showProblemDetailSheet(
  BuildContext context,
  WidgetRef ref, {
  required int problemId,
  required Problem initialProblem,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ProblemDetailSheet(
      problemId: problemId,
      initialProblem: initialProblem,
      ref: ref,
    ),
  );
}

class _ProblemDetailSheet extends ConsumerStatefulWidget {
  const _ProblemDetailSheet({
    required this.problemId,
    required this.initialProblem,
    required this.ref,
  });

  final int problemId;
  final Problem initialProblem;
  final WidgetRef ref;

  @override
  ConsumerState<_ProblemDetailSheet> createState() =>
      _ProblemDetailSheetState();
}

class _ProblemDetailSheetState extends ConsumerState<_ProblemDetailSheet> {
  Problem? _problem;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _problem = widget.initialProblem;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final full = await ref
          .read(suiviRepositoryProvider)
          .getProblemById(widget.problemId);
      if (mounted) setState(() { _problem = full; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Impossible de charger les détails.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final problem = _problem!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          _Handle(theme: theme),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: problem.status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        problem.status.icon,
                        color: problem.status.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            problem.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          StatusChip(
                            label: problem.status.label,
                            color: problem.status.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if (problem.description.isNotEmpty) ...[
                  Text(
                    problem.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Dates row
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Créé le',
                  value: problem.createdAt != null
                      ? _fmtDate(problem.createdAt!)
                      : '—',
                ),
                if (problem.resolvedAt != null)
                  _InfoRow(
                    icon: Icons.check_circle_outline,
                    label: 'Résolu le',
                    value: _fmtDate(problem.resolvedAt!),
                  ),

                // Agent
                if (problem.assignedTo != null) ...[
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Agent responsable',
                    value: problem.assignedTo!.fullName,
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Linked alerts
                if (problem.alerts.isNotEmpty) ...[
                  Text(
                    'Signalements liés (${problem.alerts.length})',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...problem.alerts.map(
                    (a) => _AlertSummaryTile(alert: a),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                ],

                // Status history timeline
                Text(
                  'Historique des statuts',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error),
                  )
                else if (problem.statusHistory.isEmpty)
                  Text(
                    'Aucun changement de statut.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  _StatusTimeline(entries: problem.statusHistory),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label : ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertSummaryTile extends StatelessWidget {
  const _AlertSummaryTile({required this.alert});

  final dynamic alert; // AlertSummary

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.report_outlined, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              alert.title as String,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            alert.status as String,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.entries});

  final List<StatusHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: List.generate(entries.length, (i) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;
        final statusColor = _colorForStatus(entry.newStatus);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor, width: 2),
                      ),
                      child: Icon(
                        _iconForStatus(entry.newStatus),
                        size: 12,
                        color: statusColor,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: colorScheme.outlineVariant,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _labelForStatus(entry.newStatus),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (entry.previousStatus != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(était : ${_labelForStatus(entry.previousStatus!)})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (entry.changedAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _fmtDate(entry.changedAt!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (entry.changedBy != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'par ${entry.changedBy}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (entry.comment != null && entry.comment!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.comment!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Color _colorForStatus(String status) => switch (status.toUpperCase()) {
        'IN_PROGRESS' => const Color(0xFFF59E0B),
        'RESOLVED' => const Color(0xFF10B981),
        'REJECTED' => const Color(0xFFEF4444),
        _ => const Color(0xFF3B82F6),
      };

  IconData _iconForStatus(String status) => switch (status.toUpperCase()) {
        'IN_PROGRESS' => Icons.autorenew_rounded,
        'RESOLVED' => Icons.check_rounded,
        'REJECTED' => Icons.close_rounded,
        _ => Icons.fiber_new_rounded,
      };

  String _labelForStatus(String status) => switch (status.toUpperCase()) {
        'IN_PROGRESS' => 'En cours',
        'RESOLVED' => 'Résolu',
        'REJECTED' => 'Rejeté',
        _ => 'Nouveau',
      };
}
