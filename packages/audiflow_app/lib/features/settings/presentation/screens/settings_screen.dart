import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Placeholder screen for the Settings tab.
///
/// Displays a centered icon and text indicating the settings feature
/// is coming soon. This screen will be replaced with the full
/// settings implementation for app configuration.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.settings,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text('Settings', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'App settings will appear here',
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
