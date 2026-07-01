import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:urban_alert/core/extensions/date_extensions.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/shared/widgets/status_chip.dart';

class MyAlertCard extends StatelessWidget {
  const MyAlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Alert alert;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _canModify => alert.status == AlertStatus.newAlert;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ──────────────────────────────────────────────
              _Thumbnail(
                imageUrl: alert.images.isNotEmpty ? alert.images.first : null,
                status: alert.status,
              ),
              const SizedBox(width: 12),

              // ── Content ────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (alert.category != null)
                          Flexible(
                            child: Text(
                              alert.category!.name,
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          alert.createdAt?.timeAgo ?? '',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    StatusChip(
                      label: alert.status.label,
                      color: alert.status.color,
                      small: true,
                    ),
                  ],
                ),
              ),

              // ── Actions ────────────────────────────────────────────────
              if (_canModify) ...[
                const SizedBox(width: 4),
                Column(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      iconSize: 20,
                      tooltip: 'Modifier',
                      style: IconButton.styleFrom(
                        foregroundColor: scheme.primary,
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      iconSize: 20,
                      tooltip: 'Supprimer',
                      style: IconButton.styleFrom(
                        foregroundColor: scheme.error,
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imageUrl, required this.status});
  final String? imageUrl;
  final AlertStatus status;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          placeholder: (ctx, url) => _Placeholder(status: status),
          errorWidget: (ctx, url, e) => _Placeholder(status: status),
        ),
      );
    }
    return _Placeholder(status: status);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.status});
  final AlertStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.location_city_rounded,
        color: status.color.withValues(alpha: 0.6),
        size: 26,
      ),
    );
  }
}
