import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import 'audio_sheet.dart';
import 'sleep_timer_icon_button.dart';

/// A compact player widget displayed at the bottom of the screen.
///
/// Binds playback state to [MiniPlayerCard]: artwork, title, podcast
/// name, the action buttons, and the bottom-edge progress line. Tapping
/// the card expands to the full player screen.
///
/// Phones show skip-forward and play/pause. Tablets have room for the
/// full transport: speed, skip back, play/pause, skip forward, and sleep
/// timer.
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

  Future<void> _handleSkip(Future<void> Function() skip) async {
    // Re-entrancy guard: ignore rapid taps while a seek is in flight
    if (_isSeeking) return;

    final isPlaying =
        ref.read(audioPlayerControllerProvider) is PlaybackPlaying;
    setState(() {
      _isSeeking = true;
      _wasPlayingBeforeSeek = isPlaying;
    });
    try {
      await skip();
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
      actions: _actions(context, isPlaying: isPlaying, isLoading: isLoading),
    );
  }

  // Sheets opened from the trailing buttons rise on that side on tablets,
  // above the button that opened them.
  List<Widget> _actions(
    BuildContext context, {
    required bool isPlaying,
    required bool isLoading,
  }) {
    final controller = ref.read(audioPlayerControllerProvider.notifier);
    final playPause = _MiniPlayerPlayPauseButton(
      isPlaying: isPlaying,
      isLoading: isLoading,
    );
    final skipForward = _MiniPlayerSkipButton(
      isForward: true,
      onPressed: () => _handleSkip(controller.skipForward),
    );
    if (!DeviceUtils.isTablet(MediaQuery.sizeOf(context).shortestSide)) {
      return [skipForward, playPause];
    }
    return [
      const _MiniPlayerSpeedButton(),
      _MiniPlayerSkipButton(
        isForward: false,
        onPressed: () => _handleSkip(controller.skipBackward),
      ),
      playPause,
      skipForward,
      const SleepTimerIconButton(
        sheetAlignment: AlignmentDirectional.bottomEnd,
      ),
    ];
  }
}

class _MiniPlayerSkipButton extends ConsumerWidget {
  const _MiniPlayerSkipButton({
    required this.isForward,
    required this.onPressed,
  });

  final bool isForward;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsRepo = ref.watch(appSettingsRepositoryProvider);
    final skipSeconds = isForward
        ? settingsRepo.getSkipForwardSeconds()
        : settingsRepo.getSkipBackwardSeconds();

    return Semantics(
      button: true,
      label: isForward
          ? l10n.playerForwardLabel(skipSeconds)
          : l10n.playerRewindLabel(skipSeconds),
      child: IconButton(
        color: AppColors.of(context).ink,
        icon: SkipDurationIcon(
          seconds: skipSeconds,
          isForward: isForward,
          size: 24,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

/// Text-only speed label (e.g. "1.3x") that opens the Audio sheet; the
/// full player's icon variant is too wide for the mini player row.
class _MiniPlayerSpeedButton extends ConsumerWidget {
  const _MiniPlayerSpeedButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final label = PlaybackSpeedScale.label(ref.watch(nowPlayingSpeedProvider));
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: AppColors.of(context).ink),
      onPressed: () =>
          showAudioSheet(context, alignment: AlignmentDirectional.bottomEnd),
      child: Text(
        label,
        semanticsLabel: l10n.playerAudioButtonLabel(label),
        style: Theme.of(context).textTheme.labelLarge,
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
