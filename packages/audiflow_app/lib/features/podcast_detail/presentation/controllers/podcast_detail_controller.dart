import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_detail_controller.g.dart';

/// Refresh window in minutes - skip fetch if last fetched within this time.
const _refreshWindowMinutes = 10;

/// Checks if remote fetch should be performed.
///
/// Returns false if:
/// - Offline
/// - Within refresh window (10 minutes)
bool shouldFetchRemote({
  required DateTime? lastFetchedAt,
  required bool isOnline,
}) {
  if (!isOnline) return false;
  if (lastFetchedAt == null) return true;

  const refreshWindow = Duration(minutes: _refreshWindowMinutes);
  final elapsed = DateTime.now().difference(lastFetchedAt);
  return refreshWindow <= elapsed;
}

/// Provider for subscription repository access.
///
/// Re-exported from audiflow_domain for convenience.
@riverpod
SubscriptionRepository subscriptionRepositoryAccess(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider);
}

/// Provides a Dio client for RSS feed fetching.
@Riverpod(keepAlive: true)
Dio feedHttpClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        'User-Agent': 'Audiflow/2.0 (Podcast Player)',
      },
    ),
  );
  ref.onDispose(() => dio.close());
  return dio;
}

/// Podcast metadata hints for creating cached subscriptions.
///
/// A simple static map (not a Riverpod provider) to avoid
/// "modified during build" errors. The podcast detail screen
/// sets metadata here before watching [podcastDetailProvider],
/// which reads it to create cached subscriptions.
class PodcastMetadataHints {
  PodcastMetadataHints._();

  static final _hints = <String, Podcast>{};

  /// Stores podcast metadata keyed by feedUrl.
  static void set(String feedUrl, Podcast podcast) {
    _hints[feedUrl] = podcast;
  }

  /// Returns the stored podcast metadata for a feedUrl.
  static Podcast? get(String feedUrl) => _hints[feedUrl];

