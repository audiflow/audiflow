import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';

/// A compact player widget displayed at the bottom of the screen.
///
/// Binds playback state to [MiniPlayerCard]: artwork, title, podcast
/// name, skip-forward and play/pause buttons, and the bottom-edge
/// progress line. Tapping the card expands to the full player screen.
class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key, this.onTap});

  /// Callback when the mini player is tapped.
  final VoidCallback? onTap;

  /// Computes progress from saved position when live progress is unavailable.
  static double _savedProgress(NowPlayingInfo info) {
    final saved = info.savedPosition;
    final total = info.totalDuration;
    if (saved == null || total == null || total == Duration.zero) return 0.0;
    return saved.inMilliseconds / total.inMilliseconds;
  }

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer> {
  bool _isSeeking = false;
  bool _wasPlayingBeforeSeek = false;

  Future<void> _handleSkipForward() async {
    // Re-entrancy guard: ignore rapid taps while a seek is in flight
    if (_isSeeking) return;

    final isPlaying =
        ref.read(audioPlayerControllerProvider) is PlaybackPlaying;
    setState(() {
      _isSeeking = true;
      _wasPlayingBeforeSeek = isPlaying;
    });
    try {
      await ref.read(audioPlayerControllerProvider.notifier).skipForward();
      // Allow player state to stabilize after seek
      await Future<void>.delayed(const Duration(milliseconds: 150));
    } finally {
      if (mounted) {
        setState(() => _isSeeking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    final playbackState = ref.watch(audioPlayerControllerProvider);
    final progress = ref.watch(playbackProgressProvider);

    if (nowPlaying == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = _isSeeking
        ? _wasPlayingBeforeSeek
        : playbackState is PlaybackPlaying;
    final isLoading = _isSeeking ? false : playbackState is PlaybackLoading;

    return MiniPlayerCard(
      semanticLabel: l10n.playerNowPlayingLabel(
        nowPlaying.episodeTitle,
        nowPlaying.podcastTitle,
      ),
      onTap: widget.onTap,
      artwork: MiniPlayerArtwork(
        imageUrl: nowPlaying.artworkUrl,
        size: MiniPlayerCard.artworkSize,
        borderRadius: 0,
      ),
      title: nowPlaying.episodeTitle,
      subtitle: nowPlaying.podcastTitle,
      progress: progress?.progress ?? MiniPlayer._savedProgress(nowPlaying),
      actions: [
        _MiniPlayerSkipForwardButton(onPressed: _handleSkipForward),
        _MiniPlayerPlayPauseButton(isPlaying: isPlaying, isLoading: isLoading),
      ],
    );
  }
}

class _MiniPlayerSkipForwardButton extends ConsumerWidget {
  const _MiniPlayerSkipForwardButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsRepo = ref.watch(appSettingsRepositoryProvider);
    final skipSeconds = settingsRepo.getSkipForwardSeconds();

    return Semantics(
      button: true,
      label: l10n.playerForwardLabel(skipSeconds),
      child: IconButton(
        color: AppColors.of(context).ink,
        icon: SkipDurationIcon(seconds: skipSeconds, isForward: true, size: 24),
        onPressed: onPressed,
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
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    if (isLoading) {
      return Semantics(
        label: l10n.playerLoadingLabel,
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
      label: isPlaying ? l10n.playerPauseLabel : l10n.playerPlayLabel,
      child: IconButton(
        icon: Icon(
          isPlaying ? Symbols.pause : Symbols.play_arrow,
          fill: 1,
          size: 32,
        ),
        color: colors.ink,
        onPressed: () {
          final controller = ref.read(audioPlayerControllerProvider.notifier);
          if (isPlaying) {
            controller.pause();
          } else {
            final nowPlaying = ref.read(nowPlayingControllerProvider);
            controller.togglePlayPause(nowPlaying?.episodeUrl);
          }
        },
      ),
    );
  }
}
