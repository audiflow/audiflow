// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

/// Configuration for text generation.
class GenerationConfig {
  /// Creates a [GenerationConfig].
  const GenerationConfig({
    this.temperature = 0.7,
    this.maxOutputTokens,
    this.stopSequences,
  });

  /// Controls randomness in generation (0.0 = deterministic, 1.0 = creative).
  ///
  /// Default is 0.7.
  final double temperature;

  /// Maximum number of tokens to generate.
  ///
  /// If null, uses platform default.
  final int? maxOutputTokens;

  /// Sequences that stop generation when encountered.
  final List<String>? stopSequences;

  /// Converts to map for platform channel communication.
  Map<String, dynamic> toMap() => {
    'temperature': temperature,
    if (maxOutputTokens != null) 'maxOutputTokens': maxOutputTokens,
    if (stopSequences != null) 'stopSequences': stopSequences,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerationConfig &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          maxOutputTokens == other.maxOutputTokens;

  @override
  int get hashCode => Object.hash(temperature, maxOutputTokens);
}
