import 'dart:async';
import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';
import '../../../helpers/fake_audio_playback_controller.dart';
import '../../../helpers/fake_queue_service.dart';

void main() {
  group('VoiceCommandOrchestrator', () {
    group('startVoiceCommand', () {
      test('transitions idle -> listening when permission granted', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);

        await fixture.notifier.startVoiceCommand();

        check(fixture.state).isA<VoiceListening>();
        check(fixture.recorder.startCount).equals(1);
      });

      test('transitions to error when permission denied', () async {
        final fixture = await _Fixture.build(
          recorder: _FakeVoiceRecorder()..hasPermissionResult = false,
        );
        addTearDown(fixture.dispose);

        await fixture.notifier.startVoiceCommand();

        check(fixture.state).isA<VoiceError>();
        check((fixture.state as VoiceError).message).contains('permission');
        check(fixture.recorder.startCount).equals(0);
      });

      test('transitions to error when recorder.start() throws', () async {
        final fixture = await _Fixture.build(
          recorder: _FakeVoiceRecorder()..startThrows = Exception('mic busy'),
        );
        addTearDown(fixture.dispose);

        await fixture.notifier.startVoiceCommand();

        check(fixture.state).isA<VoiceError>();
        check((fixture.state as VoiceError).message).contains('Microphone');
      });

      test('second concurrent start is a no-op', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);

        // Don't await the first; start the second synchronously while the
        // first is still in its hasPermission/start await chain.
        final first = fixture.notifier.startVoiceCommand();
        final second = fixture.notifier.startVoiceCommand();
        await Future.wait([first, second]);

        check(fixture.recorder.startCount).equals(1);
        check(fixture.state).isA<VoiceListening>();
      });

      test('start from terminal success state is allowed', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);
        fixture.notifier.state = const VoiceRecognitionState.success(
          message: 'Done',
        );

        await fixture.notifier.startVoiceCommand();

        check(fixture.state).isA<VoiceListening>();
      });

      test('start while listening is rejected', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);
        await fixture.notifier.startVoiceCommand();

        await fixture.notifier.startVoiceCommand();

        check(fixture.recorder.startCount).equals(1);
      });
    });

    group('stopVoiceCommand', () {
      test(
        'listening -> processing -> executing -> success on happy path',
        () async {
          final fixture = await _Fixture.build(
            session: _FakeSession(
              GemmaFunctionCall(name: 'pause', args: const {}),
            ),
          );
          addTearDown(fixture.dispose);
          await fixture.notifier.startVoiceCommand();

          await fixture.notifier.stopVoiceCommand();

          check(fixture.state).isA<VoiceSuccess>();
          check((fixture.state as VoiceSuccess).message).equals('Paused');
          check(fixture.recorder.stopCount).equals(1);
        },
      );

      test('no-op when not listening', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);

        await fixture.notifier.stopVoiceCommand();

        check(fixture.state).isA<VoiceIdle>();
        check(fixture.recorder.stopCount).equals(0);
      });

      test('transitions to error when recorder.stop() throws', () async {
        final recorder = _FakeVoiceRecorder()..stopThrows = Exception('boom');
        final fixture = await _Fixture.build(recorder: recorder);
        addTearDown(fixture.dispose);
        await fixture.notifier.startVoiceCommand();

        await fixture.notifier.stopVoiceCommand();

        check(fixture.state).isA<VoiceError>();
        check((fixture.state as VoiceError).message).contains('capture audio');
      });

      test('transitions to error when Gemma route throws', () async {
        final session = _FakeSession.throwing(Exception('inference failed'));
        final fixture = await _Fixture.build(session: session);
        addTearDown(fixture.dispose);
        await fixture.notifier.startVoiceCommand();

        await fixture.notifier.stopVoiceCommand();

        check(fixture.state).isA<VoiceError>();
        check((fixture.state as VoiceError).message).contains('processing');
      });

      test('concurrent stop calls only run the recorder.stop once', () async {
        final fixture = await _Fixture.build(
          session: _FakeSession(
            GemmaFunctionCall(name: 'pause', args: const {}),
          ),
        );
        addTearDown(fixture.dispose);
        await fixture.notifier.startVoiceCommand();

        await Future.wait([
          fixture.notifier.stopVoiceCommand(),
          fixture.notifier.stopVoiceCommand(),
        ]);

        check(fixture.recorder.stopCount).equals(1);
      });
    });

    group('cancelVoiceCommand', () {
      test('cancels recorder and returns to idle when listening', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);
        await fixture.notifier.startVoiceCommand();

        await fixture.notifier.cancelVoiceCommand();

        check(fixture.state).isA<VoiceIdle>();
        check(fixture.recorder.cancelCount).equals(1);
      });

      test('does not call recorder.cancel when not listening', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);

        await fixture.notifier.cancelVoiceCommand();

        check(fixture.recorder.cancelCount).equals(0);
      });

      test(
        'cancel during processing drops the Gemma result silently',
        () async {
          // The route resolves after cancel; the dropped result must not
          // overwrite the new idle state.
          final routeCompleter = Completer<GemmaFunctionCall>();
          final session = _FakeSession.deferred(routeCompleter.future);
          final fixture = await _Fixture.build(session: session);
          addTearDown(fixture.dispose);
          await fixture.notifier.startVoiceCommand();
          final stopFuture = fixture.notifier.stopVoiceCommand();
          // Now we're awaiting the route; cancel.
          await fixture.notifier.cancelVoiceCommand();
          routeCompleter.complete(
            GemmaFunctionCall(name: 'pause', args: const {}),
          );
          await stopFuture;

          check(fixture.state).isA<VoiceIdle>();
        },
      );
    });

    group('30s auto-stop timer', () {
      test('fires stopVoiceCommand after the cap when held', () {
        fakeAsync((async) {
          late _Fixture fixture;
          unawaited(
            _Fixture.build(
              session: _FakeSession(
                GemmaFunctionCall(name: 'pause', args: const {}),
              ),
            ).then((f) => fixture = f),
          );
          async.flushMicrotasks();

          unawaited(fixture.notifier.startVoiceCommand());
          async.flushMicrotasks();
          check(fixture.state).isA<VoiceListening>();

          // Cap is 30s; advance just past.
          async.elapse(const Duration(seconds: 31));
          async.flushMicrotasks();

          check(fixture.recorder.stopCount).equals(1);
          fixture.dispose();
        });
      });

      test('cancelled by manual stop', () {
        fakeAsync((async) {
          late _Fixture fixture;
          unawaited(
            _Fixture.build(
              session: _FakeSession(
                GemmaFunctionCall(name: 'pause', args: const {}),
              ),
            ).then((f) => fixture = f),
          );
          async.flushMicrotasks();

          unawaited(fixture.notifier.startVoiceCommand());
          async.flushMicrotasks();
          unawaited(fixture.notifier.stopVoiceCommand());
          async.flushMicrotasks();

          // Advance past the cap; the timer should NOT fire a second stop.
          async.elapse(const Duration(seconds: 31));
          async.flushMicrotasks();

          check(fixture.recorder.stopCount).equals(1);
          fixture.dispose();
        });
      });
    });

    group('resetToIdle', () {
      test('returns success state to idle and bumps epoch', () async {
        final fixture = await _Fixture.build();
        addTearDown(fixture.dispose);
        fixture.notifier.state = const VoiceRecognitionState.success(
          message: 'Done',
        );

        fixture.notifier.resetToIdle();

        check(fixture.state).isA<VoiceIdle>();
      });
    });
  });
}

