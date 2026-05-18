import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsEvent', () {
    test('PodcastSubscribed', () {
      final e = PodcastSubscribed(
        podcastId: 'p1',
        source: SubscribeSource.search,
      );
      check(e.name).equals('podcast_subscribe');
      check(e.params).deepEquals({'podcast_id': 'p1', 'source': 'search'});
    });

    test('PodcastUnsubscribed', () {
      final e = PodcastUnsubscribed(podcastId: 'p1');
      check(e.name).equals('podcast_unsubscribe');
      check(e.params).deepEquals({'podcast_id': 'p1'});
    });

    test('EpisodePlayStarted', () {
      final e = EpisodePlayStarted(
        podcastId: 'p1',
        episodeId: 'e1',
        source: PlaySource.queue,
      );
      check(e.name).equals('episode_play_start');
      check(
        e.params,
      ).deepEquals({'podcast_id': 'p1', 'episode_id': 'e1', 'source': 'queue'});
    });

    test('EpisodePaused', () {
      final e = EpisodePaused(
        podcastId: 'p1',
        episodeId: 'e1',
        positionSec: 120,
      );
      check(e.name).equals('episode_pause');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'position_sec': 120,
      });
    });

    test('EpisodeCompleted', () {
      final e = EpisodeCompleted(
        podcastId: 'p1',
        episodeId: 'e1',
        durationSec: 1800,
      );
      check(e.name).equals('episode_complete');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'duration_sec': 1800,
      });
    });

    test('EpisodeSeeked', () {
      final e = EpisodeSeeked(
        podcastId: 'p1',
        episodeId: 'e1',
        fromSec: 100,
        toSec: 200,
      );
      check(e.name).equals('episode_seek');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'from_sec': 100,
        'to_sec': 200,
      });
    });

    test('PlaybackSpeedChanged', () {
      final e = PlaybackSpeedChanged(speed: 1.5);
      check(e.name).equals('playback_speed_change');
      check(e.params).deepEquals({'speed': 1.5});
    });

    test('SearchQueryEntered emits length only', () {
      final e = SearchQueryEntered(queryLen: 12);
      check(e.name).equals('search_query');
      check(e.params).deepEquals({'query_len': 12});
    });

    test('EpisodeDownloadStarted', () {
      final e = EpisodeDownloadStarted(podcastId: 'p1', episodeId: 'e1');
      check(e.name).equals('episode_download_start');
      check(e.params).deepEquals({'podcast_id': 'p1', 'episode_id': 'e1'});
    });

    test('EpisodeDownloadCompleted', () {
      final e = EpisodeDownloadCompleted(
        podcastId: 'p1',
        episodeId: 'e1',
        bytes: 1024,
      );
      check(e.name).equals('episode_download_complete');
      check(
        e.params,
      ).deepEquals({'podcast_id': 'p1', 'episode_id': 'e1', 'bytes': 1024});
    });

    test('SmartPlaylistPlayed', () {
      final e = SmartPlaylistPlayed(
        patternId: 'coten_radio',
        playlistId: 'regular',
      );
      check(e.name).equals('smart_playlist_play');
      check(
        e.params,
      ).deepEquals({'pattern_id': 'coten_radio', 'playlist_id': 'regular'});
    });

    test('StationPlayed', () {
      final e = StationPlayed(stationId: 's1');
      check(e.name).equals('station_play');
      check(e.params).deepEquals({'station_id': 's1'});
    });

    test('SleepTimerSet (duration)', () {
      final e = SleepTimerSet(mode: SleepTimerMode.duration, value: 30);
      check(e.name).equals('sleep_timer_set');
      check(e.params).deepEquals({'mode': 'duration', 'value': 30});
    });

    test('SleepTimerSet (end_of_episode omits value)', () {
      final e = SleepTimerSet(mode: SleepTimerMode.endOfEpisode);
      check(e.name).equals('sleep_timer_set');
      check(e.params).deepEquals({'mode': 'end_of_episode'});
    });

    test('SleepTimerSet (episodes carries value)', () {
      final e = SleepTimerSet(mode: SleepTimerMode.episodes, value: 3);
      check(e.name).equals('sleep_timer_set');
      check(e.params).deepEquals({'mode': 'episodes', 'value': 3});
    });

    test('SleepTimerSet (end_of_chapter omits value)', () {
      final e = SleepTimerSet(mode: SleepTimerMode.endOfChapter);
      check(e.name).equals('sleep_timer_set');
      check(e.params).deepEquals({'mode': 'end_of_chapter'});
    });
  });
}
