import 'package:audiflow_core/audiflow_core.dart'
    show AutoPlayOrder, DuckInterruptionBehavior;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({
    bool autoSync = true,
    bool wifiOnlySync = false,
    bool notifyNewEpisodes = false,
    bool wifiOnlyDownload = false,
    int syncIntervalMinutes = 60,
  }) : _autoSync = autoSync,
       _wifiOnlySync = wifiOnlySync,
       _notifyNewEpisodes = notifyNewEpisodes,
       _wifiOnlyDownload = wifiOnlyDownload,
       _syncIntervalMinutes = syncIntervalMinutes;

  final bool _autoSync;
  final bool _wifiOnlySync;
  final bool _notifyNewEpisodes;
  final bool _wifiOnlyDownload;
  final int _syncIntervalMinutes;

  @override
  bool getAutoSync() => _autoSync;

  @override
  bool getWifiOnlySync() => _wifiOnlySync;

  @override
  bool getNotifyNewEpisodes() => _notifyNewEpisodes;

  @override
  bool getWifiOnlyDownload() => _wifiOnlyDownload;

  @override
  int getSyncIntervalMinutes() => _syncIntervalMinutes;

  // Unused interface methods — no-op stubs
  @override
  ThemeMode getThemeMode() => ThemeMode.system;
  @override
  Future<void> setThemeMode(ThemeMode mode) async {}
  @override
  String? getLocale() => null;
  @override
  Future<void> setLocale(String? locale) async {}
  @override
  double getTextScale() => 1.0;
  @override
  Future<void> setTextScale(double scale) async {}
  @override
  double getPlaybackSpeed() => 1.0;
  @override
  Future<void> setPlaybackSpeed(double speed) async {}
  @override
  int getSkipForwardSeconds() => 30;
  @override
  Future<void> setSkipForwardSeconds(int seconds) async {}
  @override
  int getSkipBackwardSeconds() => 15;
  @override
  Future<void> setSkipBackwardSeconds(int seconds) async {}
  @override
  double getAutoCompleteThreshold() => 0.9;
  @override
  Future<void> setAutoCompleteThreshold(double threshold) async {}
  @override
  bool getContinuousPlayback() => true;
  @override
  Future<void> setContinuousPlayback(bool enabled) async {}
  @override
  AutoPlayOrder getAutoPlayOrder() => AutoPlayOrder.oldestFirst;
  @override
  Future<void> setAutoPlayOrder(AutoPlayOrder order) async {}
  @override
  DuckInterruptionBehavior getDuckInterruptionBehavior() =>
      DuckInterruptionBehavior.duck;
  @override
  Future<void> setDuckInterruptionBehavior(
    DuckInterruptionBehavior behavior,
  ) async {}
  @override
  Future<void> setWifiOnlyDownload(bool enabled) async {}
  @override
  bool getAutoDeletePlayed() => false;
  @override
  Future<void> setAutoDeletePlayed(bool enabled) async {}
  @override
  int getMaxConcurrentDownloads() => 3;
  @override
  Future<void> setMaxConcurrentDownloads(int count) async {}
  @override
  int getBatchDownloadLimit() => 25;
  @override
  Future<void> setBatchDownloadLimit(int limit) async {}
  @override
  Future<void> setAutoSync(bool enabled) async {}
  @override
  Future<void> setSyncIntervalMinutes(int minutes) async {}
  @override
  Future<void> setWifiOnlySync(bool enabled) async {}
  @override
  Future<void> setNotifyNewEpisodes(bool enabled) async {}
  @override
  String? getSearchCountry() => null;
  @override
  Future<void> setSearchCountry(String? country) async {}
  @override
  int getLastTabIndex() => 0;
  @override
  Future<void> setLastTabIndex(int index) async {}
  @override
  Future<void> clearAll() async {}
}

