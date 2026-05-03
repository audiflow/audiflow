import 'package:audiflow_core/audiflow_core.dart';

/// Configuration for extracting smart playlist display names from
/// episode data.
///
/// Reads a value, optionally matches a regex pattern, and formats the
/// result via a `${N}` template (`${0}` = full match, `${1}`, `${2}`,
/// ... = capture groups). Out-of-range references render as empty.
/// When [template] is omitted the raw match (or source value when no
/// pattern is set) is returned.
///
/// Example JSON configs:
/// ```json
/// // Multi-capture template
/// {
///   "source": "title",
///   "pattern": "\\[(.+?)\\s+(\\d+)\\]",
///   "template": "${1} ${2}"
/// }
///
/// // Use seasonNumber with template
/// {
///   "source": "seasonNumber",
///   "template": "Season ${0}"
/// }
///
/// // With fallback chain
/// {
///   "source": "title",
///   "pattern": "\\[(.+?)\\]",
///   "template": "${1}",
///   "fallback": {
///     "source": "seasonNumber",
///     "template": "Season ${0}"
///   }
/// }
/// ```
final class SmartPlaylistTitleExtractor {
  const SmartPlaylistTitleExtractor({
    required this.source,
    this.pattern,
    this.template,
    this.fallback,
    this.fallbackValue,
  });

  /// Creates an extractor from JSON configuration.
  factory SmartPlaylistTitleExtractor.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistTitleExtractor(
      source: json['source'] as String,
      pattern: json['pattern'] as String?,
      template: json['template'] as String?,
      fallback: json['fallback'] != null
          ? SmartPlaylistTitleExtractor.fromJson(
              json['fallback'] as Map<String, dynamic>,
            )
          : null,
      fallbackValue: json['fallbackValue'] as String?,
    );
  }

  /// Episode field to extract from.
  ///
  /// Supported values: "title", "description", "seasonNumber",
  /// "episodeNumber"
  final String source;

  /// Regex pattern to match against the source value (optional).
  final String? pattern;

  /// Template using `${N}` references (`${0}` = full match,
  /// `${1}`, `${2}`, ... = capture groups). When `null`, behaves
  /// as `${0}`.
  final String? template;

  /// Fallback extractor used when this one fails.
  final SmartPlaylistTitleExtractor? fallback;

  /// Fallback string used when `source` is `seasonNumber` or
  /// `episodeNumber` and the value is missing or `< 1`. Has no
  /// effect for `title` / `description` sources.
  final String? fallbackValue;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'source': source,
      if (pattern != null) 'pattern': pattern,
      if (template != null) 'template': template,
      if (fallback != null) 'fallback': fallback!.toJson(),
      if (fallbackValue != null) 'fallbackValue': fallbackValue,
    };
  }

  /// Extracts the smart playlist title from an episode.
  ///
  /// Returns null if extraction fails and no fallback is available.
  String? extract(EpisodeData episode) {
    if (fallbackValue != null) {
      final numeric = switch (source) {
        'seasonNumber' => episode.seasonNumber,
        'episodeNumber' => episode.episodeNumber,
        _ => null,
      };
      if ((source == 'seasonNumber' || source == 'episodeNumber') &&
          (numeric == null || 1 > numeric)) {
        return fallbackValue;
      }
    }

    final sourceValue = _getSourceValue(episode);
    if (sourceValue == null) {
      return fallback?.extract(episode);
    }

    final List<String?> groups;
    final patternValue = pattern;
    if (patternValue != null) {
      final match = RegExp(patternValue).firstMatch(sourceValue);
      if (match == null) {
        return fallback?.extract(episode);
      }
      groups = List.generate(match.groupCount + 1, match.group);
    } else {
      groups = [sourceValue];
    }

    return _render(template, groups);
  }

  String? _getSourceValue(EpisodeData episode) {
    return switch (source) {
      'title' => episode.title,
      'description' => episode.description,
      'seasonNumber' => episode.seasonNumber?.toString(),
      'episodeNumber' => episode.episodeNumber?.toString(),
      _ => null,
    };
  }

  static String _render(String? template, List<String?> groups) {
    if (template == null) {
      return _groupValue(groups, 0);
    }
    return _expandTemplate(template, groups);
  }

  static String _groupValue(List<String?> groups, int n) {
    if (n < 0 || groups.length <= n) return '';
    return groups[n] ?? '';
  }

  /// Expands `${N}` tokens in [template]. Out-of-range groups become
  /// empty. Malformed tokens (e.g. `${abc}`, unclosed `${`) are
  /// emitted literally.
  static String _expandTemplate(String template, List<String?> groups) {
    final out = StringBuffer();
    var i = 0;
    while (i < template.length) {
      if (i + 1 < template.length &&
          template.codeUnitAt(i) == 0x24 /* $ */ &&
          template.codeUnitAt(i + 1) == 0x7B /* { */ ) {
        final close = template.indexOf('}', i + 2);
        if (close != -1) {
          final inner = template.substring(i + 2, close);
          final n = int.tryParse(inner);
          if (n != null && 0 <= n) {
            out.write(_groupValue(groups, n));
            i = close + 1;
            continue;
          }
        }
      }
      out.write(template[i]);
      i++;
    }
    return out.toString();
  }
}
