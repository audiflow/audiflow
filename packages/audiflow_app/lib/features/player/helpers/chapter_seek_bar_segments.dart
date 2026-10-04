import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';

/// Splits the seek bar track at each chapter start.
///
/// [chapters] must be ordered by `startMs`. A first chapter that starts after
/// zero leaves an untitled leading segment. Starts at or past the end, and
/// duplicates, add no boundary. Returns a single segment when there are no
/// chapters or the duration is unknown, so such episodes look unchanged.
List<SeekBarSegment> chapterSeekBarSegments(
  List<EpisodeChapter> chapters,
  Duration duration,
) {
  final durationMs = duration.inMilliseconds;
  if (chapters.isEmpty || durationMs <= 0) return SeekBarSegment.single;

  final boundaries = <double>[];
  for (final chapter in chapters) {
    if (chapter.startMs <= 0 || durationMs <= chapter.startMs) continue;
    final fraction = chapter.startMs / durationMs;
    if (boundaries.isNotEmpty && fraction <= boundaries.last) continue;
    boundaries.add(fraction);
  }
  if (boundaries.isEmpty) return SeekBarSegment.single;

  final edges = [0.0, ...boundaries, 1.0];
  return [
    for (var i = 0; i < edges.length - 1; i++)
      SeekBarSegment(start: edges[i], end: edges[i + 1]),
  ];
}
