import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audiflow_core/audiflow_core.dart';

/// Pure-logic handler for audio-focus interruption events.
///
/// Owns the decision logic for how playback reacts to interruption
/// begin / end events (e.g. incoming notification sounds, phone calls):
///
/// * Lowers volume or pauses on `begin`, based on user preference for
///   the "duck" (transient) interruption type.
/// * Rewinds the track by a small amount immediately before an
///   interruption-driven pause so the listener does not miss content.
/// * Resumes playback on `end` **only** when this handler was the one
///   that paused it — never when the user had already paused manually.
///
/// All side-effects (pause, resume, seek, setVolume) are supplied as
/// callbacks so the class is unit-testable without a real `just_audio`
/// player or `audio_session`.
class AudioInterruptionHandler {
  AudioInterruptionHandler({
    required DuckInterruptionBehavior Function() readDuckBehavior,
    required bool Function() isPlaying,
    required Duration Function() currentPosition,
    required Future<void> Function(Duration) seek,
    required Future<void> Function() pause,
    required Future<void> Function() resume,
    required Future<void> Function(double) setVolume,
    Duration rewindBeforePause = const Duration(
      seconds: SettingsDefaults.interruptionRewindSeconds,
    ),
    double duckedVolume = 0.3,
    double fullVolume = 1.0,
  }) : _readDuckBehavior = readDuckBehavior,
       _isPlaying = isPlaying,
       _currentPosition = currentPosition,
       _seek = seek,
       _pause = pause,
       _resume = resume,
       _setVolume = setVolume,
       _rewindBeforePause = rewindBeforePause,
       _duckedVolume = duckedVolume,
       _fullVolume = fullVolume;

  final DuckInterruptionBehavior Function() _readDuckBehavior;
  final bool Function() _isPlaying;
  final Duration Function() _currentPosition;
  final Future<void> Function(Duration) _seek;
  final Future<void> Function() _pause;
  final Future<void> Function() _resume;
  final Future<void> Function(double) _setVolume;
  final Duration _rewindBeforePause;
  final double _duckedVolume;
  final double _fullVolume;

  /// True when playback was auto-paused by this handler and is awaiting
  /// an interruption-end event to resume. Exposed for diagnostics/tests.
  bool get playInterrupted => _committedAction == _DuckAction.paused;

  /// Action committed at the most recent [onBegin]. The recorded value
  /// drives the corresponding [onEnd] so a preference change mid-
  /// interruption or a mismatched end-event type cannot leave the
  /// player ducked forever or flag-stuck-set forever.
  _DuckAction? _committedAction;

  /// Called when an interruption begins (e.g. a notification sound starts
  /// playing on Android, or an incoming call on iOS).
  Future<void> onBegin(AudioInterruptionType type) async {
    // Reentrancy / duplicate-event guard: if a previous begin is still
    // active (awaiting its end), ignore the new one. The committed-state
    // mutation below happens synchronously before any `await`, so this
    // check is sufficient on Dart's single-threaded event loop.
    if (_committedAction != null) return;

    final behavior = _readDuckBehavior();
    final treatAsDuck =
        type == AudioInterruptionType.duck &&
        behavior == DuckInterruptionBehavior.duck;

    // Only act on an active interruption if the player was actually
    // playing. If the user had manually paused, we must not touch
    // volume (duck path) or commit any action that onEnd would undo.
    if (!_isPlaying()) return;

    if (treatAsDuck) {
      _committedAction = _DuckAction.ducked;
      await _setVolume(_duckedVolume);
      return;
    }

    _committedAction = _DuckAction.paused;
    await _rewindBeforePauseSafely();
    await _pause();
  }

  /// Called when an interruption ends. Drives behavior off the action
  /// recorded at [onBegin] (not the current preference or event type),
  /// so a pref toggle or mismatched end-type cannot strand the player
  /// in a ducked or forever-flagged state.
  Future<void> onEnd(AudioInterruptionType type) async {
    final action = _committedAction;
    if (action == null) return;
    // Clear before side-effects so a subsequent begin (if it races in
    // after our await) observes a clean slate.
    _committedAction = null;

    switch (action) {
      case _DuckAction.ducked:
        await _setVolume(_fullVolume);
      case _DuckAction.paused:
        if (type == AudioInterruptionType.unknown) {
          // "Unknown" end events are not reliably actionable; clear
          // state but do not auto-resume.
          return;
        }
        await _resume();
    }
  }

  Future<void> _rewindBeforePauseSafely() async {
    final current = _currentPosition();
    final target = current - _rewindBeforePause;
    final clamped = target < Duration.zero ? Duration.zero : target;
    await _seek(clamped);
  }
}

/// What the handler actually did at the most recent [onBegin]. The
/// committed action — not the current preference — determines what
/// [onEnd] needs to undo.
enum _DuckAction { ducked, paused }
