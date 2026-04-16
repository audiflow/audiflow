import 'package:audiflow_core/audiflow_core.dart'
    show AutoPlayOrder, DuckInterruptionBehavior, SettingsDefaults;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Hand-written fakes (no mockito code generation)
// ---------------------------------------------------------------------------

class _FakeSubscriptionRepository implements SubscriptionRepository {
  String? lastUpdatedItunesId;
  DateTime? lastUpdatedTimestamp;
  int? lastCacheHeadersId;
  String? lastCacheEtag;
  String? lastCacheLastModified;

  @override
  Future<void> updateLastRefreshed(String itunesId, DateTime timestamp) async {
    lastUpdatedItunesId = itunesId;
    lastUpdatedTimestamp = timestamp;
  }

  @override
  Future<void> updateHttpCacheHeaders(
    int id, {
    String? etag,
    String? lastModified,
  }) async {
    lastCacheHeadersId = id;
    lastCacheEtag = etag;
    lastCacheLastModified = lastModified;
  }

  // Unused methods for this test suite
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
  }) => throw UnimplementedError();

  @override
  Future<void> unsubscribe(String itunesId) => throw UnimplementedError();

  @override
  Future<bool> isSubscribed(String itunesId) => throw UnimplementedError();

  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) =>
      throw UnimplementedError();

  @override
  Future<List<Subscription>> getSubscriptions() => throw UnimplementedError();

  @override
  Stream<List<Subscription>> watchSubscriptions() => throw UnimplementedError();

  @override
  Future<Subscription?> getSubscription(String itunesId) =>
      throw UnimplementedError();

  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) =>
      throw UnimplementedError();

  @override
  Future<Subscription?> getById(int id) => throw UnimplementedError();

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
  }) => throw UnimplementedError();

  @override
  Future<Subscription?> promoteToSubscribed(String itunesId) =>
      throw UnimplementedError();

  @override
  Future<void> updateLastAccessed(int id) => throw UnimplementedError();

  @override
  Future<List<Subscription>> getCachedSubscriptions() =>
      throw UnimplementedError();

  @override
  Future<bool> deleteById(int id) => throw UnimplementedError();

  @override
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) =>
      throw UnimplementedError();
}

class _FakeEpisodeRepository implements EpisodeRepository {
  List<Episode> upsertedEpisodes = [];
  Set<String> storedGuids = {};
  List<({int podcastId, Set<String> guids})> deleteCalls = [];

  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async => storedGuids;

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async => null;

  @override
  Future<void> upsertEpisodes(List<Episode> episodes) async {
    upsertedEpisodes.addAll(episodes);
  }

  @override
  Future<int> deleteByPodcastIdAndGuids(
    int podcastId,
    Set<String> guids, {
    Set<String> protectedGuids = const {},
  }) async {
    final effective = guids.difference(protectedGuids);
    deleteCalls.add((podcastId: podcastId, guids: Set.of(effective)));
    return effective.length;
  }

  // Unused methods for this test suite
  @override
  Future<List<Episode>> getByPodcastId(int podcastId) =>
      throw UnimplementedError();

  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) =>
      throw UnimplementedError();

  @override
  Future<Episode?> getById(int id) => throw UnimplementedError();

  @override
  Future<Episode?> getByAudioUrl(String audioUrl) => throw UnimplementedError();

  @override
  Future<void> upsertFromFeedItems(
    int podcastId,
    List<PodcastItem> items, {
    NumberingExtractor? extractor,
  }) => throw UnimplementedError();

  @override
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List<PodcastItem> items, {
    required SmartPlaylistPatternConfig config,
  }) => throw UnimplementedError();

  @override
  Future<List<Episode>> getByIds(List<int> ids) => throw UnimplementedError();

  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) => throw UnimplementedError();

  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) =>
      throw UnimplementedError();

  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) => throw UnimplementedError();
}

class _FakeAppSettingsRepository implements AppSettingsRepository {
  int syncIntervalMinutes;

