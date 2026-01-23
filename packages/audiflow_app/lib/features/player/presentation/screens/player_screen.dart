import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Full player screen placeholder.
///
/// This screen will be expanded with full playback controls, seek bar,
/// episode details, and other features in a future update.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _isSeeking = false;
  bool _wasPlayingBeforeSeek = false;

  void _beginSeek(bool wasPlaying) {
    setState(() {
      _isSeeking = true;
      _wasPlayingBeforeSeek = wasPlaying;
    });
  }

  Future<void> _endSeek() async {
    // Allow player state to stabilize after seek
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _isSeeking = false);
  }

  @override
  Widget build(BuildContext context) {
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final progress = ref.watch(playbackProgressProvider);

    final isPlaying = playbackState is PlaybackPlaying;
    final isLoading = playbackState is PlaybackLoading;

    // During seeking, preserve the play/pause state from before seek started
    final displayIsPlaying = _isSeeking ? _wasPlayingBeforeSeek : isPlaying;
    final displayIsLoading = _isSeeking ? false : isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: 'Close player',
          child: IconButton(
            icon: const Icon(Symbols.keyboard_arrow_down),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
                    _PlayerArtwork(artworkUrl: nowPlaying.artworkUrl),
                    const SizedBox(height: 32),
                    _PlayerInfo(
                      episodeTitle: nowPlaying.episodeTitle,
                      podcastTitle: nowPlaying.podcastTitle,
                    ),
                    const SizedBox(height: 32),
                    _PlayerProgressBar(
                      progress: progress,
                      onSeekStart: () => _beginSeek(isPlaying),
                      onSeekEnd: _endSeek,
                    ),
                    const SizedBox(height: 24),
                    _PlayerControls(
                      isPlaying: displayIsPlaying,
                      isLoading: displayIsLoading,
                      onSkipBackward: () => _handleSkip(
                        ref
                            .read(audioPlayerControllerProvider.notifier)
                            .skipBackward,
                        isPlaying,
                      ),
                      onSkipForward: () => _handleSkip(
                        ref
                            .read(audioPlayerControllerProvider.notifier)
                            .skipForward,
                        isPlaying,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSkip(
    Future<void> Function() skipAction,
    bool wasPlaying,
  ) async {
    _beginSeek(wasPlaying);
    await skipAction();
    await _endSeek();
  }
}

class _PlayerArtwork extends StatelessWidget {
  const _PlayerArtwork({this.artworkUrl});

  final String? artworkUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      image: true,
      label: 'Episode artwork',
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: artworkUrl != null
              ? Image.network(
                  artworkUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _Placeholder(colorScheme: colorScheme),
                )
              : _Placeholder(colorScheme: colorScheme),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Symbols.podcasts,
        color: colorScheme.onSurfaceVariant,
        size: 100,
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({required this.episodeTitle, required this.podcastTitle});

  final String episodeTitle;
  final String podcastTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: '$episodeTitle by $podcastTitle',
      child: Column(
        children: [
          ExcludeSemantics(
            child: Text(
              episodeTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Text(
              podcastTitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerProgressBar extends ConsumerStatefulWidget {
  const _PlayerProgressBar({this.progress, this.onSeekStart, this.onSeekEnd});

  final PlaybackProgress? progress;
  final VoidCallback? onSeekStart;
  final Future<void> Function()? onSeekEnd;

  @override
  ConsumerState<_PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<_PlayerProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.progress;

    final displayValue = _isDragging ? _dragValue : (progress?.progress ?? 0.0);
    final displayPosition = _isDragging
        ? _computeDragPosition(progress?.duration)
        : progress?.position;

    return Semantics(
      slider: true,
      value:
          '${_formatDuration(displayPosition)} of ${_formatDuration(progress?.duration)}',
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: displayValue,
              onChangeStart: (value) {
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
                widget.onSeekStart?.call();
              },
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
              },
              onChangeEnd: (value) async {
                final duration = progress?.duration ?? Duration.zero;
                final seekPosition = Duration(
                  milliseconds: (duration.inMilliseconds * value).round(),
                );
                await ref
                    .read(audioPlayerControllerProvider.notifier)
                    .seek(seekPosition);
                // Parent handles stabilization delay via onSeekEnd
                await widget.onSeekEnd?.call();
                if (!mounted) return;
                setState(() => _isDragging = false);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ExcludeSemantics(
                  child: Text(
                    _formatDuration(displayPosition),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                ExcludeSemantics(
                  child: Text(
                    _formatDuration(progress?.duration),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Duration? _computeDragPosition(Duration? duration) {
    if (duration == null) return null;
    return Duration(
      milliseconds: (duration.inMilliseconds * _dragValue).round(),
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

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.isPlaying,
    required this.isLoading,
    required this.onSkipBackward,
    required this.onSkipForward,
  });

  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onSkipBackward;
  final VoidCallback onSkipForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          label: 'Rewind 30 seconds',
          child: IconButton(
            icon: const Icon(Symbols.replay_30),
            iconSize: 36,
            onPressed: onSkipBackward,
          ),
        ),
        const SizedBox(width: 24),
        _PlayerPlayPauseButton(isPlaying: isPlaying, isLoading: isLoading),
        const SizedBox(width: 24),
        Semantics(
          button: true,
          label: 'Forward 30 seconds',
          child: IconButton(
            icon: const Icon(Symbols.forward_30),
            iconSize: 36,
            onPressed: onSkipForward,
          ),
        ),
      ],
    );
  }
}

class _PlayerPlayPauseButton extends ConsumerWidget {
  const _PlayerPlayPauseButton({
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
          width: 64,
          height: 64,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: isPlaying ? 'Pause' : 'Play',
      child: IconButton.filled(
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
      ),
    );
  }
}
