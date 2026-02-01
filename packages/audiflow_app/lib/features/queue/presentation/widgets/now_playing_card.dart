import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../podcast_detail/presentation/screens/episode_detail_screen.dart';

/// Card widget showing the currently playing episode at the top of the queue.
///
/// Displays artwork, "NOW PLAYING" label, and episode title.
/// Tapping navigates to the episode detail screen.
class NowPlayingCard extends ConsumerWidget {
  const NowPlayingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingControllerProvider);

    if (nowPlaying == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEpisodeDetail(context, nowPlaying),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              MiniPlayerArtwork(
                imageUrl: nowPlaying.artworkUrl,
                size: 64,
                borderRadius: 8,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'NOW PLAYING',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      nowPlaying.episodeTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEpisodeDetail(
    BuildContext context,
    NowPlayingInfo nowPlaying,
  ) {
    final episode = nowPlaying.episode;
    if (episode == null) return;

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
          podcastTitle: nowPlaying.podcastTitle,
          artworkUrl: nowPlaying.artworkUrl,
        ),
      ),
    );
  }
}
