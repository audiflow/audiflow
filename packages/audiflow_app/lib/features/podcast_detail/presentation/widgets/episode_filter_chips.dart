import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Filter options for episode list.
enum EpisodeFilter {
  all('All'),
  unplayed('Unplayed'),
  inProgress('In Progress');

  const EpisodeFilter(this.label);
  final String label;
}

/// Chip row for filtering episodes by playback status.
class EpisodeFilterChips extends StatelessWidget {
  const EpisodeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final EpisodeFilter selected;
  final ValueChanged<EpisodeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: EpisodeFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.xs),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