class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({List<Subscription>? subscriptions})
    : _subscriptions = subscriptions ?? [];

  final List<Subscription> _subscriptions;
  bool getSubscriptionsCalled = false;

  @override
  Future<List<Subscription>> getSubscriptions() async {
    getSubscriptionsCalled = true;
    return List.unmodifiable(_subscriptions);
  }

  // Unused interface methods — no-op stubs
  @override
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
    SubscribeSource source = SubscribeSource.unknown,
  }) async => throw UnimplementedError();

  @override
  Future<void> unsubscribe(String itunesId) async {}

  @override
  Future<bool> isSubscribed(String itunesId) async => false;

  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) async => false;

  @override
  Stream<List<Subscription>> watchSubscriptions() => const Stream.empty();

  @override
  Future<Subscription?> getSubscription(String itunesId) async => null;

  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) async => null;

  @override
  Future<Subscription?> getById(int id) async => null;

  @override
  Future<void> updateLastRefreshed(String itunesId, DateTime timestamp) async {}

  @override
  Future<Subscription> getOrCreateCached({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
  }) async => throw UnimplementedError();

  @override
  Future<Subscription?> promoteToSubscribed(String itunesId) async => null;

  @override
  Future<void> updateLastAccessed(int id) async {}

  @override
  Future<List<Subscription>> getCachedSubscriptions() async => [];

  @override
  Future<bool> deleteById(int id) async => false;

  @override
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) async {}

  @override
  Future<void> updateDescription(int id, String? description) async {}

  @override
  Future<void> updateHttpCacheHeaders(
    int id, {
    String? etag,
    String? lastModified,
  }) async {}

  @override
  Future<void> clearAllHttpCacheHeaders() async {}
}

class FakeEpisodeRepository implements EpisodeRepository {
  FakeEpisodeRepository({Map<int, List<Episode>>? episodesByPodcastId})
    : _episodesByPodcastId = episodesByPodcastId ?? {};

  final Map<int, List<Episode>> _episodesByPodcastId;

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async =>
      _episodesByPodcastId[podcastId] ?? [];

  // Unused interface methods — no-op stubs
  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) => const Stream.empty();
  @override
  Future<Episode?> getById(int id) async => null;
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => null;
  @override
  Future<void> upsertEpisodes(List<Episode> episodes) async {}
  @override
  Future<void> upsertFromFeedItems(
    int podcastId,
    List<PodcastItem> items, {
    NumberingExtractor? extractor,
  }) async {}
  @override
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List<PodcastItem> items, {
    required SmartPlaylistPatternConfig config,
  }) async {}
  @override
  Future<List<Episode>> getByIds(List<int> ids) async => [];
  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async => {};
  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async => null;
  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) async {}
  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) async =>
      null;
  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) async => [];
  @override
  Future<int> deleteByPodcastIdAndGuids(
    int podcastId,
    Set<String> guids,
  ) async => 0;
  @override
  Future<List<Episode>> getPendingAutoDownloadByPodcastId(
    int podcastId,
  ) async => const [];
  @override
  Future<void> markAutoDownloadEnqueued(Iterable<int> ids) async {}
}

class FakeAutoDownloadEnqueuer implements AutoDownloadEnqueuer {
  final List<({int podcastId, bool autoDownload, bool wifiOnly})> calls = [];

  @override
  Future<AutoDownloadEnqueueResult> enqueueForSubscription(
    Subscription subscription, {
    required bool wifiOnly,
  }) async {
    calls.add((
      podcastId: subscription.id,
      autoDownload: subscription.autoDownload,
      wifiOnly: wifiOnly,
    ));
    return const AutoDownloadEnqueueResult(
      inspected: 0,
      created: 0,
      skipped: 0,
    );
  }
}

class FakeDownloadRepository implements DownloadRepository {
  final List<({int episodeId, String audioUrl, bool wifiOnly})>
  createdDownloads = [];

