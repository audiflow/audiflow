import 'package:audiflow_domain/audiflow_domain.dart' show EpisodeFilter;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      child: Row(
        children: EpisodeFilter.values.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: Spacing.xs),
            child: FilterChip(
              label: Text(_labelFor(l10n, filter)),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(AppLocalizations l10n, EpisodeFilter filter) {
    switch (filter) {
      case EpisodeFilter.all:
        return l10n.episodeFilterAll;
      case EpisodeFilter.unplayed:
        return l10n.episodeFilterUnplayed;
      case EpisodeFilter.inProgress:
        return l10n.episodeFilterInProgress;
    }
  }
}
