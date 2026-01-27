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

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.
@riverpod
Future<ParsedFeed> podcastDetail(Ref ref, String feedUrl) async {
  final logger = ref.watch(namedLoggerProvider('PodcastDetail'));
  logger.i('Starting to fetch feed from: $feedUrl');

  final dio = ref.watch(feedHttpClientProvider);
  final feedParser = ref.watch(feedParserServiceProvider);

  try {
    // Fetch XML content using Dio (better mobile compatibility)
    final response = await dio.get<String>(
      feedUrl,
      options: Options(responseType: ResponseType.plain),
    );

    if (response.data == null || response.data!.isEmpty) {
      throw PodcastException(
        message: 'Empty response from feed URL',
        sourceUrl: feedUrl,
      );
    }

    logger.d('Fetched ${response.data!.length} bytes, parsing...');

    // Parse the XML content
    final result = await feedParser.parseFromString(response.data!);

    logger.i('Successfully parsed feed: ${result.episodeCount} episodes');

    // Persist episodes if user is subscribed to this podcast
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);

    if (subscription != null) {
      final episodeRepo = ref.read(episodeRepositoryProvider);

      // Look up season pattern for this feed to extract season/episode numbers
      final pattern = ref.read(seasonPatternByFeedUrlProvider(feedUrl));
      final extractor = pattern?.seasonEpisodeExtractor;
      logger.d(
        'Season pattern lookup: feedUrl=$feedUrl, '
        'pattern=${pattern?.id}, hasExtractor=${extractor != null}',
      );

      await episodeRepo.upsertFromFeedItems(
        subscription.id,
        result.episodes,
        extractor: extractor,
      );
      logger.d('Persisted ${result.episodes.length} episodes for subscription');

      // Invalidate all season providers after episodes are persisted
      // Both ID-based and feedUrl-based providers must be invalidated
      ref.invalidate(podcastSeasonsProvider(subscription.id));
      ref.invalidate(hasSeasonViewProvider(subscription.id));
      ref.invalidate(podcastSeasonsByFeedUrlProvider(feedUrl));
      ref.invalidate(hasSeasonViewByFeedUrlProvider(feedUrl));
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
        if (filter == EpisodeFilter.unplayed) filtered.add(item);
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

  // Sort by episode number
  final sorted = List<PodcastItem>.from(episodes);
  sorted.sort((a, b) {
    final aNum = a.episodeNumber ?? 0;
    final bNum = b.episodeNumber ?? 0;
    return sortOrder == SortOrder.ascending
        ? aNum.compareTo(bNum)
        : bNum.compareTo(aNum);
  });

  return sorted;
}

/// Whether season view is available for a podcast.
///
/// Checks the parsed feed data directly for season numbers, so it works
/// for both subscribed and non-subscribed podcasts.
@riverpod
Future<bool> hasSeasonViewAfterLoad(Ref ref, String feedUrl) async {
  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);

  // Check if any episode in the feed has a season number
  return feed.episodes.any((e) => e.seasonNumber != null);
}