  @override
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
  }) async {
    createdDownloads.add((
      episodeId: episodeId,
      audioUrl: audioUrl,
      wifiOnly: wifiOnly,
    ));
    return null;
  }

  // Unused interface methods — no-op stubs
  @override
  Future<DownloadTask?> getById(int id) async => null;
  @override
  Future<DownloadTask?> getByEpisodeId(int episodeId) async => null;
  @override
  Stream<DownloadTask?> watchByEpisodeId(int episodeId) => const Stream.empty();
  @override
  Future<List<DownloadTask>> getAll() async => [];
  @override
  Stream<List<DownloadTask>> watchAll() => const Stream.empty();
  @override
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) async => [];
  @override
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status) =>
      const Stream.empty();
  @override
  Future<DownloadTask?> getCompletedForEpisode(int episodeId) async => null;
  @override
  Future<DownloadTask?> getNextPending({required bool isOnWifi}) async => null;
  @override
  Future<void> updateProgress({
    required int id,
    required int downloadedBytes,
    int? totalBytes,
  }) async {}
  @override
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  }) async {}
  @override
  Future<void> incrementRetryCount(int id) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<int> getActiveCount() async => 0;
  @override
  Future<int> getTotalStorageUsed() async => 0;
  @override
  Future<int> deleteAllCompleted() async => 0;
}

class FakePlaybackHistoryRepository implements PlaybackHistoryRepository {
  FakePlaybackHistoryRepository({Map<int, PlaybackHistory>? historyByEpisodeId})
    : _historyByEpisodeId = historyByEpisodeId ?? {};

  final Map<int, PlaybackHistory> _historyByEpisodeId;

  @override
  Future<Map<int, PlaybackHistory>> getByPodcastId(int podcastId) async =>
      Map.unmodifiable(_historyByEpisodeId);

  @override
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) async =>
      _historyByEpisodeId[episodeId];

  // Unused interface methods — no-op stubs
  @override
  Future<void> saveProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
    int listenedDeltaMs = 0,
    int realtimeDeltaMs = 0,
  }) async {}
  @override
  Future<void> markCompleted(int episodeId) async {}
  @override
  Future<void> markIncomplete(int episodeId) async {}
  @override
  Future<void> incrementPlayCount(int episodeId) async {}
  @override
  Future<bool> isCompleted(int episodeId) async => false;
  @override
  Future<double?> getProgressPercent(int episodeId) async => null;
  @override
  Future<PlaybackHistory?> getLastPlayed() async => null;
  @override
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) =>
      const Stream.empty();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Subscription _makeSubscription({
  required int id,
  required String title,
  DateTime? subscribedAt,
  DateTime? lastAccessedAt,
  bool autoDownload = false,
}) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/feed/$id'
    ..title = title
    ..artistName = 'Artist $id'
    ..subscribedAt = subscribedAt ?? DateTime(2024, 1, id)
    ..lastAccessedAt = lastAccessedAt
    ..autoDownload = autoDownload;
}

