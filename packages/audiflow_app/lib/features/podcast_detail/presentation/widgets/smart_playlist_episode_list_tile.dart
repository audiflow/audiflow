import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.progress,
    this.siblingEpisodeIds,
    this.lastRefreshedAt,
    this.subscriptionId,
  });

  final Episode episode;
  final String podcastTitle;
  final String? artworkUrl;

  /// RSS feed-level image URL for thumbnail deduplication.
  final String? feedImageUrl;
  final EpisodeWithProgress? progress;

  /// Subscription's last refresh timestamp for "new" badge logic.
  final DateTime? lastRefreshedAt;

  /// Episode IDs in the same group, for adhoc queue building.
  final List<int>? siblingEpisodeIds;

  /// Subscription database ID for building universal share links.
  final int? subscriptionId;

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
      onLongPress: () => _showContextMenu(context, ref, audioUrl, progress),
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
        _buildShareButton(context, ref),
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
    final podcastItem = PodcastItem(
      parsedAt: DateTime.now(),
      sourceUrl: episode.audioUrl,
      title: episode.title,
      description: episode.description ?? '',
      publishDate: episode.publishedAt,
      duration: episode.durationMs != null
          ? Duration(milliseconds: episode.durationMs!)
          : null,
      enclosureUrl: episode.audioUrl,
      guid: episode.guid,
      episodeNumber: episode.episodeNumber,
      seasonNumber: episode.seasonNumber,
      images: episode.imageUrl != null
          ? [PodcastImage(url: episode.imageUrl!)]
          : const [],
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EpisodeDetailScreen(
          episode: podcastItem,
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
          progress: progress,
          subscriptionId: subscriptionId,
        ),
      ),
    );
  }

  void _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    String audioUrl,
    EpisodeWithProgress? progress,
  ) {
    final isCompleted = progress?.isCompleted ?? false;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
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
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                isCompleted ? Icons.replay : Icons.check_circle_outline,
              ),
              title: Text(
                isCompleted
                    ? AppLocalizations.of(context).markAsUnplayed
                    : AppLocalizations.of(context).markAsPlayed,
              ),
              onTap: () {
                Navigator.pop(context);
                _togglePlayedStatus(ref, audioUrl, isCompleted);
              },
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
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
  }

  Widget _buildDownloadButton(
    BuildContext context,
    WidgetRef ref,
    DownloadTask? task,
  ) {
    return DownloadStatusIcon(
      task: task,
      size: 24,
      onTap: () => _onDownloadTap(context, ref, task),
    );
  }

  Future<void> _onDownloadTap(
    BuildContext context,
    WidgetRef ref,
    DownloadTask? task,
  ) async {
    final downloadService = ref.read(downloadServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    if (task == null) {
      await downloadService.downloadEpisode(episode.id);
      return;
    }

    task.downloadStatus.when(
      pending: () async {
        await downloadService.cancel(task.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.downloadCancelled)));
      },
      downloading: () async {
        await downloadService.pause(task.id);
      },
      paused: () async {
        await downloadService.resume(task.id);
      },
      completed: () {
        _showDeleteConfirmation(context, ref, task);
      },
      failed: () async {
        await downloadService.retry(task.id);
        messenger.showSnackBar(SnackBar(content: Text(l10n.downloadRetrying)));
      },
      cancelled: () async {
        final result = await downloadService.downloadEpisode(episode.id);
        if (result != null) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.downloadStarted)));
        }
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    DownloadTask task,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.downloadDeleteTitle),
        content: Text(l10n.downloadDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(downloadServiceProvider).delete(task.id);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.downloadDeleted)));
              }
            },
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share, size: 20),
      iconSize: 20,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 36),
      padding: EdgeInsets.zero,
      onPressed: () => shareEpisode(
        ref: ref,
        subscriptionId: subscriptionId,
        episodeGuid: episode.guid,
        fallbackLink: null,
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
