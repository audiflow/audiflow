import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../share/services/fake_subscription_repository.dart';

class _FakeItunesChartsClient extends ItunesChartsClient {
  final Map<String, Podcast> podcasts = {};
  SearchException? error;

  @override
  Future<Podcast> fetchPodcast(String podcastId) async {
    final error = this.error;
    if (error != null) throw error;
    final podcast = podcasts[podcastId];
    if (podcast != null) return podcast;
    throw SearchException.notFound(providerId: 'fake', message: 'none');
  }
}

/// Parses only bodies containing a key of [feeds]; anything else is not a
/// feed, as with the real parser. Matches by containment because the mock
/// adapter JSON-encodes string replies.
class _FakeFeedParserService extends FeedParserService {
  final Map<String, PodcastFeed> feeds = {};
  List<PodcastItem> episodes = [_episode(enclosureUrl: 'https://e/1.mp3')];

  @override
  Future<ParsedFeed> parseFromString(
    String xmlContent, {
    DateTime? knownNewestPubDate,
    String? knownNewestGuid,
  }) async {
    final feed = feeds.entries
        .where((e) => xmlContent.contains(e.key))
        .firstOrNull
        ?.value;
    if (feed == null) throw PodcastException(message: 'not a feed');
    return ParsedFeed(podcast: feed, episodes: episodes);
  }
}

PodcastItem _episode({String? enclosureUrl}) => PodcastItem.fromData(
  parsedAt: DateTime(2026),
  sourceUrl: '',
  title: 'Episode',
  description: '',
  enclosureUrl: enclosureUrl,
);