  /// Removes the stored hint for a feedUrl.
  static void remove(String feedUrl) {
    _hints.remove(feedUrl);
  }
}

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.
///
/// Persists episodes to Isar when a subscription entry exists or can
/// be created from metadata hints. Non-subscribed podcasts get a
/// cached subscription entry so the smart playlist resolver works.
@riverpod
Future<ParsedFeed> podcastDetail(Ref ref, String feedUrl) async {
  final logger = ref.watch(namedLoggerProvider('PodcastDetail'));
  logger.i('Starting to fetch feed from: $feedUrl');

  final dio = ref.watch(feedHttpClientProvider);
  final feedParser = ref.watch(feedParserServiceProvider);

  try {
    // Look up existing subscription for conditional request headers
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    var subscription = await subscriptionRepo.getByFeedUrl(feedUrl);

    // Build conditional request headers from cached HTTP metadata
    final conditionalHeaders = <String, String>{};
    if (subscription != null) {
      if (subscription.httpEtag != null) {
        conditionalHeaders['If-None-Match'] = subscription.httpEtag!;
      }
      if (subscription.httpLastModified != null) {
        conditionalHeaders['If-Modified-Since'] =
            subscription.httpLastModified!;
      }
    }

    // Fetch XML content using Dio (better mobile compatibility)
    final response = await dio.get<String>(
      feedUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: conditionalHeaders.isEmpty ? null : conditionalHeaders,
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    // 304 Not Modified — feed unchanged, rebuild from Isar
    if (response.statusCode == 304 && subscription != null) {
      logger.i('Feed not modified (304), loading episodes from Isar');
      await subscriptionRepo.updateLastAccessed(subscription.id);

      final episodeRepo = ref.read(episodeRepositoryProvider);
      final episodes = await episodeRepo.getByPodcastId(subscription.id);
      final podcastItems = episodes.map(_episodeToItem).toList();

      return ParsedFeed(
        podcast: PodcastFeed(
          parsedAt: DateTime.now(),
          sourceUrl: feedUrl,
          title: subscription.title,
          description: subscription.description ?? '',
          author: subscription.artistName,
        ),
        episodes: podcastItems,
      );
    }

    if (response.data == null || response.data!.isEmpty) {
      throw PodcastException(
        message: 'Empty response from feed URL',
        sourceUrl: feedUrl,
      );
    }

    logger.d('Fetched ${response.data!.length} bytes, parsing...');

    // Store HTTP cache headers from 200 response
    if (subscription != null) {
      final etag = response.headers.value('etag');
      final lastModified = response.headers.value('last-modified');
      if (etag != null || lastModified != null) {
        await subscriptionRepo.updateHttpCacheHeaders(
          subscription.id,
          etag: etag,
          lastModified: lastModified,
        );
      }
    }

    // Look up newest known episode for pubDate-based early-stop
    DateTime? knownNewestPubDate;
    String? knownNewestGuid;

    if (subscription != null) {
      final episodeRepo = ref.read(episodeRepositoryProvider);
      final newest = await episodeRepo.getNewestByPodcastId(subscription.id);
      knownNewestPubDate = newest?.publishedAt;
      knownNewestGuid = newest?.guid;
    }

    // Parse the XML content with early-stop when possible
    final result = await feedParser.parseFromString(
      response.data!,
      knownNewestPubDate: knownNewestPubDate,
      knownNewestGuid: knownNewestGuid,
    );

    logger.i(
      'Successfully parsed feed: '
      '${result.episodeCount} episodes',
    );

    if (subscription != null) {
      // Hint no longer needed -- subscription already exists
      PodcastMetadataHints.remove(feedUrl);
    } else {
      // Create a cached subscription for non-subscribed podcasts
      final hint = PodcastMetadataHints.get(feedUrl);
      if (hint != null) {
        subscription = await subscriptionRepo.getOrCreateCached(
          itunesId: hint.id,
          feedUrl: feedUrl,
          title: hint.name,
          artistName: hint.artistName,
          artworkUrl: hint.artworkUrl,
          description: hint.description,
          genres: hint.genres,
          explicit: hint.explicit,
        );
        logger.d('Created cached subscription id=${subscription.id}');
        PodcastMetadataHints.remove(feedUrl);

        // Store HTTP cache headers for newly-created cached subscription
        final etag = response.headers.value('etag');
        final lastModified = response.headers.value('last-modified');
        if (etag != null || lastModified != null) {
          await subscriptionRepo.updateHttpCacheHeaders(
            subscription.id,
            etag: etag,
            lastModified: lastModified,
          );
        }
      }
    }

    if (subscription != null) {
      // Update last accessed timestamp
      await subscriptionRepo.updateLastAccessed(subscription.id);

      final episodeRepo = ref.read(episodeRepositoryProvider);

      // Look up smart playlist pattern for per-group extraction
      final pattern = await ref.read(
        smartPlaylistPatternByFeedUrlProvider(feedUrl).future,
      );
      logger.d(
        'Smart playlist pattern lookup: '
        'feedUrl=$feedUrl, '
        'pattern=${pattern?.id}',
      );

      if (pattern != null) {
        await episodeRepo.upsertFromFeedItemsWithConfig(
          subscription.id,
          result.episodes,
          config: pattern,
        );
      } else {
        await episodeRepo.upsertFromFeedItems(subscription.id, result.episodes);
      }
      logger.d(
        'Persisted ${result.episodes.length} episodes '
        'for subscription',
      );

      // Invalidate all smart playlist providers after
      // episodes are persisted. Both ID-based and
      // feedUrl-based providers must be invalidated.
      ref.invalidate(podcastSmartPlaylistsProvider(subscription.id));
      ref.invalidate(hasSmartPlaylistViewProvider(subscription.id));
      ref.invalidate(podcastSmartPlaylistsByFeedUrlProvider(feedUrl));
      ref.invalidate(hasSmartPlaylistViewByFeedUrlProvider(feedUrl));
    }

    return result;
  } on DioException catch (e) {
    logger.e('Network error fetching feed', error: e);
    throw PodcastException(
      message: 'Network error: ${e.message}',
      sourceUrl: feedUrl,
    );
  } catch (e, stack) {
    logger.e('Error fetching/parsing feed', error: e, stackTrace: stack);
    rethrow;
  }
}

/// Fetches episode progress for a given audio URL.
///
/// Returns [EpisodeWithProgress] if the episode exists in the database,
/// otherwise returns null (episode not yet persisted).
@riverpod
Future<EpisodeWithProgress?> episodeProgress(Ref ref, String audioUrl) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

  final episode = await episodeRepo.getByAudioUrl(audioUrl);
  if (episode == null) return null;

  final history = await historyRepo.getByEpisodeId(episode.id);
  return EpisodeWithProgress(episode: episode, history: history);
}

/// Map of audioUrl -> EpisodeWithProgress for a podcast.
typedef EpisodeProgressMap = Map<String, EpisodeWithProgress>;

