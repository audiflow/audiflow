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

/// Progress callback for long-running AI operations.
///
/// [progress] is a value between 0.0 and 1.0.
typedef AiProgressCallback = void Function(double progress);

/// Main entry point for on-device AI features.
///
/// Uses singleton pattern for testability via dependency injection.
/// Access the singleton instance via [AudiflowAi.instance] or create
/// a custom instance for testing.
abstract class AudiflowAi {
  /// Singleton instance for production use.
  static AudiflowAi get instance => _instance ??= AudiflowAiImpl();
  static AudiflowAi? _instance;

  /// Replace singleton instance (for testing).
  @visibleForTesting
  static set testInstance(AudiflowAi instance) => _instance = instance;

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
  static void setInstance(AudiflowAi instance) => _instance = instance;
}

/// Default implementation of [AudiflowAi].
class AudiflowAiImpl implements AudiflowAi {
  /// Creates an [AudiflowAiImpl].
  AudiflowAiImpl();

  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

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

    try {
      await AudiflowAiChannel.channel.invokeMethod<Map<dynamic, dynamic>>(
        AudiflowAiChannel.initialize,
        {
          if (systemInstructions != null) 'instructions': systemInstructions,
        },
      );
      _isInitialized = true;
    } on PlatformException catch (e) {
      throw AiGenerationException('Failed to initialize: ${e.message}', e);
    }
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
  }) async {
    _ensureInitialized();

    try {
      final result = await AudiflowAiChannel.channel
          .invokeMethod<Map<dynamic, dynamic>>(
            AudiflowAiChannel.generateText,
            {
              'prompt': prompt,
              if (config != null) 'config': config.toMap(),
            },
          );

      return AiResponse(
        text: result?[AudiflowAiChannel.kText] as String? ?? '',
        tokenCount: result?[AudiflowAiChannel.kTokenCount] as int?,
        durationMs: result?[AudiflowAiChannel.kDurationMs] as int?,
      );
    } on PlatformException catch (e) {
      if (e.code == 'PROMPT_TOO_LONG') {
        throw PromptTooLongException(
          int.tryParse(e.details?.toString() ?? '') ?? 4000,
        );
      }
      throw AiGenerationException('Text generation failed: ${e.message}', e);
    }
  }

  @override
  Future<String> summarize({
    required String text,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) async {
    _ensureInitialized();

    // Stub implementation - will be implemented in Phase 2
    onProgress?.call(1);
    final response = await generateText(
      prompt: 'Summarize the following text:\n\n$text',
      config: const GenerationConfig(maxOutputTokens: 500),
    );
    return response.text;
  }

  @override
  Future<EpisodeSummary> summarizeEpisode({
    required String title,
    required String description,
    String? transcript,
    SummarizationConfig? config,
    AiProgressCallback? onProgress,
  }) async {
    _ensureInitialized();

    if (title.isEmpty && description.isEmpty) {
      throw InsufficientContentException(
        'Episode title and description cannot both be empty',
      );
    }

    // Stub implementation - will be implemented in Phase 2
    onProgress?.call(1);
    return EpisodeSummary(
      summary: 'Summary of $title',
      keyTopics: const [],
    );
  }

  @override
  Future<VoiceCommand> parseVoiceCommand({
    required String transcription,
  }) async {
    _ensureInitialized();

    // Stub implementation - will be implemented in Phase 2
    return VoiceCommand(
      intent: VoiceIntent.unknown,
      parameters: const {},
      confidence: 0,
      rawTranscription: transcription,
    );
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
