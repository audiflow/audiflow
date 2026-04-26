import 'dart:async';
import 'dart:typed_data';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../settings/providers/settings_providers.dart';
import '../models/voice_recognition_state.dart';
import '../repositories/voice_audio_recorder.dart';
import 'gemma_voice_command_route.dart';
import 'gemma_voice_providers.dart';
import 'play_podcast_by_name_service.dart';
import 'settings_intent_resolver.dart';
import 'settings_metadata_registry.dart';
import 'settings_snapshot_service.dart';
import 'voice_command_executor.dart';
import 'voice_debug_info_notifier.dart';

part 'voice_command_orchestrator.g.dart';

/// Hard cap on a single utterance. Matches the Gemma audio token budget
/// (25 tokens/sec, ~750 against the chat session's 1024-token cap).
const Duration _maxRecordingDuration = Duration(seconds: 30);

/// Orchestrates the on-device Gemma 4 voice command flow.
///
/// Hold-to-talk state machine:
/// `idle -> listening (mic open) -> processing (Gemma) -> executing
/// (executor) -> success | error | settingsXxx -> idle`
///
/// Settings change states (`settingsAutoApplied`, `settingsDisambiguation`,
/// `settingsLowConfidence`) are emitted from the executing transition when
/// the parsed command is `changeSettings`; the UI then calls back into
/// [confirmSettingsChange] / [undoSettingsChange] /
/// [selectSettingsCandidate] to resolve.
@Riverpod(keepAlive: true)
class VoiceCommandOrchestrator extends _$VoiceCommandOrchestrator {
  late VoiceAudioRecorder _recorder;
  late GemmaVoiceCommandRoute _route;
  late VoiceCommandExecutor _executor;
  late PlayPodcastByNameService _playPodcast;
  late SettingsIntentResolver _settingsResolver;
  late SettingsMetadataRegistry _settingsRegistry;
  Logger? _logger;

  Timer? _autoStopTimer;

  /// Bumped on every cancel and on every fresh start so async continuations
  /// can detect "the session I belong to was cancelled" after each await.
  int _epoch = 0;

  /// Synchronously latched at the top of [stop] so the manual-release vs
  /// 30s-timer race can't double-stop the recorder.
  bool _stopping = false;

  /// Synchronously latched while a [start] is in flight so two concurrent
  /// start calls can't both reach `_recorder.start()` (the second would hit
  /// the recorder's re-entry StateError, an Error subtype that escapes our
  /// `on Exception` catch).
  bool _starting = false;

  @override
  VoiceRecognitionState build() {
    _recorder = ref.watch(voiceAudioRecorderProvider);
    _route = ref.watch(gemmaVoiceCommandRouteProvider);
    _executor = ref.watch(voiceCommandExecutorProvider);
    _playPodcast = ref.watch(playPodcastByNameServiceProvider);
    _logger = ref.watch(namedLoggerProvider('VoiceOrchestrator'));

    final registry = SettingsMetadataRegistry();
    _settingsRegistry = registry;
    _settingsResolver = SettingsIntentResolver(registry);

    ref.onDispose(() {
      _autoStopTimer?.cancel();
      _autoStopTimer = null;
    });

    return const VoiceRecognitionState.idle();
  }

  /// Begin recording. No-op while already in a non-terminal state or while
  /// another start is in flight.
  Future<void> startVoiceCommand() async {
    if (_starting ||
        (state is! VoiceIdle &&
            state is! VoiceSuccess &&
            state is! VoiceError)) {
      _logger?.d(
        'startVoiceCommand: skipping (starting=$_starting, '
        'state=${state.runtimeType})',
      );
      return;
    }
    _starting = true;
    final epoch = ++_epoch;
    _logger?.i('startVoiceCommand: epoch=$epoch, checking permission');
    try {
      if (!await _recorder.hasPermission()) {
        _logger?.w('startVoiceCommand: microphone permission denied');
        if (_epoch == epoch) {
          state = const VoiceRecognitionState.error(
            message: 'Microphone permission denied',
          );
        }
        return;
      }
      _logger?.i('startVoiceCommand: permission OK, starting recorder');
      try {
        await _recorder.start();
      } on Exception catch (e, st) {
        _logger?.e('recorder.start() failed', error: e, stackTrace: st);
        if (_epoch == epoch) {
          state = const VoiceRecognitionState.error(
            message: 'Microphone unavailable',
          );
        }
        return;
      }
      if (_epoch != epoch) {
        _logger?.w('startVoiceCommand: cancelled mid-start, tearing down');
        try {
          await _recorder.cancel();
        } on Exception catch (e, st) {
          _logger?.w(
            'recorder.cancel() during start-cancel race failed',
            error: e,
            stackTrace: st,
          );
        }
        return;
      }
      _stopping = false;
      _autoStopTimer = Timer(_maxRecordingDuration, () {
        _logger?.w('startVoiceCommand: 30s cap reached, auto-stopping');
        unawaited(stopVoiceCommand());
      });
      state = const VoiceRecognitionState.listening();
      _logger?.i('startVoiceCommand: now listening (epoch=$epoch)');
    } finally {
      _starting = false;
    }
  }

