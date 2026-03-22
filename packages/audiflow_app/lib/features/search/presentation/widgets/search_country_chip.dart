import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Compact tappable chip displaying the current search country code.
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

    return ActionChip(
      label: Text(
        countryCode.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      avatar: const Icon(Icons.language, size: 18),
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
