import 'package:audiflow_domain/patterns.dart';

/// Diagnostic result from running title extraction.
class TitleDiagnosticResult {
  const TitleDiagnosticResult({
    this.extractedValue,
    this.patternUsed,
    this.matchResult,
    this.fallbackValue,
    this.fallbackConditionMet,
    this.error,
  });

  final String? extractedValue;
  final String? patternUsed;
  final String? matchResult;
  final String? fallbackValue;
  final bool? fallbackConditionMet;
  final String? error;
}

/// Wraps [SeasonTitleExtractor] to capture diagnostic information.
class TitleExtractorDiagnostics {
  const TitleExtractorDiagnostics(this.extractor);

  final SeasonTitleExtractor extractor;

  /// Runs extraction and captures diagnostic details.
  TitleDiagnosticResult run(EpisodeData episode) {
    final seasonNum = episode.seasonNumber;

    // Step 1: Check fallbackValue condition
    if (extractor.fallbackValue != null &&
        (seasonNum == null || 1 > seasonNum)) {
      return TitleDiagnosticResult(
        extractedValue: extractor.fallbackValue,
        fallbackValue: extractor.fallbackValue,
        fallbackConditionMet: true,
      );
    }

    // Step 2: Get source value
    final sourceValue = _getSourceValue(episode);
    if (sourceValue == null) {
      return TitleDiagnosticResult(
        error: 'source "${extractor.source}" returned null',
      );
    }

    // Step 3: Try pattern match
    if (extractor.pattern != null) {
      final regex = RegExp(extractor.pattern!);
      final match = regex.firstMatch(sourceValue);

      if (match == null) {
        // Try fallback extractor if available
        if (extractor.fallback != null) {
          final fallbackDiagnostics = TitleExtractorDiagnostics(
            extractor.fallback!,
          );
          final fallbackResult = fallbackDiagnostics.run(episode);
          if (fallbackResult.extractedValue != null) {
            return fallbackResult;
          }
        }
        return TitleDiagnosticResult(
          patternUsed: extractor.pattern,
          fallbackValue: extractor.fallbackValue,
          error: 'pattern did not match title: "$sourceValue"',
        );
      }

      final groupValue = extractor.group == 0
          ? match.group(0)
          : (extractor.group <= match.groupCount
                ? match.group(extractor.group)
                : null);

      if (groupValue == null) {
        return TitleDiagnosticResult(
          patternUsed: extractor.pattern,
          matchResult: match.group(0),
          error: 'capture group ${extractor.group} not found',
        );
      }

      var result = groupValue;
      if (extractor.template != null) {
        result = extractor.template!.replaceAll('{value}', result);
      }

      return TitleDiagnosticResult(
        extractedValue: result,
        patternUsed: extractor.pattern,
        matchResult: groupValue,
      );
    }

    // No pattern - use source directly
    var result = sourceValue;
    if (extractor.template != null) {
      result = extractor.template!.replaceAll('{value}', result);
    }

    return TitleDiagnosticResult(extractedValue: result);
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