  /// Stop recording, dispatch to Gemma, and execute the resulting command.
  Future<void> stopVoiceCommand() async {
    // Synchronous claim: manual release and the 30s timer can both call
    // stop() in the same microtask; only the first one proceeds.
    if (state is! VoiceListening || _stopping) {
      _logger?.d(
        'stopVoiceCommand: skipping (state=${state.runtimeType}, '
        'stopping=$_stopping)',
      );
      return;
    }
    _stopping = true;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    final epoch = _epoch;
    _logger?.i('stopVoiceCommand: stopping recorder (epoch=$epoch)');

    final Uint8List audio;
    try {
      audio = await _recorder.stop();
    } on Exception catch (e, st) {
      _logger?.e('recorder.stop() failed', error: e, stackTrace: st);
      if (_epoch == epoch) {
        state = const VoiceRecognitionState.error(
          message: 'Failed to capture audio',
        );
      }
      return;
    }
    _logger?.i('stopVoiceCommand: captured ${audio.length}B audio');
    if (_epoch != epoch) {
      _logger?.d(
        'stopVoiceCommand epoch mismatch; dropping ${audio.length}B audio',
      );
      return;
    }

    state = const VoiceRecognitionState.processing(transcription: '');
    _logger?.i('stopVoiceCommand: dispatching to Gemma');

    final VoiceCommand command;
    final dispatchStart = DateTime.now();
    try {
      command = await _route.dispatch(audio);
    } on Exception catch (e, st) {
      _logger?.e('Gemma route.dispatch() failed', error: e, stackTrace: st);
      if (_epoch == epoch) {
        state = const VoiceRecognitionState.error(
          message: 'Voice processing failed',
        );
      }
      return;
    }
    final dispatchMs = DateTime.now().difference(dispatchStart).inMilliseconds;
    _logger?.i(
      'stopVoiceCommand: Gemma returned intent=${command.intent.name} '
      'in ${dispatchMs}ms',
    );
    if (_epoch != epoch) {
      _logger?.d('stopVoiceCommand: epoch mismatch after dispatch, dropping');
      return;
    }

    await _executeCommand(command, epoch);
  }

  /// Cancel any in-flight recording / dispatch and return to idle.
  Future<void> cancelVoiceCommand() async {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    _epoch += 1;
    final wasListening = state is VoiceListening;
    _transitionToIdle();
    if (!wasListening) {
      return;
    }
    try {
      await _recorder.cancel();
    } on Exception catch (e, st) {
      _logger?.w('recorder.cancel() failed', error: e, stackTrace: st);
    }
  }

  /// Reset state to idle. Bumps the epoch so any in-flight async work that
  /// belongs to the previous session can't overwrite the new state.
  void resetToIdle() {
    _epoch += 1;
    _transitionToIdle();
  }

  void _transitionToIdle() {
    // Clear the stop latch unconditionally — every terminal transition
    // ends a session, so a stale `_stopping = true` left over from a
    // cancel-during-stop race must not block the next start.
    _stopping = false;
    state = const VoiceRecognitionState.idle();
    ref.read(voiceDebugInfoProvider.notifier).reset();
  }

  /// Confirm a low-confidence settings change and apply it.
  Future<void> confirmSettingsChange(String key, String value) async {
    _logger?.i('Confirming settings change: $key = $value');
    try {
      final result = await _applySetting(key: key, value: value);
      if (!result.isSuccess) {
        state = VoiceRecognitionState.error(
          message: result.errorMessage ?? 'Failed to apply setting',
        );
        return;
      }
      final metadata = _settingsResolver.registry.findByKey(key);
      state = VoiceRecognitionState.settingsAutoApplied(
        key: key,
        displayNameKey: metadata?.displayNameKey ?? key,
        oldValue: result.previousValue ?? '',
        newValue: value,
      );
      unawaited(_resetToIdleAfterDelay());
    } on Exception catch (e, st) {
      _logger?.e('confirmSettingsChange failed', error: e, stackTrace: st);
      state = const VoiceRecognitionState.error(
        message: 'Failed to apply setting',
      );
    }
  }

