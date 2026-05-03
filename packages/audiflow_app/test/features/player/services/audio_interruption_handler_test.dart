import 'package:audio_session/audio_session.dart';
import 'package:audiflow_app/features/player/services/audio_interruption_handler.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records calls made against the handler's injected side-effects so
/// tests can assert on behavior instead of touching real audio APIs.
class _RecordingTarget {
  bool playing = false;
  Duration position = Duration.zero;
  DuckInterruptionBehavior behavior = DuckInterruptionBehavior.duck;

  final List<Duration> seekCalls = [];
  final List<double> volumeCalls = [];
  final List<({String event, Map<String, Object?> data})> diagnostics = [];
  int pauseCalls = 0;
  int resumeCalls = 0;
}

AudioInterruptionHandler _buildHandler(_RecordingTarget target) {
  return AudioInterruptionHandler(
    readDuckBehavior: () => target.behavior,
    isPlaying: () => target.playing,
    currentPosition: () => target.position,
    seek: (d) async {
      target.seekCalls.add(d);
    },
    pause: () async {
      target.pauseCalls++;
      target.playing = false;
    },
    resume: () async {
      target.resumeCalls++;
      target.playing = true;
    },
    setVolume: (v) async {
      target.volumeCalls.add(v);
    },
    onDiagnostic: (event, data) =>
        target.diagnostics.add((event: event, data: data)),
  );
}

