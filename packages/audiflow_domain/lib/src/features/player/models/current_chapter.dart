import 'package:meta/meta.dart';

import '../../transcript/models/episode_chapter.dart';

/// The chapter that contains the playback position, with its place in the
/// episode's chapter list.
@immutable
class CurrentChapter {
  const CurrentChapter({required this.index, required this.chapter});

  /// Zero-based position of [chapter] in the episode's chapters, ordered by
  /// start time.
  final int index;

  final EpisodeChapter chapter;

  /// One-based chapter number shown to the user.
  int get number => index + 1;

  // EpisodeChapter is an Isar collection without value equality, so compare
  // the fields that identify it; providers rely on this to skip rebuilds
  // while playback stays inside the same chapter.
  @override
  bool operator ==(Object other) =>
      other is CurrentChapter &&
      other.index == index &&
      other.chapter.id == chapter.id &&
      other.chapter.startMs == chapter.startMs &&
      other.chapter.title == chapter.title;

  @override
  int get hashCode =>
      Object.hash(index, chapter.id, chapter.startMs, chapter.title);
}

/// Index of the chapter containing [position] in [chapters], which must be
/// ordered by `startMs`.
///
/// A chapter covers `startMs <= position < next.startMs`; the last one runs
/// to the end of the episode. Returns null before the first chapter starts
/// (an untitled lead-in) or when there are no chapters.
int? chapterIndexAt(List<EpisodeChapter> chapters, Duration position) {
  final positionMs = position.inMilliseconds;
  for (var i = chapters.length - 1; 0 <= i; i--) {
    if (chapters[i].startMs <= positionMs) return i;
  }
  return null;
}
