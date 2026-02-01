import '../../../common/database/app_database.dart';
import '../extensions/episode_extensions.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../models/smart_playlist_sort.dart';
import '../models/smart_playlist_title_extractor.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes using RSS metadata (seasonNumber field).
class RssMetadataResolver implements SmartPlaylistResolver {
  @override
  String get type => 'rss';

  @override
  SmartPlaylistSortSpec get defaultSort => const SimpleSmartPlaylistSort(
    SmartPlaylistSortField.playlistNumber,
    SortOrder.ascending,
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistPattern? pattern,
  ) {
    final playlistConfigs = pattern?.config['playlists'] as List<dynamic>?;
    if (playlistConfigs != null) {
      return _resolveWithParentPlaylists(
        episodes,
        pattern,
        playlistConfigs.cast<Map<String, dynamic>>(),
      );
    }
    return _resolveBySeasonNumber(episodes, pattern);
  }

  SmartPlaylistGrouping? _resolveBySeasonNumber(
    List<Episode> episodes,
    SmartPlaylistPattern? pattern,
  ) {
    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];
    final groupNullAs = pattern?.config['groupNullSeasonAs'] as int?;

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;
      if (seasonNum != null && 1 <= seasonNum) {
        grouped.putIfAbsent(seasonNum, () => []).add(episode);
      } else if (groupNullAs != null) {
        grouped.putIfAbsent(groupNullAs, () => []).add(episode);
      } else {
        ungrouped.add(episode.id);
      }
    }

    if (grouped.isEmpty) return null;

    final titleExtractor = pattern?.titleExtractor;
    final yearGroupedMap =
        pattern?.config['yearGroupedPlaylists'] as Map<String, dynamic>?;

    final playlists = grouped.entries.map((entry) {
      final seasonNumber = entry.key;
      final playlistEpisodes = entry.value;
      final displayName = _extractDisplayName(
        seasonNumber: seasonNumber,
        episodes: playlistEpisodes,
        titleExtractor: titleExtractor,
      );
      return SmartPlaylist(
        id: 'season_$seasonNumber',
        displayName: displayName,
        sortKey: seasonNumber,
        episodeIds: playlistEpisodes.map((e) => e.id).toList(),
        yearHeaderMode: yearGroupedMap?['$seasonNumber'] == true
            ? YearHeaderMode.firstEpisode
            : YearHeaderMode.none,
      );
    }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  SmartPlaylistGrouping? _resolveWithParentPlaylists(
    List<Episode> episodes,
    SmartPlaylistPattern? pattern,
    List<Map<String, dynamic>> configs,
  ) {
    final titleExtractor = pattern?.titleExtractor;
    final groupNullAs = pattern?.config['groupNullSeasonAs'] as int?;

    // Build compiled filters for each playlist config.
    final filters = configs.map(_PlaylistFilter.from).toList();

    // Assign episodes to playlists. Each episode goes to the
    // first matching playlist, or the last without titleFilter.
    final buckets = List.generate(configs.length, (_) => <Episode>[]);
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;
      final hasSeason =
          (seasonNum != null && 1 <= seasonNum) || groupNullAs != null;

      if (!hasSeason) {
        ungrouped.add(episode.id);
        continue;
      }

      var matched = false;
      for (var i = 0; filters.length - i != 0; i++) {
        if (filters[i].matches(episode.title)) {
          buckets[i].add(episode);
          matched = true;
          break;
        }
      }

      if (!matched) {
        // Find last playlist without titleFilter (fallback).
        final fallbackIdx = _findFallbackIndex(filters);
        if (0 <= fallbackIdx) {
          buckets[fallbackIdx].add(episode);
        } else {
          ungrouped.add(episode.id);
        }
      }
    }

    // Build SmartPlaylists with groups from season buckets.
    final playlists = <SmartPlaylist>[];
    for (var i = 0; configs.length - i != 0; i++) {
      final cfg = configs[i];
      final bucketEpisodes = buckets[i];
      if (bucketEpisodes.isEmpty) continue;

      final groups = _buildGroups(bucketEpisodes, groupNullAs, titleExtractor);
      final allEpisodeIds = bucketEpisodes.map((e) => e.id).toList();

      playlists.add(
        SmartPlaylist(
          id: cfg['id'] as String,
          displayName: cfg['displayName'] as String,
          sortKey: playlists.length,
          episodeIds: allEpisodeIds,
          contentType: _parseContentType(cfg['contentType'] as String?),
          yearHeaderMode: _parseYearHeaderMode(
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
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  int _findFallbackIndex(List<_PlaylistFilter> filters) {
    for (var i = filters.length - 1; 0 <= i; i--) {
      if (filters[i].isFallback) return i;
    }
    return -1;
  }

  List<SmartPlaylistGroup> _buildGroups(
    List<Episode> episodes,
    int? groupNullAs,
    SmartPlaylistTitleExtractor? titleExtractor,
  ) {
    final grouped = <int, List<Episode>>{};
    for (final episode in episodes) {
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
      final displayName = _extractDisplayName(
        seasonNumber: seasonNumber,
        episodes: groupEpisodes,
        titleExtractor: titleExtractor,
      );
      final stats = _computeGroupStats(groupEpisodes);
      final thumbnailUrl = _latestThumbnail(groupEpisodes);
      return SmartPlaylistGroup(
        id: 'season_$seasonNumber',
        displayName: displayName,
        sortKey: seasonNumber,
        episodeIds: groupEpisodes.map((e) => e.id).toList(),
        thumbnailUrl: thumbnailUrl,
        earliestDate: stats.earliest,
        latestDate: stats.latest,
        totalDurationMs: stats.totalDurationMs,
      );
    }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));
  }

  static SmartPlaylistContentType _parseContentType(String? value) {
    return switch (value) {
      'groups' => SmartPlaylistContentType.groups,
      _ => SmartPlaylistContentType.episodes,
    };
  }

  static YearHeaderMode _parseYearHeaderMode(String? value) {
    return switch (value) {
      'firstEpisode' => YearHeaderMode.firstEpisode,
      'perEpisode' => YearHeaderMode.perEpisode,
      _ => YearHeaderMode.none,
    };
  }

  String _extractDisplayName({
    required int seasonNumber,
    required List<Episode> episodes,
    required SmartPlaylistTitleExtractor? titleExtractor,
  }) {
    if (titleExtractor == null || episodes.isEmpty) {
      return 'Season $seasonNumber';
    }

    final extracted = titleExtractor.extract(episodes.first.toEpisodeData());
    return extracted ?? 'Season $seasonNumber';
  }
}

/// Computed stats for a group of episodes.
typedef _GroupStats = ({
  DateTime? earliest,
  DateTime? latest,
  int? totalDurationMs,
});

/// Computes min/max publishedAt and total duration from episodes.
_GroupStats _computeGroupStats(List<Episode> episodes) {
  DateTime? earliest;
  DateTime? latest;
  var totalMs = 0;
  var hasDuration = false;

  for (final ep in episodes) {
    final pub = ep.publishedAt;
    if (pub != null) {
      if (earliest == null || pub.isBefore(earliest)) earliest = pub;
      if (latest == null || pub.isAfter(latest)) latest = pub;
    }
    final dur = ep.durationMs;
    if (dur != null && 0 < dur) {
      totalMs += dur;
      hasDuration = true;
    }
  }

  return (
    earliest: earliest,
    latest: latest,
    totalDurationMs: hasDuration ? totalMs : null,
  );
}

/// Returns the imageUrl of the newest episode that has one.
String? _latestThumbnail(List<Episode> episodes) {
  final sorted = [...episodes]
    ..sort((a, b) {
      final aPub = a.publishedAt;
      final bPub = b.publishedAt;
      if (aPub == null && bPub == null) return 0;
      if (aPub == null) return 1;
      if (bPub == null) return -1;
      return bPub.compareTo(aPub);
    });
  for (final ep in sorted) {
    if (ep.imageUrl != null) return ep.imageUrl;
  }
  return null;
}

/// Compiled filter for a single playlist config entry.
class _PlaylistFilter {
  _PlaylistFilter._({this.titleFilter, this.excludeFilter, this.requireFilter});

  factory _PlaylistFilter.from(Map<String, dynamic> cfg) {
    final title = cfg['titleFilter'] as String?;
    final exclude = cfg['excludeFilter'] as String?;
    final require = cfg['requireFilter'] as String?;
    return _PlaylistFilter._(
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
