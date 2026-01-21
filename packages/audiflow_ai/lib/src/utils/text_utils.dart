// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

// ignore_for_file: avoid_classes_with_only_static_members

/// Utilities for text processing and normalization.
///
/// Provides methods for stripping HTML, decoding entities, and normalizing text
/// for AI processing.
abstract final class TextUtils {
  /// Named HTML entities to their character equivalents.
  static const _namedEntities = <String, String>{
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'nbsp': '\u00A0',
    'copy': '\u00A9',
    'reg': '\u00AE',
    'trade': '\u2122',
    'mdash': '\u2014',
    'ndash': '\u2013',
    'hellip': '\u2026',
    'lsquo': '\u2018',
    'rsquo': '\u2019',
    'ldquo': '\u201C',
    'rdquo': '\u201D',
    'bull': '\u2022',
    'middot': '\u00B7',
    'iexcl': '\u00A1',
    'cent': '\u00A2',
    'pound': '\u00A3',
    'curren': '\u00A4',
    'yen': '\u00A5',
    'euro': '\u20AC',
    'sect': '\u00A7',
    'deg': '\u00B0',
    'plusmn': '\u00B1',
    'para': '\u00B6',
    'frac14': '\u00BC',
    'frac12': '\u00BD',
    'frac34': '\u00BE',
    'times': '\u00D7',
    'divide': '\u00F7',
  };

  /// Pattern for matching HTML tags.
  static final _htmlTagPattern = RegExp(
    r'<[^>]*>',
    multiLine: true,
    dotAll: true,
  );

  /// Pattern for script/style tags with content.
  static final _scriptStylePattern = RegExp(
    r'<(script|style)[^>]*>.*?</\1>',
    multiLine: true,
    dotAll: true,
    caseSensitive: false,
  );

  /// Pattern for HTML comments.
  static final _commentPattern = RegExp(
    r'<!--.*?-->',
    multiLine: true,
    dotAll: true,
  );

  /// Pattern for named HTML entities.
  static final _namedEntityPattern = RegExp(r'&([a-zA-Z]+);');

  /// Pattern for numeric HTML entities.
  static final _numericEntityPattern = RegExp(r'&#(\d+);');

  /// Pattern for hex HTML entities.
  static final _hexEntityPattern = RegExp(r'&#[xX]([0-9a-fA-F]+);');

  /// Pattern for whitespace normalization.
  static final _whitespacePattern = RegExp(r'\s+');

  /// Pattern for sentence boundaries.
  static final _sentencePattern = RegExp(r'[.!?]+(?:\s|$)');

  /// Strips all HTML tags from [html].
  ///
  /// Also removes script/style content and HTML comments.
  /// Returns plain text with tags replaced by spaces where appropriate.
  static String stripHtml(String html) {
    if (html.isEmpty) {
      return '';
    }

    var result = html;

    // Remove script and style tags with their content
    result = result.replaceAll(_scriptStylePattern, ' ');

    // Remove HTML comments
    result = result.replaceAll(_commentPattern, ' ');

    // Remove remaining HTML tags
    result = result.replaceAll(_htmlTagPattern, ' ');

    // Collapse multiple spaces
    result = result.replaceAll(_whitespacePattern, ' ').trim();

    return result;
  }

  /// Decodes HTML entities in [text].
  ///
  /// Handles named entities (e.g., &amp;), numeric entities (e.g., &#38;),
  /// and hex entities (e.g., &#x26;).
  static String decodeHtmlEntities(String text) {
    if (text.isEmpty) {
      return '';
    }

    var result = text;

    // Decode hex entities first (&#x26;)
    result = result.replaceAllMapped(_hexEntityPattern, (match) {
      final hex = match.group(1)!;
      final codePoint = int.tryParse(hex, radix: 16);
      if (codePoint != null) {
        return String.fromCharCode(codePoint);
      }
      return match.group(0)!;
    });

    // Decode numeric entities (&#38;)
    result = result.replaceAllMapped(_numericEntityPattern, (match) {
      final num = match.group(1)!;
      final codePoint = int.tryParse(num);
      if (codePoint != null) {
        return String.fromCharCode(codePoint);
      }
      return match.group(0)!;
    });

    // Decode named entities (&amp;)
    result = result.replaceAllMapped(_namedEntityPattern, (match) {
      final name = match.group(1)!.toLowerCase();
      return _namedEntities[name] ?? match.group(0)!;
    });

    return result;
  }

  /// Normalizes whitespace in [text].
  ///
  /// Collapses multiple whitespace characters (spaces, tabs, newlines)
  /// into single spaces and trims leading/trailing whitespace.
  static String normalizeWhitespace(String text) {
    if (text.isEmpty) {
      return '';
    }

    return text.replaceAll(_whitespacePattern, ' ').trim();
  }

  /// Fully normalizes [text] for AI processing.
  ///
  /// Performs the following operations in order:
  /// 1. Strip HTML tags
  /// 2. Decode HTML entities
  /// 3. Normalize whitespace
  static String normalizeText(String text) {
    if (text.isEmpty) {
      return '';
    }

    var result = stripHtml(text);
    result = decodeHtmlEntities(result);
    result = normalizeWhitespace(result);

    return result;
  }

  /// Truncates [text] to [maxLength] characters.
  ///
  /// If [atWordBoundary] is true, truncates at the last word boundary
  /// before [maxLength]. Appends [suffix] to indicate truncation.
  static String truncateText(
    String text,
    int maxLength, {
    bool atWordBoundary = false,
    String suffix = '...',
  }) {
    if (text.isEmpty || text.length <= maxLength) {
      return text;
    }

    final targetLength = maxLength - suffix.length;
    if (targetLength <= 0) {
      return suffix;
    }

    var truncated = text.substring(0, targetLength);

    if (atWordBoundary) {
      // Find last space
      final lastSpace = truncated.lastIndexOf(' ');
      if (0 < lastSpace) {
        truncated = truncated.substring(0, lastSpace);
      }
    }

    return '$truncated$suffix';
  }

  /// Counts the number of words in [text].
  ///
  /// Words are separated by whitespace.
  static int countWords(String text) {
    if (text.isEmpty) {
      return 0;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    return trimmed.split(_whitespacePattern).length;
  }

  /// Extracts sentences from [text].
  ///
  /// Sentences are delimited by '.', '!', or '?'.
  /// Handles basic cases; may not correctly handle all abbreviations.
  static List<String> extractSentences(String text) {
    if (text.isEmpty) {
      return [];
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final sentences = <String>[];
    var lastEnd = 0;

    for (final match in _sentencePattern.allMatches(trimmed)) {
      final sentence = trimmed.substring(lastEnd, match.end).trim();
      if (sentence.isNotEmpty) {
        sentences.add(sentence);
      }
      lastEnd = match.end;
    }

    // Add remaining text if no terminal punctuation
    if (lastEnd < trimmed.length) {
      final remaining = trimmed.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        sentences.add(remaining);
      }
    }

    return sentences;
  }
}
