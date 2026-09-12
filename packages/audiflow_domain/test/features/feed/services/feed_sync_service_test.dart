import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

@GenerateMocks([
  SubscriptionRepository,
  EpisodeRepository,
  AppSettingsRepository,
  FeedParserService,
  PresetConfigRepository,
  StationPodcastRepository,
  Dio,
])
import 'feed_sync_service_test.mocks.dart';

class _NoopAutoDownloadEnqueuer implements AutoDownloadEnqueuer {
  @override
  Future<AutoDownloadEnqueueResult> enqueueForSubscription(
    Subscription subscription, {
    required bool wifiOnly,
  }) async {
    return const AutoDownloadEnqueueResult(
      inspected: 0,
      created: 0,
      skipped: 0,
    );
  }
}

Subscription _subscription({
  int id = 1,
  String itunesId = 'itunes-1',
  String feedUrl = 'https://example.com/feed.xml',
  String title = 'Test Podcast',
  DateTime? lastRefreshedAt,
  String artistName = 'Test Artist',
  String? artworkUrl,
  String? description,
}) {
  return Subscription()
    ..id = id
    ..itunesId = itunesId
    ..feedUrl = feedUrl
    ..title = title
    ..artistName = artistName
    ..artworkUrl = artworkUrl
    ..description = description
    ..genres = ''
    ..explicit = false
    ..subscribedAt = DateTime.now()
    ..lastRefreshedAt = lastRefreshedAt;
}

/// Matches the feed fetch regardless of the cancel token and options the
/// service attaches, so stubs and verifications stay one line each.
late MockDio mockDio;

Future<Response<String>> dioGet([String? url]) => mockDio.get<String>(
  url ?? any,
  cancelToken: anyNamed('cancelToken'),
  options: anyNamed('options'),
);

Response<String> okResponse([String body = '<rss></rss>']) =>
    Response(data: body, statusCode: 200, requestOptions: RequestOptions());

