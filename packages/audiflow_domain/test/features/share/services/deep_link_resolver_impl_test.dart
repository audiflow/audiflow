import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/share/services/deep_link_resolver_impl.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_subscription_repository.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeEpisodeRepository implements EpisodeRepository {
  final Map<String, Episode> _episodes = {};

  void addEpisode({
    required int podcastId,
    required String guid,
    required String title,
    required String audioUrl,
    String? description,
    DateTime? publishedAt,
    int? durationMs,
    String? imageUrl,
    int? episodeNumber,
    int? seasonNumber,
  }) {
    final episode = Episode()
      ..podcastId = podcastId
      ..guid = guid
      ..title = title
      ..audioUrl = audioUrl
      ..description = description
      ..publishedAt = publishedAt
      ..durationMs = durationMs
      ..imageUrl = imageUrl
      ..episodeNumber = episodeNumber
      ..seasonNumber = seasonNumber;
    _episodes['$podcastId:$guid'] = episode;
  }

  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) async {
    return _episodes['$podcastId:$guid'];
  }

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
  Future<void> upsertEpisodes(List<Episode> episodes) =>
      throw UnimplementedError();

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
  Future<Set<String>> getGuidsByPodcastId(int podcastId) =>
      throw UnimplementedError();

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) =>
      throw UnimplementedError();

  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) => throw UnimplementedError();

  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) => throw UnimplementedError();

  @override
  Future<int> deleteByPodcastIdAndGuids(
    int podcastId,
    Set<String> guids, {
    Set<String> protectedGuids = const {},
  }) => throw UnimplementedError();
}

class FakeItunesChartsClient extends ItunesChartsClient {
  Podcast? _podcast;

  void setPodcast(Podcast podcast) {
    _podcast = podcast;
  }

  @override
  Future<Podcast?> lookupPodcast(String podcastId) async => _podcast;
}

class FakeFeedParserService extends FeedParserService {
  List<PodcastItem> _episodes = [];
  Exception? _exception;

  void setEpisodes(List<PodcastItem> episodes) {
    _episodes = episodes;
  }

  void setException(Exception exception) {
    _exception = exception;
  }

