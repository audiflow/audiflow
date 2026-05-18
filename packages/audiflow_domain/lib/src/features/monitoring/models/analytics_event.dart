/// Base type for all analytics events.
///
/// Every concrete event maps to a single GA event name and a flat
/// param map of primitive values (string / num / bool).
sealed class AnalyticsEvent {
  const AnalyticsEvent();
  String get name;
  Map<String, Object> get params;
}

enum SubscribeSource { search, discovery, opml, deeplink, unknown }

enum PlaySource { queue, library, playlist, station, search, deeplink }

enum SleepTimerMode { duration, episodes, endOfEpisode, endOfChapter }

// Converts a camelCase string to snake_case for GA event param values.
String _toSnake(String s) {
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    final isUpper = 65 <= c && c <= 90;
    if (isUpper && 0 < i) buf.write('_');
    buf.writeCharCode(isUpper ? c + 32 : c);
  }
  return buf.toString();
}

class PodcastSubscribed extends AnalyticsEvent {
  const PodcastSubscribed({required this.podcastId, required this.source});
  final String podcastId;
  final SubscribeSource source;
  @override
  String get name => 'podcast_subscribe';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'source': source.name,
  };
}

class PodcastUnsubscribed extends AnalyticsEvent {
  const PodcastUnsubscribed({required this.podcastId});
  final String podcastId;
  @override
  String get name => 'podcast_unsubscribe';
  @override
  Map<String, Object> get params => {'podcast_id': podcastId};
}

class EpisodePlayStarted extends AnalyticsEvent {
  const EpisodePlayStarted({
    required this.podcastId,
    required this.episodeId,
    required this.source,
  });
  final String podcastId;
  final String episodeId;
  final PlaySource source;
  @override
  String get name => 'episode_play_start';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'source': source.name,
  };
}

class EpisodePaused extends AnalyticsEvent {
  const EpisodePaused({
    required this.podcastId,
    required this.episodeId,
    required this.positionSec,
  });
  final String podcastId;
  final String episodeId;
  final int positionSec;
  @override
  String get name => 'episode_pause';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'position_sec': positionSec,
  };
}

class EpisodeCompleted extends AnalyticsEvent {
  const EpisodeCompleted({
    required this.podcastId,
    required this.episodeId,
    required this.durationSec,
  });
  final String podcastId;
  final String episodeId;
  final int durationSec;
  @override
  String get name => 'episode_complete';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'duration_sec': durationSec,
  };
}

class EpisodeSeeked extends AnalyticsEvent {
  const EpisodeSeeked({
    required this.podcastId,
    required this.episodeId,
    required this.fromSec,
    required this.toSec,
  });
  final String podcastId;
  final String episodeId;
  final int fromSec;
  final int toSec;
  @override
  String get name => 'episode_seek';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'from_sec': fromSec,
    'to_sec': toSec,
  };
}

class PlaybackSpeedChanged extends AnalyticsEvent {
  const PlaybackSpeedChanged({required this.speed});
  final double speed;
  @override
  String get name => 'playback_speed_change';
  @override
  Map<String, Object> get params => {'speed': speed};
}

class SearchQueryEntered extends AnalyticsEvent {
  const SearchQueryEntered({required this.queryLen});
  final int queryLen;
  @override
  String get name => 'search_query';
  @override
  Map<String, Object> get params => {'query_len': queryLen};
}

class EpisodeDownloadStarted extends AnalyticsEvent {
  const EpisodeDownloadStarted({
    required this.podcastId,
    required this.episodeId,
  });
  final String podcastId;
  final String episodeId;
  @override
  String get name => 'episode_download_start';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
  };
}

class EpisodeDownloadCompleted extends AnalyticsEvent {
  const EpisodeDownloadCompleted({
    required this.podcastId,
    required this.episodeId,
    required this.bytes,
  });
  final String podcastId;
  final String episodeId;
  final int bytes;
  @override
  String get name => 'episode_download_complete';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'bytes': bytes,
  };
}

class SmartPlaylistPlayed extends AnalyticsEvent {
  const SmartPlaylistPlayed({
    required this.patternId,
    required this.playlistId,
  });
  final String patternId;
  final String playlistId;
  @override
  String get name => 'smart_playlist_play';
  @override
  Map<String, Object> get params => {
    'pattern_id': patternId,
    'playlist_id': playlistId,
  };
}

class StationPlayed extends AnalyticsEvent {
  const StationPlayed({required this.stationId});
  final String stationId;
  @override
  String get name => 'station_play';
  @override
  Map<String, Object> get params => {'station_id': stationId};
}

class SleepTimerSet extends AnalyticsEvent {
  const SleepTimerSet({required this.mode, this.value});
  final SleepTimerMode mode;
  final int? value;
  @override
  String get name => 'sleep_timer_set';
  @override
  Map<String, Object> get params {
    final modeName = _toSnake(mode.name);
    final v = value;
    return v == null ? {'mode': modeName} : {'mode': modeName, 'value': v};
  }
}
