import 'package:flutter/material.dart';

import 'year_grouped_slivers.dart';

/// Inline year divider for separating episodes by year.
///
/// Reusable in both sliver and non-sliver contexts.
class YearDivider extends StatelessWidget {
  const YearDivider({super.key, required this.year, this.onTap});

  /// The year to display. Shows "Unknown" when 0.
  final int year;

  /// Optional tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: yearHeaderHeight,
        color: colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          year == 0 ? 'Unknown' : '$year',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
