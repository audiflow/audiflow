import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../download/presentation/helpers/download_action_helper.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/podcast_detail_controller.dart';
import '../screens/episode_detail_screen.dart';
import 'episode_pill_duration_label.dart';

/// Displays a single episode from the database (Episode model) with playback.
///
/// Works with [Episode] (Drift model) instead of [PodcastItem] (RSS model).
class SmartPlaylistEpisodeListTile extends ConsumerWidget {
  const SmartPlaylistEpisodeListTile({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.feedImageUrl,
    this.fallbackThumbnailUrl,
    this.showThumbnail = true,
    this.progress,
    this.siblingEpisodeIds,
    this.lastRefreshedAt,
    this.itunesId,
    this.feedUrl,
    this.effectiveOrder,
    this.displayTitle,
    this.playlistId,
    this.stationName,
  });

  final Episode episode;
  final String podcastTitle;
  final String? artworkUrl;

  /// Title rendered in the row. Falls back to `episode.title` when null.
  final String? displayTitle;

  /// RSS feed-level image URL for thumbnail deduplication.
  final String? feedImageUrl;

  /// Shown when episode has no image. Use in contexts where podcast
  /// artwork is not already visible (e.g. station lists).
  final String? fallbackThumbnailUrl;

  /// When `false`, suppresses the row thumbnail (smart playlist
  /// per-group / per-playlist `showThumbnail` opt-out).
  final bool showThumbnail;

  final EpisodeWithProgress? progress;

  /// Subscription's last refresh timestamp for "new" badge logic.
  final DateTime? lastRefreshedAt;

  /// Episode IDs in the same group, for adhoc queue building.
  final List<int>? siblingEpisodeIds;

  /// When provided, overrides the user's global auto-play order setting.
  final AutoPlayOrder? effectiveOrder;

  /// iTunes ID for building universal share links.
  final String? itunesId;

  /// Feed URL for invalidating the batch progress provider after changes.
  final String? feedUrl;

  /// Smart playlist id (e.g. `regular`, `short`) used for analytics.
  final String? playlistId;

  /// When set, the tile is rendered in a station context.
  /// Overrides play source to [PlaySource.station] and emits [StationPlayed]
  /// instead of [SmartPlaylistPlayed].
  final String? stationName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioUrl = episode.audioUrl;

    final currentPlayingUrl = ref.watch(currentPlayingEpisodeUrlProvider);
    final isCurrentEpisode = currentPlayingUrl == audioUrl;
    final isPlaying = ref.watch(isEpisodePlayingProvider(audioUrl));
    final isLoading = ref.watch(isEpisodeLoadingProvider(audioUrl));
    final isCompleted = progress?.isCompleted ?? false;
    final isNew =
        !isCompleted &&
        !(progress?.isInProgress ?? false) &&
        _isRecentlyPublished(episode.publishedAt);

    final downloadAsync = ref.watch(episodeDownloadProvider(episode.id));
    final downloadTask = downloadAsync.value;

    final hasTranscript =
        ref.watch(episodeHasTranscriptProvider(episode.id)).value ?? false;

    final l10n = AppLocalizations.of(context);

    final livePlayback = isCurrentEpisode
        ? ref.watch(playbackProgressProvider)
        : null;
    final liveFraction = _liveFraction(livePlayback);
    final liveRemaining = _liveRemaining(livePlayback);

