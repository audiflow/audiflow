import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../download/presentation/helpers/download_action_helper.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';
import '../../../share/presentation/helpers/share_helper.dart';
import '../controllers/podcast_detail_controller.dart';

/// Displays a single episode (PodcastItem) with playback controls.
///
/// Progress data is passed in from the parent list rather than each tile
/// querying individually, which improves list performance.
class EpisodeListTile extends ConsumerWidget {
  const EpisodeListTile({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.feedImageUrl,
    this.progress,
    this.lastRefreshedAt,
    this.siblingEpisodeIds,
    this.itunesId,
    this.feedUrl,
  });

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;

  /// RSS feed-level image URL for thumbnail deduplication.
  final String? feedImageUrl;

  /// Pre-fetched progress data. If null, episode is not yet in database.
  final EpisodeWithProgress? progress;

  /// Subscription's last refresh timestamp for "new" badge logic.
  final DateTime? lastRefreshedAt;

  /// Ordered episode IDs visible in the current list view.
  ///
  /// When provided, the adhoc queue is built from these IDs instead of
  /// falling back to a database query by episode number.
  final List<int>? siblingEpisodeIds;

  /// iTunes ID for building universal share links.
  final String? itunesId;

  /// Feed URL for invalidating the batch progress provider after changes.
  final String? feedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enclosureUrl = episode.enclosureUrl;

    final currentPlayingUrl = ref.watch(currentPlayingEpisodeUrlProvider);
    final isCurrentEpisode =
        enclosureUrl != null && currentPlayingUrl == enclosureUrl;

    final isPlaying = enclosureUrl != null
        ? ref.watch(isEpisodePlayingProvider(enclosureUrl))
        : false;
    final isLoading = enclosureUrl != null
        ? ref.watch(isEpisodeLoadingProvider(enclosureUrl))
        : false;

    final isCompleted = progress?.isCompleted ?? false;
    final isNew =
        !isCompleted &&
        !(progress?.isInProgress ?? false) &&
        _isRecentlyPublished(episode.publishDate);

    final episodeId = progress?.episode.id;
    final downloadTask = episodeId != null
        ? ref.watch(episodeDownloadProvider(episodeId)).value
        : null;

    final hasTranscript = episodeId != null
        ? ref.watch(episodeHasTranscriptProvider(episodeId)).value ?? false
        : false;

    final l10n = AppLocalizations.of(context);