/// Provides sorted seasons for a podcast.
///
/// For subscribed podcasts, uses database-backed season resolution.
/// For non-subscribed podcasts, derives seasons from feed data directly.
@riverpod
Future<SeasonGrouping?> sortedPodcastSeasons(
  Ref ref,
  String feedUrl,
  String podcastId,
) async {
  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);

  // Try database-backed resolution first (for subscribed podcasts)
  var grouping = await ref.watch(
    podcastSeasonsByFeedUrlProvider(feedUrl).future,
  );

  // Fall back to feed-based resolution for non-subscribed podcasts
  if (grouping == null) {
    final pattern = ref.watch(seasonPatternByFeedUrlProvider(feedUrl));
    grouping = _resolveFromFeed(feed.episodes, pattern);
  }

  if (grouping == null) return null;

  // Get persisted preferences if subscribed, otherwise use defaults
  final subscription = await ref.watch(
    subscriptionByFeedUrlProvider(feedUrl).future,
  );
  SeasonSortField sortField;
  SortOrder sortOrder;

  if (subscription != null) {
    final prefs = await ref.watch(
      podcastViewPreferenceControllerProvider(subscription.id).future,
    );
    sortField = prefs.seasonSortField;
    sortOrder = prefs.seasonSortOrder;
  } else {
    sortField = SeasonSortField.seasonNumber;
    sortOrder = SortOrder.ascending;
  }
  final pattern = ref.watch(seasonPatternByFeedUrlProvider(feedUrl));
  final episodeRepo = ref.watch(episodeRepositoryProvider);

  // Sort seasons based on config
  final sortedSeasons = List<Season>.from(grouping.seasons);

  // Cache for newest episode dates (computed lazily)
  final newestDates = <String, DateTime?>{};

  Future<DateTime?> getNewestDate(Season season) async {
    if (!newestDates.containsKey(season.id)) {
      final episodes = await episodeRepo.getByIds(season.episodeIds);
      DateTime? newest;
      for (final ep in episodes) {
        if (ep.publishedAt != null) {
          if (newest == null || newest.isBefore(ep.publishedAt!)) {
            newest = ep.publishedAt;
          }
        }
      }
      newestDates[season.id] = newest;
    }
    return newestDates[season.id];
  }

  // Check if pattern has custom composite sort
  final customSort = pattern?.customSort;
  if (customSort is CompositeSeasonSort) {
    // Apply composite sorting rules (pattern's rules take precedence)
    // User's ascending/descending choice inverts the final result
    // Pre-fetch dates for all seasons that might need them
    for (final season in sortedSeasons) {
      await getNewestDate(season);
    }

    // Partition: numbered seasons vs special seasons (sortKey=0, e.g., 番外編)
    // Special seasons always appear at the end regardless of sort order
    final numberedSeasons = sortedSeasons.where((s) => 0 < s.sortKey).toList();
    final specialSeasons = sortedSeasons.where((s) => s.sortKey == 0).toList();

    numberedSeasons.sort((a, b) {
      final comparison = _compareWithCompositeSort(
        a,
        b,
        customSort.rules,
        newestDates,
      );
      // User's order choice inverts ascending ↔ descending
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    // Special seasons sorted by newest episode date (always at end)
    specialSeasons.sort(
      (a, b) => _compareDates(newestDates[a.id], newestDates[b.id]),
    );

    sortedSeasons
      ..clear()
      ..addAll(numberedSeasons)
      ..addAll(specialSeasons);
  } else {
    // Apply simple user-selected sort
    if (sortField == SeasonSortField.newestEpisodeDate) {
      for (final season in sortedSeasons) {
        await getNewestDate(season);
      }
    }

    sortedSeasons.sort((a, b) {
      final comparison = _compareByField(a, b, sortField, newestDates);
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  return SeasonGrouping(
    seasons: sortedSeasons,
    ungroupedEpisodeIds: grouping.ungroupedEpisodeIds,
    resolverType: grouping.resolverType,
  );
}

/// Compares two seasons using composite sort rules.
///
/// For COTEN RADIO: compares by sortKey (season number).
/// Note: Special seasons (sortKey=0) are partitioned out before this is called.
int _compareWithCompositeSort(
  Season a,
  Season b,
  List<SeasonSortRule> rules,
  Map<String, DateTime?> newestDates,
) {
  for (final rule in rules) {
    // Check if condition applies to both seasons
    if (rule.condition != null) {
      final bothMatch =
          _checkCondition(a, rule.condition!) &&
          _checkCondition(b, rule.condition!);
      if (!bothMatch) continue; // Try next rule
    }

    // Apply this rule
    final comparison = _compareByField(a, b, rule.field, newestDates);
    if (comparison != 0) {
      // Apply rule's order (ascending = as-is, descending = negated)
      return rule.order == SortOrder.ascending ? comparison : -comparison;
    }
  }
  return 0;
}

bool _checkCondition(Season season, SeasonSortCondition condition) {
  return switch (condition) {
    SortKeyGreaterThan(:final value) => value < season.sortKey,
  };
}

int _compareByField(
  Season a,
  Season b,
  SeasonSortField field,
  Map<String, DateTime?> newestDates,
) {
  return switch (field) {
    SeasonSortField.seasonNumber => a.sortKey.compareTo(b.sortKey),
    SeasonSortField.alphabetical => a.displayName.compareTo(b.displayName),
    SeasonSortField.newestEpisodeDate => _compareDates(
      newestDates[a.id],
      newestDates[b.id],
    ),
    SeasonSortField.progress => a.sortKey.compareTo(b.sortKey), // TODO
  };
}

int _compareDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // null dates go last
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Resolves seasons from feed data for non-subscribed podcasts.
///
/// Groups episodes by seasonNumber from feed metadata.
/// Uses negative indices as placeholder episode IDs since feed items
/// don't have database IDs.
SeasonGrouping? _resolveFromFeed(
  List<PodcastItem> episodes,
  SeasonPattern? pattern,
) {
  final grouped = <int, List<PodcastItem>>{};
  final ungroupedIndices = <int>[];

  for (var i = 0; i < episodes.length; i++) {
    final episode = episodes[i];
    final seasonNum = episode.seasonNumber;

    if (seasonNum != null && 1 <= seasonNum) {
      grouped.putIfAbsent(seasonNum, () => []).add(episode);
    } else {
      // Use negative index as placeholder ID (no DB ID available)
      ungroupedIndices.add(-(i + 1));
    }
  }

  if (grouped.isEmpty) return null;

  final titleExtractor = pattern?.titleExtractor;

  final seasons = grouped.entries.map((entry) {
    final seasonNumber = entry.key;
    final seasonEpisodes = entry.value;

    // Try to extract custom title from first episode
    String displayName = 'Season $seasonNumber';
    if (titleExtractor != null && seasonEpisodes.isNotEmpty) {
      final firstEpisode = seasonEpisodes.first;
      final episodeData = SimpleEpisodeData(
        title: firstEpisode.title,
        description: firstEpisode.description,
        seasonNumber: firstEpisode.seasonNumber,
        episodeNumber: firstEpisode.episodeNumber,
      );
      final extracted = titleExtractor.extract(episodeData);
      if (extracted != null) {
        displayName = extracted;
      }
    }

    // Create placeholder IDs for episode indices
    final episodeIds = <int>[];
    for (final ep in seasonEpisodes) {
      final idx = episodes.indexOf(ep);
      episodeIds.add(-(idx + 1));
    }

    // Get thumbnail from latest episode (sorted by publishDate, newest first)
    final sortedByDate = List<PodcastItem>.from(seasonEpisodes)
      ..sort((a, b) {
        final aPub = a.publishDate;
        final bPub = b.publishDate;
        if (aPub == null && bPub == null) return 0;
        if (aPub == null) return 1;
        if (bPub == null) return -1;
        return bPub.compareTo(aPub);
      });
    String? thumbnailUrl;
    for (final ep in sortedByDate) {
      if (ep.images.isNotEmpty) {
        thumbnailUrl = ep.images.first.url;
        break;
      }
    }

    return Season(
      id: 'season_$seasonNumber',
      displayName: displayName,
      sortKey: seasonNumber,
      episodeIds: episodeIds,
      thumbnailUrl: thumbnailUrl,
    );
  }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));

  return SeasonGrouping(
    seasons: seasons,
    ungroupedEpisodeIds: ungroupedIndices,
    resolverType: 'feed',
  );
}
