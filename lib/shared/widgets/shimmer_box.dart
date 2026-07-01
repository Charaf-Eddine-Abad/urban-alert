import 'package:flutter/material.dart';

/// Animated shimmer placeholder for skeleton loading screens.
/// Width defaults to fill available space; pass an explicit [width] for fixed sizes.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 4.0,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
    final highlight = isDark ? const Color(0xFF404040) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        // Highlight sweeps from Alignment(-2, 0) to (2, 0).
        // Visible inside the widget (Alignment -1 to 1) when 0.25 < t < 0.75.
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-3.0 + 4.0 * t, 0),
              end: Alignment(-1.0 + 4.0 * t, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}
