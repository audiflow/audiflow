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

    logger.i(
      'Successfully parsed feed: '
      '${result.episodeCount} episodes',
    );

    // Persist episodes if user is subscribed to this podcast
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);

    if (subscription != null) {
      final episodeRepo = ref.read(episodeRepositoryProvider);

      // Look up smart playlist pattern for this feed
      final pattern = ref.read(smartPlaylistPatternByFeedUrlProvider(feedUrl));
      final extractor = pattern?.smartPlaylistEpisodeExtractor;
      logger.d(
        'Smart playlist pattern lookup: '
        'feedUrl=$feedUrl, '
        'pattern=${pattern?.id}, '
        'hasExtractor=${extractor != null}',
      );

      await episodeRepo.upsertFromFeedItems(
        subscription.id,
        result.episodes,
        extractor: extractor,
      );
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

/// Whether smart playlist view is available for a podcast.
///
/// Checks for season numbers in feed data or a registered
/// pattern matching the feed URL.
@riverpod
Future<bool> hasSmartPlaylistViewAfterLoad(Ref ref, String feedUrl) async {
  // Check for a registered pattern first (e.g., category-based)
  final pattern = ref.watch(smartPlaylistPatternByFeedUrlProvider(feedUrl));
  if (pattern != null) return true;

  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);
  return feed.episodes.any((e) => e.seasonNumber != null);
}