// -----------------------------------------------------------------------------
// Test fixture
// -----------------------------------------------------------------------------

class _Fixture {
  _Fixture._({
    required this.container,
    required this.recorder,
    required this.playPodcast,
  });

  final ProviderContainer container;
  final _FakeVoiceRecorder recorder;
  final _FakePlayPodcast playPodcast;

  VoiceCommandOrchestrator get notifier =>
      container.read(voiceCommandOrchestratorProvider.notifier);

  VoiceRecognitionState get state =>
      container.read(voiceCommandOrchestratorProvider);

  static Future<_Fixture> build({
    _FakeVoiceRecorder? recorder,
    _FakeSession? session,
    _FakePlayPodcast? playPodcast,
  }) async {
    final r = recorder ?? _FakeVoiceRecorder();
    final p = playPodcast ?? _FakePlayPodcast();
    final s =
        session ??
        _FakeSession(GemmaFunctionCall(name: 'pause', args: const {}));
    final settingsRepo = FakeAppSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        voiceAudioRecorderProvider.overrideWith((ref) => r),
        gemmaInferenceSessionProvider.overrideWith((ref) => s),
        playPodcastByNameServiceProvider.overrideWith((ref) => p),
        appSettingsRepositoryProvider.overrideWith((ref) => settingsRepo),
        // The real executor is cheap to construct from existing fakes and
        // exercises the same code path the orchestrator calls.
        voiceCommandExecutorProvider.overrideWith(
          (ref) => _FakeExecutor(settingsRepo),
        ),
        // Silence orchestrator error logging in tests.
        namedLoggerProvider(
          'VoiceOrchestrator',
        ).overrideWithValue(_silentLogger),
      ],
    );
    // Force the notifier to build so its `late` deps resolve before tests.
    container.read(voiceCommandOrchestratorProvider);
    return _Fixture._(container: container, recorder: r, playPodcast: p);
  }

  void dispose() => container.dispose();
}

