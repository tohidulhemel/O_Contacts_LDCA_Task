import 'package:flutter/material.dart';

// Reusable empty-state widget.
// Used on Home (no contacts), Favorites (no favorites), and Search (no matches).
class EmptyContactsView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyContactsView({
    super.key,
    this.icon = Icons.people_outline,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}