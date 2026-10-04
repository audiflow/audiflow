import 'package:audiflow_app/features/player/helpers/chapter_seek_bar_segments.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

EpisodeChapter _chapter(int startMs) => EpisodeChapter()
  ..episodeId = 1
  ..sortOrder = startMs
  ..title = 'At $startMs'
  ..startMs = startMs;

const _tenSeconds = Duration(seconds: 10);

void main() {
  group('chapterSeekBarSegments', () {
    test('is a single segment without chapters', () {
      check(
        chapterSeekBarSegments(const [], _tenSeconds),
      ).deepEquals(SeekBarSegment.single);
    });

    test('is a single segment when the duration is unknown', () {
      check(
        chapterSeekBarSegments([_chapter(0), _chapter(5000)], Duration.zero),
      ).deepEquals(SeekBarSegment.single);
    });

    test('splits at each chapter start', () {
      check(
        chapterSeekBarSegments([
          _chapter(0),
          _chapter(2500),
          _chapter(5000),
        ], _tenSeconds),
      ).deepEquals(const [
        SeekBarSegment(start: 0, end: 0.25),
        SeekBarSegment(start: 0.25, end: 0.5),
        SeekBarSegment(start: 0.5, end: 1),
      ]);
    });

    test('keeps an untitled lead-in before a late first chapter', () {
      check(chapterSeekBarSegments([_chapter(2000)], _tenSeconds)).deepEquals(
        const [
          SeekBarSegment(start: 0, end: 0.2),
          SeekBarSegment(start: 0.2, end: 1),
        ],
      );
    });

    test('ignores duplicate starts and starts past the end', () {
      check(
        chapterSeekBarSegments([
          _chapter(0),
          _chapter(5000),
          _chapter(5000),
          _chapter(12000),
        ], _tenSeconds),
      ).deepEquals(const [
        SeekBarSegment(start: 0, end: 0.5),
        SeekBarSegment(start: 0.5, end: 1),
      ]);
    });

    test('is a single segment when only chapter starts at zero', () {
      check(
        chapterSeekBarSegments([_chapter(0)], _tenSeconds),
      ).deepEquals(SeekBarSegment.single);
    });
  });
}
