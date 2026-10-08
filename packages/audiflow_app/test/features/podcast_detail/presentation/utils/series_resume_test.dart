import 'package:audiflow_app/features/podcast_detail/presentation/utils/series_resume.dart';
import 'package:audiflow_domain/audiflow_domain.dart'
    show
        Episode,
        EpisodeWithProgress,
        PlaybackHistory,
        SmartPlaylistEpisodeData;
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

enum _State { unplayed, started, played }

SmartPlaylistEpisodeData _episode(int id, _State state, {int? number}) {
  final episode = Episode()
    ..id = id
    ..podcastId = 1
    ..guid = 'g$id'
    ..title = 'E$id'
    ..audioUrl = 'https://example.com/$id.mp3'
    ..episodeNumber = number
    ..publishedAt = DateTime(2026, 1, id);
  final history = switch (state) {
    _State.unplayed => null,
    _State.started =>
      PlaybackHistory()
        ..episodeId = id
        ..positionMs = 1000
        ..durationMs = 60000,
    _State.played =>
      PlaybackHistory()
        ..episodeId = id
        ..positionMs = 60000
        ..durationMs = 60000
        ..completedAt = DateTime(2026, 2),
  };
  return SmartPlaylistEpisodeData(
    episode: episode,
    progress: EpisodeWithProgress(episode: episode, history: history),
  );
}

void main() {
  test('resumes the started episode, in oldest-first order', () {
    // Given newest first, as a descending list arrives.
    final target = seriesResumeTarget([
      _episode(3, _State.unplayed),
      _episode(2, _State.started),
      _episode(1, _State.played),
    ]);
    check(target).isNotNull()
      ..has((t) => t.data.episode.id, 'id').equals(2)
      ..has((t) => t.resuming, 'resuming').isTrue()
      ..has((t) => t.number, 'number').equals(2);
  });

  test('starts the first unplayed episode when none is started', () {
    final target = seriesResumeTarget([
      _episode(3, _State.unplayed),
      _episode(2, _State.unplayed),
      _episode(1, _State.played),
    ]);
    check(target).isNotNull()
      ..has((t) => t.data.episode.id, 'id').equals(2)
      ..has((t) => t.resuming, 'resuming').isFalse();
  });

  test('prefers the feed episode number', () {
    final target = seriesResumeTarget([
      _episode(1, _State.unplayed, number: 41),
    ]);
    check(target).isNotNull().has((t) => t.number, 'number').equals(41);
  });

  test('null once every episode is played', () {
    check(
      seriesResumeTarget([
        _episode(1, _State.played),
        _episode(2, _State.played),
      ]),
    ).isNull();
  });
}
