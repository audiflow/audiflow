import 'package:flutter/material.dart';

/// Compact tappable country code indicator sized for TextField prefixIcon.
class SearchCountryChip extends StatelessWidget {
  const SearchCountryChip({
    required this.countryCode,
    required this.onTap,
    super.key,
  });

  final String countryCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              countryCode.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 18, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
