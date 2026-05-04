import 'package:audiflow_domain/patterns.dart';

/// Diagnostic result from running title extraction.
class TitleDiagnosticResult {
  const TitleDiagnosticResult({
    this.extractedValue,
    this.patternUsed,
    this.matchResult,
    this.templateUsed,
    this.fallbackValue,
    this.fallbackConditionMet,
    this.error,
  });

  final String? extractedValue;
  final String? patternUsed;
  final String? matchResult;
  final String? templateUsed;
  final String? fallbackValue;
  final bool? fallbackConditionMet;
  final String? error;
}

/// Wraps [SmartPlaylistTitleExtractor] to capture diagnostic
/// information about each extraction step.
class TitleExtractorDiagnostics {
  const TitleExtractorDiagnostics(this.extractor);

  final SmartPlaylistTitleExtractor extractor;

  /// Runs extraction and captures diagnostic details.
  TitleDiagnosticResult run(EpisodeData episode) {
    // Step 1: fallbackValue short-circuit only applies to numeric sources.
    if (extractor.fallbackValue != null) {
      final source = extractor.source;
      final numeric = switch (source) {
        'seasonNumber' => episode.seasonNumber,
        'episodeNumber' => episode.episodeNumber,
        _ => null,
      };
      if ((source == 'seasonNumber' || source == 'episodeNumber') &&
          (numeric == null || numeric < 1)) {
        return TitleDiagnosticResult(
          extractedValue: extractor.fallbackValue,
          fallbackValue: extractor.fallbackValue,
          fallbackConditionMet: true,
        );
      }
    }

    // Step 2: get source value.
    final sourceValue = _getSourceValue(episode);
    if (sourceValue == null) {
      return TitleDiagnosticResult(
        error: 'source "${extractor.source}" returned null',
      );
    }

    // Step 3: pattern + template.
    final pattern = extractor.pattern;
    if (pattern != null) {
      final match = RegExp(pattern).firstMatch(sourceValue);
      if (match == null) {
        if (extractor.fallback != null) {
          final fallbackResult = TitleExtractorDiagnostics(
            extractor.fallback!,
          ).run(episode);
          if (fallbackResult.extractedValue != null) {
            return fallbackResult;
          }
        }
        return TitleDiagnosticResult(
          patternUsed: pattern,
          fallbackValue: extractor.fallbackValue,
          error: 'pattern did not match title: "$sourceValue"',
        );
      }

      final fullMatch = match.group(0);
      final result = extractor.extract(episode);
      return TitleDiagnosticResult(
        extractedValue: result,
        patternUsed: pattern,
        matchResult: fullMatch,
        templateUsed: extractor.template,
      );
    }

    // No pattern: source value substitutes ${0}.
    final result = extractor.extract(episode);
    return TitleDiagnosticResult(
      extractedValue: result,
      matchResult: sourceValue,
      templateUsed: extractor.template,
    );
  }

  String? _getSourceValue(EpisodeData episode) {
    return switch (extractor.source) {
      'title' => episode.title,
      'description' => episode.description,
      'seasonNumber' => episode.seasonNumber?.toString(),
      'episodeNumber' => episode.episodeNumber?.toString(),
      _ => null,
    };
  }
}
