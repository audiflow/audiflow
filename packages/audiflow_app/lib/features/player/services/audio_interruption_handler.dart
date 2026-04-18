import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:audiflow_core/audiflow_core.dart';

/// Structured diagnostic sink for interruption-handler decision points.
///
/// Kept as a plain callback so the class stays free of any telemetry SDK
/// dependency (mirrors `FeedSyncDiagnosticSink`). The app layer wires
/// this to Sentry breadcrumbs / captureMessage.
///
/// [event] is a stable identifier (e.g. `player.interruption:begin-entry`).
/// [data] must hold JSON-friendly values (String, num, bool, null, or
/// nested Maps/Lists of the same).
typedef PlaybackInterruptionDiagnosticSink =
    void Function(String event, Map<String, Object?> data);

void _noopDiagnosticSink(String event, Map<String, Object?> data) {}

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
    PlaybackInterruptionDiagnosticSink onDiagnostic = _noopDiagnosticSink,
  }) : _readDuckBehavior = readDuckBehavior,
       _isPlaying = isPlaying,
       _currentPosition = currentPosition,
       _seek = seek,
       _pause = pause,
       _resume = resume,
       _setVolume = setVolume,
       _rewindBeforePause = rewindBeforePause,
       _duckedVolume = duckedVolume,
       _fullVolume = fullVolume,
       _onDiagnostic = onDiagnostic;

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
  final PlaybackInterruptionDiagnosticSink _onDiagnostic;

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
    final entryIsPlaying = _isPlaying();
    final behavior = _readDuckBehavior();
    _onDiagnostic('player.interruption:begin-entry', {
      'type': type.name,
      'isPlaying': entryIsPlaying,
      'behavior': behavior.name,
      'committedAction': _committedAction?.name,
    });

    // Reentrancy / duplicate-event guard: if a previous begin is still
    // active (awaiting its end), ignore the new one. The committed-state
    // mutation below happens synchronously before any `await`, so this
    // check is sufficient on Dart's single-threaded event loop.
    if (_committedAction != null) {
      _onDiagnostic('player.interruption:begin-skip-reentrant', {
        'type': type.name,
        'committedAction': _committedAction?.name,
      });
      return;
    }

    final treatAsDuck =
        type == AudioInterruptionType.duck &&
        behavior == DuckInterruptionBehavior.duck;

    // Only act on an active interruption if the player was actually
    // playing. If the user had manually paused, we must not touch
    // volume (duck path) or commit any action that onEnd would undo.
    if (!entryIsPlaying) {
      _onDiagnostic('player.interruption:begin-skip-not-playing', {
        'type': type.name,
        'treatAsDuck': treatAsDuck,
      });
      return;
    }

    if (treatAsDuck) {
      _committedAction = _DuckAction.ducked;
      await _setVolume(_duckedVolume);
      _onDiagnostic('player.interruption:begin-ducked', {
        'duckedVolume': _duckedVolume,
      });
      return;
    }

    _committedAction = _DuckAction.paused;
    _onDiagnostic('player.interruption:begin-pausing', {
      'type': type.name,
      'rewindMs': _rewindBeforePause.inMilliseconds,
      'positionMs': _currentPosition().inMilliseconds,
    });
    try {
      await _rewindBeforePauseSafely();
      await _pause();
      _onDiagnostic('player.interruption:begin-paused', {
        'isPlayingAfter': _isPlaying(),
      });
    } catch (e, stack) {
      _onDiagnostic('player.interruption:begin-pause-failed', {
        'error': e.toString(),
        'stack': stack.toString(),
      });
      rethrow;
    }
  }

  /// Called when an interruption ends. Drives behavior off the action
  /// recorded at [onBegin] (not the current preference or event type),
  /// so a pref toggle or mismatched end-type cannot strand the player
  /// in a ducked or forever-flagged state.
  Future<void> onEnd(AudioInterruptionType type) async {
    final action = _committedAction;
    _onDiagnostic('player.interruption:end-entry', {
      'type': type.name,
      'committedAction': action?.name,
      'isPlaying': _isPlaying(),
    });
    if (action == null) return;
    // Clear before side-effects so a subsequent begin (if it races in
    // after our await) observes a clean slate.
    _committedAction = null;

    switch (action) {
      case _DuckAction.ducked:
        await _setVolume(_fullVolume);
        _onDiagnostic('player.interruption:end-volume-restored', {});
      case _DuckAction.paused:
        if (type == AudioInterruptionType.unknown) {
          // "Unknown" end events are not reliably actionable; clear
          // state but do not auto-resume.
          _onDiagnostic('player.interruption:end-unknown-no-resume', {});
          return;
        }
        await _resume();
        _onDiagnostic('player.interruption:end-resumed', {});
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
