import 'package:audiflow_app/features/podcast_detail/presentation/utils/played_display.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  EpisodeWithProgress progressWith(PlaybackHistory? history) =>
      EpisodeWithProgress(
        episode: Episode()
          ..id = 1
          ..podcastId = 1
          ..guid = 'ep-1'
          ..title = 'Episode 1'
          ..audioUrl = 'https://example.com/ep1.mp3',
        history: history,
      );

  PlaybackHistory played({int positionMs = 0, bool isReplaying = false}) =>
      PlaybackHistory()
        ..episodeId = 1
        ..completedAt = DateTime(2026, 10, 9)
        ..positionMs = positionMs
        ..isReplaying = isReplaying;

  group('showsPlayedState', () {
    test('shows a finished listen as played', () {
      check(
        showsPlayedState(progressWith(played()), isPlaying: false),
      ).isTrue();
    });

    test('does not while the episode plays', () {
      check(
        showsPlayedState(progressWith(played()), isPlaying: true),
      ).isFalse();
    });

    test('does not for an open replay at position zero', () {
      check(
        showsPlayedState(
          progressWith(played(isReplaying: true)),
          isPlaying: false,
        ),
      ).isFalse();
    });

    test('does not for an unplayed episode', () {
      check(
        showsPlayedState(
          progressWith(PlaybackHistory()..episodeId = 1),
          isPlaying: false,
        ),
      ).isFalse();
      check(showsPlayedState(null, isPlaying: false)).isFalse();
    });
  });
}
