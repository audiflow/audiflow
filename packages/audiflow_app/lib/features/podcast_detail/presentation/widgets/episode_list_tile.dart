import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../queue/presentation/controllers/queue_controller.dart';
import '../controllers/podcast_detail_controller.dart';

/// Displays a single episode with play/pause controls.
///
/// Shows episode title, duration, publish date, and a play/pause button.
/// The button state reflects the current playback status of this episode.
/// Also displays progress indicators for in-progress and completed episodes.
/// Long-press to access mark played/unplayed options.
///
/// Progress data is passed in from the parent list rather than each tile
/// querying individually, which dramatically improves list performance.
class EpisodeListTile extends ConsumerWidget {
  const EpisodeListTile({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.progress,
  });

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;

  /// Pre-fetched progress data. If null, episode is not yet in database.
  final EpisodeWithProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enclosureUrl = episode.enclosureUrl;

    // Only watch the current playing URL, not the entire playback state
    final currentPlayingUrl = ref.watch(currentPlayingEpisodeUrlProvider);
    final isCurrentEpisode =
        enclosureUrl != null && currentPlayingUrl == enclosureUrl;

    // Use select to only rebuild when this specific episode's state changes
    final isPlaying = enclosureUrl != null
        ? ref.watch(isEpisodePlayingProvider(enclosureUrl))
        : false;
    final isLoading = enclosureUrl != null
        ? ref.watch(isEpisodeLoadingProvider(enclosureUrl))
        : false;

    // Use passed-in progress data instead of querying per tile
    final isCompleted = progress?.isCompleted ?? false;

    // Watch download status if episode exists in database
    final episodeId = progress?.episode.id;
    final downloadTask = episodeId != null
        ? ref.watch(episodeDownloadProvider(episodeId)).value
        : null;

    return GestureDetector(
      onLongPress: enclosureUrl != null
          ? () => _showContextMenu(context, ref, enclosureUrl, progress)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        title: Text(
          episode.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isCurrentEpisode ? FontWeight.bold : FontWeight.normal,
            color: isCurrentEpisode
                ? colorScheme.primary
                : isCompleted
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                : null,
          ),
        ),
        subtitle: _buildSubtitle(theme, progress),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (episodeId != null)
              AddToQueueButton(
                onPlayLater: () {
                  ref
                      .read(queueControllerProvider.notifier)
                      .playLater(episodeId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to queue'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                onPlayNext: () {
                  ref
                      .read(queueControllerProvider.notifier)
                      .playNext(episodeId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Playing next'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            if (episodeId != null)
              _buildDownloadButton(context, ref, episodeId, downloadTask),
            _buildPlayButton(
              context,
              ref,
              enclosureUrl: enclosureUrl,
              isPlaying: isPlaying,
              isLoading: isLoading,
            ),
          ],
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
              title: Text(isCompleted ? 'Mark as unplayed' : 'Mark as played'),
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
    final episode = await episodeRepo.getByAudioUrl(audioUrl);
    if (episode == null) return;

    final historyService = ref.read(playbackHistoryServiceProvider);
    if (isCurrentlyCompleted) {
      await historyService.markIncomplete(episode.id);
    } else {
      await historyService.markCompleted(episode.id);
    }

    // Invalidate the batch progress provider to refresh the entire list
    // This is more efficient than N individual invalidations
    // The feedUrl would need to be passed in, but for now we'll use individual
    ref.invalidate(episodeProgressProvider(audioUrl));
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
      onTap: () => _onDownloadTap(context, ref, episodeId, task),
    );
  }

  Future<void> _onDownloadTap(
    BuildContext context,
    WidgetRef ref,
    int episodeId,
    DownloadTask? task,
  ) async {
    final downloadService = ref.read(downloadServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (task == null) {
      await downloadService.downloadEpisode(episodeId);
      return;
    }

    task.downloadStatus.when(
      pending: () async {
        await downloadService.cancel(task.id);
        messenger.showSnackBar(
          const SnackBar(content: Text('Download cancelled')),
        );
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
        messenger.showSnackBar(
          const SnackBar(content: Text('Retrying download')),
        );
      },
      cancelled: () async {
        final result = await downloadService.downloadEpisode(episodeId);
        if (result != null) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Download started')),
          );
        }
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    DownloadTask task,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete download?'),
        content: const Text('The downloaded file will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(downloadServiceProvider).delete(task.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, EpisodeWithProgress? progress) {
    final parts = <String>[];

    // Show remaining time if in progress, otherwise show total duration
    if (progress != null && progress.isInProgress) {
      final remaining = progress.remainingTimeFormatted;
      if (remaining != null) {
        parts.add(remaining);
      } else if (episode.formattedDuration != null) {
        parts.add(episode.formattedDuration!);
      }
    } else if (episode.formattedDuration != null) {
      parts.add(episode.formattedDuration!);
    }

    if (episode.publishDate != null) {
      parts.add(DateFormat.yMMMd().format(episode.publishDate!));
    }

    if (episode.episodeNumber != null) {
      final seasonPart = episode.seasonNumber != null
          ? 'S${episode.seasonNumber}:'
          : '';
      parts.add('${seasonPart}E${episode.episodeNumber}');
    }

    if (parts.isEmpty && progress == null) return const SizedBox.shrink();

    // Build subtitle with progress indicator
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (parts.isNotEmpty)
          Text(
            parts.join(' - '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        if (progress != null &&
            (progress.isCompleted || progress.isInProgress)) ...[
          const SizedBox(height: 4),
          EpisodeProgressIndicator(
            isCompleted: progress.isCompleted,
            isInProgress: progress.isInProgress,
            remainingTimeFormatted: progress.remainingTimeFormatted,
          ),
        ],
      ],
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    WidgetRef ref, {
    required String? enclosureUrl,
    required bool isPlaying,
    required bool isLoading,
  }) {
    if (enclosureUrl == null) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Icon(Icons.block, color: Colors.grey),
      );
    }

    if (isLoading) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
        size: 40,
      ),
      color: Theme.of(context).colorScheme.primary,
      onPressed: () =>
          _onPlayPausePressed(context, ref, enclosureUrl, isPlaying),
    );
  }

  Future<bool> _showReplaceQueueDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace queue?'),
        content: const Text(
          'Starting playback will replace your current queue with episodes from this list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
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

    // Starting new playback - handle adhoc queue
    final episodeId = progress?.episode.id;
    if (episodeId != null) {
      final queueService = ref.read(queueServiceProvider);

      // Check if confirmation needed
      final shouldConfirm = await queueService.shouldConfirmAdhocReplace();

      if (shouldConfirm) {
        if (!context.mounted) return;
        final confirmed = await _showReplaceQueueDialog(context);
        if (!confirmed) return;
      }

      // Create adhoc queue
      await queueService.createAdhocQueue(
        startingEpisodeId: episodeId,
        sourceContext: podcastTitle,
      );
    }

    // Start playback
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
