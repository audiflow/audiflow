// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'channel/audiflow_ai_channel.dart';
import 'exceptions/audiflow_ai_exception.dart';
import 'models/ai_capability.dart';
import 'models/ai_response.dart';
import 'models/episode_summary.dart';
import 'models/generation_config.dart';
import 'models/summarization_config.dart';
import 'models/voice_command.dart';
import 'services/summarization_service.dart';
import 'services/text_generation_service.dart';
import 'services/voice_command_service.dart';

/// Progress callback for long-running AI operations.
///
/// [progress] is a value between 0.0 and 1.0.
typedef AiProgressCallback = void Function(double progress);

/// Token for cancelling long-running AI operations.
///
/// Create a [CancellationToken] and pass it to operations that support
/// cancellation. Call [cancel] to request cancellation.
class CancellationToken {
  /// Creates a new [CancellationToken].
  CancellationToken();

  /// A token that is never cancelled.
  ///
  /// Use this when you need a token but don't need cancellation support.
  static final CancellationToken none = _NoneCancellationToken();

  final List<VoidCallback> _listeners = [];
  bool _isCancelled = false;

  /// Whether cancellation has been requested.
  bool get isCancelled => _isCancelled;

  /// Request cancellation of the associated operation.
  void cancel() {
    if (_isCancelled) {
      return;
    }
    _isCancelled = true;
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Add a listener that is called when cancellation is requested.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a previously added listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}

/// A cancellation token that is never cancelled.
class _NoneCancellationToken extends CancellationToken {
  @override
  bool get isCancelled => false;

  @override
  void cancel() {
    // No-op: none token cannot be cancelled
  }
}

/// Main entry point for on-device AI features.
///
/// Uses singleton pattern for testability via dependency injection.
/// Access the singleton instance via [AudiflowAi.instance] or create
/// a custom instance for testing.
abstract class AudiflowAi {
  /// Singleton instance for production use.
  static AudiflowAi get instance => _instance ??= AudiflowAiImpl();
  static AudiflowAi? _instance;

  /// Get the current test instance (for testing verification).
  @visibleForTesting
  static AudiflowAi? get testInstance => _instance;

  /// Replace singleton instance (for testing).
  @visibleForTesting
  static set testInstance(AudiflowAi? instance) => _instance = instance;

  /// Reset to default instance.
  @visibleForTesting
  static void resetInstance() => _instance = null;

  /// Current initialization state.
  bool get isInitialized;

  /// Check device AI capability.
  Future<AiCapability> checkCapability();

  /// Initialize AI engine with optional custom instructions.
  ///
  /// Throws [AiNotAvailableException] if the device doesn't support AI.
  /// Throws [AiCoreRequiredException] if AICore is not installed (Android).
  Future<void> initialize({String? systemInstructions});

  /// Reinitialize with new configuration.
  Future<void> reinitialize({String? systemInstructions});

  /// Generate text from prompt.
  ///
  /// Throws [AiNotInitializedException] if not initialized.
  /// Throws [PromptTooLongException] if prompt exceeds model limit.
  /// Throws [AiGenerationException] on generation failure.
  Future<AiResponse> generateText({
    required String prompt,
    GenerationConfig? config,
  });

  /// Summarize arbitrary text.
  ///
  /// [onProgress] receives hybrid progress updates:
  /// - Chunk-based progress at boundaries (e.g., 20%, 40%, 60%)
  /// - Native-layer progress within chunks if available (smoother updates)
  ///
  /// Throws [AiNotInitializedException] if not initialized.
  /// Throws [AiSummarizationException] on summarization failure.
  Future<String> summarize({
    required String text,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  });

  /// Summarize podcast episode with context.
  ///
  /// [onProgress] receives hybrid progress updates:
  /// - Chunk-based progress at boundaries (e.g., 20%, 40%, 60%)
  /// - Native-layer progress within chunks if available (smoother updates)
  ///
  /// Throws [AiNotInitializedException] if not initialized.
  /// Throws [InsufficientContentException] if content is empty.
  Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  });

  /// Parse voice command transcription.
  ///
  /// Throws [AiNotInitializedException] if not initialized.
  Future<VoiceCommand> parseVoiceCommand({required String transcription});

  /// Open AICore install page (Android only).
  ///
  /// Returns true if the install page was opened successfully.
  Future<bool> promptAiCoreInstall();

  /// Release native resources.
  Future<void> dispose();

  /// Replace singleton instance (for testing).
  ///
  /// Prefer using [testInstance] setter instead.
  @visibleForTesting
  // ignore: use_setters_to_change_properties
  static void setInstance(AudiflowAi instance) => _instance = instance;
}

