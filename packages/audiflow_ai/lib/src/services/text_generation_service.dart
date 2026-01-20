// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:flutter/services.dart';

import '../channel/audiflow_ai_channel.dart';
import '../exceptions/audiflow_ai_exception.dart';
import '../models/ai_capability.dart';
import '../models/ai_response.dart';
import '../models/generation_config.dart';
import '../utils/prompt_templates.dart';

/// Service that orchestrates text generation via platform channel.
///
/// Provides low-level access to the AI text generation capabilities.
/// For higher-level operations like summarization, use SummarizationService.
class TextGenerationService {
  /// Creates a [TextGenerationService].
  TextGenerationService();

  bool _isInitialized = false;

  /// Whether the service has been successfully initialized.
  bool get isInitialized => _isInitialized;

  /// Checks if AI generation is available on this device.
  ///
  /// Returns true if capability is `AiCapability.full` or
  /// `AiCapability.limited`.
  Future<bool> isAvailable() async {
    try {
      final result = await AudiflowAiChannel.channel
          .invokeMethod<Map<dynamic, dynamic>>(
            AudiflowAiChannel.checkCapability,
          );

      final status = result?[AudiflowAiChannel.kStatus] as String?;
      final capability = _mapStatusToCapability(status);
      return capability.isUsable;
    } on MissingPluginException {
      return false;
    }
  }

  /// Initializes the AI engine with optional system instructions.
  ///
  /// If [systemInstructions] is not provided, uses default podcast-optimized
  /// instructions from [PromptTemplates].
  ///
  /// Throws [AiNotAvailableException] if the device doesn't support AI.
  /// Throws [AiCoreRequiredException] if AICore is not installed (Android).
  Future<void> initialize({String? systemInstructions}) async {
    final instructions =
        systemInstructions ?? PromptTemplates.systemInstructions;

    try {
      await AudiflowAiChannel.channel.invokeMethod<Map<dynamic, dynamic>>(
        AudiflowAiChannel.initialize,
        {'instructions': instructions},
      );
      _isInitialized = true;
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  /// Generates text from a prompt.
  ///
  /// [prompt] is the text prompt to generate from.
  /// [config] optionally specifies generation parameters like temperature.
  ///
  /// Returns an [AiResponse] containing the generated text and metadata.
  ///
  /// Throws [AiNotInitializedException] if not initialized.
  /// Throws [PromptTooLongException] if prompt exceeds model limit.
  /// Throws [AiGenerationException] on generation failure.
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

  /// Generates text and returns just the text string.
  ///
  /// This is a convenience method for simple use cases.
  ///
  /// [prompt] is the text prompt to generate from.
  /// [maxTokens] is the maximum tokens to generate (default 500).
  ///
  /// Returns the generated text string.
  ///
  /// Throws [AiNotInitializedException] if not initialized.
  /// Throws [PromptTooLongException] if prompt exceeds model limit.
  /// Throws [AiGenerationException] on generation failure.
  Future<String> generateTextSimple({
    required String prompt,
    int maxTokens = 500,
  }) async {
    final response = await generateText(
      prompt: prompt,
      config: GenerationConfig(maxOutputTokens: maxTokens),
    );
    return response.text;
  }

  /// Releases resources held by the service.
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

  void _handlePlatformException(PlatformException e) {
    if (e.code == 'AI_NOT_AVAILABLE') {
      throw AiNotAvailableException(e.message);
    }
    if (e.code == 'AICORE_REQUIRED') {
      throw AiCoreRequiredException();
    }
    throw AiGenerationException('Initialization failed: ${e.message}', e);
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
