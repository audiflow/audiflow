import 'package:audiflow_podcast/audiflow_podcast.dart' show PodcastException;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:dio/dio.dart';

import '../../feed/builders/podcast_builder.dart';
import '../../feed/services/feed_parser_service.dart';
import '../models/feed_link.dart';
import '../models/feed_link_exception.dart';
import '../extensions/subscription_extensions.dart';
import '../models/subscriptions.dart';
import '../repositories/subscription_repository.dart';
import 'feed_autodiscovery.dart';
import 'feed_placeholder_id.dart';

/// Resolves a [FeedLink] to the [Podcast] the podcast detail screen
/// previews, so the user can subscribe the same way as from search.
///
/// A podcast that already has a subscription entry (subscribed, imported,
/// or cached from an earlier visit) resolves to that entry, so the detail
/// screen shows its existing state instead of a duplicate.
class FeedLinkResolver {
  FeedLinkResolver({
    required this._subscriptionRepository,
    required this._itunesClient,
    required this._httpClient,
    required this._feedParser,
  });

  final SubscriptionRepository _subscriptionRepository;
  final ItunesChartsClient _itunesClient;
  final Dio _httpClient;
  final FeedParserService _feedParser;

  /// Throws [FeedLinkException] when [link] does not lead to a podcast.
  Future<Podcast> resolve(FeedLink link) async {
    return switch (link) {
      DirectFeedLink(:final url) => _resolveFeedUrl(url),
      ItunesFeedLink(:final itunesId) => _resolveItunesId(itunesId),
      UnsupportedFeedLink(:final platformName) => throw FeedLinkException(
        FeedLinkFailure.unsupportedLink,
        platformName: platformName,
      ),
    };
  }

  Future<Podcast> _resolveItunesId(String itunesId) async {
    final subscription = await _subscriptionRepository.getSubscription(
      itunesId,
    );
    if (subscription != null) return subscription.toPodcast();

    final podcast = await _lookUp(itunesId);
    final feedUrl = podcast.feedUrl;
    if (feedUrl == null || feedUrl.isEmpty) {
      throw const FeedLinkException(FeedLinkFailure.notFound);
    }
    final imported = await _findByFeedUrl(feedUrl);
    return imported?.toPodcast() ?? podcast;
  }

  Future<Podcast> _lookUp(String itunesId) async {
    try {
      return await _itunesClient.fetchPodcast(itunesId);
    } on SearchException catch (e) {
      throw FeedLinkException(_lookupFailure(e), cause: e);
    }
  }

  Future<Podcast> _resolveFeedUrl(String url) async {
    final existing = await _findByFeedUrl(url);
    if (existing != null) return existing.toPodcast();

    final page = await _fetch(url);
    if (!looksLikeHtml(page.body)) return _parseFeed(url, page.body);

    // Relative hrefs resolve against the page actually served, after
    // redirects.
    final announced = discoverFeedUrl(page.body, page.url);
    if (announced == null) {
      throw const FeedLinkException(FeedLinkFailure.notPodcastFeed);
    }
    final announcedExisting = await _findByFeedUrl(announced);
    if (announcedExisting != null) return announcedExisting.toPodcast();
    return _parseFeed(announced, (await _fetch(announced)).body);
  }

  /// The entry for [feedUrl], also under its `http` form: feed links are
  /// upgraded to `https`, while OPML imports keep the URL as written.
  Future<Subscription?> _findByFeedUrl(String feedUrl) async {
    final exact = await _subscriptionRepository.getByFeedUrl(feedUrl);
    if (exact != null) return exact;
    final uri = Uri.parse(feedUrl);
    if (uri.scheme != 'https') return null;
    return _subscriptionRepository.getByFeedUrl(
      uri.replace(scheme: 'http').toString(),
    );
  }

  Future<({String body, Uri url})> _fetch(String url) async {
    try {
      final response = await _httpClient.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data;
      if (body == null || body.isEmpty) {
        throw const FeedLinkException(FeedLinkFailure.notPodcastFeed);
      }
      return (body: body, url: response.realUri);
    } on DioException catch (e) {
      throw FeedLinkException(_httpFailure(e), cause: e);
    }
  }

  Future<Podcast> _parseFeed(String feedUrl, String body) async {
    final ParsedFeed parsed;
    try {
      parsed = await _feedParser.parseFromString(body);
    } on PodcastException catch (e) {
      throw FeedLinkException(FeedLinkFailure.notPodcastFeed, cause: e);
    }
    // Blog and comment feeds are RSS too; only audio makes a podcast.
    final hasAudio = parsed.episodes.any(
      (episode) => episode.enclosureUrl?.isNotEmpty ?? false,
    );
    if (!hasAudio) {
      throw const FeedLinkException(FeedLinkFailure.notPodcastFeed);
    }
    final feed = parsed.podcast;
    return Podcast(
      id: feedPlaceholderId(feedUrl),
      name: feed.title,
      artistName: feed.author ?? '',
      feedUrl: feedUrl,
      description: feed.description,
      artworkUrl: feed.primaryImage?.url,
    );
  }
}

/// Not found means the directory has no such podcast; anything else is a
/// failure to ask it.
FeedLinkFailure _lookupFailure(SearchException error) {
  if (error.code == StatusCode.notFound) return FeedLinkFailure.notFound;
  return error is SearchNetworkException
      ? FeedLinkFailure.network
      : FeedLinkFailure.serverError;
}

/// A status means the server answered; no status means it was never
/// reached. 408 and 429 are transient, so they read as server trouble
/// rather than a gone feed.
FeedLinkFailure _httpFailure(DioException error) {
  final status = error.response?.statusCode;
  if (status == null) return FeedLinkFailure.network;
  final isClientError = 400 <= status && status < 500;
  final isTransient = status == 408 || status == 429;
  return isClientError && !isTransient
      ? FeedLinkFailure.feedUnavailable
      : FeedLinkFailure.serverError;
}
