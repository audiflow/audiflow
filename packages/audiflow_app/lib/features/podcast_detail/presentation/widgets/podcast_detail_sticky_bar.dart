import 'package:audiflow_domain/audiflow_domain.dart'
    show EpisodeFilter, PodcastViewMode, SmartPlaylist, SortOrder;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'episode_filter_chips.dart';
import 'episode_list_section.dart';

/// Controls pinned under the floating navigation on podcast detail
/// (redesign 4.2): the Episodes / Series switch, then a row that depends
/// on the view (filter chips, or the series-type dropdown) with the sort
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
    this.seriesCount,
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

  /// Shown as "N series ·" before the sort toggle on the Series view.
  final int? seriesCount;

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
                Expanded(child: series ? _seriesType() : _filterChips()),
                if (series && seriesCount != null)
                  Text(
                    '${l10n.podcastDetailGroupCount(seriesCount!)} ·',
                    style: AppTextStyles.tabular(
                      AppTextStyles.meta.copyWith(color: colors.inkTertiary),
                    ),
                  ),
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

  Widget _filterChips() {
    return EpisodeFilterChips(selected: filter, onSelected: onFilterSelected);
  }

  Widget _seriesType() {
    final selected = selectedPlaylist;
    if (selected == null) return const SizedBox.shrink();
    // The dropdown takes at most ~58% of the row so the sort toggle keeps
    // its room even for long series-type names.
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: Spacing.screenHorizontal),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: (constraints.maxWidth + Spacing.sm) * 0.58,
            ),
            child: _SeriesTypeDropdown(
              playlists: playlists,
              selected: selected,
              onSelected: onPlaylistSelected,
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined pill naming the current series type; opens a menu of the
/// others when there is more than one.
class _SeriesTypeDropdown extends StatelessWidget {
  const _SeriesTypeDropdown({
    required this.playlists,
    required this.selected,
    required this.onSelected,
  });

  final List<SmartPlaylist> playlists;
  final SmartPlaylist selected;
  final ValueChanged<SmartPlaylist> onSelected;

  bool get _hasChoices => 1 < playlists.length;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.surface,
      shape: StadiumBorder(side: BorderSide(color: colors.outline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _hasChoices ? () => _showMenu(context) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36),
          child: Padding(
            padding: EdgeInsets.only(
              left: Spacing.md,
              right: _hasChoices ? Spacing.sm : Spacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    selected.formattedDisplayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(color: colors.ink),
                  ),
                ),
                if (_hasChoices) ...[
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: colors.inkSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final bottomLeft = box.localToGlobal(
      box.size.bottomLeft(Offset.zero),
      ancestor: overlay,
    );
    final colors = AppColors.of(context);
    final chosen = await showMenu<SmartPlaylist>(
      context: context,
      position: RelativeRect.fromRect(
        bottomLeft & Size(box.size.width, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        for (final playlist in playlists)
          PopupMenuItem(
            value: playlist,
            child: Text(
              playlist.formattedDisplayName,
              style: playlist.id == selected.id
                  ? AppTextStyles.body.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    )
                  : null,
            ),
          ),
      ],
    );
    if (chosen != null) onSelected(chosen);
  }
}