    return EpisodeCard(
      title: displayTitle ?? episode.title,
      pillLabel: _buildPillLabel(
        progress,
        isCompleted,
        isPlaying,
        l10n,
        liveRemaining,
      ),
      dateLabel: _buildDateLabel(l10n),
      isInProgress: (progress?.isInProgress ?? false) || (liveFraction != null),
      progressFraction: liveFraction ?? _buildProgressFraction(progress),
      description: episode.description,
      thumbnailUrl: episode.imageUrl,
      fallbackThumbnailUrl: fallbackThumbnailUrl,
      podcastArtworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
      showThumbnail: showThumbnail,
      isPlaying: isPlaying,
      isLoading: isLoading,
      isNew: isNew,
      isCompleted: isCompleted,
      isCurrentEpisode: isCurrentEpisode,
      hasTranscript: hasTranscript,
      transcriptLabel: l10n.episodeTranscriptAvailable,
      onTap: () => _navigateToDetail(context),
      onPlayPause: () => _onPlayPausePressed(context, ref, audioUrl, isPlaying),
      onLongPress: () =>
          _showContextMenu(context, ref, audioUrl, progress, downloadTask),
      actionButtons: [
        AddToQueueButton(
          onPlayLater: () {
            ref.read(queueControllerProvider.notifier).playLater(episode.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.queueAddedToQueue),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onPlayNext: () {
            ref.read(queueControllerProvider.notifier).playNext(episode.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.queuePlayingNext),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        _buildDownloadButton(context, ref, downloadTask),
        _buildMoreButton(context, ref, audioUrl, progress, downloadTask),
      ],
    );
  }

  /// Episode is "new" if published after the last feed refresh, or within
  /// the last 2 days when no refresh timestamp is available.
  bool _isRecentlyPublished(DateTime? publishDate) {
    if (publishDate == null) return false;
    final threshold =
        lastRefreshedAt ?? DateTime.now().subtract(const Duration(days: 2));
    return threshold.isBefore(publishDate);
  }

  String _buildPillLabel(
    EpisodeWithProgress? p,
    bool isCompleted,
    bool isPlaying,
    AppLocalizations l10n,
    Duration? liveRemaining,
  ) {
    if (isCompleted) return l10n.episodePillCompleted;

    final inProgress =
        isPlaying || (p?.isInProgress ?? false) || liveRemaining != null;
    if (inProgress) {
      if (liveRemaining != null) {
        return l10n.episodePillRemaining(
          episodePillDurationLabel(liveRemaining, l10n),
        );
      }
      final remainingDuration = p?.remainingDuration;
      if (remainingDuration != null) {
        return l10n.episodePillRemaining(
          episodePillDurationLabel(remainingDuration, l10n),
        );
      }
      final totalMs = episode.durationMs;
      if (totalMs != null) {
        return l10n.episodePillRemaining(
          episodePillDurationLabel(Duration(milliseconds: totalMs), l10n),
        );
      }
    }

    final totalMs = episode.durationMs;
    if (totalMs != null) {
      return episodePillDurationLabel(Duration(milliseconds: totalMs), l10n);
    }
    return '';
  }

  double? _liveFraction(PlaybackProgress? p) {
    if (p == null) return null;
    if (p.duration.inMilliseconds <= 0) return null;
    return p.progress;
  }

  Duration? _liveRemaining(PlaybackProgress? p) {
    if (p == null) return null;
    if (p.duration.inMilliseconds <= 0) return null;
    final remaining = p.duration - p.position;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String? _buildDateLabel(AppLocalizations l10n) {
    final date = episode.publishedAt;
    if (date == null) return null;
    return date.formatEpisodeDate(
      todayLabel: l10n.dateToday,
      yesterdayLabel: l10n.dateYesterday,
    );
  }

  double? _buildProgressFraction(EpisodeWithProgress? p) {
    if (p == null) return null;
    return p.progressPercent;
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EpisodeDetailScreen(
          episode: episode.toPodcastItem(feedUrl: feedUrl ?? ''),
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
          progress: progress,
          itunesId: itunesId,
        ),
      ),
    );
  }

  void _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    String audioUrl,
    EpisodeWithProgress? progress,
    DownloadTask? downloadTask,
  ) {
    final isCompleted = progress?.isCompleted ?? false;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (sheetContext, scrollController) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                child: Text(
                  episode.title,
                  style: Theme.of(sheetContext).textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.playlist_play),
                      title: Text(l10n.playNext),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ref
                            .read(queueControllerProvider.notifier)
                            .playNext(episode.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.queuePlayingNext),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.playlist_add),
                      title: Text(l10n.addToQueue),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ref
                            .read(queueControllerProvider.notifier)
                            .playLater(episode.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.queueAddedToQueue),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        isCompleted ? Icons.replay : Icons.check_circle_outline,
                      ),
                      title: Text(
                        isCompleted ? l10n.markAsUnplayed : l10n.markAsPlayed,
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _togglePlayedStatus(ref, audioUrl, isCompleted);
                      },
                    ),
                    _buildDownloadMenuTile(
                      context,
                      sheetContext,
                      ref,
                      downloadTask,
                      l10n,
                    ),
                    if (itunesId != null || episode.link != null)
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: Text(l10n.shareEpisode),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          shareEpisode(
                            context: context,
                            ref: ref,
                            itunesId: itunesId,
                            episodeGuid: episode.guid,
                            fallbackLink: episode.link,
                          );
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(l10n.goToEpisode),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _navigateToDetail(context);
                      },
                    ),
                    const SizedBox(height: Spacing.sm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadMenuTile(
    BuildContext outerContext,
    BuildContext sheetContext,
    WidgetRef ref,
    DownloadTask? task,
    AppLocalizations l10n,
  ) {
    if (task case final DownloadTask nonNullTask
        when nonNullTask.downloadStatus is DownloadStatusCompleted) {
      return ListTile(
        leading: const Icon(Icons.delete_outline),
        title: Text(l10n.removeDownload),
        onTap: () {
          Navigator.pop(sheetContext);
          showDownloadDeleteConfirmation(
            context: outerContext,
            ref: ref,
            task: nonNullTask,
          );
        },
      );
    }

    return ListTile(
      leading: const Icon(Icons.download),
      title: Text(l10n.downloadEpisode),
      onTap: () {
        Navigator.pop(sheetContext);
        handleDownloadTap(
          context: outerContext,
          ref: ref,
          episodeId: episode.id,
          task: task,
        );
      },
    );
  }

  Future<void> _togglePlayedStatus(
    WidgetRef ref,
    String audioUrl,
    bool isCurrentlyCompleted,
  ) async {
    final episodeRepo = ref.read(episodeRepositoryProvider);
    final dbEpisode = await episodeRepo.getByAudioUrl(audioUrl);
    if (dbEpisode == null) return;

    final historyService = ref.read(playbackHistoryServiceProvider);
    if (isCurrentlyCompleted) {
      await historyService.markIncomplete(dbEpisode.id);
    } else {
      await historyService.markCompleted(dbEpisode.id);
    }

    // Family-level invalidate covers every keyed instance any open
    // screen might watch (episode by audio URL, podcast batch by feed
    // URL, smart playlist by episode-id list).
    ref.invalidate(episodeProgressProvider);
    ref.invalidate(podcastEpisodeProgressProvider);
    ref.invalidate(smartPlaylistEpisodesProvider);
  }

  Widget _buildDownloadButton(
    BuildContext context,
    WidgetRef ref,
    DownloadTask? task,
  ) {
    return DownloadStatusIcon(
      task: task,
      size: 24,
      onTap: () => handleDownloadTap(
        context: context,
        ref: ref,
        episodeId: episode.id,
        task: task,
      ),
    );
  }

  Widget _buildMoreButton(
    BuildContext context,
    WidgetRef ref,
    String audioUrl,
    EpisodeWithProgress? progress,
    DownloadTask? downloadTask,
  ) {
    void open() =>
        _showContextMenu(context, ref, audioUrl, progress, downloadTask);
    return Tooltip(
      message: MaterialLocalizations.of(context).moreButtonTooltip,
      child: InkWell(
        onTap: open,
        onLongPress: open,
        customBorder: const CircleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
          child: const Icon(Icons.more_horiz, size: 20),
        ),
      ),
    );
  }

  Future<void> _onPlayPausePressed(
    BuildContext context,
    WidgetRef ref,
    String url,
    bool isPlaying,
  ) async {
    final controller = ref.read(audioPlayerControllerProvider.notifier);

    if (isPlaying) {
      controller.pause();
      return;
    }

    if (controller.isLoaded(url)) {
      controller.resume();
      return;
    }

    final queueService = ref.read(queueServiceProvider);

    final shouldConfirm = await queueService.shouldConfirmAdhocReplace();
    if (shouldConfirm) {
      if (!context.mounted) return;
      final confirmed = await _showReplaceQueueDialog(context);
      if (!confirmed) return;
    }

    await queueService.createAdhocQueue(
      startingEpisodeId: episode.id,
      sourceContext: podcastTitle,
      siblingEpisodeIds: siblingEpisodeIds,
      effectiveOrder: effectiveOrder,
    );

    final isStation = stationName != null;
    final source = isStation ? PlaySource.station : PlaySource.playlist;

    controller
      ..markPlaySource(source)
      ..play(
        url,
        metadata: NowPlayingInfo(
          episodeUrl: url,
          episodeTitle: episode.title,
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl ?? episode.imageUrl,
          totalDuration: episode.durationMs != null
              ? Duration(milliseconds: episode.durationMs!)
              : null,
          itunesId: itunesId,
          episodeGuid: episode.guid,
          feedUrl: feedUrl,
        ),
      );

    final analytics = ref.read(analyticsServiceProvider);
    if (isStation) {
      unawaited(() async {
        final installId = await ref
            .read(installIdRepositoryProvider)
            .getOrCreate();
        await analytics.log(
          StationPlayed(stationId: stableId('$installId:${stationName!}')),
        );
      }());
    } else if (playlistId != null) {
      final resolvedPresetId = feedUrl != null
          ? ref.read(presetByFeedUrlProvider(feedUrl!)).value?.id
          : null;
      // Use the resolved preset slug when available. While the preset
      // provider is still loading, fall back to the raw feedUrl so the
      // analyst can still group plays per podcast. The 100-char param
      // limit is enforced at the analytics_event boundary. When neither
      // is available, skip the emit rather than send a constant-collision
      // hash of an empty string.
      String? presetId;
      if (resolvedPresetId != null && resolvedPresetId.isNotEmpty) {
        presetId = resolvedPresetId;
      } else if (feedUrl != null && feedUrl!.isNotEmpty) {
        presetId = feedUrl;
      }
      if (presetId != null) {
        unawaited(
          analytics.log(
            SmartPlaylistPlayed(presetId: presetId, playlistId: playlistId!),
          ),
        );
      }
    }
  }

  Future<bool> _showReplaceQueueDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.episodeReplaceQueueTitle),
        content: Text(l10n.episodeReplaceQueueContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.episodeReplace),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
