// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_core/audiflow_core.dart';

/// Base exception for all AI-related errors.
class AudiflowAiException extends AppException {
  /// Creates an [AudiflowAiException].
  AudiflowAiException(super.message, [super.code, this.cause]);

  /// The underlying cause of this exception.
  final Object? cause;

  @override
  String toString() {
    final base = super.toString();
    return cause != null ? '$base (cause: $cause)' : base;
  }
}

/// Exception thrown when the device does not support on-device AI.
class AiNotAvailableException extends AudiflowAiException {
  /// Creates an [AiNotAvailableException].
  AiNotAvailableException([String? details])
    : super(
        details ?? 'On-device AI is not available on this device',
        'AI_NOT_AVAILABLE',
      );
}

/// Exception thrown when AI methods are called before initialization.
class AiNotInitializedException extends AudiflowAiException {
  /// Creates an [AiNotInitializedException].
  AiNotInitializedException()
    : super(
        'AI engine not initialized. Call AudiflowAi.initialize() first.',
        'AI_NOT_INITIALIZED',
      );
}

/// Exception thrown when AICore is required but not installed (Android only).
class AiCoreRequiredException extends AudiflowAiException {
  /// Creates an [AiCoreRequiredException].
  AiCoreRequiredException()
    : super(
        'Google AICore is required. Call AudiflowAi.promptAiCoreInstall().',
        'AICORE_REQUIRED',
      );
}

/// Exception thrown when text generation fails.
class AiGenerationException extends AudiflowAiException {
  /// Creates an [AiGenerationException].
  AiGenerationException(String message, [Object? cause])
    : super(message, 'AI_GENERATION_FAILED', cause);
}

/// Exception thrown when summarization fails.
class AiSummarizationException extends AudiflowAiException {
  /// Creates an [AiSummarizationException].
  AiSummarizationException(String message, [Object? cause])
    : super(message, 'AI_SUMMARIZATION_FAILED', cause);
}

/// Exception thrown when the prompt exceeds the model's context limit.
class PromptTooLongException extends AudiflowAiException {
  /// Creates a [PromptTooLongException].
  PromptTooLongException(this.maxTokens)
    : super(
        'Prompt exceeds maximum length of $maxTokens tokens',
        'PROMPT_TOO_LONG',
      );

  /// The maximum allowed number of tokens.
  final int maxTokens;
}

/// Exception thrown when input content is too short or empty.
class InsufficientContentException extends AudiflowAiException {
  /// Creates an [InsufficientContentException].
  InsufficientContentException([String? details])
    : super(
        details ?? 'Insufficient content for processing',
        'INSUFFICIENT_CONTENT',
      );
}
