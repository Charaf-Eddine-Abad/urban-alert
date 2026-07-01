import 'package:flutter/material.dart';

/// Temporary screen used to hold router slots during development.
/// Replaced feature-by-feature as phases are implemented.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.label, this.actions});
  final String label;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label), actions: actions),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'En cours de développement',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
