import 'package:audiflow_app/features/car/models/car_list_item.dart';
import 'package:audiflow_app/features/car/services/car_catalog.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Subscription _subscription(int id, String title) => Subscription()
  ..id = id
  ..itunesId = 'itunes-$id'
  ..feedUrl = 'https://example.com/$id.xml'
  ..title = title
  ..artistName = 'Host $id'
  ..artworkUrl = 'https://example.com/$id.jpg'
  ..subscribedAt = DateTime(2026);

Episode _episode(
  int id, {
  int podcastId = 1,
  DateTime? publishedAt,
  String? imageUrl,
  int? durationMs,
  bool explicit = false,
}) => Episode()
  ..id = id
  ..podcastId = podcastId
  ..guid = 'guid-$id'
  ..title = 'Episode $id'
  ..audioUrl = 'https://example.com/$id.mp3'
  ..publishedAt = publishedAt
  ..imageUrl = imageUrl
  ..durationMs = durationMs
  ..itunesExplicit = explicit;

PlaybackHistory _history(
  int episodeId, {
  int positionMs = 0,
  int? durationMs,
}) => PlaybackHistory()
  ..episodeId = episodeId
  ..positionMs = positionMs
  ..durationMs = durationMs;

class _FakeQueueService extends Fake implements QueueService {
  PlaybackQueue queue = const PlaybackQueue();

  @override
  Future<PlaybackQueue> getQueue() async => queue;
}

class _FakeHistoryRepository extends Fake implements PlaybackHistoryRepository {
  List<PlaybackHistory> inProgress = [];
  Map<int, PlaybackHistory> byPodcast = {};

  @override
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) =>
      Stream.value(inProgress.take(limit).toList());

  @override
  Future<Map<int, PlaybackHistory>> getByPodcastId(int podcastId) async =>
      byPodcast;
}

class _FakeEpisodeRepository extends Fake implements EpisodeRepository {
  List<Episode> episodes = [];

  @override
  Future<List<Episode>> getByIds(List<int> ids) async =>
      // Reversed: the repository does not promise any order.
      episodes.where((e) => ids.contains(e.id)).toList().reversed.toList();

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async =>
      episodes.where((e) => e.podcastId == podcastId).toList();
}

class _FakeSubscriptionRepository extends Fake
    implements SubscriptionRepository {
  Map<int, Subscription> subscriptions = {};

  @override
  Future<Subscription?> getById(int id) async => subscriptions[id];
}

class _FakeDownloadRepository extends Fake implements DownloadRepository {
  List<DownloadTask> completed = [];

  @override
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) async =>
      completed;
}

class _FakeParentalControlRepository extends Fake
    implements ParentalControlRepository {
  bool hideExplicit = false;
  bool failRead = false;

  @override
  Future<bool> getHideExplicit(int itunesId) async {
    if (failRead) throw StateError('store unavailable');
    return hideExplicit;
  }
}

