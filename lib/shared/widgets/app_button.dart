import 'package:flutter/material.dart';

/// Primary full-width button with a built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !loading;

    return ElevatedButton(
      onPressed: isActive ? onPressed : null,
      child: loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : (icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [icon!, const SizedBox(width: 8), Text(label)],
                )
              : Text(label)),
    );
  }
}
