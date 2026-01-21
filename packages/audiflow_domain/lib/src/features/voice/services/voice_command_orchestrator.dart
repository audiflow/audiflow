import 'dart:async';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../models/voice_recognition_state.dart';
import '../repositories/speech_recognition_repository.dart';
import '../repositories/speech_recognition_repository_impl.dart';
import 'play_podcast_by_name_service.dart';

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
  late final SpeechRecognitionRepository _speechRepository;
  late final PlayPodcastByNameService _playPodcastService;
  late final Logger? _logger;

  bool _isInitialized = false;
  Completer<void>? _listeningCompleter;

  @override
  VoiceRecognitionState build() {
    _speechRepository = ref.watch(speechRecognitionRepositoryProvider);
    _playPodcastService = ref.watch(playPodcastByNameServiceProvider);
    _logger = ref.watch(namedLoggerProvider('VoiceOrchestrator'));

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
          state = const VoiceRecognitionState.success(message: 'Paused');
        case VoiceIntent.stop:
          state = const VoiceRecognitionState.success(message: 'Stopped');
        case VoiceIntent.search:
          final query = command.parameters['query'] ?? '';
          state = VoiceRecognitionState.success(
            message: 'Searching for "$query"',
          );
        case VoiceIntent.skipForward:
          state = const VoiceRecognitionState.success(
            message: 'Skipping forward',
          );
        case VoiceIntent.skipBackward:
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
          state = const VoiceRecognitionState.success(
            message: 'Added to queue',
          );
        case VoiceIntent.removeFromQueue:
          state = const VoiceRecognitionState.success(
            message: 'Removed from queue',
          );
        case VoiceIntent.clearQueue:
          state = const VoiceRecognitionState.success(message: 'Queue cleared');
        case VoiceIntent.seek:
          state = const VoiceRecognitionState.success(message: 'Seeking');
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

    // === English patterns ===

    // Play commands: "play [podcast name]" or "play the latest episode of [name]"
    final playPatternsEn = [
      RegExp(
        r'^play\s+(?:the\s+)?(?:latest\s+)?(?:episode\s+)?(?:of\s+)?(.+)$',
        caseSensitive: false,
      ),
      RegExp(r'^play\s+(.+)$', caseSensitive: false),
    ];

    for (final pattern in playPatternsEn) {
      final match = pattern.firstMatch(lower);
      if (match != null) {
        final podcastName = match.group(1)?.trim();
        if (podcastName != null && podcastName.isNotEmpty) {
          return VoiceCommand(
            intent: VoiceIntent.play,
            parameters: {'podcastName': podcastName},
            confidence: 0.7,
            rawTranscription: transcription,
          );
        }
      }
    }

    // Pause command (English)
    if (lower == 'pause' || lower == 'stop' || lower == 'pause playback') {
      return VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Search command (English): "search for [query]"
    final searchMatchEn = RegExp(
      r'^search\s+(?:for\s+)?(.+)$',
      caseSensitive: false,
    ).firstMatch(lower);
    if (searchMatchEn != null) {
      final query = searchMatchEn.group(1)?.trim();
      if (query != null && query.isNotEmpty) {
        return VoiceCommand(
          intent: VoiceIntent.search,
          parameters: {'query': query},
          confidence: 0.8,
          rawTranscription: transcription,
        );
      }
    }

    // === Japanese patterns ===

    // Play commands: "[name]を再生", "[name]の最新話を再生して", etc.
    final playPatternsJa = [
      // "[name]の最新話を再生して" or "[name]の最新話を再生"
      RegExp(r'^(.+?)の最新(?:話|エピソード)を再生(?:して)?$'),
      // "[name]を再生して" or "[name]を再生"
      RegExp(r'^(.+?)を再生(?:して)?$'),
      // "[name]再生して" or "[name]再生"
      RegExp(r'^(.+?)再生(?:して)?$'),
    ];

    for (final pattern in playPatternsJa) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final podcastName = match.group(1)?.trim();
        if (podcastName != null && podcastName.isNotEmpty) {
          return VoiceCommand(
            intent: VoiceIntent.play,
            parameters: {'podcastName': podcastName},
            confidence: 0.7,
            rawTranscription: transcription,
          );
        }
      }
    }

    // Pause command (Japanese)
    if (text.contains('一時停止') ||
        text.contains('停止') ||
        text.contains('ストップ') ||
        text.contains('ポーズ')) {
      return VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: transcription,
      );
    }

    // Search command (Japanese): "[query]を検索", "[query]検索"
    final searchPatternsJa = [
      RegExp(r'^(.+?)を検索(?:して)?$'),
      RegExp(r'^(.+?)検索(?:して)?$'),
    ];

    for (final pattern in searchPatternsJa) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final query = match.group(1)?.trim();
        if (query != null && query.isNotEmpty) {
          return VoiceCommand(
            intent: VoiceIntent.search,
            parameters: {'query': query},
            confidence: 0.8,
            rawTranscription: transcription,
          );
        }
      }
    }

    return null;
  }
}
