import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../models/car_list_item.dart';
import 'car_artwork_resolver.dart';
import 'car_catalog.dart';
import 'car_playback.dart';

/// A parsed Android Auto media id.
///
/// Browsable ids: the audio_service roots, a tab (`upNext`, `inProgress`,
/// `library`, `downloads`), and `podcast/<podcastId>`. Playable ids:
/// `queue/<queueItemId>` and `episode/<episodeId>`.
sealed class CarMediaId {
  const CarMediaId();

  static const _queuePrefix = 'queue/';
  static const _episodePrefix = 'episode/';
  static const _podcastPrefix = 'podcast/';

  /// The id named by [value], or null for one this build did not issue.
  static CarMediaId? parse(String value) {
    if (value == AudioService.browsableRootId) return const CarRootId();
    if (value == AudioService.recentRootId) return const CarRecentId();
    if (CarSection.byName(value) case final section?) {
      if (section != CarSection.podcast) return CarTabId(section);
    }
    if (_idAfter(_podcastPrefix, value) case final id?) return CarPodcastId(id);
    if (_idAfter(_queuePrefix, value) case final id?) return CarQueueItemId(id);
    if (_idAfter(_episodePrefix, value) case final id?) return CarEpisodeId(id);
    return null;
  }

  static int? _idAfter(String prefix, String value) {
    if (!value.startsWith(prefix)) return null;
    return int.tryParse(value.substring(prefix.length));
  }

  static String tab(CarSection section) => section.name;
  static String podcast(int podcastId) => '$_podcastPrefix$podcastId';
  static String queueItem(int queueItemId) => '$_queuePrefix$queueItemId';
  static String episode(int episodeId) => '$_episodePrefix$episodeId';
}

/// The browsable root: the tabs.
final class CarRootId extends CarMediaId {
  const CarRootId();
}

/// The root Android asks for to offer playback resumption.
final class CarRecentId extends CarMediaId {
  const CarRecentId();
}

final class CarTabId extends CarMediaId {
  const CarTabId(this.section);
  final CarSection section;
}

final class CarPodcastId extends CarMediaId {
  const CarPodcastId(this.podcastId);
  final int podcastId;
}

final class CarQueueItemId extends CarMediaId {
  const CarQueueItemId(this.queueItemId);
  final int queueItemId;
}

final class CarEpisodeId extends CarMediaId {
  const CarEpisodeId(this.episodeId);
  final int episodeId;
}

/// Answers Android Auto's media browser, which audio_service forwards to
/// the audio handler (`getChildren`, `subscribeToChildren`,
/// `playFromMediaId`).
///
/// Android has no signal for a head unit connecting, so the list data is
/// watched from the first browse request for the rest of the process
/// ([onFirstBrowse]). The recent root does not count: Android's own media
/// resumption asks for it on every phone, Android Auto or not.

/// Description extras Android Auto reads to draw a row's progress
/// (`MediaConstants.DESCRIPTION_EXTRAS_KEY_COMPLETION_*` in androidx).
const _completionStatusKey = 'android.media.extra.PLAYBACK_STATUS';
const _completionPercentageKey =
    'androidx.media.MediaItem.Extras.COMPLETION_PERCENTAGE';
const _partiallyPlayed = 1;

class CarMediaBrowser {
  CarMediaBrowser({
    required this._catalog,
    required this._playback,
    required this._artwork,
    required this._tabTitles,
    required this._logger,
    required this._onFirstBrowse,
    this._artworkWait = const Duration(seconds: 2),
  });

  /// The tabs, in the order Android Auto shows them. Android Auto shows at
  /// most four.
  static const tabs = [
    CarSection.upNext,
    CarSection.inProgress,
    CarSection.library,
    CarSection.downloads,
  ];

  final CarCatalog Function() _catalog;
  final CarPlayback _playback;
  final CarArtworkResolver _artwork;
  final Map<CarSection, String> Function() _tabTitles;
  final Logger _logger;
  final void Function() _onFirstBrowse;

  /// How long a list waits for its artwork before it is sent without the
  /// rows still loading; those rows get theirs on the follow-up reload.
  final Duration _artworkWait;

  final Map<String, BehaviorSubject<Map<String, dynamic>>> _subscriptions = {};
  bool _browsed = false;

  /// The children of [parentMediaId]; empty for an id this build does not
  /// know or a list that failed to load.
  Future<List<MediaItem>> getChildren(String parentMediaId) async {
    final id = CarMediaId.parse(parentMediaId);
    if (id is! CarRecentId) _markBrowsed();
    try {
      return await switch (id) {
        CarRootId() => Future.value(_tabItems()),
        CarRecentId() => _recent(),
        CarTabId(:final section) => _rows(parentMediaId, section),
        CarPodcastId(:final podcastId) => _rows(
          parentMediaId,
          CarSection.podcast,
          podcastId: podcastId,
        ),
        _ => Future.value(const <MediaItem>[]),
      };
    } on Object catch (e, stack) {
      _logger.e('Failed to browse $parentMediaId', error: e, stackTrace: stack);
      return const [];
    }
  }

