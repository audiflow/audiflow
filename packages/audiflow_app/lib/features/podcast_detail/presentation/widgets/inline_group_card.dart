import 'package:audiflow_domain/audiflow_domain.dart'
    show
        EffectiveThumbnails,
        SmartPlaylistEpisodeData,
        SmartPlaylistGroup,
        presetByFeedUrlProvider;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Formats duration in ms using localized strings.
String? formatGroupDuration(int? totalMs, AppLocalizations l10n) {
  if (totalMs == null || totalMs == 0) return null;
  final minutes = totalMs ~/ 60000;
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (0 < hours) {
    return l10n.groupDurationHoursMinutes(hours, remainingMinutes);
  }
  return l10n.groupDurationMinutes(minutes);
}

/// Played state of a series row: how many episodes are finished and the
/// overall progress (finished episodes count 1, started ones their part).
class SeriesPlayback {
  const SeriesPlayback({
    required this.played,
    required this.total,
    required this.fraction,
  });

  factory SeriesPlayback.of(
    Iterable<int> episodeIds,
    Map<int, SmartPlaylistEpisodeData> episodes,
  ) {
    var played = 0;
    var total = 0;
    var progress = 0.0;
    for (final id in episodeIds) {
      total++;
      final state = episodes[id]?.progress;
      if (state == null) continue;
      if (state.isCompleted) {
        played++;
        progress += 1;
      } else if (state.isInProgress) {
        progress += (state.progressPercent ?? 0).clamp(0.0, 1.0);
      }
    }
    return SeriesPlayback(
      played: played,
      total: total,
      fraction: total == 0 ? 0 : progress / total,
    );
  }

  final int played;
  final int total;

  /// 0 when nothing has been started, 1 when every episode is played.
  final double fraction;

  bool get started => 0 < fraction;
  bool get finished => 0 < total && total <= played;
}

/// Series row on the podcast's Series tab (redesign 4.2): artwork, name,
/// "N episodes · total time", played status, and a bottom-edge line once
/// the series has been started. Sits on a grouped surface.
class InlineGroupCard extends ConsumerWidget {
  const InlineGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.playback,
    this.prependSeasonNumber = false,
    this.feedUrl,
    this.playlistId,
    this.episodeCountOverride,
    this.totalDurationMsOverride,
  });

  final SmartPlaylistGroup group;
  final VoidCallback onTap;

  /// Played state; no status line when null.
  final SeriesPlayback? playback;
  final bool prependSeasonNumber;

  /// Feed URL of the parent podcast. When set together with
  /// [playlistId], the row resolves the `showThumbnail` flag
  /// from the matched smart playlist config.
  final String? feedUrl;

  /// Parent playlist id. See [feedUrl].
  final String? playlistId;

  /// When set, overrides `group.episodeIds.length` for the
  /// episode count display (used in perEpisode year mode).
  final int? episodeCountOverride;

  /// When set, overrides `group.totalDurationMs` for the
  /// duration display (used in split-by-year mode).
  final int? totalDurationMsOverride;

  static const _thumbnailSize = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final duration = formatGroupDuration(
      totalDurationMsOverride ?? group.totalDurationMs,
      l10n,
    );
    final count = l10n.groupEpisodeCount(
      episodeCountOverride ?? group.episodeIds.length,
    );
    final meta = duration == null ? count : '$count · $duration';
    final hasThumbnail =
        _resolveShowThumbnail(ref) && group.thumbnailUrl != null;
    final playback = this.playback;

    return InkWell(
      onTap: onTap,
      child: BottomEdgeProgress(
        fraction: playback != null && playback.started
            ? playback.fraction
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.rowHorizontal,
            vertical: Spacing.rowVertical,
          ),
          child: Row(
            children: [
              if (hasThumbnail) ...[
                _thumbnail(colors),
                const SizedBox(width: Spacing.sm + Spacing.xs),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.formattedDisplayName(
                        parentPrependSeasonNumber: prependSeasonNumber,
                      ),
                      style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      meta,
                      style: AppTextStyles.tabular(
                        AppTextStyles.meta.copyWith(color: colors.inkSecondary),
                      ),
                    ),
                    if (playback != null)
                      Text(
                        _status(playback, l10n),
                        style: AppTextStyles.caption.copyWith(
                          color: playback.started
                              ? colors.accent
                              : colors.inkTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(Icons.chevron_right, color: colors.inkTertiary),
            ],
          ),
        ),
      ),
    );
  }

  String _status(SeriesPlayback playback, AppLocalizations l10n) {
    if (playback.finished) return l10n.seriesStatusPlayed;
    if (!playback.started) return l10n.seriesStatusUnplayed;
    return l10n.seriesStatusPartlyPlayed(playback.played, playback.total);
  }

  Widget _thumbnail(AppColors colors) {
    return ClipRRect(
      borderRadius: AppBorders.artworkList,
      child: ArtworkImage(
        url: group.thumbnailUrl!,
        width: _thumbnailSize,
        height: _thumbnailSize,
        loading: const ArtworkLoadingIndicator(),
        placeholder: Container(
          width: _thumbnailSize,
          height: _thumbnailSize,
          color: colors.surfaceSunken,
          child: Icon(
            Icons.folder_outlined,
            size: 24,
            color: colors.inkQuaternary,
          ),
        ),
      ),
    );
  }

  bool _resolveShowThumbnail(WidgetRef ref) {
    final url = feedUrl;
    final id = playlistId;
    if (url == null || id == null) return true;

    final config = ref.watch(presetByFeedUrlProvider(url)).value;
    if (config == null) return true;

    final playlistDef = config.findPlaylist(id);
    if (playlistDef == null) return true;

    final groupDef = playlistDef.grouping.findStaticClassifier(group.id);

    return EffectiveThumbnails.groupCard(
      showEpisodeThumbnail: config.showEpisodeThumbnail,
      playlist: playlistDef,
      group: groupDef,
    );
  }
}

/// Helper for perEpisode year mode to carry filtered IDs
/// alongside the original group in inline view.
class YearFilteredInlineGroup {
  const YearFilteredInlineGroup({
    required this.group,
    required this.filteredEpisodeIds,
    this.earliestDate,
    this.latestDate,
    this.totalDurationMs,
  });

  final SmartPlaylistGroup group;
  final List<int> filteredEpisodeIds;

  /// Filtered earliest episode date (for split-by-year).
  final DateTime? earliestDate;

  /// Filtered latest episode date (for split-by-year).
  final DateTime? latestDate;

  /// Filtered total duration in ms (for split-by-year).
  final int? totalDurationMs;
}