Episode _makeEpisode({
  required int id,
  required int podcastId,
  required String title,
}) {
  return Episode()
    ..id = id
    ..podcastId = podcastId
    ..guid = 'guid_$id'
    ..title = title
    ..audioUrl = 'https://example.com/audio/$id.mp3';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BackgroundRefreshService', () {
    test('returns early when auto-sync is disabled', () async {
      final settings = FakeAppSettingsRepository(autoSync: false);
      final subscriptionRepo = FakeSubscriptionRepository(
        subscriptions: [_makeSubscription(id: 1, title: 'Podcast 1')],
      );
      final episodeRepo = FakeEpisodeRepository();
      final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
      var syncCallCount = 0;
      var notifyCallCount = 0;

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        autoDownloadEnqueuer: autoDownloadEnqueuer,
        playbackHistoryRepo: FakePlaybackHistoryRepository(),
        settingsRepo: settings,
        syncFeed: (sub) async {
          syncCallCount++;
          return SingleFeedSyncResult(
            podcastId: sub.id,
            success: true,
            skipped: false,
          );
        },
        showNotification: (notifications) async {
          notifyCallCount++;
        },
      );

      await service.execute();

      expect(subscriptionRepo.getSubscriptionsCalled, isFalse);
      expect(syncCallCount, 0);
      expect(notifyCallCount, 0);
    });

    test(
      'sorts subscriptions by lastAccessedAt descending, null falls back to subscribedAt',
      () async {
        // Sub A: no lastAccessedAt, subscribedAt = Jan 5
        final subA = _makeSubscription(
          id: 1,
          title: 'Sub A',
          subscribedAt: DateTime(2025, 1, 5),
          lastAccessedAt: null,
        );

        // Sub B: lastAccessedAt = Jan 9
        final subB = _makeSubscription(
          id: 2,
          title: 'Sub B',
          subscribedAt: DateTime(2025, 1, 1),
          lastAccessedAt: DateTime(2025, 1, 9),
        );

        // Sub C: lastAccessedAt = Jan 7
        final subC = _makeSubscription(
          id: 3,
          title: 'Sub C',
          subscribedAt: DateTime(2025, 1, 1),
          lastAccessedAt: DateTime(2025, 1, 7),
        );

        final settings = FakeAppSettingsRepository(autoSync: true);
        final subscriptionRepo = FakeSubscriptionRepository(
          subscriptions: [subA, subB, subC],
        );
        final episodeRepo = FakeEpisodeRepository();
        final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
        final syncedIds = <int>[];

        final service = BackgroundRefreshService(
          subscriptionRepo: subscriptionRepo,
          episodeRepo: episodeRepo,
          autoDownloadEnqueuer: autoDownloadEnqueuer,
          playbackHistoryRepo: FakePlaybackHistoryRepository(),
          settingsRepo: settings,
          syncFeed: (sub) async {
            syncedIds.add(sub.id);
            return SingleFeedSyncResult(
              podcastId: sub.id,
              success: true,
              skipped: false,
            );
          },
          showNotification: (_) async {},
          timeBudget: const Duration(seconds: 60),
        );

        await service.execute();

        // Expected order: B (Jan 9) -> C (Jan 7) -> A (falls back to Jan 5)
        expect(syncedIds, [2, 3, 1]);
      },
    );

    test('collects per-episode notifications and calls callback', () async {
      final sub = _makeSubscription(id: 10, title: 'My Podcast');
      final episodes = [
        _makeEpisode(id: 101, podcastId: 10, title: 'Episode 1'),
        _makeEpisode(id: 102, podcastId: 10, title: 'Episode 2'),
      ];

      final settings = FakeAppSettingsRepository(
        autoSync: true,
        notifyNewEpisodes: true,
      );
      final subscriptionRepo = FakeSubscriptionRepository(subscriptions: [sub]);
      final episodeRepo = FakeEpisodeRepository(
        episodesByPodcastId: {10: episodes},
      );
      final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
      List<NewEpisodeNotification>? capturedNotifications;

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        autoDownloadEnqueuer: autoDownloadEnqueuer,
        playbackHistoryRepo: FakePlaybackHistoryRepository(),
        settingsRepo: settings,
        syncFeed: (sub) async => SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: false,
          newEpisodeCount: 2,
        ),
        showNotification: (notifications) async {
          capturedNotifications = notifications;
        },
        timeBudget: const Duration(seconds: 60),
      );

      await service.execute();

      expect(capturedNotifications, isNotNull);
      expect(capturedNotifications!.length, 2);
      expect(capturedNotifications![0].episodeId, 101);
      expect(capturedNotifications![0].podcastTitle, 'My Podcast');
      expect(capturedNotifications![0].episodeTitle, 'Episode 1');
      expect(capturedNotifications![1].episodeId, 102);
      expect(capturedNotifications![1].episodeTitle, 'Episode 2');
    });

    test('caps notifications at 7', () async {
      // 3 podcasts x 4 new episodes each = 12, but capped at 7
      final subscriptions = [
        _makeSubscription(id: 1, title: 'Podcast 1'),
        _makeSubscription(id: 2, title: 'Podcast 2'),
        _makeSubscription(id: 3, title: 'Podcast 3'),
      ];
      final episodesByPodcastId = <int, List<Episode>>{};
      for (final sub in subscriptions) {
        episodesByPodcastId[sub.id] = List.generate(
          4,
          (i) => _makeEpisode(
            id: sub.id * 100 + i,
            podcastId: sub.id,
            title: 'Episode $i of ${sub.title}',
          ),
        );
      }

      final settings = FakeAppSettingsRepository(
        autoSync: true,
        notifyNewEpisodes: true,
      );
      final subscriptionRepo = FakeSubscriptionRepository(
        subscriptions: subscriptions,
      );
      final episodeRepo = FakeEpisodeRepository(
        episodesByPodcastId: episodesByPodcastId,
      );
      final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
      List<NewEpisodeNotification>? capturedNotifications;

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        autoDownloadEnqueuer: autoDownloadEnqueuer,
        playbackHistoryRepo: FakePlaybackHistoryRepository(),
        settingsRepo: settings,
        syncFeed: (sub) async => SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: false,
          newEpisodeCount: 4,
        ),
        showNotification: (notifications) async {
          capturedNotifications = notifications;
        },
        timeBudget: const Duration(seconds: 60),
      );

      await service.execute();

      expect(capturedNotifications, isNotNull);
      expect(capturedNotifications!.length, 7);
    });

    test(
      'continues syncing subsequent subscriptions after one fails and rethrows summary',
      () async {
        final subs = [
          _makeSubscription(id: 1, title: 'Podcast 1'),
          _makeSubscription(id: 2, title: 'Podcast 2'),
          _makeSubscription(id: 3, title: 'Podcast 3'),
        ];

        final settings = FakeAppSettingsRepository(autoSync: true);
        final subscriptionRepo = FakeSubscriptionRepository(
          subscriptions: subs,
        );
        final episodeRepo = FakeEpisodeRepository();
        final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
        final syncedIds = <int>[];

        final service = BackgroundRefreshService(
          subscriptionRepo: subscriptionRepo,
          episodeRepo: episodeRepo,
          autoDownloadEnqueuer: autoDownloadEnqueuer,
          playbackHistoryRepo: FakePlaybackHistoryRepository(),
          settingsRepo: settings,
          syncFeed: (sub) async {
            syncedIds.add(sub.id);
            if (sub.id == 1) {
              throw Exception('simulated feed failure for subscription 1');
            }
            return SingleFeedSyncResult(
              podcastId: sub.id,
              success: true,
              skipped: false,
            );
          },
          showNotification: (_) async {},
          timeBudget: const Duration(seconds: 60),
        );

        await expectLater(
          () => service.execute(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('1 feed(s) failed to sync'),
            ),
          ),
        );

        // All three subscriptions must be attempted despite sub 1 throwing.
        // Sort order: id=3 (Jan 3) → id=2 (Jan 2) → id=1 (Jan 1, oldest).
        expect(syncedIds, [3, 2, 1]);
      },
    );

    test('skips notifications for episodes already played', () async {
      final sub = _makeSubscription(id: 10, title: 'My Podcast');
      final episodes = [
        _makeEpisode(id: 101, podcastId: 10, title: 'Already Listened'),
        _makeEpisode(id: 102, podcastId: 10, title: 'Genuinely New'),
      ];

      final settings = FakeAppSettingsRepository(
        autoSync: true,
        notifyNewEpisodes: true,
      );
      final subscriptionRepo = FakeSubscriptionRepository(subscriptions: [sub]);
      final episodeRepo = FakeEpisodeRepository(
        episodesByPodcastId: {10: episodes},
      );
      final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
      final playbackHistoryRepo = FakePlaybackHistoryRepository(
        historyByEpisodeId: {
          101: PlaybackHistory()
            ..episodeId = 101
            ..completedAt = DateTime(2026, 4, 21),
        },
      );
      List<NewEpisodeNotification>? captured;

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        autoDownloadEnqueuer: autoDownloadEnqueuer,
        playbackHistoryRepo: playbackHistoryRepo,
        settingsRepo: settings,
        syncFeed: (sub) async => SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: false,
          newEpisodeCount: 2,
        ),
        showNotification: (notifications) async {
          captured = notifications;
        },
        timeBudget: const Duration(seconds: 60),
      );

      await service.execute();

      expect(captured, isNotNull);
      expect(captured!.map((n) => n.episodeId), [102]);
    });

    test('skips notifications for episodes with in-progress history', () async {
      final sub = _makeSubscription(id: 10, title: 'My Podcast');
      final episodes = [
        _makeEpisode(id: 201, podcastId: 10, title: 'Partially Heard'),
      ];

      final settings = FakeAppSettingsRepository(
        autoSync: true,
        notifyNewEpisodes: true,
      );
      final subscriptionRepo = FakeSubscriptionRepository(subscriptions: [sub]);
      final episodeRepo = FakeEpisodeRepository(
        episodesByPodcastId: {10: episodes},
      );
      final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
      final playbackHistoryRepo = FakePlaybackHistoryRepository(
        historyByEpisodeId: {
          201: PlaybackHistory()
            ..episodeId = 201
            ..positionMs = 30000,
        },
      );
      var notifyCallCount = 0;

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        autoDownloadEnqueuer: autoDownloadEnqueuer,
        playbackHistoryRepo: playbackHistoryRepo,
        settingsRepo: settings,
        syncFeed: (sub) async => SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: false,
          newEpisodeCount: 1,
        ),
        showNotification: (_) async {
          notifyCallCount++;
        },
        timeBudget: const Duration(seconds: 60),
      );

      await service.execute();

      expect(notifyCallCount, 0);
    });

    test(
      'invokes auto-download enqueuer for every synced subscription, '
      'including those with no new episodes (foreground race coverage)',
      () async {
        final subs = [
          _makeSubscription(id: 1, title: 'Podcast 1', autoDownload: true),
          _makeSubscription(id: 2, title: 'Podcast 2', autoDownload: false),
        ];
        final settings = FakeAppSettingsRepository(
          autoSync: true,
          wifiOnlyDownload: true,
        );
        final subscriptionRepo = FakeSubscriptionRepository(
          subscriptions: subs,
        );
        final episodeRepo = FakeEpisodeRepository();
        final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();

        final service = BackgroundRefreshService(
          subscriptionRepo: subscriptionRepo,
          episodeRepo: episodeRepo,
          autoDownloadEnqueuer: autoDownloadEnqueuer,
          playbackHistoryRepo: FakePlaybackHistoryRepository(),
          settingsRepo: settings,
          syncFeed: (sub) async => SingleFeedSyncResult(
            podcastId: sub.id,
            success: true,
            skipped: false,
            // Zero new episodes — emulates the case where the foreground
            // path already ingested the GUIDs before this background pass.
            newEpisodeCount: 0,
          ),
          showNotification: (_) async {},
          timeBudget: const Duration(seconds: 60),
        );

        await service.execute();

        // Both subscriptions still hit the enqueuer so any backlog left
        // by the foreground path is cleaned up.
        expect(autoDownloadEnqueuer.calls.length, 2);
        expect(
          autoDownloadEnqueuer.calls.map((c) => c.podcastId),
          containsAll([1, 2]),
        );
        expect(
          autoDownloadEnqueuer.calls.every((c) => c.wifiOnly == true),
          isTrue,
        );
      },
    );

    test('does not notify when setting is disabled', () async {
      final sub = _makeSubscription(id: 1, title: 'Podcast 1');
      final episodes = [_makeEpisode(id: 11, podcastId: 1, title: 'Episode 1')];

      final settings = FakeAppSettingsRepository(
        autoSync: true,
        notifyNewEpisodes: false,
      );
      final subscriptionRepo = FakeSubscriptionRepository(subscriptions: [sub]);
      final episodeRepo = FakeEpisodeRepository(
        episodesByPodcastId: {1: episodes},
      );
      final autoDownloadEnqueuer = FakeAutoDownloadEnqueuer();
      var notifyCallCount = 0;

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        autoDownloadEnqueuer: autoDownloadEnqueuer,
        playbackHistoryRepo: FakePlaybackHistoryRepository(),
        settingsRepo: settings,
        syncFeed: (sub) async => SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: false,
          newEpisodeCount: 1,
        ),
        showNotification: (_) async {
          notifyCallCount++;
        },
        timeBudget: const Duration(seconds: 60),
      );

      await service.execute();

      expect(notifyCallCount, 0);
    });
  });
}