  /// Emits whenever the children of [parentMediaId] change; audio_service
  /// then tells Android Auto to reload them.
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    return _subscriptions.putIfAbsent(
      parentMediaId,
      () => BehaviorSubject.seeded(const {}),
    );
  }

  /// Plays the row [mediaId]. Unknown or browsable ids are ignored.
  Future<void> playFromMediaId(String mediaId) async {
    final played = switch (CarMediaId.parse(mediaId)) {
      CarQueueItemId(:final queueItemId) => _playback.playQueueItem(
        queueItemId,
      ),
      CarEpisodeId(:final episodeId) => _playback.playEpisode(episodeId),
      _ => Future.value(false),
    };
    if (!await played) _logger.w('Nothing to play for $mediaId');
  }

  /// Tells Android Auto to reload the open lists showing [sections].
  void notifyChanged(Set<CarSection> sections) {
    for (final MapEntry(key: parentMediaId, value: subject)
        in _subscriptions.entries) {
      if (sections.contains(_sectionOf(parentMediaId))) subject.add(const {});
    }
  }

  void dispose() {
    for (final subject in _subscriptions.values) {
      unawaited(subject.close());
    }
    _subscriptions.clear();
  }

  void _markBrowsed() {
    if (_browsed) return;
    _browsed = true;
    _onFirstBrowse();
  }

  static CarSection? _sectionOf(String parentMediaId) {
    return switch (CarMediaId.parse(parentMediaId)) {
      CarTabId(:final section) => section,
      CarPodcastId() => CarSection.podcast,
      // Resumption offers the latest in-progress episode.
      CarRecentId() => CarSection.inProgress,
      _ => null,
    };
  }

  List<MediaItem> _tabItems() {
    final titles = _tabTitles();
    return [
      for (final section in tabs)
        MediaItem(
          id: CarMediaId.tab(section),
          title: titles[section] ?? section.name,
          playable: false,
        ),
    ];
  }

  /// The most recently played unfinished episode, for "resume" on the
  /// head unit and the system media controls.
  Future<List<MediaItem>> _recent() async {
    final rows = await _catalog().items(CarSection.inProgress);
    return _toMediaItems(
      AudioService.recentRootId,
      CarSection.inProgress,
      rows.take(1).toList(),
    );
  }

  Future<List<MediaItem>> _rows(
    String parentMediaId,
    CarSection section, {
    int? podcastId,
  }) async {
    final rows = await _catalog().items(section, podcastId: podcastId);
    return _toMediaItems(parentMediaId, section, rows);
  }

  Future<List<MediaItem>> _toMediaItems(
    String parentMediaId,
    CarSection section,
    List<CarListItem> rows,
  ) async {
    final artwork = await _resolveArtwork(parentMediaId, rows);
    return [
      for (final row in rows)
        MediaItem(
          id: _mediaIdOf(row, section),
          title: row.title,
          artist: row.detail,
          displaySubtitle: row.detail,
          artUri: artwork[row.artworkUrl],
          playable: section != CarSection.library,
          extras: _progressExtras(row.progress),
        ),
    ];
  }

  static Map<String, dynamic>? _progressExtras(double? progress) {
    if (progress == null) return null;
    return {
      _completionStatusKey: _partiallyPlayed,
      _completionPercentageKey: progress.clamp(0.0, 1.0),
    };
  }

  static String _mediaIdOf(CarListItem row, CarSection section) {
    return switch (section) {
      CarSection.upNext => CarMediaId.queueItem(row.id),
      CarSection.library => CarMediaId.podcast(row.id),
      CarSection.inProgress ||
      CarSection.downloads ||
      CarSection.podcast => CarMediaId.episode(row.id),
    };
  }

  /// Resolves the artwork of [rows], waiting at most [_artworkWait]. When
  /// some is still loading, [parentMediaId] is reloaded once it has all
  /// arrived, so a first visit fills its images in.
  Future<Map<String, Uri>> _resolveArtwork(
    String parentMediaId,
    List<CarListItem> rows,
  ) async {
    final resolved = <String, Uri>{};
    final urls = {for (final row in rows) ?row.artworkUrl};
    var allDone = false;
    final all = Future.wait([
      for (final url in urls)
        _artwork
            .resolve(url)
            .then((uri) {
              if (uri != null) resolved[url] = uri;
            })
            // One bad image must not empty the whole list.
            .catchError(
              (Object e) => _logger.w('Artwork failed: $url', error: e),
            ),
    ]).then((_) => allDone = true);
    await Future.any([all, Future<void>.delayed(_artworkWait)]);
    final sent = {...resolved};
    if (!allDone) {
      // Reload only when late artwork actually arrived: artwork that keeps
      // failing slowly would otherwise reload (and refetch) forever.
      unawaited(
        all.then((_) {
          if (sent.length < resolved.length) {
            _subscriptions[parentMediaId]?.add(const {});
          }
        }),
      );
    }
    return sent;
  }
}