  /// Revert a previously applied setting to [previousValue].
  Future<void> undoSettingsChange(String key, String previousValue) async {
    _logger?.i('Undoing settings change: $key -> $previousValue');
    try {
      final result = await _applySetting(key: key, value: previousValue);
      if (!result.isSuccess) {
        state = VoiceRecognitionState.error(
          message: result.errorMessage ?? 'Failed to undo setting',
        );
        return;
      }
      _transitionToIdle();
    } on Exception catch (e, st) {
      _logger?.e('undoSettingsChange failed', error: e, stackTrace: st);
      state = const VoiceRecognitionState.error(
        message: 'Failed to undo setting',
      );
    }
  }

  /// Apply a candidate selected from a disambiguation prompt.
  Future<void> selectSettingsCandidate(
    SettingsResolutionCandidate candidate,
  ) async {
    _logger?.i(
      'Selecting settings candidate: ${candidate.key} = ${candidate.newValue}',
    );

    if (candidate.newValue.isEmpty) {
      state = const VoiceRecognitionState.error(
        message: 'No value resolved for this setting',
      );
      return;
    }

    try {
      final result = await _applySetting(
        key: candidate.key,
        value: candidate.newValue,
      );
      if (!result.isSuccess) {
        state = VoiceRecognitionState.error(
          message: result.errorMessage ?? 'Failed to apply setting',
        );
        return;
      }
      final metadata = _settingsResolver.registry.findByKey(candidate.key);
      state = VoiceRecognitionState.settingsAutoApplied(
        key: candidate.key,
        displayNameKey: metadata?.displayNameKey ?? candidate.key,
        oldValue: result.previousValue ?? '',
        newValue: candidate.newValue,
      );
      unawaited(_resetToIdleAfterDelay());
    } on Exception catch (e, st) {
      _logger?.e('selectSettingsCandidate failed', error: e, stackTrace: st);
      state = const VoiceRecognitionState.error(
        message: 'Failed to apply setting',
      );
    }
  }

  Future<void> _executeCommand(VoiceCommand command, int epoch) async {
    ref.read(voiceDebugInfoProvider.notifier).setLastCommand(command);
    state = VoiceRecognitionState.executing(command: command);
    try {
      switch (command.intent) {
        case VoiceIntent.play:
          await _handlePlayCommand(command, epoch);
        case VoiceIntent.pause:
          await _executor.pause();
          state = const VoiceRecognitionState.success(message: 'Paused');
        case VoiceIntent.stop:
          await _executor.stop();
          state = const VoiceRecognitionState.success(message: 'Stopped');
        case VoiceIntent.search:
          // Search navigation is handled by the UI layer reacting to the
          // success state with a query parameter.
          final query = command.parameters['query'] ?? '';
          state = VoiceRecognitionState.success(
            message: 'Searching for "$query"',
          );
        case VoiceIntent.skipForward:
          await _executor.skipForward();
          state = const VoiceRecognitionState.success(
            message: 'Skipping forward',
          );
        case VoiceIntent.skipBackward:
          await _executor.skipBackward();
          state = const VoiceRecognitionState.success(
            message: 'Skipping backward',
          );
        case VoiceIntent.goToLibrary:
          state = const VoiceRecognitionState.success(
            message: 'Opening library',
          );
        case VoiceIntent.goToQueue:
          state = const VoiceRecognitionState.success(message: 'Opening queue');
        case VoiceIntent.openSettings:
          state = const VoiceRecognitionState.success(
            message: 'Opening settings',
          );
        case VoiceIntent.addToQueue:
          // addToQueue requires episode context from the UI layer.
          state = const VoiceRecognitionState.success(
            message: 'Added to queue',
          );
        case VoiceIntent.removeFromQueue:
          // removeFromQueue requires queue item ID from the UI layer.
          state = const VoiceRecognitionState.success(
            message: 'Removed from queue',
          );
        case VoiceIntent.clearQueue:
          await _executor.clearQueue();
          state = const VoiceRecognitionState.success(message: 'Queue cleared');
        case VoiceIntent.seek:
          final seconds = int.tryParse(command.parameters['seconds'] ?? '');
          if (seconds != null) {
            await _executor.seek(Duration(seconds: seconds));
          }
          state = const VoiceRecognitionState.success(message: 'Seeking');
        case VoiceIntent.changeSettings:
          await _handleChangeSettings(command, epoch);
        case VoiceIntent.unknown:
          state = VoiceRecognitionState.error(
            message: _unknownMessageFor(command),
          );
      }
    } on Exception catch (e, st) {
      _logger?.e('Failed to execute command', error: e, stackTrace: st);
      if (_epoch == epoch) {
        state = VoiceRecognitionState.error(message: 'Failed to execute: $e');
      }
      return;
    }

    if (_epoch == epoch) {
      unawaited(_resetToIdleAfterDelay());
    }
  }