  _FakeAppSettingsRepository({this.syncIntervalMinutes = 60});

  @override
  int getSyncIntervalMinutes() => syncIntervalMinutes;

  // Remaining methods unused in these tests
  @override
  Future<void> setSyncIntervalMinutes(int minutes) =>
      throw UnimplementedError();

  @override
  bool getAutoSync() => true;

  @override
  Future<void> setAutoSync(bool enabled) => throw UnimplementedError();

  @override
  bool getWifiOnlySync() => false;

  @override
  Future<void> setWifiOnlySync(bool enabled) => throw UnimplementedError();

  @override
  ThemeMode getThemeMode() => throw UnimplementedError();

  @override
  Future<void> setThemeMode(ThemeMode mode) => throw UnimplementedError();

  @override
  String? getLocale() => throw UnimplementedError();

  @override
  Future<void> setLocale(String? locale) => throw UnimplementedError();

  @override
  double getTextScale() => throw UnimplementedError();

  @override
  Future<void> setTextScale(double scale) => throw UnimplementedError();

  @override
  double getPlaybackSpeed() => throw UnimplementedError();

  @override
  Future<void> setPlaybackSpeed(double speed) => throw UnimplementedError();

  @override
  int getSkipForwardSeconds() => throw UnimplementedError();

  @override
  Future<void> setSkipForwardSeconds(int seconds) => throw UnimplementedError();

  @override
  int getSkipBackwardSeconds() => throw UnimplementedError();

  @override
  Future<void> setSkipBackwardSeconds(int seconds) =>
      throw UnimplementedError();

  @override
  double getAutoCompleteThreshold() => throw UnimplementedError();

  @override
  Future<void> setAutoCompleteThreshold(double threshold) =>
      throw UnimplementedError();

  @override
  bool getContinuousPlayback() => throw UnimplementedError();

  @override
  Future<void> setContinuousPlayback(bool enabled) =>
      throw UnimplementedError();

  @override
  AutoPlayOrder getAutoPlayOrder() => throw UnimplementedError();

  @override
  Future<void> setAutoPlayOrder(AutoPlayOrder order) =>
      throw UnimplementedError();

  @override
  DuckInterruptionBehavior getDuckInterruptionBehavior() =>
      throw UnimplementedError();

  @override
  Future<void> setDuckInterruptionBehavior(DuckInterruptionBehavior behavior) =>
      throw UnimplementedError();

  @override
  bool getWifiOnlyDownload() => throw UnimplementedError();

  @override
  Future<void> setWifiOnlyDownload(bool enabled) => throw UnimplementedError();

  @override
  bool getAutoDeletePlayed() => throw UnimplementedError();

  @override
  Future<void> setAutoDeletePlayed(bool enabled) => throw UnimplementedError();

  @override
  int getMaxConcurrentDownloads() => throw UnimplementedError();

  @override
  Future<void> setMaxConcurrentDownloads(int count) =>
      throw UnimplementedError();

  @override
  int getBatchDownloadLimit() => throw UnimplementedError();

  @override
  Future<void> setBatchDownloadLimit(int limit) => throw UnimplementedError();

  @override
  bool getNotifyNewEpisodes() => throw UnimplementedError();

  @override
  Future<void> setNotifyNewEpisodes(bool enabled) => throw UnimplementedError();

  @override
  String? getSearchCountry() => throw UnimplementedError();

  @override
  Future<void> setSearchCountry(String? country) => throw UnimplementedError();

  @override
  int getLastTabIndex() => throw UnimplementedError();

  @override
  Future<void> setLastTabIndex(int index) => throw UnimplementedError();

  @override
  bool getVoiceEnabled() => SettingsDefaults.voiceEnabled;

  @override
  Future<void> setVoiceEnabled(bool enabled) => throw UnimplementedError();

  @override
  Future<void> clearAll() => throw UnimplementedError();
}

