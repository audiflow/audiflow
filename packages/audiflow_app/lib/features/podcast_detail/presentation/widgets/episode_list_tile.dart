import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Displays a single episode with play/pause controls.
///
/// Shows episode title, duration, publish date, and a play/pause button.
/// The button state reflects the current playback status of this episode.
class EpisodeListTile extends ConsumerWidget {
  const EpisodeListTile({super.key, required this.episode});

  final PodcastItem episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final enclosureUrl = episode.enclosureUrl;

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

    return ListTile(
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
          color: isCurrentEpisode ? colorScheme.primary : null,
        ),
      ),
      subtitle: _buildSubtitle(theme),
      trailing: _buildPlayButton(
        context,
        ref,
        enclosureUrl: enclosureUrl,
        isPlaying: isPlaying,
        isLoading: isLoading,
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    final parts = <String>[];

    if (episode.formattedDuration != null) {
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

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' - '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
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
      controller.play(url);
    }
  }
}
