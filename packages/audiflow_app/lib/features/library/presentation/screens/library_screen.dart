import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Placeholder screen for the Library tab.
///
/// Displays a centered icon and text indicating the library feature
/// is coming soon. This screen will be replaced with the full
/// library implementation showing subscribed podcasts.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.library_music,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text('Library', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Your subscribed podcasts will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