class _FakeFeedParserService extends FeedParserService {
  final Stream<FeedParseProgress> Function(
    String xmlContent,
    int podcastId,
    Set<String> knownGuids,
    Future<void> Function(
      List<Episode> episodes,
      List<ParsedEpisodeMediaMeta> mediaMetas,
    )
    onBatchReady,
  )
  _streamFactory;

  _FakeFeedParserService(this._streamFactory);

  @override
  Stream<FeedParseProgress> parseWithProgress({
    required String xmlContent,
    required int podcastId,
    required Set<String> knownGuids,
    required Future<void> Function(
      List<Episode> episodes,
      List<ParsedEpisodeMediaMeta> mediaMetas,
    )
    onBatchReady,
    int batchSize = 20,
  }) {
    return _streamFactory(xmlContent, podcastId, knownGuids, onBatchReady);
  }
}

/// A Dio that always returns a fixed response.
class _FakeDio implements Dio {
  final Response<String> Function(String url) _responder;

  _FakeDio(this._responder);

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final resp = _responder(path);
    return resp as Response<T>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A Dio that always throws a [DioException].
class _ErrorDio implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: path),
      type: DioExceptionType.connectionError,
      message: 'Connection refused',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A Dio that returns 304 Not Modified.
class _NotModifiedDio implements Dio {
  Map<String, dynamic>? lastRequestHeaders;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastRequestHeaders = options?.headers;
    return Response<T>(
      statusCode: 304,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A Dio that captures request headers and returns a 200 with configurable
/// response headers.
class _HeaderCapturingDio implements Dio {
  _HeaderCapturingDio({
    String responseBody = '<rss></rss>',
    this.responseEtag,
    this.responseLastModified,
  }) : _responseBody = responseBody;

  final String _responseBody;
  final String? responseEtag;
  final String? responseLastModified;
  Map<String, dynamic>? lastRequestHeaders;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastRequestHeaders = options?.headers;
    final headerMap = <String, List<String>>{};
    if (responseEtag != null) {
      headerMap['etag'] = [responseEtag!];
    }
    if (responseLastModified != null) {
      headerMap['last-modified'] = [responseLastModified!];
    }
    return Response<T>(
      data: _responseBody as T,
      statusCode: 200,
      headers: Headers.fromMap(headerMap),
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Subscription _subscription({
  int id = 1,
  String itunesId = 'itunes-1',
  String feedUrl = 'https://example.com/feed.xml',
  String title = 'Test Podcast',
  DateTime? lastRefreshedAt,
  String? httpEtag,
  String? httpLastModified,
}) {
  return Subscription()
    ..id = id
    ..itunesId = itunesId
    ..feedUrl = feedUrl
    ..title = title
    ..artistName = 'Test Artist'
    ..genres = ''
    ..explicit = false
    ..subscribedAt = DateTime.now()
    ..lastRefreshedAt = lastRefreshedAt
    ..httpEtag = httpEtag
    ..httpLastModified = httpLastModified;
}

Response<String> _xmlResponse(String body) => Response<String>(
  data: body,
  statusCode: 200,
  requestOptions: RequestOptions(),
);

Episode _ep(int podcastId, String guid) => Episode()
  ..podcastId = podcastId
  ..guid = guid
  ..title = guid
  ..audioUrl = 'https://example.com/$guid.mp3';

/// Builds a stream that invokes [onBatchReady] with the provided [batches]
/// before emitting a [FeedParseComplete] event with [stoppedEarly].
Stream<FeedParseProgress> _progressWithBatches({
  required List<List<Episode>> batches,
  required bool stoppedEarly,
  required Future<void> Function(
    List<Episode> episodes,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  )
  onBatchReady,
  Set<String> tailGuids = const {},
}) async* {
  var total = 0;
  for (final batch in batches) {
    await onBatchReady(batch, const []);
    total += batch.length;
    yield EpisodesBatchStored(totalSoFar: total);
  }
  yield FeedParseComplete(
    total: total,
    stoppedEarly: stoppedEarly,
    tailGuids: tailGuids,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeSubscriptionRepository fakeSubscriptionRepo;
  late _FakeEpisodeRepository fakeEpisodeRepo;
  late _FakeAppSettingsRepository fakeSettingsRepo;

  setUp(() {
    fakeSubscriptionRepo = _FakeSubscriptionRepository();
    fakeEpisodeRepo = _FakeEpisodeRepository();
    fakeSettingsRepo = _FakeAppSettingsRepository(syncIntervalMinutes: 60);
  });

  FeedSyncExecutor buildExecutor({
    required Dio dio,
    FeedParserService? feedParser,
  }) {
    final parser =
        feedParser ??
        _FakeFeedParserService(
          (xml, id, guids, _) => Stream.value(
            const FeedParseComplete(total: 0, stoppedEarly: false),
          ),
        );
    return FeedSyncExecutor(
      subscriptionRepo: fakeSubscriptionRepo,
      episodeRepo: fakeEpisodeRepo,
      settingsRepo: fakeSettingsRepo,
      feedParser: parser,
      dio: dio,
    );
  }

  group('FeedSyncExecutor.syncFeed', () {
    test('skips sync when recently refreshed', () async {
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      final executor = buildExecutor(dio: _ErrorDio());

      final result = await executor.syncFeed(sub);

      expect(result.success, isTrue);
      expect(result.skipped, isTrue);
      // updateLastRefreshed must NOT have been called
      expect(fakeSubscriptionRepo.lastUpdatedItunesId, isNull);
    });

    test('syncs when enough time has elapsed', () async {
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final parser = _FakeFeedParserService(
        (xml, id, guids, _) => Stream.value(
          const FeedParseComplete(total: 3, stoppedEarly: false),
        ),
      );

      final executor = buildExecutor(
        dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
        feedParser: parser,
      );

      final result = await executor.syncFeed(sub);

      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
      expect(result.newEpisodeCount, 3);
    });

    test('syncs when lastRefreshedAt is null', () async {
      final sub = _subscription(lastRefreshedAt: null);

      final parser = _FakeFeedParserService(
        (xml, id, guids, _) => Stream.value(
          const FeedParseComplete(total: 5, stoppedEarly: false),
        ),
      );

      final executor = buildExecutor(
        dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
        feedParser: parser,
      );

      final result = await executor.syncFeed(sub);

      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
      expect(result.newEpisodeCount, 5);
    });

    test('returns error result on network failure', () async {
      final sub = _subscription(lastRefreshedAt: null);

      final executor = buildExecutor(dio: _ErrorDio());

      final result = await executor.syncFeed(sub);

      expect(result.success, isFalse);
      expect(result.skipped, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('returns failure on empty RSS response', () async {
      final sub = _subscription(lastRefreshedAt: null);

      final executor = buildExecutor(dio: _FakeDio((_) => _xmlResponse('')));

      final result = await executor.syncFeed(sub);

      expect(result.success, isFalse);
      expect(result.skipped, isFalse);
      expect(result.errorMessage, 'Empty RSS response');
    });

    test('updates lastRefreshedAt after successful sync', () async {
      final sub = _subscription(itunesId: 'itunes-42', lastRefreshedAt: null);

      final parser = _FakeFeedParserService(
        (xml, id, guids, _) => Stream.value(
          const FeedParseComplete(total: 1, stoppedEarly: false),
        ),
      );

      final executor = buildExecutor(
        dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
        feedParser: parser,
      );

      await executor.syncFeed(sub);

      expect(fakeSubscriptionRepo.lastUpdatedItunesId, 'itunes-42');
      expect(fakeSubscriptionRepo.lastUpdatedTimestamp, isNotNull);
    });

    test('force refresh ignores recent refresh timestamp', () async {
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final parser = _FakeFeedParserService(
        (xml, id, guids, _) => Stream.value(
          const FeedParseComplete(total: 0, stoppedEarly: false),
        ),
      );

      final executor = buildExecutor(
        dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
        feedParser: parser,
      );

      final result = await executor.syncFeed(sub, forceRefresh: true);

      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
    });
  });

  group('FeedSyncExecutor conditional requests', () {
    test('sends If-None-Match when subscription has httpEtag', () async {
      final sub = _subscription(lastRefreshedAt: null, httpEtag: '"abc123"');

      final dio = _NotModifiedDio();
      final executor = buildExecutor(dio: dio);

      await executor.syncFeed(sub);

      expect(dio.lastRequestHeaders?['If-None-Match'], '"abc123"');
    });

    test(
      'sends If-Modified-Since when subscription has httpLastModified',
      () async {
        final sub = _subscription(
          lastRefreshedAt: null,
          httpLastModified: 'Sat, 29 Mar 2026 00:00:00 GMT',
        );

        final dio = _NotModifiedDio();
        final executor = buildExecutor(dio: dio);

        await executor.syncFeed(sub);

        expect(
          dio.lastRequestHeaders?['If-Modified-Since'],
          'Sat, 29 Mar 2026 00:00:00 GMT',
        );
      },
    );

    test('returns success on 304 Not Modified', () async {
      final sub = _subscription(lastRefreshedAt: null, httpEtag: '"abc123"');

      final executor = buildExecutor(dio: _NotModifiedDio());

      final result = await executor.syncFeed(sub);

      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
      // lastRefreshedAt should still be updated
      expect(fakeSubscriptionRepo.lastUpdatedItunesId, sub.itunesId);
    });

    test(
      'preserves existing cache headers when 304 omits validators',
      () async {
        final sub = _subscription(
          lastRefreshedAt: null,
          httpEtag: '"existing-etag"',
          httpLastModified: 'Fri, 28 Mar 2025 00:00:00 GMT',
        );

        // _NotModifiedDio returns 304 with no ETag/Last-Modified headers
        final executor = buildExecutor(dio: _NotModifiedDio());

        await executor.syncFeed(sub);

        // Existing values must be preserved, not cleared
        expect(fakeSubscriptionRepo.lastCacheHeadersId, sub.id);
        expect(fakeSubscriptionRepo.lastCacheEtag, '"existing-etag"');
        expect(
          fakeSubscriptionRepo.lastCacheLastModified,
          'Fri, 28 Mar 2025 00:00:00 GMT',
        );
      },
    );

    test('stores HTTP cache headers from 200 response', () async {
      final sub = _subscription(lastRefreshedAt: null);

      final dio = _HeaderCapturingDio(
        responseEtag: '"new-etag"',
        responseLastModified: 'Sat, 29 Mar 2026 12:00:00 GMT',
      );

      final parser = _FakeFeedParserService(
        (xml, id, guids, _) => Stream.value(
          const FeedParseComplete(total: 0, stoppedEarly: false),
        ),
      );

      final executor = buildExecutor(dio: dio, feedParser: parser);

      await executor.syncFeed(sub);

      expect(fakeSubscriptionRepo.lastCacheHeadersId, sub.id);
      expect(fakeSubscriptionRepo.lastCacheEtag, '"new-etag"');
      expect(
        fakeSubscriptionRepo.lastCacheLastModified,
        'Sat, 29 Mar 2026 12:00:00 GMT',
      );
    });

    test(
      'does not send conditional headers when subscription has none',
      () async {
        final sub = _subscription(lastRefreshedAt: null);

        final dio = _HeaderCapturingDio();

        final parser = _FakeFeedParserService(
          (xml, id, guids, _) => Stream.value(
            const FeedParseComplete(total: 0, stoppedEarly: false),
          ),
        );

        final executor = buildExecutor(dio: dio, feedParser: parser);

        await executor.syncFeed(sub);

        expect(dio.lastRequestHeaders?.containsKey('If-None-Match'), isFalse);
        expect(
          dio.lastRequestHeaders?.containsKey('If-Modified-Since'),
          isFalse,
        );
      },
    );
  });

  group('FeedSyncExecutor dropped-episode deletion', () {
    test('deletes episodes missing from a fully-parsed feed', () async {
      final sub = _subscription(id: 7, lastRefreshedAt: null);
      fakeEpisodeRepo.storedGuids = {'a', 'b', 'c'};

      final parser = _FakeFeedParserService(
        (xml, id, guids, onBatch) => _progressWithBatches(
          batches: [
            [_ep(sub.id, 'a'), _ep(sub.id, 'c')],
          ],
          stoppedEarly: false,
          onBatchReady: onBatch,
        ),
      );

      final executor = buildExecutor(
        dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
        feedParser: parser,
      );

      final result = await executor.syncFeed(sub);

      expect(result.success, isTrue);
      expect(fakeEpisodeRepo.deleteCalls, hasLength(1));
      expect(fakeEpisodeRepo.deleteCalls.single.podcastId, sub.id);
      expect(fakeEpisodeRepo.deleteCalls.single.guids, {'b'});
    });

    test(
      'does not delete anything when the feed observed all known guids',
      () async {
        final sub = _subscription(id: 8, lastRefreshedAt: null);
        fakeEpisodeRepo.storedGuids = {'a', 'b'};

        final parser = _FakeFeedParserService(
          (xml, id, guids, onBatch) => _progressWithBatches(
            batches: [
              [_ep(sub.id, 'a'), _ep(sub.id, 'b')],
            ],
            stoppedEarly: false,
            onBatchReady: onBatch,
          ),
        );

        final executor = buildExecutor(
          dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
          feedParser: parser,
        );

        await executor.syncFeed(sub);

        expect(fakeEpisodeRepo.deleteCalls, isEmpty);
      },
    );

    test('deletes dropped episodes even when parser stopped early', () async {
      final sub = _subscription(id: 9, lastRefreshedAt: null);
      // Known: a, b, c, d. Feed has a (new), b, c (tail). d is dropped.
      fakeEpisodeRepo.storedGuids = {'a', 'b', 'c', 'd'};

      final parser = _FakeFeedParserService(
        (xml, id, guids, onBatch) => _progressWithBatches(
          batches: [
            [_ep(sub.id, 'a')],
          ],
          stoppedEarly: true,
          tailGuids: {'b', 'c'},
          onBatchReady: onBatch,
        ),
      );

      final executor = buildExecutor(
        dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
        feedParser: parser,
      );

      await executor.syncFeed(sub);

      expect(fakeEpisodeRepo.deleteCalls, hasLength(1));
      expect(fakeEpisodeRepo.deleteCalls.single.guids, {'d'});
    });

    test(
      'does not delete when stopped early and tailGuids cover all known',
      () async {
        final sub = _subscription(id: 11, lastRefreshedAt: null);
        fakeEpisodeRepo.storedGuids = {'a', 'b', 'c'};

        final parser = _FakeFeedParserService(
          (xml, id, guids, onBatch) => _progressWithBatches(
            batches: [
              [_ep(sub.id, 'a')],
            ],
            stoppedEarly: true,
            tailGuids: {'b', 'c'},
            onBatchReady: onBatch,
          ),
        );

        final executor = buildExecutor(
          dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
          feedParser: parser,
        );

        await executor.syncFeed(sub);

        expect(fakeEpisodeRepo.deleteCalls, isEmpty);
      },
    );

    test(
      'does not delete when feed parses to zero observed episodes',
      () async {
        final sub = _subscription(id: 10, lastRefreshedAt: null);
        fakeEpisodeRepo.storedGuids = {'a', 'b'};

        final parser = _FakeFeedParserService(
          (xml, id, guids, onBatch) => _progressWithBatches(
            batches: const [],
            stoppedEarly: false,
            onBatchReady: onBatch,
          ),
        );

        final executor = buildExecutor(
          dio: _FakeDio((_) => _xmlResponse('<rss></rss>')),
          feedParser: parser,
        );

        await executor.syncFeed(sub);

        expect(fakeEpisodeRepo.deleteCalls, isEmpty);
      },
    );
  });
}
