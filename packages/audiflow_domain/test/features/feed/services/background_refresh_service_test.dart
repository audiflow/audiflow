import 'package:audiflow_core/audiflow_core.dart' show AutoPlayOrder;
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
  Future<void> setAutoSync(bool enabled) async {}
  @override
  Future<void> setSyncIntervalMinutes(int minutes) async {}
  @override
  Future<void> setWifiOnlySync(bool enabled) async {}
  @override
  Future<void> setNotifyNewEpisodes(bool enabled) async {}
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
    SmartPlaylistEpisodeExtractor? extractor,
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
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) async {}
  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) async => [];
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

class FakeFeedSyncExecutor {
  FakeFeedSyncExecutor({SingleFeedSyncResult? result})
    : _result =
          result ??
          const SingleFeedSyncResult(
            podcastId: 0,
            success: true,
            skipped: false,
          );

  final SingleFeedSyncResult _result;
  final List<Subscription> syncedSubscriptions = [];

  Future<SingleFeedSyncResult> syncFeed(Subscription sub) async {
    syncedSubscriptions.add(sub);
    return SingleFeedSyncResult(
      podcastId: sub.id,
      success: _result.success,
      skipped: _result.skipped,
      newEpisodeCount: _result.newEpisodeCount,
      errorMessage: _result.errorMessage,
    );
  }
}

class FakeBackgroundNotificationService {
  int showNotificationCallCount = 0;

  Future<void> showNewEpisodesNotification(
    Map<String, int> newEpisodesPerPodcast,
  ) async {
    showNotificationCallCount++;
  }
}

// ---------------------------------------------------------------------------
// Helper: build a minimal Subscription
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
      final downloadRepo = FakeDownloadRepository();
      final syncExecutor = FakeFeedSyncExecutor();
      final notificationService = FakeBackgroundNotificationService();

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
        settingsRepo: settings,
        syncFeed: syncExecutor.syncFeed,
        showNotification: notificationService.showNewEpisodesNotification,
      );

      await service.execute();

      expect(subscriptionRepo.getSubscriptionsCalled, isFalse);
      expect(syncExecutor.syncedSubscriptions, isEmpty);
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
        final downloadRepo = FakeDownloadRepository();
        final syncExecutor = FakeFeedSyncExecutor();
        final notificationService = FakeBackgroundNotificationService();

        final service = BackgroundRefreshService(
          subscriptionRepo: subscriptionRepo,
          episodeRepo: episodeRepo,
          downloadRepo: downloadRepo,
          settingsRepo: settings,
          syncFeed: syncExecutor.syncFeed,
          showNotification: notificationService.showNewEpisodesNotification,
          // Small budget so all run without timing out
          timeBudget: const Duration(seconds: 60),
        );

        await service.execute();

        // Expected order: B (Jan 9) → C (Jan 7) → A (falls back to Jan 5)
        expect(syncExecutor.syncedSubscriptions.map((s) => s.id).toList(), [
          2,
          3,
          1,
        ]);
      },
    );
  });
}
