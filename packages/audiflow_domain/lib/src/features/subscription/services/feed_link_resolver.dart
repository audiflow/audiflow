import 'package:audiflow_podcast/audiflow_podcast.dart' show PodcastException;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:dio/dio.dart';

import '../../feed/builders/podcast_builder.dart';
import '../../feed/services/feed_parser_service.dart';
import '../models/feed_link.dart';
import '../models/feed_link_exception.dart';
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
    if (subscription != null) return _fromSubscription(subscription);

    final podcast = await _itunesClient.lookupPodcast(itunesId);
    final feedUrl = podcast?.feedUrl;
    if (podcast == null || feedUrl == null || feedUrl.isEmpty) {
      throw const FeedLinkException(FeedLinkFailure.notFound);
    }
    final imported = await _findByFeedUrl(feedUrl);
    return imported == null ? podcast : _fromSubscription(imported);
  }

  Future<Podcast> _resolveFeedUrl(String url) async {
    final existing = await _findByFeedUrl(url);
    if (existing != null) return _fromSubscription(existing);

    final body = await _fetch(url);
    if (!looksLikeHtml(body)) return _parseFeed(url, body);

    final announced = discoverFeedUrl(body, Uri.parse(url));
    if (announced == null) {
      throw const FeedLinkException(FeedLinkFailure.notPodcastFeed);
    }
    final announcedExisting = await _findByFeedUrl(announced);
    if (announcedExisting != null) return _fromSubscription(announcedExisting);
    return _parseFeed(announced, await _fetch(announced));
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

  Future<String> _fetch(String url) async {
    try {
      final response = await _httpClient.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      final body = response.data;
      if (body == null || body.isEmpty) {
        throw const FeedLinkException(FeedLinkFailure.notPodcastFeed);
      }
      return body;
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

  Podcast _fromSubscription(Subscription subscription) {
    return Podcast(
      id: subscription.itunesId,
      name: subscription.title,
      artistName: subscription.artistName,
      feedUrl: subscription.feedUrl,
      description: subscription.description,
      artworkUrl: subscription.artworkUrl,
      explicit: subscription.explicit,
    );
  }
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