void main() {
  group('AudioInterruptionHandler — unwanted-resume bug', () {
    test(
      'does NOT resume when player was already paused before interruption',
      () async {
        // Arrange: user had already paused manually.
        final t = _RecordingTarget()..playing = false;
        final handler = _buildHandler(t);

        // Act: a notification arrives (pause-type interruption).
        await handler.onBegin(AudioInterruptionType.pause);
        await handler.onEnd(AudioInterruptionType.pause);

        // Assert: no auto-resume, no spurious pause calls, nothing seeked.
        check(t.resumeCalls).equals(0);
        check(t.pauseCalls).equals(0);
        check(t.seekCalls).isEmpty();
        check(handler.playInterrupted).isFalse();
      },
    );

    test('does NOT resume when duck-ended even if originally paused', () async {
      final t = _RecordingTarget()..playing = false;
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);
      await handler.onEnd(AudioInterruptionType.duck);

      check(t.resumeCalls).equals(0);
      check(t.pauseCalls).equals(0);
    });
  });

  group('AudioInterruptionHandler — pause-type interruption while playing', () {
    test('rewinds 2 seconds and pauses on begin', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..position = const Duration(seconds: 42);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.pause);

      check(t.seekCalls).length.equals(1);
      check(t.seekCalls.single).equals(const Duration(seconds: 40));
      check(t.pauseCalls).equals(1);
      check(handler.playInterrupted).isTrue();
    });

    test('rewind is clamped to zero near the start of the track', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..position = const Duration(milliseconds: 500);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.pause);

      check(t.seekCalls).length.equals(1);
      check(t.seekCalls.single).equals(Duration.zero);
    });

    test('resumes on end when begun-while-playing', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..position = const Duration(seconds: 30);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.pause);
      check(t.playing).isFalse();
      check(handler.playInterrupted).isTrue();

      await handler.onEnd(AudioInterruptionType.pause);

      check(t.resumeCalls).equals(1);
      check(t.playing).isTrue();
      check(handler.playInterrupted).isFalse();
    });
  });

  group('AudioInterruptionHandler — duck behavior preference', () {
    test(
      'duck-mode + duck interruption: lowers then restores volume',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.duck
          ..position = const Duration(seconds: 10);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.duck);
        check(t.pauseCalls).equals(0);
        check(t.seekCalls).isEmpty();
        check(t.volumeCalls).length.equals(1);
        check(t.volumeCalls.first).isLessThan(1.0);

        await handler.onEnd(AudioInterruptionType.duck);
        check(t.volumeCalls).length.equals(2);
        check(t.volumeCalls.last).equals(1.0);
        check(t.resumeCalls).equals(0);
      },
    );

    test('pause-mode + duck interruption: rewinds, pauses, resumes', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..behavior = DuckInterruptionBehavior.pause
        ..position = const Duration(seconds: 10);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);

      check(t.seekCalls).length.equals(1);
      check(t.seekCalls.single).equals(const Duration(seconds: 8));
      check(t.pauseCalls).equals(1);
      check(t.volumeCalls).isEmpty();

      await handler.onEnd(AudioInterruptionType.duck);
      check(t.resumeCalls).equals(1);
    });
  });

  group('AudioInterruptionHandler — unknown interruption type on end', () {
    test(
      'resumes anyway (iOS strips shouldResume on long phone calls)',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..position = const Duration(seconds: 20);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.pause);
        check(handler.playInterrupted).isTrue();

        await handler.onEnd(AudioInterruptionType.unknown);

        check(t.resumeCalls).equals(1);
        check(handler.playInterrupted).isFalse();
      },
    );
  });

  group('AudioInterruptionHandler — duck interruption while paused', () {
    test('duck-begin while paused does not lower volume and does not commit '
        'an action (nothing to undo on end)', () async {
      final t = _RecordingTarget()
        ..playing = false
        ..behavior = DuckInterruptionBehavior.duck
        ..position = const Duration(seconds: 10);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);
      await handler.onEnd(AudioInterruptionType.duck);

      check(t.volumeCalls).isEmpty();
      check(t.pauseCalls).equals(0);
      check(t.resumeCalls).equals(0);
      check(handler.playInterrupted).isFalse();
    });
  });

  group('AudioInterruptionHandler — onEnd(unknown) while ducked', () {
    test(
      'restores full volume (unknown guard only gates the paused arm)',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.duck
          ..position = const Duration(seconds: 10);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.duck);
        check(t.volumeCalls).length.equals(1);

        await handler.onEnd(AudioInterruptionType.unknown);

        check(t.volumeCalls).length.equals(2);
        check(t.volumeCalls.last).equals(1.0);
        check(t.resumeCalls).equals(0);
      },
    );
  });

  group('AudioInterruptionHandler — reentrancy / duplicate events', () {
    test(
      'second onBegin before onEnd is a no-op (no double rewind/pause)',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..position = const Duration(seconds: 30);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.pause);
        // Simulate a duplicate begin (playing=false after first call).
        await handler.onBegin(AudioInterruptionType.pause);

        check(t.pauseCalls).equals(1);
        check(t.seekCalls).length.equals(1);
        check(handler.playInterrupted).isTrue();
      },
    );

    test('second onBegin while ducked is a no-op', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..behavior = DuckInterruptionBehavior.duck
        ..position = const Duration(seconds: 10);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);
      await handler.onBegin(AudioInterruptionType.duck);

      check(t.volumeCalls).length.equals(1);
      check(t.pauseCalls).equals(0);
    });

    test('onEnd without a prior active onBegin is a no-op', () async {
      final t = _RecordingTarget()..playing = true;
      final handler = _buildHandler(t);

      await handler.onEnd(AudioInterruptionType.pause);

      check(t.resumeCalls).equals(0);
      check(t.volumeCalls).isEmpty();
    });
  });

  group('AudioInterruptionHandler — preference changed mid-interruption', () {
    test('duck-begin committed as "ducked" → pref flips to pause → end still '
        'restores volume (no silent volume leak)', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..behavior = DuckInterruptionBehavior.duck
        ..position = const Duration(seconds: 10);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);
      check(t.volumeCalls).length.equals(1);

      // User toggles preference while the interruption is still active.
      t.behavior = DuckInterruptionBehavior.pause;

      await handler.onEnd(AudioInterruptionType.duck);

      // Must restore full volume regardless of the new preference,
      // and must NOT resume (duck-mode did not pause playback).
      check(t.volumeCalls).length.equals(2);
      check(t.volumeCalls.last).equals(1.0);
      check(t.resumeCalls).equals(0);
    });

    test('pause-begin committed as "paused" → pref flips to duck → end still '
        'resumes (no silent flag leak)', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..behavior = DuckInterruptionBehavior.pause
        ..position = const Duration(seconds: 30);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);
      check(handler.playInterrupted).isTrue();

      // User toggles preference while the interruption is still active.
      t.behavior = DuckInterruptionBehavior.duck;

      await handler.onEnd(AudioInterruptionType.duck);

      check(t.resumeCalls).equals(1);
      check(handler.playInterrupted).isFalse();
    });
  });

  group('AudioInterruptionHandler — mismatched begin/end types', () {
    test(
      'onBegin(pause) then onEnd(duck) resumes based on committed action',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.pause
          ..position = const Duration(seconds: 20);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.pause);
        check(handler.playInterrupted).isTrue();

        await handler.onEnd(AudioInterruptionType.duck);

        check(t.resumeCalls).equals(1);
        check(handler.playInterrupted).isFalse();
      },
    );

    test('onBegin(duck, duck-mode) then onEnd(pause) restores volume based on '
        'committed action', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..behavior = DuckInterruptionBehavior.duck
        ..position = const Duration(seconds: 10);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);
      check(t.volumeCalls).length.equals(1);

      await handler.onEnd(AudioInterruptionType.pause);

      check(t.volumeCalls).length.equals(2);
      check(t.volumeCalls.last).equals(1.0);
      check(t.resumeCalls).equals(0);
    });
  });

  group('AudioInterruptionHandler — diagnostic sink', () {
    test('emits begin-entry → begin-pausing → begin-paused on pause path '
        'and end-entry → end-resumed on resume path', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..behavior = DuckInterruptionBehavior.pause
        ..position = const Duration(seconds: 30);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.pause);
      await handler.onEnd(AudioInterruptionType.pause);

      final events = t.diagnostics.map((d) => d.event).toList();
      check(events).contains('player.interruption:begin-entry');
      check(events).contains('player.interruption:begin-pausing');
      check(events).contains('player.interruption:begin-paused');
      check(events).contains('player.interruption:end-entry');
      check(events).contains('player.interruption:end-resumed');

      final entry = t.diagnostics.firstWhere(
        (d) => d.event == 'player.interruption:begin-entry',
      );
      check(entry.data['type']).equals('pause');
      check(entry.data['isPlaying']).equals(true);
      check(entry.data['behavior']).equals('pause');

      final paused = t.diagnostics.firstWhere(
        (d) => d.event == 'player.interruption:begin-paused',
      );
      check(paused.data['isPlayingAfter']).equals(false);
    });

    test('emits begin-skip-not-playing when player was not playing', () async {
      final t = _RecordingTarget()..playing = false;
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.pause);

      final events = t.diagnostics.map((d) => d.event).toList();
      check(events).contains('player.interruption:begin-skip-not-playing');
    });

    test(
      'emits end-resumed even on unknown end type (long iOS call path)',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.pause
          ..position = const Duration(seconds: 30);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.pause);
        await handler.onEnd(AudioInterruptionType.unknown);

        final events = t.diagnostics.map((d) => d.event).toList();
        check(events).contains('player.interruption:end-resumed');
        check(
          events,
        ).not((it) => it.contains('player.interruption:end-unknown-no-resume'));
        final resumed = t.diagnostics.firstWhere(
          (d) => d.event == 'player.interruption:end-resumed',
        );
        check(resumed.data['type']).equals('unknown');
      },
    );
  });

  group('AudioInterruptionHandler — user override during interruption', () {
    test(
      'user pause during paused-interruption clears state, no resume on end',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.pause
          ..position = const Duration(seconds: 30);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.pause);
        check(handler.playInterrupted).isTrue();

        // User taps pause on the lock screen while the call is still active.
        handler.markUserOverride();
        check(handler.playInterrupted).isFalse();

        await handler.onEnd(AudioInterruptionType.pause);

        check(t.resumeCalls).equals(0);
      },
    );

    test(
      'user play during paused-interruption clears state, onEnd is no-op',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.pause
          ..position = const Duration(seconds: 30);
        final handler = _buildHandler(t);

        await handler.onBegin(AudioInterruptionType.pause);
        handler.markUserOverride();

        await handler.onEnd(AudioInterruptionType.unknown);

        // The handler must not duplicate the user's resume — it had already
        // released the committed pause, so this onEnd is a pure no-op.
        check(t.resumeCalls).equals(0);
      },
    );

    test('user override while ducked restores volume to full', () async {
      final t = _RecordingTarget()
        ..playing = true
        ..behavior = DuckInterruptionBehavior.duck
        ..position = const Duration(seconds: 10);
      final handler = _buildHandler(t);

      await handler.onBegin(AudioInterruptionType.duck);
      check(t.volumeCalls.last).equals(0.3);

      await handler.markUserOverride();

      check(t.volumeCalls.last).equals(1.0);

      // The end event arrives later — must be a no-op (no double restore).
      await handler.onEnd(AudioInterruptionType.duck);
      check(t.volumeCalls.length).equals(2);
    });

    test('user override with no committed action is a no-op', () async {
      final t = _RecordingTarget();
      final handler = _buildHandler(t);

      await handler.markUserOverride();

      check(t.volumeCalls).isEmpty();
      check(
        t.diagnostics.map((d) => d.event),
      ).not((it) => it.contains('player.interruption:user-override'));
    });

    test(
      'volume-restore failure surfaces a diagnostic and does not throw',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.duck
          ..position = const Duration(seconds: 10);
        final handler = AudioInterruptionHandler(
          readDuckBehavior: () => t.behavior,
          isPlaying: () => t.playing,
          currentPosition: () => t.position,
          seek: (d) async => t.seekCalls.add(d),
          pause: () async {
            t.pauseCalls++;
            t.playing = false;
          },
          resume: () async {
            t.resumeCalls++;
            t.playing = true;
          },
          setVolume: (v) async {
            t.volumeCalls.add(v);
            if (v == 1.0) throw StateError('platform-volume-failure');
          },
          onDiagnostic: (event, data) =>
              t.diagnostics.add((event: event, data: data)),
        );

        await handler.onBegin(AudioInterruptionType.duck);
        // The override must not throw even though setVolume(1.0) does.
        await handler.markUserOverride();

        final events = t.diagnostics.map((d) => d.event).toList();
        check(
          events,
        ).contains('player.interruption:user-override-volume-failed');
      },
    );
  });

  group('AudioInterruptionHandler — pause-arm failure', () {
    test(
      'seek failure clears _committedAction so onEnd does not force-resume',
      () async {
        final t = _RecordingTarget()
          ..playing = true
          ..behavior = DuckInterruptionBehavior.pause
          ..position = const Duration(seconds: 30);
        final handler = AudioInterruptionHandler(
          readDuckBehavior: () => t.behavior,
          isPlaying: () => t.playing,
          currentPosition: () => t.position,
          seek: (_) async => throw StateError('seek-unsupported'),
          pause: () async {
            t.pauseCalls++;
            t.playing = false;
          },
          resume: () async {
            t.resumeCalls++;
            t.playing = true;
          },
          setVolume: (v) async => t.volumeCalls.add(v),
          onDiagnostic: (event, data) =>
              t.diagnostics.add((event: event, data: data)),
        );

        // The seek inside `_rewindBeforePauseSafely` throws; onBegin
        // rethrows so the audio handler's catch can capture it.
        await check(
          handler.onBegin(AudioInterruptionType.pause),
        ).throws<StateError>();

        // Pause never landed; the previous half-armed bug would now
        // force-resume on the iOS `unknown` end notification. After
        // the fix, _committedAction is cleared on failure, so onEnd
        // is a clean no-op.
        check(handler.playInterrupted).isFalse();
        await handler.onEnd(AudioInterruptionType.unknown);
        check(t.resumeCalls).equals(0);

        final events = t.diagnostics.map((d) => d.event).toList();
        check(events).contains('player.interruption:begin-pause-failed');
      },
    );
  });
}
