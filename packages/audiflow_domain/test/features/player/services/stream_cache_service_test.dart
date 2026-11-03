import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStore implements StreamCacheStore {
  int? configuredMaxBytes;
  Object? configureError;
  int storedBytes = 0;
  List<String> stored = [];
  final List<String> removed = [];
  final List<bool> clears = [];
  final Set<String> failingRemovals = {};

  @override
  Future<void> configure({required int maxBytes}) async {
    if (configureError != null) throw configureError!;
    configuredMaxBytes = maxBytes;
  }

  @override
  Future<int> size() async => storedBytes;

  @override
  Future<List<String>> urls() async => stored;

  @override
  Future<void> clear({required bool includeInUse}) async {
    clears.add(includeInUse);
  }

  @override
  Future<void> remove(String url) async {
    if (failingRemovals.contains(url)) throw Exception('remove failed');
    removed.add(url);
  }
}

void main() {
  const finishedUrl = 'https://example.com/finished.mp3';
  const downloadedUrl = 'https://example.com/downloaded.mp3';
  const otherUrl = 'https://example.com/other.mp3';
  final now = DateTime(2026, 11, 2, 12);

  late _FakeStore store;
  late List<String> completedDownloads;
  late List<String> finishedEpisodes;
  late List<DateTime> finishedQueries;
  late bool playerIdle;
  late DateTime clockNow;

  StreamCacheService buildService() {
    return StreamCacheService(
      store: store,
      completedDownloadUrls: () async => completedDownloads,
      finishedEpisodeUrls: (time) async {
        finishedQueries.add(time);
        return finishedEpisodes;
      },
      isPlayerIdle: () => playerIdle,
      clock: () => clockNow,
    );
  }

  setUp(() {
    store = _FakeStore();
    completedDownloads = [];
    finishedEpisodes = [];
    finishedQueries = [];
    playerIdle = true;
    clockNow = now;
  });

  group('configure', () {
    test('applies the app limit', () async {
      await buildService().configure();

      check(store.configuredMaxBytes).equals(AppConstants.streamCacheMaxBytes);
    });

    test(
      'swallows a failure, since playback works without the cache',
      () async {
        store.configureError = StateError('no cache');

        await buildService().configure();

        check(store.configuredMaxBytes).isNull();
      },
    );
  });

  group('clear', () {
    test('includes the loaded stream when the player is idle', () async {
      await buildService().clear();

      check(store.clears).deepEquals([true]);
    });

    test('keeps the loaded stream while the player holds it', () async {
      playerIdle = false;

      await buildService().clear();

      check(store.clears).deepEquals([false]);
    });

    test('clearForReset includes the loaded stream regardless', () async {
      playerIdle = false;

      await buildService().clearForReset();

      check(store.clears).deepEquals([true]);
    });
  });

  group('sweep', () {
    test('removes finished episodes and completed downloads only', () async {
      store.stored = [finishedUrl, downloadedUrl, otherUrl];
      finishedEpisodes = [finishedUrl];
      completedDownloads = [downloadedUrl];

      check(await buildService().sweep()).equals(2);

      check(store.removed).unorderedEquals([finishedUrl, downloadedUrl]);
    });

    test('asks for episodes finished a whole grace period ago', () async {
      store.stored = [otherUrl];

      await buildService().sweep();

      check(
        finishedQueries,
      ).deepEquals([now.subtract(AppConstants.playedDownloadGracePeriod)]);
    });

    test('matches feed URLs in the form the player keys them', () async {
      const rawUrl = 'https://Example.com/エピソード 1.mp3';
      final cacheKey = Uri.parse(rawUrl).toString();
      check(cacheKey).not((it) => it.equals(rawUrl));
      store.stored = [cacheKey];
      finishedEpisodes = [rawUrl];

      check(await buildService().sweep()).equals(1);

      check(store.removed).deepEquals([cacheKey]);
    });

    test('queries nothing when the cache is empty', () async {
      await buildService().sweep();

      check(finishedQueries).isEmpty();
    });

    test('one failed removal does not stop the others', () async {
      store.stored = [downloadedUrl, finishedUrl];
      completedDownloads = [downloadedUrl];
      finishedEpisodes = [finishedUrl];
      store.failingRemovals.add(downloadedUrl);

      check(await buildService().sweep()).equals(1);

      check(store.removed).deepEquals([finishedUrl]);
    });

    test('a failed query reports nothing removed', () async {
      store.stored = [finishedUrl];
      final service = StreamCacheService(
        store: store,
        completedDownloadUrls: () async => throw StateError('isar'),
        finishedEpisodeUrls: (_) async => const [],
        isPlayerIdle: () => true,
      );

      check(await service.sweep()).equals(0);
    });

    test(
      'queries finished episodes at most once within the interval',
      () async {
        store.stored = [otherUrl];
        final service = buildService();

        await service.sweep();
        clockNow = now.add(const Duration(minutes: 59));
        await service.sweep();
        check(finishedQueries).length.equals(1);

        clockNow = now.add(const Duration(hours: 1));
        await service.sweep();
        check(finishedQueries).length.equals(2);
      },
    );

    test('removes a download completed within the interval', () async {
      store.stored = [downloadedUrl];
      final service = buildService();

      check(await service.sweep()).equals(0);
      completedDownloads = [downloadedUrl];
      clockNow = now.add(const Duration(minutes: 1));

      check(await service.sweep()).equals(1);

      check(store.removed).deepEquals([downloadedUrl]);
    });

    test('a failed sweep does not use up the interval', () async {
      store.stored = [finishedUrl];
      var fail = true;
      final service = StreamCacheService(
        store: store,
        completedDownloadUrls: () async => const [],
        finishedEpisodeUrls: (_) async {
          if (fail) throw StateError('isar');
          return [finishedUrl];
        },
        isPlayerIdle: () => true,
        clock: () => clockNow,
      );

      check(await service.sweep()).equals(0);
      fail = false;
      clockNow = now.add(const Duration(minutes: 1));

      check(await service.sweep()).equals(1);
    });

    test('an empty cache does not use up the interval', () async {
      final service = buildService();

      await service.sweep();
      store.stored = [finishedUrl];
      finishedEpisodes = [finishedUrl];
      clockNow = now.add(const Duration(minutes: 1));

      check(await service.sweep()).equals(1);
    });
  });
}
