import 'dart:convert';

import '../models/podcast_chapter.dart';

/// Parses Podcasting 2.0 JSON chapters files (`application/json+chapters`).
///
/// Entries hidden from the table of contents (`toc: false`) and entries
/// without a title are dropped, since they cannot be shown as chapters.
/// The result is sorted by start time.
final class JsonChaptersParser {
  const JsonChaptersParser();

  /// Parses [source] into chapters.
  ///
  /// Throws [FormatException] when [source] is not a JSON object with a
  /// `chapters` array.
  List<PodcastChapter> parse(String source) {
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic>) {
      throw const FormatException('Chapters JSON root is not an object');
    }
    final entries = root['chapters'];
    if (entries is! List) {
      throw const FormatException('Chapters JSON has no chapters array');
    }
    final chapters = entries
        .whereType<Map<String, dynamic>>()
        .map(_parseEntry)
        .nonNulls
        .toList();
    chapters.sort((a, b) => a.startTime.compareTo(b.startTime));
    return chapters;
  }

  static PodcastChapter? _parseEntry(Map<String, dynamic> entry) {
    if (entry['toc'] == false) return null;
    final title = _nonBlankString(entry['title']);
    final startTime = _seconds(entry['startTime']);
    if (title == null || startTime == null) return null;
    final endTime = _seconds(entry['endTime']);
    return PodcastChapter(
      title: title,
      startTime: startTime,
      endTime: endTime != null && startTime < endTime ? endTime : null,
      url: _nonBlankString(entry['url']),
      imageUrl: _nonBlankString(entry['img']),
    );
  }

  static Duration? _seconds(Object? value) {
    if (value is! num || value.isNaN || value.isInfinite || value < 0) {
      return null;
    }
    return Duration(milliseconds: (value * 1000).round());
  }

  static String? _nonBlankString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
