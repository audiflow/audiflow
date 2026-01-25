import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../controllers/season_sort_controller.dart';

/// Bottom sheet for selecting season sort options.
class SeasonSortSheet extends StatelessWidget {
  const SeasonSortSheet({
    super.key,
    required this.currentConfig,
    required this.onSortSelected,
  });

  final SeasonSortConfig currentConfig;
  final void Function(SeasonSortField field, SortOrder order) onSortSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.md),
            _buildSortOption(
              context,
              'Season number (ascending)',
              SeasonSortField.seasonNumber,
              SortOrder.ascending,
            ),
            _buildSortOption(
              context,
              'Season number (descending)',
              SeasonSortField.seasonNumber,
              SortOrder.descending,
            ),
            _buildSortOption(
              context,
              'Newest episode',
              SeasonSortField.newestEpisodeDate,
              SortOrder.descending,
            ),
            _buildSortOption(
              context,
              'Progress (least complete)',
              SeasonSortField.progress,
              SortOrder.ascending,
            ),
            _buildSortOption(
              context,
              'Alphabetical',
              SeasonSortField.alphabetical,
              SortOrder.ascending,
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String label,
    SeasonSortField field,
    SortOrder order,
  ) {
    final isSelected =
        currentConfig.field == field && currentConfig.order == order;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(label),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: () {
        onSortSelected(field, order);
        Navigator.pop(context);
      },
    );
  }
}

/// Shows the season sort bottom sheet.
void showSeasonSortSheet({
  required BuildContext context,
  required SeasonSortConfig currentConfig,
  required void Function(SeasonSortField field, SortOrder order) onSortSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SeasonSortSheet(
      currentConfig: currentConfig,
      onSortSelected: onSortSelected,
    ),
  );
}