/// Batch-fetches all episode progress for a podcast in a single query.
///
/// This is much more efficient than N individual episodeProgress queries
/// when displaying a list of episodes.
@riverpod
Future<EpisodeProgressMap> podcastEpisodeProgress(
  Ref ref,
  String feedUrl,
) async {
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);
  if (subscription == null) return {};

  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

  // Single batch query for all episodes
  final episodes = await episodeRepo.getByPodcastId(subscription.id);
  if (episodes.isEmpty) return {};

  // Single batch query for all histories
  final histories = await historyRepo.getByPodcastId(subscription.id);

  // Build map keyed by audioUrl for O(1) lookup in list tiles
  final result = <String, EpisodeWithProgress>{};
  for (final episode in episodes) {
    final history = histories[episode.id];
    result[episode.audioUrl] = EpisodeWithProgress(
      episode: episode,
      history: history,
    );
  }
  return result;
}

/// Extracts only the current episode URL from playback state.
///
/// This allows tiles to watch ONLY the URL, preventing rebuilds when
/// other playback properties change (e.g., position updates).
@riverpod
String? currentPlayingEpisodeUrl(Ref ref) {
  final playbackState = ref.watch(audioPlayerControllerProvider);
  return playbackState.maybeWhen(
    playing: (url) => url,
    paused: (url) => url,
    loading: (url) => url,
    orElse: () => null,
  );
}

/// Returns true if the given URL is currently playing (not paused).
@riverpod
bool isEpisodePlaying(Ref ref, String audioUrl) {
  final playbackState = ref.watch(audioPlayerControllerProvider);
  return playbackState.maybeWhen(
    playing: (url) => url == audioUrl,
    orElse: () => false,
  );
}

/// Returns true if the given URL is currently loading.
@riverpod
bool isEpisodeLoading(Ref ref, String audioUrl) {
  final playbackState = ref.watch(audioPlayerControllerProvider);
  return playbackState.maybeWhen(
    loading: (url) => url == audioUrl,
    orElse: () => false,
  );
}

/// Filters and sorts episodes based on preferences.
///
/// Returns filtered and sorted list of [PodcastItem].
@riverpod
Future<List<PodcastItem>> filteredSortedEpisodes(
  Ref ref,
  String feedUrl,
  EpisodeFilter filter,
  SortOrder sortOrder,
) async {
  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);
  var episodes = feed.episodes;

  // Apply filter
  if (filter != EpisodeFilter.all) {
    final episodeRepo = ref.watch(episodeRepositoryProvider);
    final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

    final filtered = <PodcastItem>[];
    for (final item in episodes) {
      if (item.enclosureUrl == null) continue;

      final episode = await episodeRepo.getByAudioUrl(item.enclosureUrl!);

      if (episode == null) {
        if (filter == EpisodeFilter.unplayed) {
          filtered.add(item);
        }
        continue;
      }

      final history = await historyRepo.getByEpisodeId(episode.id);
      final isCompleted = history?.completedAt != null;
      final isInProgress =
          history != null && 0 < history.positionMs && !isCompleted;

      if (filter == EpisodeFilter.unplayed && !isCompleted && !isInProgress) {
        filtered.add(item);
      } else if (filter == EpisodeFilter.inProgress && isInProgress) {
        filtered.add(item);
      }
    }
    episodes = filtered;
  }

  // Sort by publish date
  final sorted = List<PodcastItem>.from(episodes);
  sorted.sort((a, b) {
    final aDate = a.publishDate ?? DateTime(1970);
    final bDate = b.publishDate ?? DateTime(1970);
    return sortOrder == SortOrder.ascending
        ? aDate.compareTo(bDate)
        : bDate.compareTo(aDate);
  });

  return sorted;
}

/// Whether smart playlist view is available for a podcast.
///
/// Checks for season numbers in feed data or a registered
/// pattern matching the feed URL.
@riverpod
Future<bool> hasSmartPlaylistViewAfterLoad(Ref ref, String feedUrl) async {
  // Check for a registered pattern first (e.g., category-based)
  final pattern = await ref.watch(
    smartPlaylistPatternByFeedUrlProvider(feedUrl).future,
  );
  if (pattern != null) return true;

  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);
  return feed.episodes.any((e) => e.seasonNumber != null);
}

