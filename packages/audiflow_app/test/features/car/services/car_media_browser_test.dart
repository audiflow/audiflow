import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audiflow_app/features/car/models/car_list_item.dart';
import 'package:audiflow_app/features/car/services/car_artwork_resolver.dart';
import 'package:audiflow_app/features/car/services/car_catalog.dart';
import 'package:audiflow_app/features/car/services/car_media_browser.dart';
import 'package:audiflow_app/features/car/services/car_playback.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

class _FakeCatalog extends Fake implements CarCatalog {
  final rows = <CarSection, List<CarListItem>>{};
  final requests = <(CarSection, int?, int?)>[];

  @override
  Future<List<CarListItem>> items(
    CarSection section, {
    int? podcastId,
    int? stationId,
  }) async {
    requests.add((section, podcastId, stationId));
    return rows[section] ?? const [];
  }
}

class _FakePlayback extends Fake implements CarPlayback {
  final playedEpisodes = <int>[];
  final playedPodcastEpisodes = <int>[];
  final playedStationEpisodes = <(int, int)>[];
  final playedQueueItems = <int>[];

  @override
  Future<bool> playEpisode(int episodeId) async {
    playedEpisodes.add(episodeId);
    return true;
  }

  @override
  Future<bool> playPodcastEpisode(int episodeId) async {
    playedPodcastEpisodes.add(episodeId);
    return true;
  }

  @override
  Future<bool> playStationEpisode(int stationId, int episodeId) async {
    playedStationEpisodes.add((stationId, episodeId));
    return true;
  }

  @override
  Future<bool> playQueueItem(int queueItemId) async {
    playedQueueItems.add(queueItemId);
    return true;
  }
}

/// Resolves each URL to `content://test/<url>`, or holds it until
/// [release] when [hold] is set.
class _FakeArtwork implements CarArtworkResolver {
  bool hold = false;

  // Created on first use, inside the test's fakeAsync zone, so its
  // continuations run on that zone's microtask queue.
  Completer<void>? _held;

  void release() => (_held ??= Completer()).complete();

  static Uri uriFor(String url) =>
      Uri(scheme: 'content', host: 'test', pathSegments: [url]);

  /// URLs that resolve to null (unavailable artwork).
  final missing = <String>{};

  /// URLs whose resolve throws.
  final throwing = <String>{};

  @override
  Future<Uri?> resolve(String artworkUrl) async {
    if (hold) await (_held ??= Completer()).future;
    if (throwing.contains(artworkUrl)) throw StateError('decode failed');
    if (missing.contains(artworkUrl)) return null;
    return uriFor(artworkUrl);
  }
}

