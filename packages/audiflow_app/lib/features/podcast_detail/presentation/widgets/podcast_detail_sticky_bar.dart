import 'package:audiflow_domain/audiflow_domain.dart'
    show EpisodeFilter, PodcastViewMode, SmartPlaylist, SortOrder;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'episode_filter_button.dart';
import 'episode_list_section.dart';
import 'menu_selector_button.dart';

/// Controls pinned under the floating navigation on podcast detail
/// (redesign 4.2): the Episodes / Series switch, then a row that depends
/// on the view (the episode filter menu, or the series-type menu) with the sort
/// toggle on the right.
class PodcastDetailStickyBar extends StatelessWidget {
  const PodcastDetailStickyBar({
    super.key,
    required this.showModeSwitch,
    required this.mode,
    required this.onModeChanged,
    required this.playlists,
    required this.selectedPlaylist,
    required this.onPlaylistSelected,
    required this.filter,
    required this.onFilterSelected,
    required this.sortOrder,
    required this.onToggleSortOrder,
  });

  /// Off for podcasts without series: only the episodes row shows.
  final bool showModeSwitch;
  final PodcastViewMode mode;
  final ValueChanged<PodcastViewMode> onModeChanged;
  final List<SmartPlaylist> playlists;
  final SmartPlaylist? selectedPlaylist;
  final ValueChanged<SmartPlaylist> onPlaylistSelected;
  final EpisodeFilter filter;
  final ValueChanged<EpisodeFilter> onFilterSelected;
  final SortOrder sortOrder;
  final VoidCallback onToggleSortOrder;

  static const double _rowHeight = 52;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final series = mode == PodcastViewMode.smartPlaylists;
    return ColoredBox(
      color: colors.bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showModeSwitch)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.screenHorizontal,
                Spacing.xs,
                Spacing.screenHorizontal,
                0,
              ),
              child: AppSegmentedControl<PodcastViewMode>(
                segments: [
                  (PodcastViewMode.episodes, l10n.episodesLabel),
                  (PodcastViewMode.smartPlaylists, l10n.podcastDetailSeriesTab),
                ],
                selected: mode,
                onChanged: onModeChanged,
              ),
            ),
          SizedBox(
            height: _rowHeight,
            child: Row(
              children: [
                Expanded(child: series ? _seriesType() : _filterButton()),
                SortOrderButton(
                  sortOrder: sortOrder,
                  onPressed: onToggleSortOrder,
                ),
                const SizedBox(width: Spacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton() {
    return _leadingSelector(
      EpisodeFilterButton(selected: filter, onSelected: onFilterSelected),
    );
  }

  Widget _seriesType() {
    final selected = selectedPlaylist;
    if (selected == null) return const SizedBox.shrink();
    return _leadingSelector(
      MenuSelectorButton<SmartPlaylist>(
        choices: playlists,
        selected: selected,
        labelOf: (playlist) => playlist.formattedDisplayName,
        isSelected: (playlist) => playlist.id == selected.id,
        onSelected: onPlaylistSelected,
      ),
    );
  }

  /// Left-aligns a selector pill. It takes at most ~58% of the row so the
  /// sort toggle keeps its room even for long names.
  Widget _leadingSelector(Widget selector) {
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: Spacing.screenHorizontal),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: (constraints.maxWidth + Spacing.sm) * 0.58,
            ),
            child: selector,
          ),
        ),
      ),
    );
  }
}