/// Provides sorted smart playlists for a podcast.
///
/// All visited podcasts have episodes in Isar (cached or
/// subscribed), so database-backed resolution always works.
@riverpod
Future<SmartPlaylistGrouping?> sortedPodcastSmartPlaylists(
  Ref ref,
  String feedUrl,
) async {
  // Database-backed resolution works for all visited podcasts
  final grouping = await ref.watch(
    podcastSmartPlaylistsByFeedUrlProvider(feedUrl).future,
  );

  if (grouping == null) return null;

  // Get persisted preferences if subscribed,
  // otherwise use defaults
  final subscription = await ref.watch(
    subscriptionByFeedUrlProvider(feedUrl).future,
  );
  SmartPlaylistSortField sortField;
  SortOrder sortOrder;

  if (subscription != null) {
    final prefs = await ref.watch(
      podcastViewPreferenceControllerProvider(subscription.id).future,
    );
    sortField = prefs.smartPlaylistSortField;
    sortOrder = prefs.smartPlaylistSortOrder;
  } else {
    sortField = SmartPlaylistSortField.playlistNumber;
    sortOrder = SortOrder.descending;
  }
  final pattern = await ref.watch(
    smartPlaylistPatternByFeedUrlProvider(feedUrl).future,
  );
  final episodeRepo = ref.watch(episodeRepositoryProvider);

  // Sort smart playlists based on config
  final sortedPlaylists = List<SmartPlaylist>.from(grouping.playlists);

  // Cache for newest episode dates (computed lazily)
  final newestDates = <String, DateTime?>{};

  Future<DateTime?> getNewestDate(SmartPlaylist playlist) async {
    if (!newestDates.containsKey(playlist.id)) {
      final episodes = await episodeRepo.getByIds(playlist.episodeIds);
      DateTime? newest;
      for (final ep in episodes) {
        if (ep.publishedAt != null) {
          if (newest == null || newest.isBefore(ep.publishedAt!)) {
            newest = ep.publishedAt;
          }
        }
      }
      newestDates[playlist.id] = newest;
    }
    return newestDates[playlist.id];
  }

  // Multiple playlist definitions means parent playlists
  // already in config order — skip custom sorting.
  final hasParentPlaylists = pattern != null && 1 < pattern.playlists.length;

  // For single-playlist configs, use that playlist's
  // groupSort. Multi-playlist configs preserve config order.
  final groupSort = (pattern != null && pattern.playlists.length == 1)
      ? pattern.playlists.first.groupList?.sort
      : null;
  if (hasParentPlaylists) {
    // Preserve config order as-is.
  } else if (groupSort != null) {
    for (final playlist in sortedPlaylists) {
      await getNewestDate(playlist);
    }

    final numberedPlaylists = sortedPlaylists
        .where((s) => 0 < s.sortKey)
        .toList();
    final specialPlaylists = sortedPlaylists
        .where((s) => s.sortKey == 0)
        .toList();

    numberedPlaylists.sort((a, b) {
      final comparison = _compareByField(a, b, groupSort.field, newestDates);
      final directed = groupSort.order == SortOrder.ascending
          ? comparison
          : -comparison;
      return sortOrder != groupSort.order ? -directed : directed;
    });

    specialPlaylists.sort(
      (a, b) => _compareDates(newestDates[a.id], newestDates[b.id]),
    );

    sortedPlaylists
      ..clear()
      ..addAll(numberedPlaylists)
      ..addAll(specialPlaylists);
  } else {
    // Apply simple user-selected sort
    if (sortField == SmartPlaylistSortField.newestEpisodeDate) {
      for (final playlist in sortedPlaylists) {
        await getNewestDate(playlist);
      }
    }

    sortedPlaylists.sort((a, b) {
      final comparison = _compareByField(a, b, sortField, newestDates);
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  return SmartPlaylistGrouping(
    playlists: sortedPlaylists,
    ungroupedEpisodeIds: grouping.ungroupedEpisodeIds,
    resolverType: grouping.resolverType,
  );
}

int _compareByField(
  SmartPlaylist a,
  SmartPlaylist b,
  SmartPlaylistSortField field,
  Map<String, DateTime?> newestDates,
) {
  return switch (field) {
    SmartPlaylistSortField.playlistNumber => a.sortKey.compareTo(b.sortKey),
    SmartPlaylistSortField.alphabetical => a.displayName.compareTo(
      b.displayName,
    ),
    SmartPlaylistSortField.newestEpisodeDate => _compareDates(
      newestDates[a.id],
      newestDates[b.id],
    ),
  };
}

int _compareDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // null dates go last
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Converts an Isar [Episode] to a [PodcastItem] for UI display.
///
/// Used when the server returns 304 Not Modified and we rebuild
/// the feed from persisted episodes instead of re-parsing XML.
PodcastItem _episodeToItem(Episode episode) {
  return PodcastItem(
    parsedAt: DateTime.now(),
    sourceUrl: '',
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
