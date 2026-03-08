import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../controllers/smart_playlist_sort_controller.dart';

/// Bottom sheet for selecting smart playlist sort options.
class SmartPlaylistSortSheet extends StatelessWidget {
  const SmartPlaylistSortSheet({
    super.key,
    required this.currentConfig,
    required this.onSortSelected,
  });

  final SmartPlaylistSortConfig currentConfig;
  final void Function(SmartPlaylistSortField field, SortOrder order)
  onSortSelected;

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
              'Playlist number (ascending)',
              SmartPlaylistSortField.playlistNumber,
              SortOrder.ascending,
            ),
            _buildSortOption(
              context,
              'Playlist number (descending)',
              SmartPlaylistSortField.playlistNumber,
              SortOrder.descending,
            ),
            _buildSortOption(
              context,
              'Newest episode',
              SmartPlaylistSortField.newestEpisodeDate,
              SortOrder.descending,
            ),
            _buildSortOption(
              context,
              'Alphabetical',
              SmartPlaylistSortField.alphabetical,
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
    SmartPlaylistSortField field,
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

/// Shows the smart playlist sort bottom sheet.
void showSmartPlaylistSortSheet({
  required BuildContext context,
  required SmartPlaylistSortConfig currentConfig,
  required void Function(SmartPlaylistSortField field, SortOrder order)
  onSortSelected,
}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SmartPlaylistSortSheet(
      currentConfig: currentConfig,
      onSortSelected: onSortSelected,
    ),
  );
}