    return EpisodeCard(
      title: episode.title,
      subtitle: _buildSubtitleText(l10n),
      description: episode.description,
      thumbnailUrl: episode.primaryImage?.url,
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
      onPlayPause: enclosureUrl != null
          ? () => _onPlayPausePressed(context, ref, enclosureUrl, isPlaying)
          : null,
      onLongPress: enclosureUrl != null
          ? () => _showContextMenu(
              context,
              ref,
              enclosureUrl,
              progress,
              downloadTask,
            )
          : null,
      actionButtons: [
        if (episodeId != null)
          AddToQueueButton(
            onPlayLater: () {
              ref.read(queueControllerProvider.notifier).playLater(episodeId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.queueAddedToQueue),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            onPlayNext: () {
              ref.read(queueControllerProvider.notifier).playNext(episodeId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.queuePlayingNext),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        if (episodeId != null)
          _buildDownloadButton(context, ref, episodeId, downloadTask),
        _buildMoreButton(context, ref, enclosureUrl, progress, downloadTask),
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
      } else if (episode.formattedDuration != null) {
        parts.add(episode.formattedDuration!);
      }
    } else if (episode.formattedDuration != null) {
      parts.add(episode.formattedDuration!);
    }

    if (episode.publishDate != null) {
      parts.add(
        episode.publishDate!.formatEpisodeDate(
          todayLabel: l10n.dateToday,
          yesterdayLabel: l10n.dateYesterday,
        ),
      );
    }

    return parts.join('  ');
  }

  void _navigateToDetail(BuildContext context) {
    final guid = episode.guid ?? episode.enclosureUrl ?? '';
    final location = GoRouterState.of(context).uri.toString();
    context.push(
      '$location/${AppRoutes.episodeDetail}'.replaceAll(
        ':episodeGuid',
        Uri.encodeComponent(guid),
      ),
      extra: <String, dynamic>{
        'episode': episode,
        'podcastTitle': podcastTitle,
        'artworkUrl': artworkUrl,
        'progress': progress,
        'itunesId': itunesId,
      },
    );
  }

  void _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    String? audioUrl,
    EpisodeWithProgress? progress,
    DownloadTask? downloadTask,
  ) {
    final isCompleted = progress?.isCompleted ?? false;
    final episodeId = progress?.episode.id;
    final l10n = AppLocalizations.of(context);
    final canShare =
        (itunesId != null && episode.guid != null) || episode.link != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
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
                    if (episodeId != null) ...[
                      ListTile(
                        leading: const Icon(Icons.playlist_play),
                        title: Text(l10n.playNext),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          ref
                              .read(queueControllerProvider.notifier)
                              .playNext(episodeId);
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
                              .playLater(episodeId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.queueAddedToQueue),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                    ListTile(
                      leading: Icon(
                        isCompleted ? Icons.replay : Icons.check_circle_outline,
                      ),
                      title: Text(
                        isCompleted ? l10n.markAsUnplayed : l10n.markAsPlayed,
                      ),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (audioUrl != null) {
                          _togglePlayedStatus(ref, audioUrl, isCompleted);
                        }
                      },
                    ),
                    if (episodeId != null)
                      _buildDownloadMenuTile(
                        context,
                        sheetContext,
                        ref,
                        episodeId,
                        downloadTask,
                        l10n,
                      ),
                    if (canShare)
                      ListTile(
                        leading: const Icon(Icons.share),
                        title: Text(l10n.shareEpisode),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          shareEpisode(
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
    int episodeId,
    DownloadTask? task,
    AppLocalizations l10n,
  ) {
    final isDownloaded =
        task != null && task.downloadStatus is DownloadStatusCompleted;

    if (isDownloaded) {
      return ListTile(
        leading: const Icon(Icons.delete_outline),
        title: Text(l10n.removeDownload),
        onTap: () {
          Navigator.pop(sheetContext);
          showDownloadDeleteConfirmation(
            context: outerContext,
            ref: ref,
            task: task,
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
          episodeId: episodeId,
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
    final episode = await episodeRepo.getByAudioUrl(audioUrl);
    if (episode == null) return;

    final historyService = ref.read(playbackHistoryServiceProvider);
    if (isCurrentlyCompleted) {
      await historyService.markIncomplete(episode.id);
    } else {
      await historyService.markCompleted(episode.id);
    }

    ref.invalidate(episodeProgressProvider(audioUrl));
    if (feedUrl != null) {
      ref.invalidate(podcastEpisodeProgressProvider(feedUrl!));
    }
  }

  Widget _buildDownloadButton(
    BuildContext context,
    WidgetRef ref,
    int episodeId,
    DownloadTask? task,
  ) {
    return DownloadStatusIcon(
      task: task,
      size: 24,
      onTap: () => handleDownloadTap(
        context: context,
        ref: ref,
        episodeId: episodeId,
        task: task,
      ),
    );
  }

  Widget _buildMoreButton(
    BuildContext context,
    WidgetRef ref,
    String? enclosureUrl,
    EpisodeWithProgress? progress,
    DownloadTask? downloadTask,
  ) {
    return IconButton(
      icon: const Icon(Icons.more_horiz, size: 20),
      iconSize: 20,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      onPressed: () =>
          _showContextMenu(context, ref, enclosureUrl, progress, downloadTask),
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

    final episodeId = progress?.episode.id;
    if (episodeId != null) {
      final queueService = ref.read(queueServiceProvider);

      final shouldConfirm = await queueService.shouldConfirmAdhocReplace();
      if (shouldConfirm) {
        if (!context.mounted) return;
        final confirmed = await _showReplaceQueueDialog(context);
        if (!confirmed) return;
      }

      await queueService.createAdhocQueue(
        startingEpisodeId: episodeId,
        sourceContext: podcastTitle,
        siblingEpisodeIds: siblingEpisodeIds,
      );
    }

    controller.play(
      url,
      metadata: NowPlayingInfo(
        episodeUrl: url,
        episodeTitle: episode.title,
        podcastTitle: podcastTitle,
        artworkUrl: artworkUrl ?? episode.primaryImage?.url,
        totalDuration: episode.duration,
      ),
    );
  }
}
