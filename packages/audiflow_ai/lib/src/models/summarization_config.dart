// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Style options for text summarization.
enum SummarizationStyle {
  /// Brief summary focusing on key points.
  concise,

  /// Comprehensive summary with supporting details.
  detailed,

  /// Summary formatted as bullet points.
  bulletPoints,
}

/// Configuration for text summarization.
class SummarizationConfig {
  /// Creates a [SummarizationConfig].
  const SummarizationConfig({
    this.maxLength = 200,
    this.style = SummarizationStyle.concise,
    this.includeBulletPoints = false,
  });

  /// Maximum length of summary in words.
  final int maxLength;

  /// Style of the summary.
  final SummarizationStyle style;

  /// Whether to include bullet points in the summary.
  final bool includeBulletPoints;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummarizationConfig &&
          runtimeType == other.runtimeType &&
          maxLength == other.maxLength &&
          style == other.style &&
          includeBulletPoints == other.includeBulletPoints;

  @override
  int get hashCode => Object.hash(maxLength, style, includeBulletPoints);
}
