import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/podcast_detail_controller.dart';

/// Displays a single episode from the database (Episode model) with playback.
///
/// Similar to [EpisodeListTile] but works with [Episode] (Drift model)
/// instead of [PodcastItem] (RSS parsed model).
class SeasonEpisodeListTile extends ConsumerWidget {
  const SeasonEpisodeListTile({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.progress,
  });

  final Episode episode;
  final String podcastTitle;
  final String? artworkUrl;
  final EpisodeWithProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final audioUrl = episode.audioUrl;

    final currentPlayingUrl = ref.watch(currentPlayingEpisodeUrlProvider);
    final isCurrentEpisode = currentPlayingUrl == audioUrl;

    final isPlaying = ref.watch(isEpisodePlayingProvider(audioUrl));
    final isLoading = ref.watch(isEpisodeLoadingProvider(audioUrl));

    final isCompleted = progress?.isCompleted ?? false;

    final downloadAsync = ref.watch(episodeDownloadProvider(episode.id));
    final downloadTask = downloadAsync.value;

    return GestureDetector(
      onLongPress: () => _showContextMenu(context, ref, audioUrl, progress),
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
            _buildDownloadButton(context, ref, downloadTask),
            _buildPlayButton(
              context,
              ref,
              audioUrl: audioUrl,
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

  Widget _buildSubtitle(ThemeData theme, EpisodeWithProgress? progress) {
    final parts = <String>[];

    // Show remaining time if in progress, otherwise show total duration
    if (progress != null && progress.isInProgress) {
      final remaining = progress.remainingTimeFormatted;
      if (remaining != null) {
        parts.add(remaining);
      } else if (episode.durationMs != null) {
        parts.add(_formatDuration(episode.durationMs!));
      }
    } else if (episode.durationMs != null) {
      parts.add(_formatDuration(episode.durationMs!));
    }

    if (episode.publishedAt != null) {
      parts.add(DateFormat.yMMMd().format(episode.publishedAt!));
    }

    if (episode.episodeNumber != null) {
      final seasonPart = episode.seasonNumber != null
          ? 'S${episode.seasonNumber}:'
          : '';
      parts.add('${seasonPart}E${episode.episodeNumber}');
    }

    if (parts.isEmpty && progress == null) return const SizedBox.shrink();

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

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (0 < hours) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

    if (task == null) {
      final result = await downloadService.downloadEpisode(episode.id);
      if (result != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Download started')),
        );
      }
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
        final result = await downloadService.downloadEpisode(episode.id);
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

  Widget _buildPlayButton(
    BuildContext context,
    WidgetRef ref, {
    required String audioUrl,
    required bool isPlaying,
    required bool isLoading,
  }) {
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
      onPressed: () => _onPlayPausePressed(ref, audioUrl, isPlaying),
    );
  }

  void _onPlayPausePressed(WidgetRef ref, String url, bool isPlaying) {
    final controller = ref.read(audioPlayerControllerProvider.notifier);
    if (isPlaying) {
      controller.pause();
    } else if (controller.isLoaded(url)) {
      controller.resume();
    } else {
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
  }
}
