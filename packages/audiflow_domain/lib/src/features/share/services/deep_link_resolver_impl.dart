import 'dart:convert';

import 'package:audiflow_search/audiflow_search.dart';

import '../../feed/models/episode_ext.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/deep_link_target.dart';
import '../../feed/services/feed_parser_service.dart';
import 'deep_link_resolver.dart';

/// Resolves audiflow.reedom.com universal links to [DeepLinkTarget] instances.
///
/// URL format:
///   https://audiflow.reedom.com/p/{itunesId}
///   https://audiflow.reedom.com/p/{itunesId}/e/{base64urlGuid}
class DeepLinkResolverImpl implements DeepLinkResolver {
  const DeepLinkResolverImpl({
    required SubscriptionRepository subscriptionRepository,
    required EpisodeRepository episodeRepository,
    required ItunesChartsClient itunesChartsClient,
    required FeedParserService feedParserService,
  }) : _subscriptionRepository = subscriptionRepository,
       _episodeRepository = episodeRepository,
       _itunesChartsClient = itunesChartsClient,
       _feedParserService = feedParserService;

  static const _host = 'audiflow.reedom.com';
  static const _scheme = 'https';
  static const _podcastSegment = 'p';
  static const _episodeSegment = 'e';
  static const _episodeMinSegments = 4;

  final SubscriptionRepository _subscriptionRepository;
  final EpisodeRepository _episodeRepository;
  final ItunesChartsClient _itunesChartsClient;
  final FeedParserService _feedParserService;

  @override
  Future<DeepLinkTarget?> resolve(Uri uri) async {
    if (!_isAudioflowLink(uri)) return null;

    final segments = uri.pathSegments;
    if (2 > segments.length || segments[0] != _podcastSegment) return null;

    final itunesId = segments[1];
    final isEpisodeLink =
        _episodeMinSegments <= segments.length &&
        segments[2] == _episodeSegment;

    final (podcastTitle, feedUrl, artworkUrl, subscriptionId) =
        await _resolvePodcastInfo(itunesId);
    if (feedUrl == null) return null;

    if (!isEpisodeLink) {
      return DeepLinkTarget.podcast(
        itunesId: itunesId,
        feedUrl: feedUrl,
        title: podcastTitle,
        artworkUrl: artworkUrl,
      );
    }

    final encodedGuid = segments[3];
    final String guid;
    try {
      guid = _decodeBase64UrlGuid(encodedGuid);
    } on FormatException {
      return DeepLinkTarget.podcast(
        itunesId: itunesId,
        feedUrl: feedUrl,
        title: podcastTitle,
        artworkUrl: artworkUrl,
      );
    }

    if (subscriptionId != null) {
      final localEpisode = await _episodeRepository.getByPodcastIdAndGuid(
        subscriptionId,
        guid,
      );
      if (localEpisode != null) {
        return DeepLinkTarget.episode(
          itunesId: itunesId,
          feedUrl: feedUrl,
          episode: localEpisode.toPodcastItem(feedUrl: feedUrl),
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
        );
      }
    }

    // Not found locally — parse feed to find episode
    final parsedFeed = await _feedParserService.parseFromUrl(feedUrl);
    final feedEpisode = parsedFeed.episodes
        .where((item) => item.guid == guid)
        .firstOrNull;
    if (feedEpisode != null) {
      return DeepLinkTarget.episode(
        itunesId: itunesId,
        feedUrl: feedUrl,
        episode: feedEpisode,
        podcastTitle: podcastTitle,
        artworkUrl: artworkUrl,
      );
    }

    // Fall back to podcast target when GUID not found in feed
    return DeepLinkTarget.podcast(
      itunesId: itunesId,
      feedUrl: feedUrl,
      title: podcastTitle,
      artworkUrl: artworkUrl,
    );
  }

  bool _isAudioflowLink(Uri uri) => uri.scheme == _scheme && uri.host == _host;

  /// Returns (title, feedUrl, artworkUrl, subscriptionId) for the given iTunes
  /// ID. Checks local subscriptions first, then falls back to iTunes API.
  /// [subscriptionId] is null when the podcast is not locally subscribed.
  Future<(String, String?, String?, int?)> _resolvePodcastInfo(
    String itunesId,
  ) async {
    final subscription = await _subscriptionRepository.getSubscription(
      itunesId,
    );
    if (subscription != null) {
      return (
        subscription.title,
        subscription.feedUrl,
        subscription.artworkUrl,
        subscription.id,
      );
    }

    final podcast = await _itunesChartsClient.lookupPodcast(itunesId);
    if (podcast == null) return ('', null, null, null);

    return (podcast.name, podcast.feedUrl, podcast.artworkUrl, null);
  }

  String _decodeBase64UrlGuid(String encodedGuid) {
    final normalized = base64Url.normalize(encodedGuid);
    return utf8.decode(base64Url.decode(normalized));
  }
}
