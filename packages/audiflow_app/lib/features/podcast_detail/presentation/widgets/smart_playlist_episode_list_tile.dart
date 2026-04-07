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
    this.progress,
    this.siblingEpisodeIds,
    this.lastRefreshedAt,
    this.itunesId,
    this.feedUrl,
    this.forceDisplayOrder = false,
  });

  final Episode episode;
  final String podcastTitle;
  final String? artworkUrl;

  /// RSS feed-level image URL for thumbnail deduplication.
  final String? feedImageUrl;

  /// Shown when episode has no image. Use in contexts where podcast
  /// artwork is not already visible (e.g. station lists).
  final String? fallbackThumbnailUrl;
  final EpisodeWithProgress? progress;

  /// Subscription's last refresh timestamp for "new" badge logic.
  final DateTime? lastRefreshedAt;

  /// Episode IDs in the same group, for adhoc queue building.
  final List<int>? siblingEpisodeIds;

  /// When true, the queue preserves [siblingEpisodeIds] order regardless
  /// of the user's auto-play order setting.
  final bool forceDisplayOrder;

  /// iTunes ID for building universal share links.
  final String? itunesId;

  /// Feed URL for invalidating the batch progress provider after changes.
  final String? feedUrl;

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

    return EpisodeCard(
      title: episode.title,
      subtitle: _buildSubtitleText(l10n),
      description: episode.description,
      thumbnailUrl: episode.imageUrl,
      fallbackThumbnailUrl: fallbackThumbnailUrl,
      podcastArtworkUrl: artworkUrl,
      feedImageUrl: feedImageUrl,
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

  String _buildSubtitleText(AppLocalizations l10n) {
    final parts = <String>[];

    if (progress != null && progress!.isInProgress) {
      final remaining = progress!.remainingTimeFormatted;
      if (remaining != null) {
        parts.add(remaining);
      } else if (episode.durationMs != null) {
        parts.add(_formatDuration(episode.durationMs!));
      }
    } else if (episode.durationMs != null) {
      parts.add(_formatDuration(episode.durationMs!));
    }

    if (episode.publishedAt != null) {
      parts.add(
        episode.publishedAt!.formatEpisodeDate(
          todayLabel: l10n.dateToday,
          yesterdayLabel: l10n.dateYesterday,
        ),
      );
    }

    return parts.join('  ');
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (0 < hours) return '${hours}h ${minutes}min';
    return '$minutes min';
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
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.7,
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

    ref.invalidate(episodeProgressProvider(audioUrl));
    if (feedUrl != null) {
      ref.invalidate(podcastEpisodeProgressProvider(feedUrl!));
    }
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
    return IconButton(
      icon: const Icon(Icons.more_horiz, size: 20),
      iconSize: 20,
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
      padding: EdgeInsets.zero,
      onPressed: () =>
          _showContextMenu(context, ref, audioUrl, progress, downloadTask),
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
      forceDisplayOrder: forceDisplayOrder,
    );

    controller.play(
      url,
      metadata: NowPlayingInfo(
        episodeUrl: url,
        episodeTitle: episode.title,
        podcastTitle: podcastTitle,
        artworkUrl: artworkUrl ?? episode.imageUrl,
        totalDuration: episode.durationMs != null
            ? Duration(milliseconds: episode.durationMs!)
            : null,
      ),
    );
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
