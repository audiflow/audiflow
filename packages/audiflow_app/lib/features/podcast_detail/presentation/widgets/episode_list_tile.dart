import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/podcast_detail_controller.dart';

/// Displays a single episode with play/pause controls.
///
/// Shows episode title, duration, publish date, and a play/pause button.
/// The button state reflects the current playback status of this episode.
/// Also displays progress indicators for in-progress and completed episodes.
/// Long-press to access mark played/unplayed options.
class EpisodeListTile extends ConsumerWidget {
  const EpisodeListTile({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
  });

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final enclosureUrl = episode.enclosureUrl;

    // Watch episode progress for this episode
    final progressAsync = enclosureUrl != null
        ? ref.watch(episodeProgressProvider(enclosureUrl))
        : const AsyncValue<EpisodeWithProgress?>.data(null);
    final progress = progressAsync.value;

    // Check if this episode is currently playing or paused
    final isCurrentEpisode =
        enclosureUrl != null &&
        playbackState.maybeWhen(
          playing: (url) => url == enclosureUrl,
          paused: (url) => url == enclosureUrl,
          loading: (url) => url == enclosureUrl,
          orElse: () => false,
        );

    final isPlaying = playbackState.maybeWhen(
      playing: (url) => url == enclosureUrl,
      orElse: () => false,
    );

    final isLoading = playbackState.maybeWhen(
      loading: (url) => url == enclosureUrl,
      orElse: () => false,
    );

    // Dim completed episodes
    final isCompleted = progress?.isCompleted ?? false;

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
        trailing: _buildPlayButton(
          context,
          ref,
          enclosureUrl: enclosureUrl,
          isPlaying: isPlaying,
          isLoading: isLoading,
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

    // Invalidate the progress provider to refresh UI
    ref.invalidate(episodeProgressProvider(audioUrl));
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
      onPressed: () => _onPlayPausePressed(ref, enclosureUrl, isPlaying),
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
          artworkUrl: artworkUrl ?? episode.primaryImage?.url,
          totalDuration: episode.duration,
        ),
      );
    }
  }
}
