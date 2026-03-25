import 'dart:async';
import 'dart:convert';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../settings/providers/settings_providers.dart';
import '../models/voice_recognition_state.dart';
import '../repositories/speech_recognition_repository.dart';
import '../repositories/speech_recognition_repository_impl.dart';
import 'play_podcast_by_name_service.dart';
import 'settings_intent_resolver.dart';
import 'settings_metadata_registry.dart';
import 'settings_snapshot_service.dart';
import 'voice_command_executor.dart';

part 'voice_command_orchestrator.g.dart';

/// Orchestrates voice command flow from speech recognition to execution.
///
/// Manages the state machine:
/// idle -> listening -> processing -> executing -> success/error -> idle
///
/// Usage:
/// ```dart
/// final state = ref.watch(voiceCommandOrchestratorProvider);
/// final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
/// await orchestrator.startVoiceCommand();
/// ```
@Riverpod(keepAlive: true)
class VoiceCommandOrchestrator extends _$VoiceCommandOrchestrator {
  late SpeechRecognitionRepository _speechRepository;
  late PlayPodcastByNameService _playPodcastService;
  late VoiceCommandExecutor _executor;
  late Logger? _logger;
  late SettingsIntentResolver _settingsResolver;
  late SettingsMetadataRegistry _settingsRegistry;

  bool _isInitialized = false;
  Completer<void>? _listeningCompleter;

  @override
  VoiceRecognitionState build() {
    _speechRepository = ref.watch(speechRecognitionRepositoryProvider);
    _playPodcastService = ref.watch(playPodcastByNameServiceProvider);
    _executor = ref.watch(voiceCommandExecutorProvider);
    _logger = ref.watch(namedLoggerProvider('VoiceOrchestrator'));

    _settingsRegistry = SettingsMetadataRegistry();
    _settingsResolver = SettingsIntentResolver(_settingsRegistry);

    // Reset initialization flag — dependencies may be new instances
    _isInitialized = false;

    ref.onDispose(_cleanup);

    return const VoiceRecognitionState.idle();
  }

  /// Initialize the voice command system.
  ///
  /// Returns true if initialization succeeded.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _logger?.i('Initializing voice command system');

    // Initialize speech recognition
    final speechAvailable = await _speechRepository.initialize();
    if (!speechAvailable) {
      _logger?.w('Speech recognition not available');
      state = const VoiceRecognitionState.error(
        message: 'Speech recognition is not available on this device',
      );
      return false;
    }

    // Initialize AI for voice command parsing
    try {
      if (!AudiflowAi.instance.isInitialized) {
        _logger?.i('Initializing AudiflowAi for voice commands');
        await AudiflowAi.instance.initialize();
      }
    } on AudiflowAiException catch (e) {
      _logger?.w(
        'AI initialization failed: $e - voice commands will have limited functionality',
      );
      // Continue anyway - we can still do basic pattern matching
    }