/// Provides sorted smart playlists for a podcast.
///
/// For subscribed podcasts, uses database-backed resolution.
/// For non-subscribed podcasts, derives playlists from feed
/// data directly.
@riverpod
Future<SmartPlaylistGrouping?> sortedPodcastSmartPlaylists(
  Ref ref,
  String feedUrl,
  String podcastId,
) async {
  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);

  // Try database-backed resolution first
  // (for subscribed podcasts)
  var grouping = await ref.watch(
    podcastSmartPlaylistsByFeedUrlProvider(feedUrl).future,
  );

  // Fall back to feed-based resolution for
  // non-subscribed podcasts
  if (grouping == null) {
    final pattern = ref.watch(smartPlaylistPatternByFeedUrlProvider(feedUrl));
    grouping = _resolveFromFeed(feed.episodes, pattern);
  }

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
  final pattern = ref.watch(smartPlaylistPatternByFeedUrlProvider(feedUrl));
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

  // Parent playlists (from `playlists` config) are already in
  // config order — skip custom sorting.
  final hasParentPlaylists = pattern?.config['playlists'] != null;

  // Parent playlists keep config order — no sorting needed.
  final customSort = pattern?.customSort;
  if (hasParentPlaylists) {
    // Preserve config order as-is.
  } else if (customSort is CompositeSmartPlaylistSort) {
    // Apply composite sorting rules
    // Pre-fetch dates for all playlists that might need them
    for (final playlist in sortedPlaylists) {
      await getNewestDate(playlist);
    }

    // Partition: numbered playlists vs special playlists
    // (sortKey=0, e.g., 番外編)
    // Special playlists always appear at the end
    final numberedPlaylists = sortedPlaylists
        .where((s) => 0 < s.sortKey)
        .toList();
    final specialPlaylists = sortedPlaylists
        .where((s) => s.sortKey == 0)
        .toList();

    numberedPlaylists.sort((a, b) {
      final comparison = _compareWithCompositeSort(
        a,
        b,
        customSort.rules,
        newestDates,
      );
      // User's order choice inverts ascending/descending
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    // Special playlists sorted by newest episode date
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

/// Compares two smart playlists using composite sort rules.
///
/// For COTEN RADIO: compares by sortKey (playlist number).
/// Note: Special playlists (sortKey=0) are partitioned out
/// before this is called.
int _compareWithCompositeSort(
  SmartPlaylist a,
  SmartPlaylist b,
  List<SmartPlaylistSortRule> rules,
  Map<String, DateTime?> newestDates,
) {
  for (final rule in rules) {
    // Check if condition applies to both playlists
    if (rule.condition != null) {
      final bothMatch =
          _checkCondition(a, rule.condition!) &&
          _checkCondition(b, rule.condition!);
      if (!bothMatch) continue; // Try next rule
    }

    // Apply this rule
    final comparison = _compareByField(a, b, rule.field, newestDates);
    if (comparison != 0) {
      // Apply rule's order
      return rule.order == SortOrder.ascending ? comparison : -comparison;
    }
  }
  return 0;
}

bool _checkCondition(
  SmartPlaylist playlist,
  SmartPlaylistSortCondition condition,
) {
  return switch (condition) {
    SortKeyGreaterThan(:final value) => value < playlist.sortKey,
  };
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
    SmartPlaylistSortField.progress => a.sortKey.compareTo(b.sortKey), // TODO
  };
}

int _compareDates(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1; // null dates go last
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Resolves smart playlist episodes from feed data using
/// negative placeholder IDs.
///
/// For non-subscribed podcasts, episode IDs are negative
/// indices into the feed episode list: `-(index + 1)`.
/// This provider resolves them back to [SmartPlaylistEpisodeData]
/// by converting [PodcastItem] to synthetic [Episode] objects.
@riverpod
Future<List<SmartPlaylistEpisodeData>> feedSmartPlaylistEpisodes(
  Ref ref,
  String feedUrl,
  List<int> episodeIds,
) async {
  if (episodeIds.isEmpty) return [];

  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);
  final episodes = feed.episodes;

  final result = <SmartPlaylistEpisodeData>[];
  for (final id in episodeIds) {
    // Negative IDs encode feed index as -(index + 1)
    final index = -(id) - 1;
    if (index < 0 || episodes.length <= index) continue;

    final item = episodes[index];
    if (item.enclosureUrl == null) continue;

    final episode = Episode(
      id: id,
      podcastId: 0,
      guid: item.guid ?? 'feed_$index',
      title: item.title,
      description: item.description,
      audioUrl: item.enclosureUrl!,
      durationMs: item.duration?.inMilliseconds,
      publishedAt: item.publishDate,
      imageUrl: item.images.isNotEmpty ? item.images.first.url : null,
      episodeNumber: item.episodeNumber,
      seasonNumber: item.seasonNumber,
    );

    result.add(SmartPlaylistEpisodeData(episode: episode));
  }

  return result;
}

/// Resolves smart playlists from feed data for
/// non-subscribed podcasts.
///
/// For category patterns, groups by title regex. Otherwise
/// groups by seasonNumber. Uses negative indices as
/// placeholder episode IDs since feed items don't have
/// database IDs.
SmartPlaylistGrouping? _resolveFromFeed(
  List<PodcastItem> episodes,
  SmartPlaylistPattern? pattern,
) {
  if (pattern?.resolverType == 'category') {
    return _resolveFromFeedByCategory(episodes, pattern!);
  }
  // Patterns with `playlists` config produce parent playlists
  // with groups inside (not season-level playlists).
  if (pattern?.config['playlists'] != null) {
    return _resolveFromFeedWithParentPlaylists(episodes, pattern!);
  }
  return _resolveFromFeedBySeason(episodes, pattern);
}

/// Groups feed episodes by title-pattern categories.
SmartPlaylistGrouping? _resolveFromFeedByCategory(
  List<PodcastItem> episodes,
  SmartPlaylistPattern pattern,
) {
  final categoriesRaw = pattern.config['categories'] as List<dynamic>?;
  if (categoriesRaw == null || categoriesRaw.isEmpty) return null;

  final categories = categoriesRaw.cast<Map<String, dynamic>>();
  final matchers = categories.map((c) {
    return (
      regex: RegExp(c['pattern'] as String),
      id: c['id'] as String,
      displayName: c['displayName'] as String,
      yearGrouped: c['yearGrouped'] as bool? ?? false,
      sortKey: c['sortKey'] as int,
    );
  }).toList();

  final grouped = <String, List<PodcastItem>>{};
  final ungroupedIndices = <int>[];

  for (var i = 0; i < episodes.length; i++) {
    final episode = episodes[i];
    var matched = false;
    for (final matcher in matchers) {
      if (matcher.regex.hasMatch(episode.title)) {
        grouped.putIfAbsent(matcher.id, () => []).add(episode);
        matched = true;
        break;
      }
    }
    if (!matched) {
      ungroupedIndices.add(-(i + 1));
    }
  }

  if (grouped.isEmpty) return null;

  final playlists = matchers.where((m) => grouped.containsKey(m.id)).map((m) {
    final playlistEpisodes = grouped[m.id]!;
    final episodeIds = playlistEpisodes
        .map((ep) => -(episodes.indexOf(ep) + 1))
        .toList();

    String? thumbnailUrl;
    for (final ep in playlistEpisodes) {
      if (ep.images.isNotEmpty) {
        thumbnailUrl = ep.images.first.url;
        break;
      }
    }

    // Resolve sub-categories if configured
    final categoryConfig = categories.firstWhere((c) => c['id'] == m.id);
    final subCategoriesConfig =
        categoryConfig['subCategories'] as List<dynamic>?;
    List<SmartPlaylistGroup>? groups;
    if (subCategoriesConfig != null) {
      groups = _resolveGroupsFromFeed(
        subCategoriesConfig,
        playlistEpisodes,
        episodes,
      );
    }

    return SmartPlaylist(
      id: 'playlist_${m.id}',
      displayName: m.displayName,
      sortKey: m.sortKey,
      episodeIds: episodeIds,
      thumbnailUrl: thumbnailUrl,
      yearHeaderMode: m.yearGrouped
          ? YearHeaderMode.firstEpisode
          : YearHeaderMode.none,
      groups: groups,
    );
  }).toList();

  return SmartPlaylistGrouping(
    playlists: playlists,
    ungroupedEpisodeIds: ungroupedIndices,
    resolverType: 'category',
  );
}

/// Groups feed episodes into parent playlists with groups using
/// the `playlists` config from the pattern.
SmartPlaylistGrouping? _resolveFromFeedWithParentPlaylists(
  List<PodcastItem> episodes,
  SmartPlaylistPattern pattern,
) {
  final playlistConfigs = (pattern.config['playlists'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final titleExtractor = pattern.titleExtractor;
  final groupNullAs = pattern.config['groupNullSeasonAs'] as int?;

  // Build compiled filters for each playlist config.
  final filters = playlistConfigs.map(_FeedPlaylistFilter.from).toList();

  // Assign episodes to playlists.
  final buckets = List.generate(playlistConfigs.length, (_) => <PodcastItem>[]);
  final ungroupedIndices = <int>[];

  for (var i = 0; episodes.length - i != 0; i++) {
    final episode = episodes[i];
    final seasonNum = episode.seasonNumber;
    final hasSeason =
        (seasonNum != null && 1 <= seasonNum) || groupNullAs != null;

    if (!hasSeason) {
      ungroupedIndices.add(-(i + 1));
      continue;
    }

    var matched = false;
    for (var f = 0; filters.length - f != 0; f++) {
      if (filters[f].matches(episode.title)) {
        buckets[f].add(episode);
        matched = true;
        break;
      }
    }

    if (!matched) {
      // Find last playlist without titleFilter (fallback).
      final fallbackIdx = _findFeedFallbackIndex(filters);
      if (0 <= fallbackIdx) {
        buckets[fallbackIdx].add(episode);
      } else {
        ungroupedIndices.add(-(i + 1));
      }
    }
  }

  // Build SmartPlaylists with groups from season buckets.
  final playlists = <SmartPlaylist>[];
  for (var i = 0; playlistConfigs.length - i != 0; i++) {
    final cfg = playlistConfigs[i];
    final bucketEpisodes = buckets[i];
    if (bucketEpisodes.isEmpty) continue;

    final groups = _buildFeedGroups(
      bucketEpisodes,
      episodes,
      groupNullAs,
      titleExtractor,
    );
    final allEpisodeIds = bucketEpisodes
        .map((ep) => -(episodes.indexOf(ep) + 1))
        .toList();

    // Get thumbnail from latest episode
    final sortedByDate = List<PodcastItem>.from(bucketEpisodes)
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

    playlists.add(
      SmartPlaylist(
        id: cfg['id'] as String,
        displayName: cfg['displayName'] as String,
        sortKey: playlists.length,
        episodeIds: allEpisodeIds,
        thumbnailUrl: thumbnailUrl,
        contentType: _parseFeedContentType(cfg['contentType'] as String?),
        yearHeaderMode: _parseFeedYearHeaderMode(
          cfg['yearHeaderMode'] as String?,
        ),
        episodeYearHeaders: cfg['episodeYearHeaders'] as bool? ?? false,
        groups: groups,
      ),
    );
  }

  if (playlists.isEmpty) return null;

  return SmartPlaylistGrouping(
    playlists: playlists,
    ungroupedEpisodeIds: ungroupedIndices,
    resolverType: 'rss',
  );
}

int _findFeedFallbackIndex(List<_FeedPlaylistFilter> filters) {
  for (var i = filters.length - 1; 0 <= i; i--) {
    if (filters[i].isFallback) return i;
  }
  return -1;
}

List<SmartPlaylistGroup> _buildFeedGroups(
  List<PodcastItem> bucketEpisodes,
  List<PodcastItem> allEpisodes,
  int? groupNullAs,
  SmartPlaylistTitleExtractor? titleExtractor,
) {
  final grouped = <int, List<PodcastItem>>{};
  for (final episode in bucketEpisodes) {
    final seasonNum = episode.seasonNumber;
    if (seasonNum != null && 1 <= seasonNum) {
      grouped.putIfAbsent(seasonNum, () => []).add(episode);
    } else if (groupNullAs != null) {
      grouped.putIfAbsent(groupNullAs, () => []).add(episode);
    }
  }
  return grouped.entries.map((entry) {
    final seasonNumber = entry.key;
    final groupEpisodes = entry.value;

    String displayName = 'Season $seasonNumber';
    if (titleExtractor != null && groupEpisodes.isNotEmpty) {
      final first = groupEpisodes.first;
      final episodeData = SimpleEpisodeData(
        title: first.title,
        description: first.description,
        seasonNumber: first.seasonNumber,
        episodeNumber: first.episodeNumber,
      );
      final extracted = titleExtractor.extract(episodeData);
      if (extracted != null) {
        displayName = extracted;
      }
    }

    return SmartPlaylistGroup(
      id: 'season_$seasonNumber',
      displayName: displayName,
      sortKey: seasonNumber,
      episodeIds: groupEpisodes
          .map((ep) => -(allEpisodes.indexOf(ep) + 1))
          .toList(),
    );
  }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));
}

SmartPlaylistContentType _parseFeedContentType(String? value) {
  return switch (value) {
    'groups' => SmartPlaylistContentType.groups,
    _ => SmartPlaylistContentType.episodes,
  };
}

YearHeaderMode _parseFeedYearHeaderMode(String? value) {
  return switch (value) {
    'firstEpisode' => YearHeaderMode.firstEpisode,
    'perEpisode' => YearHeaderMode.perEpisode,
    _ => YearHeaderMode.none,
  };
}

/// Compiled filter for a single playlist config entry (feed data).
class _FeedPlaylistFilter {
  _FeedPlaylistFilter._({
    this.titleFilter,
    this.excludeFilter,
    this.requireFilter,
  });

  factory _FeedPlaylistFilter.from(Map<String, dynamic> cfg) {
    final title = cfg['titleFilter'] as String?;
    final exclude = cfg['excludeFilter'] as String?;
    final require = cfg['requireFilter'] as String?;
    return _FeedPlaylistFilter._(
      titleFilter: title != null ? RegExp(title) : null,
      excludeFilter: exclude != null ? RegExp(exclude) : null,
      requireFilter: require != null ? RegExp(require) : null,
    );
  }

  final RegExp? titleFilter;
  final RegExp? excludeFilter;
  final RegExp? requireFilter;

  bool get isFallback => titleFilter == null;

  bool matches(String title) {
    if (titleFilter == null) return false;
    if (!titleFilter!.hasMatch(title)) return false;
    if (excludeFilter != null && excludeFilter!.hasMatch(title)) {
      return false;
    }
    if (requireFilter != null && !requireFilter!.hasMatch(title)) {
      return false;
    }
    return true;
  }
}

/// Groups feed episodes by seasonNumber from RSS metadata.
SmartPlaylistGrouping? _resolveFromFeedBySeason(
  List<PodcastItem> episodes,
  SmartPlaylistPattern? pattern,
) {
  final grouped = <int, List<PodcastItem>>{};
  final ungroupedIndices = <int>[];

  for (var i = 0; i < episodes.length; i++) {
    final episode = episodes[i];
    final seasonNum = episode.seasonNumber;

    if (seasonNum != null && 1 <= seasonNum) {
      grouped.putIfAbsent(seasonNum, () => []).add(episode);
    } else {
      ungroupedIndices.add(-(i + 1));
    }
  }

  if (grouped.isEmpty) return null;

  final titleExtractor = pattern?.titleExtractor;

  final playlists = grouped.entries.map((entry) {
    final playlistNumber = entry.key;
    final playlistEpisodes = entry.value;

    String displayName = 'Season $playlistNumber';
    if (titleExtractor != null && playlistEpisodes.isNotEmpty) {
      final firstEpisode = playlistEpisodes.first;
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

    final episodeIds = <int>[];
    for (final ep in playlistEpisodes) {
      final idx = episodes.indexOf(ep);
      episodeIds.add(-(idx + 1));
    }

    final sortedByDate = List<PodcastItem>.from(playlistEpisodes)
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

    return SmartPlaylist(
      id: 'smart_playlist_$playlistNumber',
      displayName: displayName,
      sortKey: playlistNumber,
      episodeIds: episodeIds,
      thumbnailUrl: thumbnailUrl,
    );
  }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));

  return SmartPlaylistGrouping(
    playlists: playlists,
    ungroupedEpisodeIds: ungroupedIndices,
    resolverType: 'feed',
  );
}

/// Resolves groups from feed data using pattern config.
List<SmartPlaylistGroup>? _resolveGroupsFromFeed(
  List<dynamic> subCategoriesConfig,
  List<PodcastItem> categoryEpisodes,
  List<PodcastItem> allEpisodes,
) {
  final configs = subCategoriesConfig.cast<Map<String, dynamic>>();
  final matchers = configs.map((c) {
    return (
      regex: RegExp(c['pattern'] as String),
      id: c['id'] as String,
      displayName: c['displayName'] as String,
    );
  }).toList();

  final grouped = <String, List<int>>{};
  final otherIds = <int>[];

  for (final episode in categoryEpisodes) {
    final placeholderId = -(allEpisodes.indexOf(episode) + 1);
    var matched = false;
    for (final matcher in matchers) {
      if (matcher.regex.hasMatch(episode.title)) {
        grouped.putIfAbsent(matcher.id, () => []).add(placeholderId);
        matched = true;
        break;
      }
    }
    if (!matched) {
      otherIds.add(placeholderId);
    }
  }

  final result = <SmartPlaylistGroup>[];
  for (final matcher in matchers) {
    final ids = grouped[matcher.id];
    if (ids != null && ids.isNotEmpty) {
      result.add(
        SmartPlaylistGroup(
          id: matcher.id,
          displayName: matcher.displayName,
          episodeIds: ids,
        ),
      );
    }
  }

  if (otherIds.isNotEmpty) {
    result.add(
      SmartPlaylistGroup(
        id: 'other',
        displayName: 'Other',
        episodeIds: otherIds,
      ),
    );
  }

  return result.isEmpty ? null : result;
}