void main() {
  const feedUrl = 'https://example.com/feed.xml';
  const rssBody = '<rss>show</rss>';

  late FakeSubscriptionRepository subscriptions;
  late _FakeItunesChartsClient itunes;
  late _FakeFeedParserService parser;
  late DioAdapter server;
  late FeedLinkResolver resolver;

  final feed = PodcastFeed.fromData(
    parsedAt: DateTime(2026),
    sourceUrl: feedUrl,
    title: 'Show',
    description: 'About the show',
    author: 'Host',
    images: [PodcastImage(url: 'https://example.com/art.jpg')],
  );

  setUp(() {
    subscriptions = FakeSubscriptionRepository();
    itunes = _FakeItunesChartsClient();
    parser = _FakeFeedParserService()..feeds[rssBody] = feed;
    final dio = Dio();
    server = DioAdapter(dio: dio);
    resolver = FeedLinkResolver(
      subscriptionRepository: subscriptions,
      itunesClient: itunes,
      httpClient: dio,
      feedParser: parser,
    );
  });

  Future<void> expectFailure(FeedLink link, FeedLinkFailure failure) async {
    await check(resolver.resolve(link)).throws<FeedLinkException>(
      (it) => it.has((e) => e.failure, 'failure').equals(failure),
    );
  }

  group('direct link', () {
    test('previews the parsed feed under a placeholder ID', () async {
      server.onGet(feedUrl, (s) => s.reply(200, rssBody));

      final podcast = await resolver.resolve(
        const FeedLink.direct(url: feedUrl),
      );

      check(podcast)
        ..has((p) => p.id, 'id').equals(feedPlaceholderId(feedUrl))
        ..has((p) => p.name, 'name').equals(feed.title)
        ..has((p) => p.artistName, 'artistName').equals(feed.author!)
        ..has((p) => p.description, 'description').equals(feed.description)
        ..has((p) => p.artworkUrl, 'artworkUrl').equals(feed.primaryImage!.url)
        ..has((p) => p.feedUrl, 'feedUrl').equals(feedUrl);
    });

    test('resolves an existing subscription without fetching', () async {
      subscriptions.addSubscription(id: 1, itunesId: '42', feedUrl: feedUrl);

      final podcast = await resolver.resolve(
        const FeedLink.direct(url: feedUrl),
      );

      check(podcast.id).equals('42');
    });

    test('matches a subscription stored under http', () async {
      subscriptions.addSubscription(
        id: 1,
        itunesId: '42',
        feedUrl: 'http://example.com/feed.xml',
      );

      final podcast = await resolver.resolve(
        const FeedLink.direct(url: feedUrl),
      );

      check(podcast.id).equals('42');
    });

    test('follows the feed a web page announces', () async {
      const pageUrl = 'https://example.com/show';
      server
        ..onGet(
          pageUrl,
          (s) => s.reply(
            200,
            // Single quotes: the mock adapter JSON-encodes string replies.
            "<html><head><link rel='alternate' "
            "type='application/rss+xml' href='/feed.xml'></head></html>",
          ),
        )
        ..onGet(feedUrl, (s) => s.reply(200, rssBody));

      final podcast = await resolver.resolve(
        const FeedLink.direct(url: pageUrl),
      );

      check(podcast.feedUrl).equals(feedUrl);
    });

    test('fails as not a feed for a page without a feed', () async {
      server.onGet(feedUrl, (s) => s.reply(200, '<html><body/></html>'));
      await expectFailure(
        const FeedLink.direct(url: feedUrl),
        FeedLinkFailure.notPodcastFeed,
      );
    });

    test('fails as not a feed when the body does not parse', () async {
      server.onGet(feedUrl, (s) => s.reply(200, '{"json": true}'));
      await expectFailure(
        const FeedLink.direct(url: feedUrl),
        FeedLinkFailure.notPodcastFeed,
      );
    });

    test('fails as not a feed when no episode has audio', () async {
      parser.episodes = [_episode()];
      server.onGet(feedUrl, (s) => s.reply(200, rssBody));
      await expectFailure(
        const FeedLink.direct(url: feedUrl),
        FeedLinkFailure.notPodcastFeed,
      );
    });

    for (final (status, failure) in [
      (404, FeedLinkFailure.feedUnavailable),
      (410, FeedLinkFailure.feedUnavailable),
      (429, FeedLinkFailure.serverError),
      (503, FeedLinkFailure.serverError),
    ]) {
      test('maps HTTP $status to $failure', () async {
        server.onGet(feedUrl, (s) => s.reply(status, ''));
        await expectFailure(const FeedLink.direct(url: feedUrl), failure);
      });
    }

    test('maps an unreachable host to a network failure', () async {
      server.onGet(
        feedUrl,
        (s) => s.throws(
          0,
          DioException.connectionError(
            requestOptions: RequestOptions(path: feedUrl),
            reason: 'offline',
          ),
        ),
      );
      await expectFailure(
        const FeedLink.direct(url: feedUrl),
        FeedLinkFailure.network,
      );
    });
  });

  group('iTunes link', () {
    const itunesId = '603013428';
    const listed = Podcast(
      id: itunesId,
      name: 'Listed',
      artistName: 'Host',
      feedUrl: feedUrl,
    );

    test('returns the directory entry', () async {
      itunes.podcasts[itunesId] = listed;
      final podcast = await resolver.resolve(
        const FeedLink.itunes(itunesId: itunesId),
      );
      check(podcast).equals(listed);
    });

    test('prefers a subscription with the same iTunes ID', () async {
      subscriptions.addSubscription(id: 1, itunesId: itunesId, title: 'Mine');
      final podcast = await resolver.resolve(
        const FeedLink.itunes(itunesId: itunesId),
      );
      check(podcast.name).equals('Mine');
    });

    test('prefers a subscription imported with the same feed', () async {
      itunes.podcasts[itunesId] = listed;
      subscriptions.addSubscription(
        id: 1,
        itunesId: feedPlaceholderId(feedUrl),
        feedUrl: feedUrl,
      );
      final podcast = await resolver.resolve(
        const FeedLink.itunes(itunesId: itunesId),
      );
      check(podcast.id).equals(feedPlaceholderId(feedUrl));
    });

    test('fails as not found when the directory has no such ID', () async {
      await expectFailure(
        const FeedLink.itunes(itunesId: itunesId),
        FeedLinkFailure.notFound,
      );
    });

    test('maps an unreachable directory to a network failure', () async {
      itunes.error = SearchNetworkException(providerId: 'fake', message: 'x');
      await expectFailure(
        const FeedLink.itunes(itunesId: itunesId),
        FeedLinkFailure.network,
      );
    });

    test('maps a directory error to a server failure', () async {
      itunes.error = SearchException.unavailable(
        providerId: 'fake',
        message: 'x',
      );
      await expectFailure(
        const FeedLink.itunes(itunesId: itunesId),
        FeedLinkFailure.serverError,
      );
    });

    test('fails as not found when the lookup has no feed', () async {
      itunes.podcasts[itunesId] = listed.copyWith(feedUrl: null);
      await expectFailure(
        const FeedLink.itunes(itunesId: itunesId),
        FeedLinkFailure.notFound,
      );
    });
  });

  test('unsupported link fails with its platform name', () async {
    await check(
      resolver.resolve(const FeedLink.unsupported(platformName: 'Spotify')),
    ).throws<FeedLinkException>(
      (it) => it
        ..has(
          (e) => e.failure,
          'failure',
        ).equals(FeedLinkFailure.unsupportedLink)
        ..has((e) => e.platformName, 'platformName').equals('Spotify'),
    );
  });
}
