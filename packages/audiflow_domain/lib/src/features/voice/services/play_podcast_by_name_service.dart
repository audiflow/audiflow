import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../feed/services/feed_parser_service.dart';
import '../../player/services/audio_player_service.dart';

part 'play_podcast_by_name_service.g.dart';

/// Exception thrown when a podcast cannot be played by name.
class PlayPodcastException implements Exception {
  PlayPodcastException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Provides a [PodcastSearchService] instance for the domain layer.
@Riverpod(keepAlive: true)
PodcastSearchService podcastSearchService(Ref ref) {
  return PodcastSearchService.create(providers: [ItunesProvider()]);
}

/// Provides a [PlayPodcastByNameService] instance.
@riverpod
PlayPodcastByNameService playPodcastByNameService(Ref ref) {
  final searchService = ref.watch(podcastSearchServiceProvider);
  final feedParserService = ref.watch(feedParserServiceProvider);
  final audioController = ref.watch(audioPlayerControllerProvider.notifier);
  final logger = ref.watch(namedLoggerProvider('PlayByName'));

  return PlayPodcastByNameService(
    searchService: searchService,
    feedParserService: feedParserService,
    audioController: audioController,
    logger: logger,
  );
}

/// Service that plays the latest episode of a podcast by name.
///
/// Flow:
/// 1. Search for podcast via PodcastSearchService
/// 2. Get feedUrl from first result
/// 3. Parse feed via FeedParserService
/// 4. Find latest episode by publishDate
/// 5. Play via AudioPlayerController
class PlayPodcastByNameService {
  PlayPodcastByNameService({
    required PodcastSearchService searchService,
    required FeedParserService feedParserService,
    required AudioPlayerController audioController,
    Logger? logger,
  }) : _searchService = searchService,
       _feedParserService = feedParserService,
       _audioController = audioController,
       _logger = logger;

  final PodcastSearchService _searchService;
  final FeedParserService _feedParserService;
  final AudioPlayerController _audioController;
  final Logger? _logger;

  /// Play the latest episode of the podcast matching the given name.
  ///
  /// Throws [PlayPodcastException] if:
  /// - No podcast is found matching the name
  /// - The podcast has no feed URL
  /// - The feed has no episodes
  /// - The latest episode has no playable audio
  Future<void> playLatestEpisode(String podcastName) async {
    _logger?.i('Playing latest episode of: "$podcastName"');

    // Step 1: Search for the podcast
    final searchResult = await _searchPodcast(podcastName);
    if (searchResult.isEmpty) {
      throw PlayPodcastException('No podcast found matching "$podcastName"');
    }

    final podcast = searchResult.podcasts.first;
    _logger?.d('Found podcast: ${podcast.name} (${podcast.id})');

    // Step 2: Get feed URL
    final feedUrl = podcast.feedUrl;
    if (feedUrl == null || feedUrl.isEmpty) {
      throw PlayPodcastException('Podcast "${podcast.name}" has no feed URL');
    }

    _logger?.d('Feed URL: $feedUrl');

    // Step 3: Parse the feed
    final parsedFeed = await _feedParserService.parseFromUrl(feedUrl);
    if (parsedFeed.episodes.isEmpty) {
      throw PlayPodcastException('Podcast "${podcast.name}" has no episodes');
    }

    _logger?.d('Found ${parsedFeed.episodes.length} episodes');

    // Step 4: Find the latest episode
    final latestEpisode = _findLatestEpisode(parsedFeed.episodes);
    _logger?.d(
      'Latest episode: ${latestEpisode.title} '
      '(${latestEpisode.publishDate})',
    );

    // Step 5: Get the audio URL
    final audioUrl = latestEpisode.enclosureUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      throw PlayPodcastException(
        'Episode "${latestEpisode.title}" has no playable audio',
      );
    }

    _logger?.i('Playing: ${latestEpisode.title}');

    // Step 6: Play the audio
    await _audioController.play(audioUrl);
  }

  Future<SearchResult> _searchPodcast(String name) async {
    final query = SearchQuery.validated(term: name, limit: 5);
    return _searchService.search(query);
  }

  /// Find the latest episode by publish date.
  ///
  /// If publish dates are not available, returns the first episode
  /// (assumes feed is sorted newest-first).
  PodcastItem _findLatestEpisode(List<PodcastItem> episodes) {
    if (1 == episodes.length) {
      return episodes.first;
    }

    // Sort by publish date descending (newest first)
    final sorted = List<PodcastItem>.of(episodes)
      ..sort((a, b) {
        final dateA = a.publishDate;
        final dateB = b.publishDate;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // nulls at end
        if (dateB == null) return -1;

        return dateB.compareTo(dateA); // descending
      });

    return sorted.first;
  }
}