void main() {
  late _FakeQueueService queueService;
  late _FakeHistoryRepository historyRepository;
  late _FakeEpisodeRepository episodeRepository;
  late _FakeSubscriptionRepository subscriptionRepository;
  late _FakeDownloadRepository downloadRepository;
  late _FakeParentalControlRepository parentalControlRepository;
  late List<Subscription> sortedSubscriptions;
  String? nowPlayingUrl;
  late CarCatalog catalog;

  final podcastA = _subscription(1, 'Podcast A');
  final podcastB = _subscription(2, 'Podcast B');

  setUp(() {
    queueService = _FakeQueueService();
    historyRepository = _FakeHistoryRepository();
    episodeRepository = _FakeEpisodeRepository();
    subscriptionRepository = _FakeSubscriptionRepository()
      ..subscriptions = {podcastA.id: podcastA, podcastB.id: podcastB};
    downloadRepository = _FakeDownloadRepository();
    parentalControlRepository = _FakeParentalControlRepository();
    sortedSubscriptions = [podcastB, podcastA];
    nowPlayingUrl = null;
    catalog = CarCatalog(
      queueService: queueService,
      historyRepository: historyRepository,
      episodeRepository: episodeRepository,
      subscriptionRepository: subscriptionRepository,
      downloadRepository: downloadRepository,
      parentalControlRepository: parentalControlRepository,
      loadSubscriptions: () async => sortedSubscriptions,
      nowPlayingUrl: () => nowPlayingUrl,
      formatDuration: (duration) => '${duration.inMinutes}m',
    );
  });

  List<int> ids(List<CarListItem> items) => [for (final i in items) i.id];

  group('upNext', () {
    QueueItemWithEpisode queued(int queueItemId, Episode episode) =>
        QueueItemWithEpisode(
          queueItem: QueueItem()
            ..id = queueItemId
            ..episodeId = episode.id
            ..position = queueItemId
            ..addedAt = DateTime(2026),
          episode: episode,
          artworkUrl: 'https://example.com/queued-${episode.id}.jpg',
        );

    test('lists queue items in play order by queue item id', () async {
      final manual = queued(11, _episode(1, podcastId: 2));
      final adhoc = queued(12, _episode(2));
      queueService.queue = PlaybackQueue(
        manualItems: [manual],
        adhocItems: [adhoc],
      );

      final items = await catalog.items(CarSection.upNext);

      check(ids(items)).deepEquals([manual.queueItem.id, adhoc.queueItem.id]);
      check(items.first)
        ..has((i) => i.title, 'title').equals(manual.episode.title)
        ..has((i) => i.detail, 'detail').equals(podcastB.title)
        ..has((i) => i.artworkUrl, 'artworkUrl').equals(manual.artworkUrl);
    });

    test('leaves out the now-playing episode', () async {
      final playing = queued(11, _episode(1));
      final next = queued(12, _episode(2));
      queueService.queue = PlaybackQueue(manualItems: [playing, next]);
      nowPlayingUrl = playing.episode.audioUrl;

      final items = await catalog.items(CarSection.upNext);

      check(ids(items)).deepEquals([next.queueItem.id]);
    });
  });

  group('inProgress', () {
    test('keeps history order and reports progress', () async {
      final first = _episode(1);
      final second = _episode(2, imageUrl: 'https://example.com/ep2.jpg');
      episodeRepository.episodes = [first, second];
      historyRepository.inProgress = [
        _history(second.id, positionMs: 30, durationMs: 120),
        _history(first.id, positionMs: 60, durationMs: 120),
      ];
      nowPlayingUrl = second.audioUrl;

      final items = await catalog.items(CarSection.inProgress);

      check(ids(items)).deepEquals([second.id, first.id]);
      check(items.first)
        ..has((i) => i.progress, 'progress').equals(30 / 120)
        ..has((i) => i.artworkUrl, 'artworkUrl').equals(second.imageUrl)
        ..has((i) => i.isPlaying, 'isPlaying').isTrue();
      check(items.last)
        ..has((i) => i.artworkUrl, 'artworkUrl').equals(podcastA.artworkUrl)
        ..has((i) => i.detail, 'detail').equals(podcastA.title)
        ..has((i) => i.isPlaying, 'isPlaying').isFalse();
    });

    test('drops histories whose episode is gone', () async {
      historyRepository.inProgress = [_history(99, positionMs: 10)];

      check(await catalog.items(CarSection.inProgress)).isEmpty();
    });
  });

  group('library', () {
    test('lists subscriptions in the library sort order', () async {
      final items = await catalog.items(CarSection.library);

      check(ids(items)).deepEquals([podcastB.id, podcastA.id]);
      check(items.first)
        ..has((i) => i.title, 'title').equals(podcastB.title)
        ..has((i) => i.detail, 'detail').equals(podcastB.artistName)
        ..has((i) => i.artworkUrl, 'artworkUrl').equals(podcastB.artworkUrl);
    });
  });

  group('downloads', () {
    DownloadTask task(int episodeId, DateTime completedAt) => DownloadTask()
      ..episodeId = episodeId
      ..audioUrl = 'https://example.com/$episodeId.mp3'
      ..createdAt = DateTime(2025)
      ..completedAt = completedAt;

    test('lists the most recently downloaded first', () async {
      episodeRepository.episodes = [_episode(1), _episode(2)];
      downloadRepository.completed = [
        task(1, DateTime(2026, 1, 1)),
        task(2, DateTime(2026, 2, 1)),
      ];

      final items = await catalog.items(CarSection.downloads);

      check(ids(items)).deepEquals([2, 1]);
    });
  });

  group('podcast', () {
    test('lists episodes newest first with duration and progress', () async {
      final older = _episode(1, publishedAt: DateTime(2026, 1, 1));
      final newer = _episode(
        2,
        publishedAt: DateTime(2026, 2, 1),
        durationMs: const Duration(minutes: 42).inMilliseconds,
      );
      final undated = _episode(3);
      episodeRepository.episodes = [older, undated, newer];
      historyRepository.byPodcast = {
        older.id: _history(older.id, positionMs: 50, durationMs: 100),
      };

      final items = await catalog.items(
        CarSection.podcast,
        podcastId: podcastA.id,
      );

      check(ids(items)).deepEquals([newer.id, older.id, undated.id]);
      check(items.first)
        ..has((i) => i.detail, 'detail').equals('42m')
        ..has((i) => i.artworkUrl, 'artworkUrl').equals(podcastA.artworkUrl)
        ..has((i) => i.progress, 'progress').isNull();
      check(items[1].progress).equals(0.5);
    });

    test('hides explicit episodes when the podcast asks to', () async {
      final clean = _episode(1);
      final explicit = _episode(2, explicit: true);
      episodeRepository.episodes = [clean, explicit];
      parentalControlRepository.hideExplicit = true;

      final items = await catalog.items(
        CarSection.podcast,
        podcastId: podcastA.id,
      );

      check(ids(items)).deepEquals([clean.id]);
    });

    test('hides explicit episodes when the flag cannot be read', () async {
      episodeRepository.episodes = [_episode(1), _episode(2, explicit: true)];
      parentalControlRepository.failRead = true;

      final items = await catalog.items(
        CarSection.podcast,
        podcastId: podcastA.id,
      );

      check(ids(items)).deepEquals([1]);
    });

    test('is empty for a podcast that is not subscribed', () async {
      episodeRepository.episodes = [_episode(1, podcastId: 9)];

      check(await catalog.items(CarSection.podcast, podcastId: 9)).isEmpty();
      check(await catalog.items(CarSection.podcast)).isEmpty();
    });

    test('caps the list at itemLimit', () async {
      episodeRepository.episodes = [
        for (var i = 0; i < CarCatalog.itemLimit + 5; i++) _episode(i),
      ];

      final items = await catalog.items(
        CarSection.podcast,
        podcastId: podcastA.id,
      );

      check(items).length.equals(CarCatalog.itemLimit);
    });
  });
}
