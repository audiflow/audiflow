import 'dart:convert';

import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:audiflow_search/audiflow_search.dart';

import '../../feed/models/episode.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/deep_link_target.dart';
import '../../feed/builders/podcast_builder.dart' show ParsedFeed;
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
    final guid = _decodeBase64UrlGuid(encodedGuid);

    if (subscriptionId != null) {
      final localEpisode = await _episodeRepository.getByPodcastIdAndGuid(
        subscriptionId,
        guid,
      );
      if (localEpisode != null) {
        return DeepLinkTarget.episode(
          itunesId: itunesId,
          episode: _episodeToItem(localEpisode),
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
        );
      }
    }

    // Not found locally — parse feed to find episode
    final parsedFeed = await _parseFeedSafely(feedUrl);
    if (parsedFeed != null) {
      final feedEpisode = parsedFeed.episodes
          .where((item) => item.guid == guid)
          .firstOrNull;
      if (feedEpisode != null) {
        return DeepLinkTarget.episode(
          itunesId: itunesId,
          episode: feedEpisode,
          podcastTitle: podcastTitle,
          artworkUrl: artworkUrl,
        );
      }
    }

    // Fall back to podcast target when episode cannot be resolved
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

  Future<ParsedFeed?> _parseFeedSafely(String feedUrl) async {
    try {
      return await _feedParserService.parseFromUrl(feedUrl);
    } on Object {
      return null;
    }
  }

  PodcastItem _episodeToItem(Episode episode) {
    return PodcastItem.fromData(
      parsedAt: DateTime.now(),
      sourceUrl: episode.audioUrl,
      title: episode.title,
      description: episode.description ?? '',
      publishDate: episode.publishedAt,
      duration: episode.durationMs != null
          ? Duration(milliseconds: episode.durationMs!)
          : null,
      enclosureUrl: episode.audioUrl,
      guid: episode.guid,
      episodeNumber: episode.episodeNumber,
      seasonNumber: episode.seasonNumber,
      images: episode.imageUrl != null
          ? [PodcastImage(url: episode.imageUrl!)]
          : const [],
    );
  }
}