void main() {
  late MockSubscriptionRepository mockSubscriptionRepo;
  late MockEpisodeRepository mockEpisodeRepo;
  late MockAppSettingsRepository mockSettingsRepo;
  late MockFeedParserService mockFeedParser;
  late MockPresetConfigRepository mockConfigRepo;
  late MockStationPodcastRepository mockStationPodcastRepo;
  late ProviderContainer container;
  late FeedSyncService service;

  setUp(() {
    mockSubscriptionRepo = MockSubscriptionRepository();
    mockEpisodeRepo = MockEpisodeRepository();
    mockSettingsRepo = MockAppSettingsRepository();
    mockFeedParser = MockFeedParserService();
    mockConfigRepo = MockPresetConfigRepository();
    mockStationPodcastRepo = MockStationPodcastRepository();
    mockDio = MockDio();

    // Default settings
    when(mockSettingsRepo.getAutoSync()).thenReturn(true);
    when(mockSettingsRepo.getSyncIntervalMinutes()).thenReturn(60);
    when(mockSettingsRepo.getWifiOnlyDownload()).thenReturn(false);

    // Smart playlist config: no pattern matches by default
    when(mockConfigRepo.findMatchingPreset(any, any)).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(mockSubscriptionRepo),
        episodeRepositoryProvider.overrideWithValue(mockEpisodeRepo),
        appSettingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        feedParserServiceProvider.overrideWithValue(mockFeedParser),
        presetConfigRepositoryProvider.overrideWithValue(mockConfigRepo),
        stationPodcastRepositoryProvider.overrideWithValue(
          mockStationPodcastRepo,
        ),
        dioProvider.overrideWithValue(mockDio),
        autoDownloadEnqueuerProvider.overrideWithValue(
          _NoopAutoDownloadEnqueuer(),
        ),
      ],
    );

    service = container.read(feedSyncServiceProvider);
  });

  tearDown(() {
    container.dispose();
  });

  group('syncAllSubscriptions', () {
    test('returns empty result when auto-sync disabled', () async {
      // Arrange
      when(mockSettingsRepo.getAutoSync()).thenReturn(false);

      // Act
      final result = await service.syncAllSubscriptions();

      // Assert
      expect(result.totalCount, 0);
      expect(result.successCount, 0);
      expect(result.skipCount, 0);
      expect(result.errorCount, 0);
      verifyNever(mockSubscriptionRepo.getSubscriptions());
    });

    test('returns empty result when no subscriptions', () async {
      // Arrange
      when(mockSubscriptionRepo.getSubscriptions()).thenAnswer((_) async => []);

      // Act
      final result = await service.syncAllSubscriptions();

      // Assert
      expect(result.totalCount, 0);
      expect(result.successCount, 0);
    });

    test('skips auto-sync check when forceRefresh is true', () async {
      // Arrange
      when(mockSettingsRepo.getAutoSync()).thenReturn(false);
      when(mockSubscriptionRepo.getSubscriptions()).thenAnswer((_) async => []);

      // Act
      final result = await service.syncAllSubscriptions(forceRefresh: true);

      // Assert - does not short-circuit despite auto-sync off
      verify(mockSubscriptionRepo.getSubscriptions()).called(1);
      expect(result.totalCount, 0);
    });

    test('syncs multiple subscriptions and aggregates results', () async {
      // Arrange
      final sub1 = _subscription(
        id: 1,
        feedUrl: 'https://example.com/feed1.xml',
        lastRefreshedAt: null,
      );
      final sub2 = _subscription(
        id: 2,
        feedUrl: 'https://example.com/feed2.xml',
        lastRefreshedAt: null,
      );
      when(
        mockSubscriptionRepo.getSubscriptions(),
      ).thenAnswer((_) async => [sub1, sub2]);

      when(dioGet()).thenAnswer((_) async => okResponse());

      when(
        mockEpisodeRepo.getGuidsByPodcastId(any),
      ).thenAnswer((_) async => <String>{});

      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer((_) {
        return Stream.value(
          const FeedParseComplete(total: 5, stoppedEarly: false),
        );
      });

      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});

      // Act
      final result = await service.syncAllSubscriptions();

      // Assert
      expect(result.totalCount, 2);
      expect(result.successCount, 2);
      expect(result.errorCount, 0);
    });
  });

  group('syncFeed', () {
    test('skips sync when recently refreshed', () async {
      // Arrange
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      // Act
      final result = await service.syncFeed(sub);

      // Assert
      expect(result.success, isTrue);
      expect(result.skipped, isTrue);
      verifyNever(dioGet());
    });

    test('syncs when lastRefreshedAt is null', () async {
      // Arrange
      final sub = _subscription(lastRefreshedAt: null);

      when(dioGet()).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(sub.id),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const FeedParseComplete(total: 3, stoppedEarly: false),
        ),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});

      // Act
      final result = await service.syncFeed(sub);

      // Assert
      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
      expect(result.newEpisodeCount, 3);
    });

    test('backfills channel metadata onto an OPML-imported podcast', () async {
      // Arrange: OPML supplies only a title and feed URL, so the subscription
      // starts with no artwork, no author, and no description.
      final sub = _subscription(lastRefreshedAt: null, artistName: '');

      when(dioGet()).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(sub.id),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          const FeedMetaReady(
            title: 'Test Podcast',
            description: 'Show notes',
            imageUrl: 'https://example.com/art.jpg',
            author: 'Jane Doe',
          ),
          const FeedParseComplete(total: 1, stoppedEarly: false),
        ]),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});

      // Act
      final result = await service.syncFeed(sub);

      // Assert
      expect(result.success, isTrue);
      verify(
        mockSubscriptionRepo.updateFeedMetadata(
          sub.id,
          artworkUrlIfMissing: 'https://example.com/art.jpg',
          artistName: 'Jane Doe',
          description: 'Show notes',
          syncedAt: anyNamed('syncedAt'),
        ),
      ).called(1);
    });

    test('syncs when enough time has elapsed', () async {
      // Arrange
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      when(dioGet()).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(sub.id),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const FeedParseComplete(total: 0, stoppedEarly: false),
        ),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});

      // Act
      final result = await service.syncFeed(sub);

      // Assert
      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
    });

    test('force refresh ignores recent refresh timestamp', () async {
      // Arrange
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      when(dioGet()).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(sub.id),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const FeedParseComplete(total: 0, stoppedEarly: false),
        ),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});

      // Act
      final result = await service.syncFeed(sub, forceRefresh: true);

      // Assert
      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
      verify(dioGet()).called(1);
    });

    test('returns failure on empty RSS response', () async {
      // Arrange
      final sub = _subscription(lastRefreshedAt: null);

      when(dioGet()).thenAnswer(
        (_) async => Response(
          data: '',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // Act
      final result = await service.syncFeed(sub);

      // Assert
      expect(result.success, isFalse);
      expect(result.skipped, isFalse);
      expect(result.errorMessage, 'Empty RSS response');
    });

    test('returns failure on null RSS response', () async {
      // Arrange
      final sub = _subscription(lastRefreshedAt: null);

      when(dioGet()).thenAnswer(
        (_) async => Response<String>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      // Act
      final result = await service.syncFeed(sub);

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Empty RSS response');
    });

    test('returns failure on network error', () async {
      // Arrange
      final sub = _subscription(lastRefreshedAt: null);

      when(dioGet()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
          message: 'Connection refused',
        ),
      );

      // Act
      final result = await service.syncFeed(sub);

      // Assert
      expect(result.success, isFalse);
      expect(result.skipped, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('updates lastRefreshedAt after successful sync', () async {
      // Arrange
      final sub = _subscription(itunesId: 'itunes-42', lastRefreshedAt: null);

      when(dioGet()).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(sub.id),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const FeedParseComplete(total: 1, stoppedEarly: false),
        ),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});

      // Act
      await service.syncFeed(sub);

      // Assert
      verify(
        mockSubscriptionRepo.updateLastRefreshed('itunes-42', any),
      ).called(1);
    });
  });

  group('suspend', () {
    void stubParseComplete() {
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const FeedParseComplete(total: 1, stoppedEarly: false),
        ),
      );
      when(
        mockEpisodeRepo.getGuidsByPodcastId(any),
      ).thenAnswer((_) async => <String>{});
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});
    }

    test('aborts a sync awaiting the feed response without writing', () async {
      final sub = _subscription(lastRefreshedAt: null);
      // Behave like Dio: the request fails only once the token is cancelled.
      when(dioGet()).thenAnswer((invocation) async {
        final token = invocation.namedArguments[#cancelToken] as CancelToken;
        throw await token.whenCancel;
      });
      final sync = service.syncFeed(sub);

      await service.suspend();

      final result = await sync;
      check(result.success).isFalse();
      check(result.skipped).isTrue();
      verifyNever(mockEpisodeRepo.upsertEpisodes(any));
      verifyNever(mockSubscriptionRepo.updateLastRefreshed(any, any));
    });

    test('skips every write when suspended after the response', () async {
      final sub = _subscription(lastRefreshedAt: null);
      stubParseComplete();
      late Future<void> cancelling;
      when(dioGet()).thenAnswer((_) async {
        cancelling = service.suspend();
        return okResponse();
      });

      final result = await service.syncFeed(sub);
      await cancelling;

      check(result.skipped).isTrue();
      verifyNever(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      );
      verifyNever(mockSubscriptionRepo.updateLastRefreshed(any, any));
    });

    test('stops batch workers from starting the next feed', () async {
      // Six feeds, four workers: two are still queued when suspend lands.
      final subs = [for (var i = 1; i <= 6; i++) _subscription(id: i)];
      when(
        mockSubscriptionRepo.getSubscriptions(),
      ).thenAnswer((_) async => subs);
      when(dioGet()).thenAnswer((invocation) async {
        final token = invocation.namedArguments[#cancelToken] as CancelToken;
        throw await token.whenCancel;
      });
      final batch = service.syncAllSubscriptions(forceRefresh: true);
      await Future<void>.delayed(Duration.zero);

      await service.suspend();

      final result = await batch;
      verify(dioGet()).called(4);
      check(result.totalCount).equals(4);
      check(result.skipCount).equals(4);
      verifyNever(mockEpisodeRepo.upsertEpisodes(any));
    });

    test('holds a sync that was mid-lookup when suspended', () async {
      // The batch captured its token at entry, so even after resume it
      // must not fetch the subscriptions the lookup returns.
      final lookup = Completer<List<Subscription>>();
      when(
        mockSubscriptionRepo.getSubscriptions(),
      ).thenAnswer((_) => lookup.future);
      final batch = service.syncAllSubscriptions(forceRefresh: true);

      final suspending = service.suspend();
      lookup.complete([_subscription()]);
      await suspending;
      service.resume();

      final result = await batch;
      check(result.totalCount).equals(0);
      verifyNever(dioGet());
    });

    test('syncs started while suspended write nothing', () async {
      when(
        mockSubscriptionRepo.getSubscriptions(),
      ).thenAnswer((_) async => [_subscription()]);
      await service.suspend();

      final result = await service.syncAllSubscriptions(forceRefresh: true);

      check(result.totalCount).equals(0);
      verifyNever(dioGet());
      verifyNever(mockSubscriptionRepo.updateLastRefreshed(any, any));
    });

    test('lets syncs started after resume run normally', () async {
      final sub = _subscription(lastRefreshedAt: null);
      stubParseComplete();
      when(dioGet()).thenAnswer((_) async => okResponse());
      await service.suspend();
      service.resume();

      final result = await service.syncFeed(sub);

      check(result.success).isTrue();
      verify(mockSubscriptionRepo.updateLastRefreshed(any, any)).called(1);
    });
  });

  group('FeedSyncResult', () {
    test('toString includes all fields', () {
      const result = FeedSyncResult(
        totalCount: 10,
        successCount: 7,
        skipCount: 2,
        errorCount: 1,
      );

      final str = result.toString();
      expect(str, contains('total: 10'));
      expect(str, contains('success: 7'));
      expect(str, contains('skip: 2'));
      expect(str, contains('error: 1'));
    });
  });

  group('SingleFeedSyncResult', () {
    test('represents successful sync', () {
      const result = SingleFeedSyncResult(
        podcastId: 1,
        success: true,
        skipped: false,
        newEpisodeCount: 5,
      );

      expect(result.podcastId, 1);
      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
      expect(result.newEpisodeCount, 5);
      expect(result.errorMessage, isNull);
    });

    test('represents skipped sync', () {
      const result = SingleFeedSyncResult(
        podcastId: 1,
        success: true,
        skipped: true,
      );

      expect(result.success, isTrue);
      expect(result.skipped, isTrue);
      expect(result.newEpisodeCount, isNull);
    });

    test('represents failed sync', () {
      const result = SingleFeedSyncResult(
        podcastId: 1,
        success: false,
        skipped: false,
        errorMessage: 'Network error',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Network error');
    });
  });

  group('syncStationFeeds', () {
    StationPodcast makeStationPodcast({
      required int stationId,
      required int podcastId,
    }) {
      return StationPodcast()
        ..stationId = stationId
        ..podcastId = podcastId
        ..addedAt = DateTime.now();
    }

    void stubSuccessfulSync(Subscription sub) {
      when(dioGet()).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(sub.id),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const FeedParseComplete(total: 2, stoppedEarly: false),
        ),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});
    }

    test('returns empty result when station has no podcasts', () async {
      when(mockStationPodcastRepo.getByStation(42)).thenAnswer((_) async => []);

      final result = await service.syncStationFeeds(42);

      expect(result.totalCount, 0);
      expect(result.successCount, 0);
      verifyNever(dioGet());
    });

    test('returns empty result when no matching subscriptions', () async {
      when(mockStationPodcastRepo.getByStation(42)).thenAnswer(
        (_) async => [makeStationPodcast(stationId: 42, podcastId: 99)],
      );
      when(mockSubscriptionRepo.getById(99)).thenAnswer((_) async => null);

      final result = await service.syncStationFeeds(42);

      expect(result.totalCount, 0);
      expect(result.successCount, 0);
    });

    test('syncs feeds for all station podcasts', () async {
      final sub1 = _subscription(
        id: 10,
        feedUrl: 'https://example.com/feed1.xml',
        lastRefreshedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      final sub2 = _subscription(
        id: 20,
        feedUrl: 'https://example.com/feed2.xml',
        lastRefreshedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      when(mockStationPodcastRepo.getByStation(42)).thenAnswer(
        (_) async => [
          makeStationPodcast(stationId: 42, podcastId: 10),
          makeStationPodcast(stationId: 42, podcastId: 20),
        ],
      );
      when(mockSubscriptionRepo.getById(10)).thenAnswer((_) async => sub1);
      when(mockSubscriptionRepo.getById(20)).thenAnswer((_) async => sub2);

      stubSuccessfulSync(sub1);
      stubSuccessfulSync(sub2);

      final result = await service.syncStationFeeds(42);

      expect(result.totalCount, 2);
      expect(result.successCount, 2);
      expect(result.errorCount, 0);
      // Force refresh bypasses timing window
      verify(dioGet()).called(2);
    });

    test('force refreshes even if recently synced', () async {
      final sub = _subscription(
        id: 10,
        feedUrl: 'https://example.com/feed.xml',
        lastRefreshedAt: DateTime.now().subtract(const Duration(seconds: 30)),
      );

      when(mockStationPodcastRepo.getByStation(42)).thenAnswer(
        (_) async => [makeStationPodcast(stationId: 42, podcastId: 10)],
      );
      when(mockSubscriptionRepo.getById(10)).thenAnswer((_) async => sub);
      stubSuccessfulSync(sub);

      final result = await service.syncStationFeeds(42);

      expect(result.successCount, 1);
      expect(result.skipCount, 0);
      verify(dioGet()).called(1);
    });

    test('handles partial failures', () async {
      final sub1 = _subscription(
        id: 10,
        feedUrl: 'https://example.com/feed1.xml',
        lastRefreshedAt: null,
      );
      final sub2 = _subscription(
        id: 20,
        feedUrl: 'https://example.com/feed2.xml',
        lastRefreshedAt: null,
      );

      when(mockStationPodcastRepo.getByStation(42)).thenAnswer(
        (_) async => [
          makeStationPodcast(stationId: 42, podcastId: 10),
          makeStationPodcast(stationId: 42, podcastId: 20),
        ],
      );
      when(mockSubscriptionRepo.getById(10)).thenAnswer((_) async => sub1);
      when(mockSubscriptionRepo.getById(20)).thenAnswer((_) async => sub2);

      // First feed succeeds
      when(
        dioGet('https://example.com/feed1.xml'),
      ).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(10),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: 10,
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.value(
          const FeedParseComplete(total: 1, stoppedEarly: false),
        ),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});

      // Second feed fails
      when(dioGet('https://example.com/feed2.xml')).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await service.syncStationFeeds(42);

      expect(result.totalCount, 2);
      expect(result.successCount, 1);
      expect(result.errorCount, 1);
    });

    test('reports all errors when every feed fails', () async {
      final sub1 = _subscription(
        id: 10,
        feedUrl: 'https://example.com/feed1.xml',
        lastRefreshedAt: null,
      );
      final sub2 = _subscription(
        id: 20,
        feedUrl: 'https://example.com/feed2.xml',
        lastRefreshedAt: null,
      );

      when(mockStationPodcastRepo.getByStation(42)).thenAnswer(
        (_) async => [
          makeStationPodcast(stationId: 42, podcastId: 10),
          makeStationPodcast(stationId: 42, podcastId: 20),
        ],
      );
      when(mockSubscriptionRepo.getById(10)).thenAnswer((_) async => sub1);
      when(mockSubscriptionRepo.getById(20)).thenAnswer((_) async => sub2);

      when(dioGet()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await service.syncStationFeeds(42);

      expect(result.totalCount, 2);
      expect(result.successCount, 0);
      expect(result.errorCount, 2);
    });
  });

  group('FeedSyncResult aggregation logic', () {
    test('counts successes, skips, and errors', () {
      final results = [
        const SingleFeedSyncResult(podcastId: 1, success: true, skipped: false),
        const SingleFeedSyncResult(podcastId: 2, success: true, skipped: true),
        const SingleFeedSyncResult(
          podcastId: 3,
          success: false,
          skipped: false,
          errorMessage: 'Error',
        ),
        const SingleFeedSyncResult(podcastId: 4, success: true, skipped: false),
      ];

      final successCount = results.where((r) => r.success).length;
      final skipCount = results.where((r) => r.skipped).length;
      final errorCount = results.where((r) => !r.success && !r.skipped).length;

      expect(successCount, 3);
      expect(skipCount, 1);
      expect(errorCount, 1);
    });
  });

  group('syncFeedsByUrls', () {
    void stubMetadataSync({required String imageUrl}) {
      when(dioGet()).thenAnswer((_) async => okResponse());
      when(
        mockEpisodeRepo.getGuidsByPodcastId(any),
      ).thenAnswer((_) async => <String>{});
      when(
        mockFeedParser.parseWithProgress(
          xmlContent: anyNamed('xmlContent'),
          podcastId: anyNamed('podcastId'),
          knownGuids: anyNamed('knownGuids'),
          onBatchReady: anyNamed('onBatchReady'),
        ),
      ).thenAnswer(
        (_) => Stream.fromIterable([
          FeedMetaReady(
            title: 'Imported Show',
            description: 'Show notes',
            imageUrl: imageUrl,
            author: 'Jane Doe',
          ),
          const FeedParseComplete(total: 1, stoppedEarly: false),
        ]),
      );
      when(
        mockSubscriptionRepo.updateLastRefreshed(any, any),
      ).thenAnswer((_) async {});
    }

    test('returns empty result for an empty url list', () async {
      final result = await service.syncFeedsByUrls(const []);

      check(result.totalCount).equals(0);
      verifyNever(mockSubscriptionRepo.getByFeedUrl(any));
    });

    test('returns empty result when no url matches a subscription', () async {
      when(
        mockSubscriptionRepo.getByFeedUrl('https://example.com/gone.xml'),
      ).thenAnswer((_) async => null);

      final result = await service.syncFeedsByUrls([
        'https://example.com/gone.xml',
      ]);

      check(result.totalCount).equals(0);
      verifyNever(dioGet());
    });

    test('backfills artwork for every imported feed', () async {
      // OPML-imported subscriptions carry no artwork and were never synced.
      final sub1 = _subscription(
        id: 1,
        itunesId: 'opml:aaa',
        feedUrl: 'https://example.com/feed1.xml',
        artistName: '',
        lastRefreshedAt: null,
      );
      final sub2 = _subscription(
        id: 2,
        itunesId: 'opml:bbb',
        feedUrl: 'https://example.com/feed2.xml',
        artistName: '',
        lastRefreshedAt: null,
      );

      when(
        mockSubscriptionRepo.getByFeedUrl(sub1.feedUrl),
      ).thenAnswer((_) async => sub1);
      when(
        mockSubscriptionRepo.getByFeedUrl(sub2.feedUrl),
      ).thenAnswer((_) async => sub2);
      stubMetadataSync(imageUrl: 'https://example.com/art.jpg');

      final result = await service.syncFeedsByUrls([
        sub1.feedUrl,
        sub2.feedUrl,
      ]);

      check(result.totalCount).equals(2);
      check(result.successCount).equals(2);
      check(result.errorCount).equals(0);
      verify(
        mockSubscriptionRepo.updateFeedMetadata(
          any,
          artworkUrlIfMissing: 'https://example.com/art.jpg',
          artistName: 'Jane Doe',
          description: 'Show notes',
          syncedAt: anyNamed('syncedAt'),
        ),
      ).called(2);
    });

    test('skips urls with no subscription and syncs the rest', () async {
      final sub = _subscription(
        id: 1,
        feedUrl: 'https://example.com/feed1.xml',
        artistName: '',
        lastRefreshedAt: null,
      );

      when(
        mockSubscriptionRepo.getByFeedUrl(sub.feedUrl),
      ).thenAnswer((_) async => sub);
      when(
        mockSubscriptionRepo.getByFeedUrl('https://example.com/gone.xml'),
      ).thenAnswer((_) async => null);
      stubMetadataSync(imageUrl: 'https://example.com/art.jpg');

      final result = await service.syncFeedsByUrls([
        sub.feedUrl,
        'https://example.com/gone.xml',
      ]);

      check(result.totalCount).equals(1);
      check(result.successCount).equals(1);
    });

    test('forces a refresh even when recently synced', () async {
      // A feed imported minutes after its last sync still needs its
      // metadata, so the timing window must not skip it.
      final sub = _subscription(
        id: 1,
        feedUrl: 'https://example.com/feed1.xml',
        artistName: '',
        lastRefreshedAt: DateTime.now().subtract(const Duration(seconds: 30)),
      );

      when(
        mockSubscriptionRepo.getByFeedUrl(sub.feedUrl),
      ).thenAnswer((_) async => sub);
      stubMetadataSync(imageUrl: 'https://example.com/art.jpg');

      final result = await service.syncFeedsByUrls([sub.feedUrl]);

      check(result.successCount).equals(1);
      check(result.skipCount).equals(0);
      verify(dioGet()).called(1);
    });

    test('reports a failed feed without aborting the others', () async {
      final sub1 = _subscription(
        id: 1,
        feedUrl: 'https://example.com/feed1.xml',
        lastRefreshedAt: null,
      );
      final sub2 = _subscription(
        id: 2,
        feedUrl: 'https://example.com/feed2.xml',
        lastRefreshedAt: null,
      );

      when(
        mockSubscriptionRepo.getByFeedUrl(sub1.feedUrl),
      ).thenAnswer((_) async => sub1);
      when(
        mockSubscriptionRepo.getByFeedUrl(sub2.feedUrl),
      ).thenAnswer((_) async => sub2);
      stubMetadataSync(imageUrl: 'https://example.com/art.jpg');
      when(dioGet(sub2.feedUrl)).thenThrow(Exception('network down'));

      final result = await service.syncFeedsByUrls([
        sub1.feedUrl,
        sub2.feedUrl,
      ]);

      check(result.totalCount).equals(2);
      check(result.successCount).equals(1);
      check(result.errorCount).equals(1);
    });

    test('caps how many feeds sync at the same time', () async {
      // Each sync spawns a parser isolate, so a large import must not
      // start one per subscription at once.
      final subs = [
        for (var i = 1; i <= 10; i++)
          _subscription(
            id: i,
            itunesId: 'opml:$i',
            feedUrl: 'https://example.com/feed$i.xml',
            artistName: '',
            lastRefreshedAt: null,
          ),
      ];
      for (final sub in subs) {
        when(
          mockSubscriptionRepo.getByFeedUrl(sub.feedUrl),
        ).thenAnswer((_) async => sub);
      }

      stubMetadataSync(imageUrl: 'https://example.com/art.jpg');

      // A sync is in flight from its fetch until it records the refresh,
      // which is the last thing a successful sync does.
      var inFlight = 0;
      var peakInFlight = 0;
      when(dioGet()).thenAnswer((_) async {
        inFlight++;
        if (peakInFlight < inFlight) peakInFlight = inFlight;
        await Future<void>.delayed(Duration.zero);
        return okResponse();
      });
      when(mockSubscriptionRepo.updateLastRefreshed(any, any)).thenAnswer((
        _,
      ) async {
        inFlight--;
      });

      final result = await service.syncFeedsByUrls([
        for (final sub in subs) sub.feedUrl,
      ]);

      check(result.totalCount).equals(10);
      check(result.successCount).equals(10);
      check(peakInFlight).isLessOrEqual(4);
      // Guards against the cap collapsing into a serial loop.
      check(peakInFlight).not((p) => p.equals(1));
    });
  });
}
