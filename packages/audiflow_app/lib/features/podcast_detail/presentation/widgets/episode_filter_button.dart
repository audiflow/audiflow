import 'package:audiflow_domain/audiflow_domain.dart' show EpisodeFilter;
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'menu_selector_button.dart';

/// Pill naming the current episode filter; opens a menu of every filter.
///
/// A menu instead of a chip row keeps all five filters reachable at any
/// width (redesign 4.2).
class EpisodeFilterButton extends StatelessWidget {
  const EpisodeFilterButton({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final EpisodeFilter selected;
  final ValueChanged<EpisodeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuSelectorButton<EpisodeFilter>(
      choices: EpisodeFilter.values,
      selected: selected,
      labelOf: (filter) => episodeFilterLabel(l10n, filter),
      onSelected: onSelected,
      leadingIcon: Icons.filter_list_rounded,
    );
  }
}

/// Localized name of [filter].
String episodeFilterLabel(AppLocalizations l10n, EpisodeFilter filter) {
  return switch (filter) {
    EpisodeFilter.all => l10n.episodeFilterAll,
    EpisodeFilter.unplayed => l10n.episodeFilterUnplayed,
    EpisodeFilter.inProgress => l10n.episodeFilterInProgress,
    EpisodeFilter.played => l10n.episodeFilterPlayed,
    EpisodeFilter.downloaded => l10n.episodeFilterDownloaded,
  };
}
