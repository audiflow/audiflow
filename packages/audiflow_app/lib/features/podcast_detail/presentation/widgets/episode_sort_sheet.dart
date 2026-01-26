import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for selecting episode sort options.
class EpisodeSortSheet extends StatelessWidget {
  const EpisodeSortSheet({
    super.key,
    required this.currentOrder,
    required this.onSortSelected,
  });

  final SortOrder currentOrder;
  final void Function(SortOrder order) onSortSelected;

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
              'Episode number (oldest first)',
              SortOrder.ascending,
            ),
            _buildSortOption(
              context,
              'Episode number (newest first)',
              SortOrder.descending,
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String label, SortOrder order) {
    final isSelected = currentOrder == order;
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
        onSortSelected(order);
        Navigator.pop(context);
      },
    );
  }
}

/// Shows the episode sort bottom sheet.
void showEpisodeSortSheet({
  required BuildContext context,
  required SortOrder currentOrder,
  required void Function(SortOrder order) onSortSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => EpisodeSortSheet(
      currentOrder: currentOrder,
      onSortSelected: onSortSelected,
    ),
  );
}
