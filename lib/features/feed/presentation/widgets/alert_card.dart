import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:urban_alert/core/extensions/date_extensions.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/shared/widgets/status_chip.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  final Alert alert;
  final VoidCallback onTap;

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
              // ── Thumbnail / placeholder ────────────────────────────────────
              _Thumbnail(
                imageUrl: alert.images.isNotEmpty ? alert.images.first : null,
                status: alert.status,
              ),
              const SizedBox(width: 12),

              // ── Content ────────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + time
                    Row(
                      children: [
                        if (alert.category != null) ...[
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
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          alert.createdAt?.timeAgo ?? '',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      alert.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Status + priority chips
                    Row(
                      children: [
                        StatusChip(
                          label: alert.status.label,
                          color: alert.status.color,
                          small: true,
                        ),
                        const SizedBox(width: 6),
                        StatusChip(
                          label: alert.priority.label,
                          color: alert.priority.color,
                          small: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Address or author
                    if (alert.address != null && alert.address!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              alert.address!,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
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
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          placeholder: (context, url) => _Placeholder(status: status),
          errorWidget: (context, url, error) => _Placeholder(status: status),
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
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.location_city_rounded,
        color: status.color.withValues(alpha: 0.7),
        size: 30,
      ),
    );
  }
}
