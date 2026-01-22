import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Full player screen placeholder.
///
/// This screen will be expanded with full playback controls, seek bar,
/// episode details, and other features in a future update.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final progress = ref.watch(playbackProgressProvider);

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Now Playing'),
      ),
      body: nowPlaying == null
          ? const Center(child: Text('No audio playing'))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    // Artwork
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: nowPlaying.artworkUrl != null
                            ? Image.network(
                                nowPlaying.artworkUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(colorScheme),
                              )
                            : _buildPlaceholder(colorScheme),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      nowPlaying.episodeTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Podcast name
                    Text(
                      nowPlaying.podcastTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 32),
                    // Progress bar
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: progress?.progress ?? 0.0,
                            onChanged: (_) {
                              // Seek functionality - placeholder
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(progress?.position),
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                _formatDuration(progress?.duration),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Symbols.replay_30),
                          iconSize: 36,
                          onPressed: () {
                            // Rewind 30s - placeholder
                          },
                        ),
                        const SizedBox(width: 24),
                        _buildPlayPauseButton(
                          context,
                          ref,
                          isPlaying: isPlaying,
                          isLoading: isLoading,
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          icon: const Icon(Symbols.forward_30),
                          iconSize: 36,
                          onPressed: () {
                            // Forward 30s - placeholder
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Symbols.podcasts,
        color: colorScheme.onSurfaceVariant,
        size: 100,
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
        width: 64,
        height: 64,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }

    return IconButton.filled(
      icon: Icon(isPlaying ? Symbols.pause : Symbols.play_arrow, fill: 1),
      iconSize: 40,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(64, 64),
      ),
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

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (60 <= duration.inMinutes) {
      final hours = duration.inHours;
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
