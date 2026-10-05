import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'seek_undo_controller.g.dart';

/// Where playback was before a seek jump, offered back by the "Go back" pill.
final class SeekUndoState {
  const SeekUndoState({required this.origin, required this.episodeUrl});

  /// Position to return to.
  final Duration origin;

  /// Episode the origin belongs to; an origin is meaningless in another one.
  final String episodeUrl;
}

/// Offers a temporary undo for seek jumps made from the player screen.
///
/// Only deliberate jumps made in view of the artwork (seek bar release,
/// chapter pick) go through [seekWithUndo]; skip buttons, transcript taps,
/// and system controls seek directly, so they never show the pill. This is
/// a thin layer over [AudioPlayerController.seekNowPlaying] and leaves its
/// internals alone.
///
/// Kept alive so the origin and its timer survive the artwork being torn
/// down and rebuilt (e.g. a tab switch) within the visible window.
@Riverpod(keepAlive: true)
class SeekUndoController extends _$SeekUndoController {
  /// How long the pill stays up after the latest jump.
  static const visibleDuration = Duration(seconds: 10);

  Timer? _hideTimer;

  @override
  SeekUndoState? build() {
    // Saved-position updates on the same episode also fire this; only an
    // episode change clears the origin.
    ref.listen<NowPlayingInfo?>(
      nowPlayingControllerProvider,
      (_, info) => _dismissUnlessFor(info?.episodeUrl),
    );
    ref.onDispose(_cancelTimer);
    return null;
  }

  /// Seeks the now-playing episode to [target] and offers to undo it.
  ///
  /// A jump made while the pill is already up keeps the first origin, so
  /// "Go back" undoes the whole run of jumps, and restarts the timer.
  ///
  /// A seek the player rejects (throws) withdraws an offer it created, so
  /// the pill never offers to undo a jump that did not happen.
  Future<void> seekWithUndo(Duration target) async {
    final previous = state;
    _recordOrigin();
    try {
      await ref
          .read(audioPlayerControllerProvider.notifier)
          .seekNowPlaying(target);
    } on Object {
      // Only an offer this jump created is withdrawn; an earlier one still
      // describes a jump that happened.
      if (!identical(state, previous)) dismiss();
      rethrow;
    }
  }

  /// Seeks back to the recorded origin and hides the pill.
  ///
  /// If the player rejects the seek (throws), the pill comes back so the
  /// listener can retry.
  Future<void> goBack() async {
    final undo = state;
    if (undo == null) return;
    dismiss();
    // The listener normally clears a stale origin first; this guards the
    // gap before it runs.
    final episodeUrl = ref.read(nowPlayingControllerProvider)?.episodeUrl;
    if (episodeUrl != undo.episodeUrl) return;
    try {
      await ref
          .read(audioPlayerControllerProvider.notifier)
          .seekNowPlaying(undo.origin);
    } on Object {
      _offer(undo);
      rethrow;
    }
  }

  /// Hides the pill without seeking.
  void dismiss() {
    _cancelTimer();
    state = null;
  }

  void _recordOrigin() {
    final nowPlaying = ref.read(nowPlayingControllerProvider);
    if (nowPlaying == null) return;
    final current = state;
    if (current != null && current.episodeUrl == nowPlaying.episodeUrl) {
      return _offer(current);
    }
    final origin = _currentPosition(nowPlaying);
    if (origin == null) return;
    _offer(SeekUndoState(origin: origin, episodeUrl: nowPlaying.episodeUrl));
  }

  // Shows [undo] and (re)starts the countdown that hides it.
  void _offer(SeekUndoState undo) {
    _cancelTimer();
    state = undo;
    _hideTimer = Timer(visibleDuration, dismiss);
  }

  /// Mirrors the player screen: live progress while audio is loaded,
  /// otherwise the saved position a restored session shows.
  Duration? _currentPosition(NowPlayingInfo nowPlaying) {
    final live = ref.read(playbackProgressProvider);
    if (live != null && Duration.zero < live.duration) return live.position;
    return nowPlaying.savedPosition;
  }

  void _dismissUnlessFor(String? episodeUrl) {
    final undo = state;
    if (undo == null || undo.episodeUrl == episodeUrl) return;
    dismiss();
  }

  void _cancelTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }
}
