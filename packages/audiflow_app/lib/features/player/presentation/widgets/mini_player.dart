import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A compact player widget displayed at the bottom of the screen.
///
/// Shows episode artwork, title, podcast name, play/pause button, and
/// a progress bar at the top. Tapping the widget expands to the full
/// player screen.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, this.onTap});

  /// Callback when the mini player is tapped.
  final VoidCallback? onTap;

  static const double height = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final progress = ref.watch(playbackProgressProvider);

    if (nowPlaying == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isPlaying = playbackState.maybeWhen(
      playing: (_) => true,
      orElse: () => false,
    );

    final isLoading = playbackState.maybeWhen(
      loading: (_) => true,
      orElse: () => false,
    );

    return Semantics(
      container: true,
      label:
          'Now playing: ${nowPlaying.episodeTitle} by ${nowPlaying.podcastTitle}',
      child: Material(
        elevation: 8,
        color: colorScheme.surfaceContainer,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                MiniPlayerProgressBar(
                  progress: progress?.progress ?? 0.0,
                  bufferedProgress: progress?.bufferedProgress ?? 0.0,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                    child: Row(
                      children: [
                        MiniPlayerArtwork(
                          imageUrl: nowPlaying.artworkUrl,
                          size: 48,
                        ),
                        const SizedBox(width: Spacing.sm),
                        _MiniPlayerInfo(
                          episodeTitle: nowPlaying.episodeTitle,
                          podcastTitle: nowPlaying.podcastTitle,
                        ),
                        _MiniPlayerPlayPauseButton(
                          isPlaying: isPlaying,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPlayerInfo extends StatelessWidget {
  const _MiniPlayerInfo({
    required this.episodeTitle,
    required this.podcastTitle,
  });

  final String episodeTitle;
  final String podcastTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              episodeTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              podcastTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayerPlayPauseButton extends ConsumerWidget {
  const _MiniPlayerPlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
  });

  final bool isPlaying;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Semantics(
        label: 'Loading',
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: isPlaying ? 'Pause' : 'Play',
      child: IconButton(
        icon: Icon(
          isPlaying ? Symbols.pause : Symbols.play_arrow,
          fill: 1,
          size: 32,
        ),
        color: colorScheme.primary,
        onPressed: () {
          final controller = ref.read(audioPlayerControllerProvider.notifier);
          if (isPlaying) {
            controller.pause();
          } else {
            controller.resume();
          }
        },
      ),
    );
  }
}