/// Default implementation of [AudiflowAi].
///
/// Coordinates all AI services and manages the platform channel.
class AudiflowAiImpl implements AudiflowAi {
  /// Creates an [AudiflowAiImpl] with default services.
  AudiflowAiImpl()
    : _textGenerationService = TextGenerationService(),
      _summarizationService = null,
      _voiceCommandService = null;

  /// Creates an [AudiflowAiImpl] with injected services for testing.
  @visibleForTesting
  AudiflowAiImpl.withServices({
    required TextGenerationService textGenerationService,
    required SummarizationService summarizationService,
    required VoiceCommandService voiceCommandService,
  }) : _textGenerationService = textGenerationService,
       _summarizationService = summarizationService,
       _voiceCommandService = voiceCommandService;

  final TextGenerationService _textGenerationService;
  SummarizationService? _summarizationService;
  VoiceCommandService? _voiceCommandService;

  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  /// Lazily initialize summarization service.
  SummarizationService get _summarization =>
      _summarizationService ??= SummarizationService(
        textGenerationService: _textGenerationService,
      );

  /// Lazily initialize voice command service.
  VoiceCommandService get _voiceCommand =>
      _voiceCommandService ??= VoiceCommandService(
        textGenerationService: _textGenerationService,
      );

  @override
  Future<AiCapability> checkCapability() async {
    try {
      final result = await AudiflowAiChannel.channel
          .invokeMethod<Map<dynamic, dynamic>>(
            AudiflowAiChannel.checkCapability,
          );
      final status = result?[AudiflowAiChannel.kStatus] as String?;
      return _mapStatusToCapability(status);
    } on MissingPluginException {
      // Native plugin not available (e.g., running in test environment)
      return AiCapability.unavailable;
    }
  }

  @override
  Future<void> initialize({String? systemInstructions}) async {
    final capability = await checkCapability();

    if (capability == AiCapability.unavailable) {
      throw AiNotAvailableException();
    }

    if (capability == AiCapability.needsSetup) {
      throw AiCoreRequiredException();
    }

    // Delegate to text generation service which handles platform channel
    await _textGenerationService.initialize(
      systemInstructions: systemInstructions,
    );

    _isInitialized = true;
  }

  @override
  Future<void> reinitialize({String? systemInstructions}) async {
    _isInitialized = false;
    await initialize(systemInstructions: systemInstructions);
  }

  @override
  Future<AiResponse> generateText({
    required String prompt,
    GenerationConfig? config,
  }) {
    _ensureInitialized();
    return _textGenerationService.generateText(prompt: prompt, config: config);
  }

  @override
  Future<String> summarize({
    required String text,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) {
    _ensureInitialized();
    return _summarization.summarize(
      text: text,
      config: config ?? const SummarizationConfig(),
      onProgress: onProgress,
    );
  }

  @override
  Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) {
    _ensureInitialized();
    return _summarization.summarizeEpisode(
      title: title,
      description: description,
      transcript: transcript,
      config: config ?? const SummarizationConfig(),
      onProgress: onProgress,
    );
  }

  @override
  Future<VoiceCommand> parseVoiceCommand({
    required String transcription,
  }) {
    _ensureInitialized();
    return _voiceCommand.parseCommand(transcription);
  }

  @override
  Future<bool> promptAiCoreInstall() async {
    try {
      final result = await AudiflowAiChannel.channel.invokeMethod<bool>(
        AudiflowAiChannel.promptAiCoreInstall,
      );
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    // Dispose text generation service
    await _textGenerationService.dispose();

    // Dispose platform channel resources
    try {
      await AudiflowAiChannel.channel.invokeMethod<void>(
        AudiflowAiChannel.dispose,
      );
    } on MissingPluginException {
      // Ignore - native plugin not available
    }

    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw AiNotInitializedException();
    }
  }

  AiCapability _mapStatusToCapability(String? status) {
    return switch (status) {
      AudiflowAiChannel.kStatusFull => AiCapability.full,
      AudiflowAiChannel.kStatusLimited => AiCapability.limited,
      AudiflowAiChannel.kStatusNeedsSetup => AiCapability.needsSetup,
      _ => AiCapability.unavailable,
    };
  }
}