  String _unknownMessageFor(VoiceCommand command) {
    return switch (command.failureReason) {
      VoiceCommandFailureReason.unrecognizedTool =>
        'Could not understand that command',
      VoiceCommandFailureReason.malformedPayload =>
        'Could not understand that command',
      VoiceCommandFailureReason.noCommandRecognized => "I didn't catch that",
      VoiceCommandFailureReason.inferenceError => 'Voice processing failed',
      null => 'Could not understand that command',
    };
  }

  Future<void> _handleChangeSettings(VoiceCommand command, int epoch) async {
    final payload = command.settingsPayload;
    if (payload == null) {
      // Gemma classified the turn as changeSettings but emitted no
      // structured payload — treat as inference failure.
      state = const VoiceRecognitionState.error(
        message: 'Could not understand the settings change',
      );
      return;
    }

    // Build the current values map from a fresh snapshot service so we see
    // post-applySetting state if a previous turn just landed.
    final snapshotService = SettingsSnapshotService(
      registry: _settingsRegistry,
      settingsRepository: ref.read(appSettingsRepositoryProvider),
    );
    final currentValues = <String, String>{};
    for (final metadata in _settingsResolver.registry.allSettings) {
      currentValues[metadata.key] = snapshotService.getCurrentValue(
        metadata.key,
      );
    }

    final resolution = _settingsResolver.resolve(
      payload,
      currentValues: currentValues,
    );

    switch (resolution) {
      case SettingsResolutionAutoApply(
        :final key,
        :final oldValue,
        :final newValue,
      ):
        final result = await _applySetting(key: key, value: newValue);
        if (_epoch != epoch) return;
        if (!result.isSuccess) {
          state = VoiceRecognitionState.error(
            message: result.errorMessage ?? 'Failed to apply setting',
          );
          return;
        }
        final metadata = _settingsResolver.registry.findByKey(key);
        state = VoiceRecognitionState.settingsAutoApplied(
          key: key,
          displayNameKey: metadata?.displayNameKey ?? key,
          oldValue: oldValue,
          newValue: newValue,
        );

      case SettingsResolutionConfirm(
        :final key,
        :final oldValue,
        :final newValue,
        :final confidence,
      ):
        final metadata = _settingsResolver.registry.findByKey(key);
        state = VoiceRecognitionState.settingsLowConfidence(
          key: key,
          displayNameKey: metadata?.displayNameKey ?? key,
          oldValue: oldValue,
          newValue: newValue,
          confidence: confidence,
        );
      // No auto-dismiss: UI must call confirmSettingsChange or resetToIdle.

      case SettingsResolutionDisambiguate(:final candidates):
        state = VoiceRecognitionState.settingsDisambiguation(
          candidates: candidates,
        );
      // No auto-dismiss: UI must call selectSettingsCandidate or resetToIdle.

      case SettingsResolutionNotFound():
        state = const VoiceRecognitionState.error(
          message: 'Could not find a matching setting',
        );
    }
  }

  Future<void> _handlePlayCommand(VoiceCommand command, int epoch) async {
    final podcastName = command.parameters['podcastName'];
    if (podcastName == null || podcastName.isEmpty) {
      // Bare "play" — resume current playback.
      await _executor.resume();
      if (_epoch != epoch) return;
      state = const VoiceRecognitionState.success(message: 'Resuming playback');
      return;
    }
    _logger?.i('Playing latest episode of: $podcastName');
    try {
      await _playPodcast.playLatestEpisode(podcastName);
      if (_epoch != epoch) return;
      state = VoiceRecognitionState.success(
        message: 'Playing latest episode of "$podcastName"',
      );
    } on Exception catch (e, st) {
      _logger?.e('Failed to play podcast', error: e, stackTrace: st);
      if (_epoch != epoch) return;
      state = VoiceRecognitionState.error(
        message: 'Could not find or play "$podcastName"',
      );
    }
  }

  /// Apply a setting and invalidate the settings provider so open settings
  /// screens rebuild with the new value. Safe because [build] uses
  /// `ref.read` (not `watch`) for the settings repository.
  Future<SettingApplyResult> _applySetting({
    required String key,
    required String value,
  }) async {
    final result = await _executor.applySetting(key: key, value: value);
    if (result.isSuccess) {
      ref.invalidate(appSettingsRepositoryProvider);
    }
    return result;
  }

  Future<void> _resetToIdleAfterDelay() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (state is VoiceSuccess ||
        state is VoiceError ||
        state is VoiceSettingsAutoApplied) {
      _transitionToIdle();
    }
  }
}
