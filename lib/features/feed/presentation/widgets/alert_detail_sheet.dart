import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:urban_alert/core/extensions/date_extensions.dart';
import 'package:urban_alert/core/theme/app_colors.dart';
import 'package:urban_alert/features/feed/domain/entities/alert.dart';
import 'package:urban_alert/shared/widgets/status_chip.dart';

/// Full-detail bottom sheet for a single alert.
/// Call via [showAlertDetailSheet] — never instantiate directly.
void showAlertDetailSheet(BuildContext context, Alert alert) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AlertDetailSheet(alert: alert),
  );
}

class _AlertDetailSheet extends StatefulWidget {
  const _AlertDetailSheet({required this.alert});
  final Alert alert;

  @override
  State<_AlertDetailSheet> createState() => _AlertDetailSheetState();
}

class _AlertDetailSheetState extends State<_AlertDetailSheet> {
  final _pageController = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final alert = widget.alert;
    final hasImages = alert.images.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Drag handle ───────────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),

              // ── Content ───────────────────────────────────────────────────
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Image carousel ──────────────────────────────
                          if (hasImages) ...[
                            SizedBox(
                              height: 220,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  PageView.builder(
                                    controller: _pageController,
                                    itemCount: alert.images.length,
                                    onPageChanged: (i) =>
                                        setState(() => _imageIndex = i),
                                    itemBuilder: (ctx, i) {
                                      return CachedNetworkImage(
                                        imageUrl: alert.images[i],
                                        fit: BoxFit.cover,
                                        errorWidget: (c, u, e) => Container(
                                          color: scheme.surfaceContainerHighest,
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (alert.images.length > 1)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _DotsIndicator(
                                        count: alert.images.length,
                                        current: _imageIndex,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ] else
                            _NoImagePlaceholder(status: alert.status),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Category ──────────────────────────────
                                if (alert.category != null)
                                  Text(
                                    alert.category!.name.toUpperCase(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                const SizedBox(height: 6),

                                // ── Title ─────────────────────────────────
                                Text(
                                  alert.title,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // ── Status + Priority ─────────────────────
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    StatusChip(
                                      label: alert.status.label,
                                      color: alert.status.color,
                                    ),
                                    StatusChip(
                                      label:
                                          'Priorité ${alert.priority.label}',
                                      color: alert.priority.color,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // ── Description ───────────────────────────
                                _Section(
                                  icon: Icons.description_outlined,
                                  title: 'Description',
                                  child: Text(
                                    alert.description,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── Location ──────────────────────────────
                                _Section(
                                  icon: Icons.location_on_outlined,
                                  title: 'Localisation',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (alert.address != null &&
                                          alert.address!.isNotEmpty)
                                        Text(
                                          alert.address!,
                                          style:
                                              textTheme.bodyMedium?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${alert.latitude.toStringAsFixed(5)}, '
                                        '${alert.longitude.toStringAsFixed(5)}',
                                        style:
                                            textTheme.labelSmall?.copyWith(
                                          color: scheme.onSurfaceVariant
                                              .withValues(alpha: 0.7),
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── Meta row ──────────────────────────────
                                _Section(
                                  icon: Icons.person_outline_rounded,
                                  title: 'Signalé par',
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        alert.authorName,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (alert.createdAt != null)
                                        Text(
                                          alert.createdAt!.formattedDateTime,
                                          style:
                                              textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == current
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder({required this.status});
  final AlertStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      color: status.color.withValues(alpha: 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 36,
            color: status.color.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 10),
          Text(
            'Aucune photo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }
}
