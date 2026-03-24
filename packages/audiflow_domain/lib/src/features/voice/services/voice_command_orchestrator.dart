import 'dart:async';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../models/voice_recognition_state.dart';
import '../repositories/speech_recognition_repository.dart';
import '../repositories/speech_recognition_repository_impl.dart';
import 'play_podcast_by_name_service.dart';
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

  bool _isInitialized = false;
  Completer<void>? _listeningCompleter;

  @override
  VoiceRecognitionState build() {
    _speechRepository = ref.watch(speechRecognitionRepositoryProvider);
    _playPodcastService = ref.watch(playPodcastByNameServiceProvider);
    _executor = ref.watch(voiceCommandExecutorProvider);
    _logger = ref.watch(namedLoggerProvider('VoiceOrchestrator'));

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

  Future<void> _processTranscription(String transcription) async {
    _logger?.i('Processing transcription: "$transcription"');
    state = VoiceRecognitionState.processing(transcription: transcription);

    try {
      // Ensure AI is initialized before parsing
      if (!AudiflowAi.instance.isInitialized) {
        _logger?.i('AI not initialized, attempting initialization');
        await AudiflowAi.instance.initialize();
      }

      // Parse the voice command using AI
      final command = await AudiflowAi.instance.parseVoiceCommand(
        transcription: transcription,
      );

      _logger?.i(
        'Parsed command: ${command.intent} with ${command.parameters}',
      );

      // Execute the command
      await _executeCommand(command);
    } on AudiflowAiException catch (e) {
      _logger?.e('AI parsing failed', error: e);
      // Fallback to simple pattern matching
      _logger?.i('Trying fallback parser for: "$transcription"');
      final fallbackCommand = _parseSimpleCommand(transcription);
      if (fallbackCommand != null) {
        _logger?.i('Using fallback command: ${fallbackCommand.intent}');
        await _executeCommand(fallbackCommand);
      } else {
        _logger?.w('Fallback parser could not understand: "$transcription"');
        state = VoiceRecognitionState.error(
          message: 'Could not understand: "$transcription"',
        );
      }
    } catch (e) {
      _logger?.e('Unexpected error processing command', error: e);
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
          // Full implementation handled by Task 9 (VoiceCommandExecutor extension).
          // Placeholder: surface an error until the executor is wired up.
          state = const VoiceRecognitionState.error(
            message: 'Settings change not yet supported',
          );
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

  Future<void> _handlePlayCommand(VoiceCommand command) async {
    final podcastName = command.parameters['podcastName'];

    if (podcastName == null || podcastName.isEmpty) {
      state = const VoiceRecognitionState.error(
        message: 'Please specify a podcast name',
      );
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
    if (state is VoiceSuccess || state is VoiceError) {
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

    // Try play command
    final playResult = _tryParsePlayCommand(text, lower, transcription);
    if (playResult != null) return playResult;

    // Try pause command
    if (_isPauseCommand(text, lower)) {
      return VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Try search command
    return _tryParseSearchCommand(text, lower, transcription);
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

  bool _isPauseCommand(String text, String lower) {
    // English
    if (lower == 'pause' || lower == 'stop' || lower == 'pause playback') {
      return true;
    }
    // Japanese
    const japanesePauseKeywords = ['一時停止', '停止', 'ストップ', 'ポーズ'];
    return japanesePauseKeywords.any(text.contains);
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