  @override
  Future<ParsedFeed> parseFromUrl(
    String url, {
    CacheOptions? cacheOptions,
  }) async {
    if (_exception != null) throw _exception!;
    final feed = PodcastFeed.fromData(
      parsedAt: DateTime.now(),
      sourceUrl: url,
      title: 'Fake Podcast',
      description: '',
    );
    return ParsedFeed(podcast: feed, episodes: _episodes);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String encodeGuid(String guid) =>
    base64Url.encode(utf8.encode(guid)).replaceAll('=', '');

DeepLinkResolverImpl _makeResolver({
  FakeSubscriptionRepository? subscriptions,
  FakeEpisodeRepository? episodes,
  FakeItunesChartsClient? itunesClient,
  FakeFeedParserService? feedParser,
}) {
  return DeepLinkResolverImpl(
    subscriptionRepository: subscriptions ?? FakeSubscriptionRepository(),
    episodeRepository: episodes ?? FakeEpisodeRepository(),
    itunesChartsClient: itunesClient ?? FakeItunesChartsClient(),
    feedParserService: feedParser ?? FakeFeedParserService(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DeepLinkResolverImpl', () {
    group('returns null for invalid URLs', () {
      test('non-audiflow host', () async {
        final resolver = _makeResolver();
        final result = await resolver.resolve(
          Uri.parse('https://example.com/p/12345'),
        );
        check(result).isNull();
      });

      test('http scheme rejected', () async {
        final resolver = _makeResolver();
        final result = await resolver.resolve(
          Uri.parse('http://audiflow.reedom.com/p/12345'),
        );
        check(result).isNull();
      });

      test('path not starting with /p/', () async {
        final resolver = _makeResolver();
        final result = await resolver.resolve(
          Uri.parse('https://audiflow.reedom.com/unknown/12345'),
        );
        check(result).isNull();
      });

      test('path too short (no itunesId)', () async {
        final resolver = _makeResolver();
        final result = await resolver.resolve(
          Uri.parse('https://audiflow.reedom.com/p'),
        );
        check(result).isNull();
      });
    });

    group('podcast link', () {
      test('resolves via local subscription', () async {
        final subs = FakeSubscriptionRepository();
        subs.addSubscription(
          id: 1,
          itunesId: '12345',
          feedUrl: 'https://feed.example.com/rss',
          title: 'My Podcast',
          artworkUrl: 'https://art.example.com/img.jpg',
        );

        final resolver = _makeResolver(subscriptions: subs);
        final result = await resolver.resolve(
          Uri.parse('https://audiflow.reedom.com/p/12345'),
        );

        check(result).isNotNull().isA<PodcastDeepLinkTarget>()
          ..has((t) => t.itunesId, 'itunesId').equals('12345')
          ..has(
            (t) => t.feedUrl,
            'feedUrl',
          ).equals('https://feed.example.com/rss')
          ..has((t) => t.title, 'title').equals('My Podcast');
      });

      test('resolves via iTunes API when not subscribed', () async {
        final itunes = FakeItunesChartsClient();
        itunes.setPodcast(
          const Podcast(
            id: '99999',
            name: 'Remote Podcast',
            artistName: 'Artist',
            feedUrl: 'https://remote.example.com/feed.rss',
            artworkUrl: 'https://art.example.com/remote.jpg',
          ),
        );

        final resolver = _makeResolver(itunesClient: itunes);
        final result = await resolver.resolve(
          Uri.parse('https://audiflow.reedom.com/p/99999'),
        );

        check(result).isNotNull().isA<PodcastDeepLinkTarget>()
          ..has((t) => t.itunesId, 'itunesId').equals('99999')
          ..has(
            (t) => t.feedUrl,
            'feedUrl',
          ).equals('https://remote.example.com/feed.rss')
          ..has((t) => t.title, 'title').equals('Remote Podcast');
      });

      test('returns null when iTunes lookup returns null', () async {
        final resolver = _makeResolver();
        final result = await resolver.resolve(
          Uri.parse('https://audiflow.reedom.com/p/unknown'),
        );
        check(result).isNull();
      });
    });

    group('episode link', () {
      const itunesId = '42';
      const feedUrl = 'https://feed.example.com/rss';
      const podcastTitle = 'Ep Podcast';
      const guid = 'urn:guid:episode-001';

      FakeSubscriptionRepository subsWithPodcast() {
        final subs = FakeSubscriptionRepository();
        subs.addSubscription(
          id: 10,
          itunesId: itunesId,
          feedUrl: feedUrl,
          title: podcastTitle,
        );
        return subs;
      }

      test(
        'decodes base64url GUID correctly and resolves local episode',
        () async {
          final subs = subsWithPodcast();
          final eps = FakeEpisodeRepository();
          eps.addEpisode(
            podcastId: 10,
            guid: guid,
            title: 'Episode One',
            audioUrl: 'https://audio.example.com/ep1.mp3',
            durationMs: 3600000,
          );

          final encodedGuid = encodeGuid(guid);
          final resolver = _makeResolver(subscriptions: subs, episodes: eps);
          final result = await resolver.resolve(
            Uri.parse('https://audiflow.reedom.com/p/$itunesId/e/$encodedGuid'),
          );

          check(result).isNotNull().isA<EpisodeDeepLinkTarget>()
            ..has((t) => t.itunesId, 'itunesId').equals(itunesId)
            ..has((t) => t.feedUrl, 'feedUrl').equals(feedUrl)
            ..has((t) => t.podcastTitle, 'podcastTitle').equals(podcastTitle)
            ..has((t) => t.episode.title, 'episode.title').equals('Episode One')
            ..has((t) => t.episode.guid, 'episode.guid').equals(guid);
        },
      );

      test(
        'resolves episode from parsed feed when not found locally',
        () async {
          final subs = subsWithPodcast();
          final feedEpisode = PodcastItem.fromData(
            parsedAt: DateTime.now(),
            sourceUrl: feedUrl,
            title: 'Feed Episode',
            description: 'From feed',
            guid: guid,
            enclosureUrl: 'https://audio.example.com/feed-ep.mp3',
          );

          final feedParser = FakeFeedParserService();
          feedParser.setEpisodes([feedEpisode]);

          final encodedGuid = encodeGuid(guid);
          final resolver = _makeResolver(
            subscriptions: subs,
            feedParser: feedParser,
          );
          final result = await resolver.resolve(
            Uri.parse('https://audiflow.reedom.com/p/$itunesId/e/$encodedGuid'),
          );

          check(result).isNotNull().isA<EpisodeDeepLinkTarget>()
            ..has(
              (t) => t.episode.title,
              'episode.title',
            ).equals('Feed Episode')
            ..has((t) => t.episode.guid, 'episode.guid').equals(guid);
        },
      );

      test(
        'falls back to podcast target when GUID is malformed base64',
        () async {
          final subs = subsWithPodcast();

          final resolver = _makeResolver(subscriptions: subs);
          final result = await resolver.resolve(
            Uri.parse(
              'https://audiflow.reedom.com/p/$itunesId/e/!!!invalid!!!',
            ),
          );

          check(result).isNotNull().isA<PodcastDeepLinkTarget>()
            ..has((t) => t.itunesId, 'itunesId').equals(itunesId)
            ..has((t) => t.feedUrl, 'feedUrl').equals(feedUrl);
        },
      );

      test(
        'falls back to podcast target when episode not found in feed',
        () async {
          final subs = subsWithPodcast();
          final encodedGuid = encodeGuid('urn:guid:missing');

          final resolver = _makeResolver(subscriptions: subs);
          final result = await resolver.resolve(
            Uri.parse('https://audiflow.reedom.com/p/$itunesId/e/$encodedGuid'),
          );

          check(result).isNotNull().isA<PodcastDeepLinkTarget>()
            ..has((t) => t.itunesId, 'itunesId').equals(itunesId)
            ..has((t) => t.feedUrl, 'feedUrl').equals(feedUrl);
        },
      );

      test('propagates exception when feed parsing fails', () async {
        final subs = subsWithPodcast();
        final feedParser = FakeFeedParserService();
        feedParser.setException(Exception('network error'));

        final encodedGuid = encodeGuid(guid);
        final resolver = _makeResolver(
          subscriptions: subs,
          feedParser: feedParser,
        );

        await check(
          resolver.resolve(
            Uri.parse('https://audiflow.reedom.com/p/$itunesId/e/$encodedGuid'),
          ),
        ).throws<Exception>();
      });
    });
  });
}
