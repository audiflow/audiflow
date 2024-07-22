import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter.freezed.dart';
part 'chapter.g.dart';

/// A class that represents an individual chapter within an Episode.
///
/// Chapters may, or may not, exist for an episode.
///
/// Part of the [podcast namespace](https://github.com/Podcastindex-org/podcast-namespace)
@freezed
class Chapter with _$Chapter {
  const factory Chapter({
    /// Title of this chapter.
    required String title,

    /// URL for the chapter image if one is available.
    String? imageUrl,

    /// URL of an external link for this chapter if available.
    String? url,

    /// Table of contents flag. If this is false the chapter should be treated
    /// as meta data only and not be displayed.
    @Default(true) bool toc,

    /// The optional end time of the chapter in seconds.
    required double startTime,

    /// The optional end time of the chapter in seconds.
    double? endTime,
  }) = _Chapter;

  factory Chapter.fromJson(Map<String, dynamic> json) =>
      _$ChapterFromJson(json);
}