void main() {
  const tabTitles = {
    CarSection.upNext: 'Up Next',
    CarSection.stations: 'Stations',
    CarSection.library: 'Library',
    CarSection.downloads: 'Downloads',
  };
  const artworkWait = Duration(seconds: 2);

  late _FakeCatalog catalog;
  late _FakePlayback playback;
  late _FakeArtwork artwork;
  late int firstBrowseCalls;
  late CarMediaBrowser browser;

  setUp(() {
    catalog = _FakeCatalog();
    playback = _FakePlayback();
    artwork = _FakeArtwork();
    firstBrowseCalls = 0;
    browser = CarMediaBrowser(
      catalog: () => catalog,
      playback: playback,
      artwork: artwork,
      tabTitles: () => tabTitles,
      logger: Logger(level: Level.off),
      onFirstBrowse: () => firstBrowseCalls++,
      artworkWait: artworkWait,
    );
  });

  tearDown(() => browser.dispose());

  group('CarMediaId', () {
    test('round-trips every id it issues', () {
      check(CarMediaId.parse(CarMediaId.tab(CarSection.downloads)))
          .isA<CarTabId>()
          .has((id) => id.section, 'section')
          .equals(CarSection.downloads);
      check(
        CarMediaId.parse(CarMediaId.podcast(4)),
      ).isA<CarPodcastId>().has((id) => id.podcastId, 'podcastId').equals(4);
      check(CarMediaId.parse(CarMediaId.queueItem(5)))
          .isA<CarQueueItemId>()
          .has((id) => id.queueItemId, 'queueItemId')
          .equals(5);
      check(
        CarMediaId.parse(CarMediaId.episode(6)),
      ).isA<CarEpisodeId>().has((id) => id.episodeId, 'episodeId').equals(6);
      check(CarMediaId.parse(CarMediaId.podcastEpisode(7)))
          .isA<CarPodcastEpisodeId>()
          .has((id) => id.episodeId, 'episodeId')
          .equals(7);
      check(
        CarMediaId.parse(CarMediaId.station(8)),
      ).isA<CarStationId>().has((id) => id.stationId, 'stationId').equals(8);
      check(
          CarMediaId.parse(CarMediaId.stationEpisode(8, 9)),
        ).isA<CarStationEpisodeId>()
        ..has((id) => id.stationId, 'stationId').equals(8)
        ..has((id) => id.episodeId, 'episodeId').equals(9);
      check(CarMediaId.parse(AudioService.browsableRootId)).isA<CarRootId>();
      check(CarMediaId.parse(AudioService.recentRootId)).isA<CarRecentId>();
    });

    test('rejects ids it did not issue', () {
      for (final id in [
        '',
        'podcast',
        'podcast/x',
        'episode/',
        'podcastEpisode/',
        'station',
        'stationEpisode/1',
        'stationEpisode/1/x',
        'radio/1',
      ]) {
        check(because: id, CarMediaId.parse(id)).isNull();
      }
    });
  });

  group('getChildren', () {
    test('lists the tabs under the root', () async {
      final items = await browser.getChildren(AudioService.browsableRootId);

      check([for (final i in items) i.id]).deepEquals([
        for (final section in CarMediaBrowser.tabs) CarMediaId.tab(section),
      ]);
      check([for (final i in items) i.title]).deepEquals([
        for (final section in CarMediaBrowser.tabs) tabTitles[section]!,
      ]);
      check(items.every((i) => i.playable == false)).isTrue();
    });

    test('maps tab rows to playable ids with artwork', () async {
      const row = CarListItem(
        id: 11,
        title: 'Episode',
        detail: 'Podcast',
        artworkUrl: 'https://example.com/a.jpg',
      );
      catalog.rows[CarSection.upNext] = [row];

      final items = await browser.getChildren(
        CarMediaId.tab(CarSection.upNext),
      );

      check(items.single)
        ..has((i) => i.id, 'id').equals(CarMediaId.queueItem(row.id))
        ..has((i) => i.title, 'title').equals(row.title)
        ..has((i) => i.displaySubtitle, 'subtitle').equals(row.detail)
        ..has(
          (i) => i.artUri,
          'artUri',
        ).equals(_FakeArtwork.uriFor(row.artworkUrl!))
        ..has((i) => i.playable, 'playable').equals(true);
    });

    test(
      'lists podcasts as browsable and their episodes as playable',
      () async {
        catalog.rows[CarSection.library] = [
          const CarListItem(id: 3, title: 'Podcast'),
        ];
        catalog.rows[CarSection.podcast] = [
          const CarListItem(id: 30, title: 'Episode'),
        ];

        final podcasts = await browser.getChildren(
          CarMediaId.tab(CarSection.library),
        );
        final episodes = await browser.getChildren(podcasts.single.id);

        check(podcasts.single)
          ..has((i) => i.id, 'id').equals(CarMediaId.podcast(3))
          ..has((i) => i.playable, 'playable').equals(false);
        check(catalog.requests.last).equals((CarSection.podcast, 3, null));
        check(episodes.single.id).equals(CarMediaId.podcastEpisode(30));
      },
    );

    test(
      'lists stations as browsable and their episodes as playable',
      () async {
        catalog.rows[CarSection.stations] = [
          const CarListItem(id: 4, title: 'Station'),
        ];
        catalog.rows[CarSection.station] = [
          const CarListItem(id: 40, title: 'Episode'),
        ];

        final stations = await browser.getChildren(
          CarMediaId.tab(CarSection.stations),
        );
        final episodes = await browser.getChildren(stations.single.id);

        check(stations.single)
          ..has((i) => i.id, 'id').equals(CarMediaId.station(4))
          ..has((i) => i.playable, 'playable').equals(false);
        check(catalog.requests.last).equals((CarSection.station, null, 4));
        check(episodes.single.id).equals(CarMediaId.stationEpisode(4, 40));
      },
    );

    test('offers only the latest in-progress episode for resumption', () async {
      catalog.rows[CarSection.inProgress] = [
        const CarListItem(id: 1, title: 'Latest'),
        const CarListItem(id: 2, title: 'Older'),
      ];

      final items = await browser.getChildren(AudioService.recentRootId);

      check([for (final i in items) i.id]).deepEquals([CarMediaId.episode(1)]);
    });

    test('is empty for an unknown id', () async {
      check(await browser.getChildren('radio/1')).isEmpty();
    });

    test('does not start watching for the system resumption request', () async {
      await browser.getChildren(AudioService.recentRootId);
      browser.subscribeToChildren(AudioService.recentRootId);

      check(firstBrowseCalls).equals(0);
    });

    test('carries row progress in the completion extras', () async {
      catalog.rows[CarSection.inProgress] = [
        const CarListItem(id: 1, title: 'Half', progress: 0.5),
        const CarListItem(id: 2, title: 'Unplayed'),
      ];

      final items = await browser.getChildren(
        CarMediaId.tab(CarSection.inProgress),
      );

      check(items.first.extras).isNotNull().deepEquals({
        'android.media.extra.PLAYBACK_STATUS': 1,
        'androidx.media.MediaItem.Extras.COMPLETION_PERCENTAGE': 0.5,
      });
      check(items.last.extras).isNull();
    });

    test('keeps the rows when one image fails', () async {
      const bad = 'https://example.com/bad.jpg';
      const good = 'https://example.com/good.jpg';
      artwork.throwing.add(bad);
      catalog.rows[CarSection.downloads] = [
        const CarListItem(id: 1, title: 'Bad', artworkUrl: bad),
        const CarListItem(id: 2, title: 'Good', artworkUrl: good),
      ];

      final items = await browser.getChildren(
        CarMediaId.tab(CarSection.downloads),
      );

      check([
        for (final i in items) i.artUri,
      ]).deepEquals([null, _FakeArtwork.uriFor(good)]);
    });

    test('does not reload for artwork that fails late', () {
      fakeAsync((async) {
        const url = 'https://example.com/gone.jpg';
        catalog.rows[CarSection.downloads] = [
          const CarListItem(id: 1, title: 'Episode', artworkUrl: url),
        ];
        artwork
          ..hold = true
          ..missing.add(url);
        final parent = CarMediaId.tab(CarSection.downloads);
        final reloads = <Object?>[];
        browser.subscribeToChildren(parent).skip(1).listen(reloads.add);

        unawaited(browser.getChildren(parent));
        async.elapse(artworkWait);
        artwork.release();
        async.flushMicrotasks();

        check(reloads).isEmpty();
      });
    });

    test('starts watching data on the first browse only', () async {
      await browser.getChildren(AudioService.browsableRootId);
      browser.subscribeToChildren(AudioService.browsableRootId);

      check(firstBrowseCalls).equals(1);
    });

    test('sends rows without late artwork and reloads once it arrives', () {
      fakeAsync((async) {
        const url = 'https://example.com/slow.jpg';
        catalog.rows[CarSection.downloads] = [
          const CarListItem(id: 1, title: 'Episode', artworkUrl: url),
        ];
        artwork.hold = true;
        final parent = CarMediaId.tab(CarSection.downloads);
        final reloads = <Object?>[];
        browser.subscribeToChildren(parent).skip(1).listen(reloads.add);

        List<MediaItem>? items;
        unawaited(browser.getChildren(parent).then((v) => items = v));
        async.elapse(artworkWait);

        check(items!.single.artUri).isNull();
        check(reloads).isEmpty();

        artwork.release();
        async.flushMicrotasks();
        check(reloads).length.equals(1);
      });
    });
  });

  group('playFromMediaId', () {
    test('plays queue items and episodes', () async {
      await browser.playFromMediaId(CarMediaId.queueItem(7));
      await browser.playFromMediaId(CarMediaId.episode(8));
      await browser.playFromMediaId(CarMediaId.podcastEpisode(9));
      await browser.playFromMediaId(CarMediaId.stationEpisode(4, 10));

      check(playback.playedQueueItems).deepEquals([7]);
      check(playback.playedEpisodes).deepEquals([8]);
      check(playback.playedPodcastEpisodes).deepEquals([9]);
      check(playback.playedStationEpisodes).deepEquals([(4, 10)]);
    });

    test('ignores browsable and unknown ids', () async {
      await browser.playFromMediaId(CarMediaId.podcast(1));
      await browser.playFromMediaId(CarMediaId.station(1));
      await browser.playFromMediaId('radio/1');

      check(playback.playedEpisodes).isEmpty();
      check(playback.playedQueueItems).isEmpty();
    });
  });

  group('notifyChanged', () {
    test('reloads only the subscribed lists showing a changed section', () {
      final reloaded = <String>[];
      for (final parent in [
        CarMediaId.tab(CarSection.upNext),
        CarMediaId.tab(CarSection.library),
        CarMediaId.podcast(3),
        CarMediaId.station(4),
        AudioService.recentRootId,
      ]) {
        browser
            .subscribeToChildren(parent)
            .skip(1)
            .listen((_) => reloaded.add(parent));
      }

      browser.notifyChanged({
        CarSection.podcast,
        CarSection.station,
        CarSection.inProgress,
      });

      return pumpEventQueue().then((_) {
        check(reloaded).unorderedEquals([
          CarMediaId.podcast(3),
          CarMediaId.station(4),
          AudioService.recentRootId,
        ]);
      });
    });
  });
}
