import 'package:audiflow_domain/audiflow_domain.dart';
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
  SmartPlaylistConfigRepository,
  StationPodcastRepository,
  Dio,
])
import 'feed_sync_service_test.mocks.dart';

Subscription _subscription({
  int id = 1,
  String itunesId = 'itunes-1',
  String feedUrl = 'https://example.com/feed.xml',
  String title = 'Test Podcast',
  DateTime? lastRefreshedAt,
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
    ..lastRefreshedAt = lastRefreshedAt;
}

void main() {
  late MockSubscriptionRepository mockSubscriptionRepo;
  late MockEpisodeRepository mockEpisodeRepo;
  late MockAppSettingsRepository mockSettingsRepo;
  late MockFeedParserService mockFeedParser;
  late MockSmartPlaylistConfigRepository mockConfigRepo;
  late MockStationPodcastRepository mockStationPodcastRepo;
  late MockDio mockDio;
  late ProviderContainer container;
  late FeedSyncService service;

  setUp(() {
    mockSubscriptionRepo = MockSubscriptionRepository();
    mockEpisodeRepo = MockEpisodeRepository();
    mockSettingsRepo = MockAppSettingsRepository();
    mockFeedParser = MockFeedParserService();
    mockConfigRepo = MockSmartPlaylistConfigRepository();
    mockStationPodcastRepo = MockStationPodcastRepository();
    mockDio = MockDio();

    // Default settings
    when(mockSettingsRepo.getAutoSync()).thenReturn(true);
    when(mockSettingsRepo.getSyncIntervalMinutes()).thenReturn(60);

    // Smart playlist config: no pattern matches by default
    when(mockConfigRepo.findMatchingPattern(any, any)).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(mockSubscriptionRepo),
        episodeRepositoryProvider.overrideWithValue(mockEpisodeRepo),
        appSettingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        feedParserServiceProvider.overrideWithValue(mockFeedParser),
        smartPlaylistConfigRepositoryProvider.overrideWithValue(mockConfigRepo),
        stationPodcastRepositoryProvider.overrideWithValue(
          mockStationPodcastRepo,
        ),
        dioProvider.overrideWithValue(mockDio),
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

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
        (_) async => Response(
          data: '<rss></rss>',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

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
      verifyNever(mockDio.get<String>(any, options: anyNamed('options')));
    });

    test('syncs when lastRefreshedAt is null', () async {
      // Arrange
      final sub = _subscription(lastRefreshedAt: null);

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
        (_) async => Response(
          data: '<rss></rss>',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );
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

    test('syncs when enough time has elapsed', () async {
      // Arrange
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
        (_) async => Response(
          data: '<rss></rss>',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );
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

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
        (_) async => Response(
          data: '<rss></rss>',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );
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
      verify(mockDio.get<String>(any, options: anyNamed('options'))).called(1);
    });

    test('returns failure on empty RSS response', () async {
      // Arrange
      final sub = _subscription(lastRefreshedAt: null);

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
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

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
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

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenThrow(
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

      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
        (_) async => Response(
          data: '<rss></rss>',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );
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
      when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
        (_) async => Response(
          data: '<rss></rss>',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );
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
      verifyNever(mockDio.get<String>(any, options: anyNamed('options')));
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
      verify(mockDio.get<String>(any, options: anyNamed('options'))).called(2);
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
      verify(mockDio.get<String>(any, options: anyNamed('options'))).called(1);
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
        mockDio.get<String>(
          'https://example.com/feed1.xml',
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: '<rss></rss>',
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );
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
      when(
        mockDio.get<String>(
          'https://example.com/feed2.xml',
          options: anyNamed('options'),
        ),
      ).thenThrow(
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
}
