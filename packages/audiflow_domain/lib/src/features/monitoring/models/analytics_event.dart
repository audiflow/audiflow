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

enum PlaySource { queue, library, playlist, station, search, deeplink, unknown }

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

// GA4 caps event param values at 100 chars. Truncate at the boundary so
// raw RSS guids / feedUrls / titles never exceed the limit silently.
String _trim(String s) => s.length <= 100 ? s : s.substring(0, 100);

// `feed_url` is the cross-source join key for aggregation: unlike
// `podcast_id` it is the same value whichever way the user found the
// podcast. Omitted (not sent empty) when unknown so GA does not bucket
// unrelated events under "".
Map<String, Object> _feedUrlParam(String? feedUrl) =>
    feedUrl == null || feedUrl.isEmpty
    ? const {}
    : {'feed_url': _trim(feedUrl)};

Map<String, Object> _speedParam(double? speed) =>
    speed == null ? const {} : {'speed': speed};

/// Resolves the `podcast_id` analytics param: the raw iTunes ID when it is
/// a real one, else the feed URL. OPML imports carry a synthetic
/// `opml:`-prefixed iTunes ID that must never reach GA.
///
/// Returns null when neither source is usable so emitters can skip.
String? analyticsPodcastId({
  required String? itunesId,
  required String? feedUrl,
}) {
  if (itunesId != null &&
      itunesId.isNotEmpty &&
      !itunesId.startsWith('opml:')) {
    return itunesId;
  }
  if (feedUrl != null && feedUrl.isNotEmpty) return feedUrl;
  return null;
}

/// Podcast/episode identity shared by episode-scoped events.
typedef EpisodeAnalyticsIds = ({
  String podcastId,
  String? feedUrl,
  String episodeId,
  String podcastTitle,
  String episodeTitle,
});

class PodcastSubscribed extends AnalyticsEvent {
  const PodcastSubscribed({
    required this.podcastId,
    this.feedUrl,
    required this.podcastTitle,
    required this.source,
  });
  final String podcastId;
  final String? feedUrl;
  final String podcastTitle;
  final SubscribeSource source;
  @override
  String get name => 'podcast_subscribe';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'podcast_title': _trim(podcastTitle),
    'source': source.name,
  };
}

class PodcastUnsubscribed extends AnalyticsEvent {
  const PodcastUnsubscribed({
    required this.podcastId,
    this.feedUrl,
    required this.podcastTitle,
  });
  final String podcastId;
  final String? feedUrl;
  final String podcastTitle;
  @override
  String get name => 'podcast_unsubscribe';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'podcast_title': _trim(podcastTitle),
  };
}

class EpisodePlayStarted extends AnalyticsEvent {
  const EpisodePlayStarted({
    required this.podcastId,
    this.feedUrl,
    required this.episodeId,
    required this.podcastTitle,
    required this.episodeTitle,
    required this.source,
    this.speed,
  });
  final String podcastId;
  final String? feedUrl;
  final String episodeId;
  final String podcastTitle;
  final String episodeTitle;
  final PlaySource source;
  final double? speed;
  @override
  String get name => 'episode_play_start';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'episode_id': _trim(episodeId),
    'podcast_title': _trim(podcastTitle),
    'episode_title': _trim(episodeTitle),
    'source': source.name,
    ..._speedParam(speed),
  };
}

class EpisodePaused extends AnalyticsEvent {
  const EpisodePaused({
    required this.podcastId,
    this.feedUrl,
    required this.episodeId,
    required this.podcastTitle,
    required this.episodeTitle,
    required this.positionSec,
  });
  final String podcastId;
  final String? feedUrl;
  final String episodeId;
  final String podcastTitle;
  final String episodeTitle;
  final int positionSec;
  @override
  String get name => 'episode_pause';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'episode_id': _trim(episodeId),
    'podcast_title': _trim(podcastTitle),
    'episode_title': _trim(episodeTitle),
    'position_sec': positionSec,
  };
}

class EpisodeResumed extends AnalyticsEvent {
  const EpisodeResumed({
    required this.podcastId,
    this.feedUrl,
    required this.episodeId,
    required this.podcastTitle,
    required this.episodeTitle,
    required this.positionSec,
  });
  final String podcastId;
  final String? feedUrl;
  final String episodeId;
  final String podcastTitle;
  final String episodeTitle;
  final int positionSec;
  @override
  String get name => 'episode_resume';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'episode_id': _trim(episodeId),
    'podcast_title': _trim(podcastTitle),
    'episode_title': _trim(episodeTitle),
    'position_sec': positionSec,
  };
}

