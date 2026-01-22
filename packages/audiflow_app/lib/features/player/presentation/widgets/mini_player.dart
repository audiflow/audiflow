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

    return Material(
      elevation: 8,
      color: colorScheme.surfaceContainer,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              // Progress bar at top
              MiniPlayerProgressBar(
                progress: progress?.progress ?? 0.0,
                bufferedProgress: progress?.bufferedProgress ?? 0.0,
              ),
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  child: Row(
                    children: [
                      // Artwork
                      MiniPlayerArtwork(
                        imageUrl: nowPlaying.artworkUrl,
                        size: 48,
                      ),
                      const SizedBox(width: Spacing.sm),
                      // Title and podcast name
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nowPlaying.episodeTitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nowPlaying.podcastTitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play/Pause button
                      _buildPlayPauseButton(
                        context,
                        ref,
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
    );
  }

  Widget _buildPlayPauseButton(
    BuildContext context,
    WidgetRef ref, {
    required bool isPlaying,
    required bool isLoading,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

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
    );
  }
}