    _isInitialized = true;
    _logger?.i('Voice command system initialized');
    return true;
  }

  /// Start listening for a voice command.
  ///
  /// Transitions through the state machine and returns when complete.
  Future<void> startVoiceCommand() async {
    // Ensure initialized
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    // Don't start if already listening
    if (state is VoiceListening) {
      _logger?.w('Already listening for voice command');
      return;
    }

    _logger?.i('Starting voice command');
    state = const VoiceRecognitionState.listening();

    _listeningCompleter = Completer<void>();
    String? finalTranscription;

    final started = await _speechRepository.startListening(
      onResult: (text, isFinal) {
        if (isFinal) {
          finalTranscription = text;
          _listeningCompleter?.complete();
        } else {
          state = VoiceRecognitionState.listening(partialTranscript: text);
        }
      },
      onError: (error) {
        _logger?.e('Speech recognition error: $error');
        state = VoiceRecognitionState.error(message: error);
        _listeningCompleter?.complete();
      },
    );

    if (!started) {
      state = const VoiceRecognitionState.error(
        message: 'Failed to start listening',
      );
      return;
    }

    // Wait for result or error
    await _listeningCompleter?.future;
    _listeningCompleter = null;

    // Process transcription if we got one
    if (finalTranscription != null && finalTranscription!.isNotEmpty) {
      await _processTranscription(finalTranscription!);
    } else if (state is! VoiceError) {
      state = const VoiceRecognitionState.error(message: 'No speech detected');
    }

    // Auto-reset to idle after a delay
    await _resetToIdleAfterDelay();
  }

  /// Cancel the current voice command operation.
  Future<void> cancelVoiceCommand() async {
    _logger?.i('Cancelling voice command');
    await _speechRepository.cancelListening();
    _listeningCompleter?.complete();
    _listeningCompleter = null;
    state = const VoiceRecognitionState.idle();
  }

  /// Reset state to idle.
  void resetToIdle() {
    state = const VoiceRecognitionState.idle();
  }

  /// Confirms a pending low-confidence settings change and applies it.
  Future<void> confirmSettingsChange(String key, String value) async {
    _logger?.i('Confirming settings change: $key = $value');
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
  }

  /// Reverts a previously applied setting to [previousValue].
  Future<void> undoSettingsChange(String key, String previousValue) async {
    _logger?.i('Undoing settings change: $key -> $previousValue');
    final result = await _applySetting(key: key, value: previousValue);
    if (!result.isSuccess) {
      state = VoiceRecognitionState.error(
        message: result.errorMessage ?? 'Failed to undo setting',
      );
      return;
    }
    state = const VoiceRecognitionState.idle();
  }

  /// Applies the selected candidate from a disambiguation prompt.
  ///
  /// If the candidate has an empty value (key-only disambiguation), the
  /// setting cannot be applied and the user is shown an error.
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
  }

  Future<void> _processTranscription(String transcription) async {
    _logger?.i('Processing transcription: "$transcription"');
    state = VoiceRecognitionState.processing(transcription: transcription);

    // Try deterministic pattern matching first — fast, reliable for known
    // commands (play, pause, skip, navigate). Only fall through to AI for
    // commands the simple parser can't handle (settings changes, ambiguous).
    final simpleCommand = _parseSimpleCommand(transcription);
    if (simpleCommand != null) {
      _logger?.i('Simple parser matched: ${simpleCommand.intent}');
      await _executeCommand(simpleCommand);
      return;
    }

    // No simple match — try platform-native NLU for settings resolution first
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    final schemaJson = jsonEncode(
      _settingsResolver.registry.toJson(settingsRepo),
    );

    final platformResult = await AudiflowAi.instance.resolveSettingsIntent(
      transcription: transcription,
      settingsSchemaJson: schemaJson,
    );

    if (platformResult != null) {
      final action = platformResult['action'] as String? ?? 'not_found';
      if (action != 'not_found') {
        _logger?.i('Platform NLU resolved: $action');
        final payload = _buildPayloadFromPlatformResult(platformResult);
        if (payload != null) {
          final command = VoiceCommand(
            intent: VoiceIntent.changeSettings,
            parameters: const {},
            confidence:
                (platformResult['confidence'] as num?)?.toDouble() ?? 0.8,
            rawTranscription: transcription,
            settingsPayload: payload,
          );
          await _executeCommand(command);
          return;
        }
      }
    }

    // Platform couldn't resolve as settings — try on-device AI for other commands
    try {
      if (!AudiflowAi.instance.isInitialized) {
        _logger?.i('AI not initialized, attempting initialization');
        await AudiflowAi.instance.initialize();
      }
      final command = await AudiflowAi.instance
          .parseVoiceCommand(transcription: transcription)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('AI call timed out'),
          );
      _logger?.i('AI parsed command: ${command.intent}');
      await _executeCommand(command);
    } on AudiflowAiException catch (e) {
      _logger?.e('AI parsing failed', error: e);
      state = VoiceRecognitionState.error(
        message: 'Could not understand: "$transcription"',
      );
    } catch (e) {
      _logger?.e('Unexpected error', error: e);
      state = VoiceRecognitionState.error(
        message: 'Failed to process command: $e',
      );
    }
  }

  Future<void> _executeCommand(VoiceCommand command) async {
    state = VoiceRecognitionState.executing(command: command);

    try {
      switch (command.intent) {
        case VoiceIntent.play:
          await _handlePlayCommand(command);
        case VoiceIntent.pause:
          await _executor.pause();
          state = const VoiceRecognitionState.success(message: 'Paused');
        case VoiceIntent.stop:
          await _executor.stop();
          state = const VoiceRecognitionState.success(message: 'Stopped');
        case VoiceIntent.search:
          // Search navigation is handled by the UI layer
          // reacting to the success state with a query parameter.
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
          // Navigation intents are handled by the UI layer
          // reacting to the executing/success state.
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
          // addToQueue requires episode context from the UI layer
          state = const VoiceRecognitionState.success(
            message: 'Added to queue',
          );
        case VoiceIntent.removeFromQueue:
          // removeFromQueue requires queue item ID from the UI layer
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
          await _handleChangeSettings(command);
        case VoiceIntent.unknown:
          state = VoiceRecognitionState.error(
            message: 'Could not understand: "${command.rawTranscription}"',
          );
      }
    } catch (e) {
      _logger?.e('Failed to execute command', error: e);
      state = VoiceRecognitionState.error(message: 'Failed to execute: $e');
    }
  }

  Future<void> _handleChangeSettings(VoiceCommand command) async {
    // Create snapshot service on-demand with a fresh repository reference
    // to avoid stale data after _applySetting invalidates the provider.
    final snapshotService = SettingsSnapshotService(
      registry: _settingsRegistry,
      settingsRepository: ref.read(appSettingsRepositoryProvider),
    );

    // Build the current values map from the snapshot service
    final currentValues = <String, String>{};
    for (final metadata in _settingsResolver.registry.allSettings) {
      currentValues[metadata.key] = snapshotService.getCurrentValue(
        metadata.key,
      );
    }

    SettingsResolution? resolution;

    if (command.settingsPayload != null) {
      // Platform NLU produced a structured payload — resolve it directly.
      _logger?.i('Resolving settings from platform payload');
      resolution = _settingsResolver.resolve(
        command.settingsPayload!,
        currentValues: currentValues,
      );
    } else {
      // No structured payload from the platform channel — try Dart-side
      // keyword matching against the registry synonyms as a fallback.
      _logger?.i(
        'No platform payload; attempting Dart-side synonym resolution: '
        '"${command.rawTranscription}"',
      );
      resolution = _resolveFromTranscription(command.rawTranscription);
    }

    if (resolution == null) {
      state = VoiceRecognitionState.error(
        message: 'Could not match a setting: "${command.rawTranscription}"',
      );
      return;
    }

    switch (resolution) {
      case SettingsResolutionAutoApply(
        :final key,
        :final oldValue,
        :final newValue,
      ):
        final result = await _applySetting(key: key, value: newValue);
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
        unawaited(_resetToIdleAfterDelay());

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
      // No auto-dismiss: UI must call confirmSettingsChange or resetToIdle

      case SettingsResolutionDisambiguate(:final candidates):
        state = VoiceRecognitionState.settingsDisambiguation(
          candidates: candidates,
        );
      // No auto-dismiss: UI must call selectSettingsCandidate or resetToIdle

      case SettingsResolutionNotFound():
        state = const VoiceRecognitionState.error(
          message: 'Could not find a matching setting for that command',
        );
    }
  }

  Future<void> _handlePlayCommand(VoiceCommand command) async {
    final podcastName = command.parameters['podcastName'];

    // Bare "play" / "再生" without podcast name = resume current playback
    if (podcastName == null || podcastName.isEmpty) {
      await _executor.resume();
      state = const VoiceRecognitionState.success(message: 'Resuming playback');
      return;
    }

    _logger?.i('Playing latest episode of: $podcastName');

    try {
      await _playPodcastService.playLatestEpisode(podcastName);
      state = VoiceRecognitionState.success(
        message: 'Playing latest episode of "$podcastName"',
      );
    } catch (e) {
      _logger?.e('Failed to play podcast', error: e);
      state = VoiceRecognitionState.error(
        message: 'Could not find or play "$podcastName"',
      );
    }
  }

  Future<void> _resetToIdleAfterDelay() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (state is VoiceSuccess ||
        state is VoiceError ||
        state is VoiceSettingsAutoApplied) {
      state = const VoiceRecognitionState.idle();
    }
  }

  void _cleanup() {
    _listeningCompleter?.complete();
    _listeningCompleter = null;
  }

  /// Simple pattern-based command parser as fallback when AI is unavailable.
  VoiceCommand? _parseSimpleCommand(String transcription) {
    final text = transcription.trim();
    final lower = text.toLowerCase();

    // Try simple playback commands (bare "再生", "play")
    if (_isResumeCommand(text, lower)) {
      return VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Try play command with podcast name
    final playResult = _tryParsePlayCommand(text, lower, transcription);
    if (playResult != null) return playResult;

    // Try stop command (must check before pause — "stop" is distinct)
    if (_isStopCommand(text, lower)) {
      return VoiceCommand(
        intent: VoiceIntent.stop,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Try pause command
    if (_isPauseCommand(text, lower)) {
      return VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Try skip commands
    final skipResult = _tryParseSkipCommand(text, lower, transcription);
    if (skipResult != null) return skipResult;

    // Try navigation commands
    final navResult = _tryParseNavigationCommand(text, lower, transcription);
    if (navResult != null) return navResult;

    // Try search command
    return _tryParseSearchCommand(text, lower, transcription);
  }

  /// Dart-side fallback resolution using registry synonym matching.
  ///
  /// When the platform NLU is unavailable and the on-device AI classified the
  /// command as `changeSettings` without producing a structured payload, this
  /// method attempts to match the raw transcription against known setting
  /// synonyms. It can only identify *which* setting the user meant -- not the
  /// target value -- so it returns [SettingsResolution.notFound] to show an
  /// informative error rather than a dead-end disambiguation screen.
  SettingsResolution? _resolveFromTranscription(String transcription) {
    final matches = _settingsRegistry.findBySynonym(transcription);
    if (matches.isEmpty) return null;

    // Synonym matching identified one or more candidate settings but cannot
    // extract a target value from the raw transcription. Return notFound so
    // the caller shows a clear error rather than a disambiguation UI where
    // all candidates are disabled (empty values).
    _logger?.i(
      'Synonym match found ${matches.length} candidate(s) but no value; '
      'returning notFound',
    );
    return const SettingsResolution.notFound();
  }

  /// Constructs a [SettingsChangePayload] from a platform channel result map.
  ///
  /// Returns null when the action is unrecognised or required fields are absent.
  SettingsChangePayload? _buildPayloadFromPlatformResult(
    Map<String, dynamic> result,
  ) {
    final action = result['action'] as String?;
    final key = result['key'] as String?;

    return switch (action) {
      'absolute' => SettingsChangePayload.absolute(
        key: key ?? '',
        value: (result['value'] as String?) ?? '',
        confidence: (result['confidence'] as num?)?.toDouble() ?? 0.8,
      ),
      'relative' => switch (result['direction'] as String?) {
        'increase' => SettingsChangePayload.relative(
          key: key ?? '',
          direction: ChangeDirection.increase,
          magnitude: switch (result['magnitude'] as String?) {
            'medium' => ChangeMagnitude.medium,
            'large' => ChangeMagnitude.large,
            _ => ChangeMagnitude.small,
          },
          confidence: (result['confidence'] as num?)?.toDouble() ?? 0.8,
        ),
        'decrease' => SettingsChangePayload.relative(
          key: key ?? '',
          direction: ChangeDirection.decrease,
          magnitude: switch (result['magnitude'] as String?) {
            'medium' => ChangeMagnitude.medium,
            'large' => ChangeMagnitude.large,
            _ => ChangeMagnitude.small,
          },
          confidence: (result['confidence'] as num?)?.toDouble() ?? 0.8,
        ),
        // Unknown or missing direction -- treat as unrecognized payload
        _ => null,
      },
      'ambiguous' => SettingsChangePayload.ambiguous(
        candidates: ((result['candidates'] as List?) ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .map(
              (c) => SettingsCandidate(
                key: c['key'] as String? ?? '',
                value: c['value'] as String? ?? '',
                confidence: (c['confidence'] as num?)?.toDouble() ?? 0.5,
              ),
            )
            .toList(),
      ),
      _ => null,
    };
  }

  /// Applies a setting and invalidates the settings provider so open
  /// settings screens rebuild with the updated value.
  ///
  /// Safe because we use [ref.read] (not watch) for the settings repository
  /// in [build], so invalidation won't trigger an orchestrator rebuild loop.
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

  bool _isResumeCommand(String text, String lower) {
    const enResume = ['play', 'resume', 'start'];
    const jaResume = ['再生', '再生して', '再生する', 'プレイ'];
    // Exact match only — "再生速度" must NOT match
    return enResume.contains(lower) || jaResume.contains(text);
  }

  VoiceCommand? _tryParsePlayCommand(
    String text,
    String lower,
    String transcription,
  ) {
    // English patterns
    final playPatternsEn = [
      RegExp(
        r'^play\s+(?:the\s+)?(?:latest\s+)?(?:episode\s+)?(?:of\s+)?(.+)$',
        caseSensitive: false,
      ),
      RegExp(r'^play\s+(.+)$', caseSensitive: false),
    ];

    // Japanese patterns
    final playPatternsJa = [
      RegExp(r'^(.+?)の最新(?:話|エピソード)を再生(?:して)?$'),
      RegExp(r'^(.+?)を再生(?:して)?$'),
      RegExp(r'^(.+?)再生(?:して)?$'),
    ];

    // Try English patterns on lowercase text
    for (final pattern in playPatternsEn) {
      final name = _extractGroup(pattern, lower);
      if (name != null) {
        return _buildPlayCommand(name, transcription);
      }
    }

    // Try Japanese patterns on original text
    for (final pattern in playPatternsJa) {
      final name = _extractGroup(pattern, text);
      if (name != null) {
        return _buildPlayCommand(name, transcription);
      }
    }

    return null;
  }

  VoiceCommand _buildPlayCommand(String podcastName, String transcription) {
    return VoiceCommand(
      intent: VoiceIntent.play,
      parameters: {'podcastName': podcastName},
      confidence: 0.7,
      rawTranscription: transcription,
    );
  }

  bool _isStopCommand(String text, String lower) {
    const enStop = ['stop', 'stop playback'];
    const jaStop = ['停止', 'ストップ', '停止して'];
    return enStop.contains(lower) || jaStop.contains(text);
  }

  bool _isPauseCommand(String text, String lower) {
    const enPause = ['pause', 'pause playback'];
    const jaPause = ['一時停止', 'ポーズ', '止めて'];
    return enPause.contains(lower) || jaPause.contains(text);
  }

  VoiceCommand? _tryParseSkipCommand(
    String text,
    String lower,
    String transcription,
  ) {
    // Skip forward
    const enForward = ['skip', 'skip forward', 'next', 'forward'];
    const jaForward = ['スキップ', '早送り', '次へ', '先送り'];
    if (enForward.contains(lower) || jaForward.contains(text)) {
      return VoiceCommand(
        intent: VoiceIntent.skipForward,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Skip backward
    const enBackward = ['rewind', 'skip back', 'back', 'go back'];
    const jaBackward = ['巻き戻し', '巻き戻して', '戻して', '前へ'];
    if (enBackward.contains(lower) || jaBackward.contains(text)) {
      return VoiceCommand(
        intent: VoiceIntent.skipBackward,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    return null;
  }

  VoiceCommand? _tryParseNavigationCommand(
    String text,
    String lower,
    String transcription,
  ) {
    // Library
    const enLibrary = [
      'library',
      'go to library',
      'open library',
      'my library',
    ];
    const jaLibrary = ['ライブラリ', 'マイライブラリ'];
    if (enLibrary.contains(lower) || jaLibrary.contains(text)) {
      return VoiceCommand(
        intent: VoiceIntent.goToLibrary,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Queue
    const enQueue = ['queue', 'go to queue', 'open queue', 'show queue'];
    const jaQueue = ['キュー', '再生キュー', '待ち行列'];
    if (enQueue.contains(lower) || jaQueue.contains(text)) {
      return VoiceCommand(
        intent: VoiceIntent.goToQueue,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Settings
    const enSettings = [
      'settings',
      'go to settings',
      'open settings',
      'preferences',
    ];
    const jaSettings = ['設定', '設定を開く'];
    if (enSettings.contains(lower) || jaSettings.contains(text)) {
      return VoiceCommand(
        intent: VoiceIntent.openSettings,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    return null;
  }

  VoiceCommand? _tryParseSearchCommand(
    String text,
    String lower,
    String transcription,
  ) {
    // English pattern
    final searchMatchEn = RegExp(
      r'^search\s+(?:for\s+)?(.+)$',
      caseSensitive: false,
    ).firstMatch(lower);
    if (searchMatchEn != null) {
      final query = searchMatchEn.group(1)?.trim();
      if (query != null && query.isNotEmpty) {
        return _buildSearchCommand(query, transcription);
      }
    }

    // Japanese patterns
    final searchPatternsJa = [
      RegExp(r'^(.+?)を検索(?:して)?$'),
      RegExp(r'^(.+?)検索(?:して)?$'),
    ];

    for (final pattern in searchPatternsJa) {
      final query = _extractGroup(pattern, text);
      if (query != null) {
        return _buildSearchCommand(query, transcription);
      }
    }

    return null;
  }

  VoiceCommand _buildSearchCommand(String query, String transcription) {
    return VoiceCommand(
      intent: VoiceIntent.search,
      parameters: {'query': query},
      confidence: 0.8,
      rawTranscription: transcription,
    );
  }

  /// Extracts the first capture group from a pattern match.
  String? _extractGroup(RegExp pattern, String input) {
    final match = pattern.firstMatch(input);
    if (match == null) return null;
    final value = match.group(1)?.trim();
    return (value != null && value.isNotEmpty) ? value : null;
  }
}