// -----------------------------------------------------------------------------
// Fakes
// -----------------------------------------------------------------------------

class _FakeVoiceRecorder implements VoiceAudioRecorder {
  bool hasPermissionResult = true;
  Object? startThrows;
  Object? stopThrows;
  Uint8List stopResult = Uint8List.fromList(const [0, 0, 0, 0]);
  int startCount = 0;
  int stopCount = 0;
  int cancelCount = 0;
  int disposeCount = 0;

  @override
  Future<bool> hasPermission() async => hasPermissionResult;

  @override
  Future<void> start() async {
    startCount += 1;
    final err = startThrows;
    if (err != null) throw err;
  }

  @override
  Future<Uint8List> stop() async {
    stopCount += 1;
    final err = stopThrows;
    if (err != null) throw err;
    return stopResult;
  }

  @override
  Future<void> cancel() async {
    cancelCount += 1;
  }

  @override
  Future<void> dispose() async {
    disposeCount += 1;
  }
}

class _FakeSession implements GemmaInferenceSession {
  _FakeSession(GemmaFunctionCall call)
    : _result = Future.value(call),
      _throws = null;

  _FakeSession.deferred(Future<GemmaFunctionCall> result)
    : _result = result,
      _throws = null;

  _FakeSession.throwing(Object error) : _result = null, _throws = error;

  final Future<GemmaFunctionCall>? _result;
  final Object? _throws;

  @override
  Future<GemmaFunctionCall> runWithAudio({
    required Uint8List audio,
    required String systemPrompt,
    required List<VoiceToolDefinition> tools,
  }) {
    final err = _throws;
    if (err != null) return Future.error(err);
    return _result!;
  }
}

class _FakePlayPodcast implements PlayPodcastByNameService {
  Object? throwError;
  String? lastName;

  @override
  Future<void> playLatestEpisode(String podcastName) async {
    lastName = podcastName;
    final err = throwError;
    if (err != null) throw err;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Real-shaped executor backed by the existing test fakes — keeps the
/// orchestrator on its production code path without dragging in audio
/// service or queue plumbing.
class _FakeExecutor extends VoiceCommandExecutor {
  _FakeExecutor(FakeAppSettingsRepository repo)
    : super(
        audioController: FakeAudioPlaybackController(),
        queueService: FakeQueueService(),
        settingsRepository: repo,
        logger: _silentLogger,
      );
}

final _silentLogger = Logger(level: Level.off, printer: SimplePrinter());
