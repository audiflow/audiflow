// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Response from AI text generation.
class AiResponse {
  /// Creates an [AiResponse].
  const AiResponse({
    required this.text,
    this.tokenCount,
    this.durationMs,
    this.metadata,
  });

  /// The generated text.
  final String text;

  /// Number of tokens in the response (platform-dependent).
  final int? tokenCount;

  /// Time taken for generation in milliseconds.
  final int? durationMs;

  /// Additional metadata from the platform.
  final Map<String, dynamic>? metadata;

  /// Whether the response is complete (not truncated).
  bool get isComplete => metadata?['truncated'] != true;

  /// Whether the response was truncated due to token limit.
  bool get wasTruncated => metadata?['truncated'] == true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiResponse &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          tokenCount == other.tokenCount &&
          durationMs == other.durationMs;

  @override
  int get hashCode => Object.hash(text, tokenCount, durationMs);

  @override
  String toString() =>
      'AiResponse(text: ${text.length} chars, tokenCount: $tokenCount, '
      'durationMs: $durationMs)';
}