class EpisodeCompleted extends AnalyticsEvent {
  const EpisodeCompleted({
    required this.podcastId,
    this.feedUrl,
    required this.episodeId,
    required this.podcastTitle,
    required this.episodeTitle,
    required this.durationSec,
    this.speed,
  });
  final String podcastId;
  final String? feedUrl;
  final String episodeId;
  final String podcastTitle;
  final String episodeTitle;
  final int durationSec;
  final double? speed;
  @override
  String get name => 'episode_complete';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'episode_id': _trim(episodeId),
    'podcast_title': _trim(podcastTitle),
    'episode_title': _trim(episodeTitle),
    'duration_sec': durationSec,
    ..._speedParam(speed),
  };
}

class EpisodeSeeked extends AnalyticsEvent {
  const EpisodeSeeked({
    required this.podcastId,
    this.feedUrl,
    required this.episodeId,
    required this.podcastTitle,
    required this.episodeTitle,
    required this.fromSec,
    required this.toSec,
  });
  final String podcastId;
  final String? feedUrl;
  final String episodeId;
  final String podcastTitle;
  final String episodeTitle;
  final int fromSec;
  final int toSec;
  @override
  String get name => 'episode_seek';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'episode_id': _trim(episodeId),
    'podcast_title': _trim(podcastTitle),
    'episode_title': _trim(episodeTitle),
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

/// A search result the user opened. The query text is deliberately not
/// sent (it can contain personal data); [rank] and [resultCount] are
/// enough to measure result quality.
class SearchResultSelected extends AnalyticsEvent {
  const SearchResultSelected({
    required this.podcastId,
    required this.feedUrl,
    required this.podcastTitle,
    required this.rank,
    required this.resultCount,
  });
  final String podcastId;
  final String? feedUrl;
  final String podcastTitle;

  /// 1-based display position.
  final int rank;
  final int resultCount;
  @override
  String get name => 'search_result_select';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'podcast_title': _trim(podcastTitle),
    'rank': rank,
    'result_count': resultCount,
  };
}

class EpisodeDownloadStarted extends AnalyticsEvent {
  const EpisodeDownloadStarted({
    required this.podcastId,
    this.feedUrl,
    required this.episodeId,
    required this.podcastTitle,
    required this.episodeTitle,
  });
  final String podcastId;
  final String? feedUrl;
  final String episodeId;
  final String podcastTitle;
  final String episodeTitle;
  @override
  String get name => 'episode_download_start';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'episode_id': _trim(episodeId),
    'podcast_title': _trim(podcastTitle),
    'episode_title': _trim(episodeTitle),
  };
}

class EpisodeDownloadCompleted extends AnalyticsEvent {
  const EpisodeDownloadCompleted({
    required this.podcastId,
    this.feedUrl,
    required this.episodeId,
    required this.podcastTitle,
    required this.episodeTitle,
    required this.bytes,
  });
  final String podcastId;
  final String? feedUrl;
  final String episodeId;
  final String podcastTitle;
  final String episodeTitle;
  final int bytes;
  @override
  String get name => 'episode_download_complete';
  @override
  Map<String, Object> get params => {
    'podcast_id': _trim(podcastId),
    ..._feedUrlParam(feedUrl),
    'episode_id': _trim(episodeId),
    'podcast_title': _trim(podcastTitle),
    'episode_title': _trim(episodeTitle),
    'bytes': bytes,
  };
}

class SmartPlaylistPlayed extends AnalyticsEvent {
  const SmartPlaylistPlayed({required this.presetId, required this.playlistId});
  final String presetId;
  final String playlistId;
  @override
  String get name => 'smart_playlist_play';
  @override
  Map<String, Object> get params => {
    'preset_id': presetId,
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

class ParentalControlEnabled extends AnalyticsEvent {
  const ParentalControlEnabled();
  @override
  String get name => 'parental_control_enabled';
  @override
  Map<String, Object> get params => const {};
}

class ParentalControlDisabled extends AnalyticsEvent {
  const ParentalControlDisabled();
  @override
  String get name => 'parental_control_disabled';
  @override
  Map<String, Object> get params => const {};
}

class ParentalControlUnlockSuccess extends AnalyticsEvent {
  const ParentalControlUnlockSuccess({required this.reason});
  final String reason;
  @override
  String get name => 'parental_control_unlock_success';
  @override
  Map<String, Object> get params => {'reason': reason};
}

class ParentalControlUnlockFailed extends AnalyticsEvent {
  const ParentalControlUnlockFailed({required this.attempts});
  final int attempts;
  @override
  String get name => 'parental_control_unlock_failed';
  @override
  Map<String, Object> get params => {'attempts': attempts};
}

class ParentalControlLockout extends AnalyticsEvent {
  const ParentalControlLockout({
    required this.attempts,
    required this.durationSeconds,
  });
  final int attempts;
  final int durationSeconds;
  @override
  String get name => 'parental_control_lockout';
  @override
  Map<String, Object> get params => {
    'attempts': attempts,
    'duration_seconds': durationSeconds,
  };
}
