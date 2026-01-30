import '../../../common/database/app_database.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../models/smart_playlist_sort.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes into predefined categories
/// by title pattern.
///
/// Reads category definitions from the pattern's config. Each
/// category has a regex pattern, display name, sort key, and
/// yearGrouped flag. Episodes are matched against categories
/// in order (first match wins).
class CategoryResolver implements SmartPlaylistResolver {
  @override
  String get type => 'category';

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
    if (pattern == null) return null;

    final categoriesRaw = pattern.config['categories'] as List<dynamic>?;
    if (categoriesRaw == null || categoriesRaw.isEmpty) {
      return null;
    }

    final categories = categoriesRaw.cast<Map<String, dynamic>>();

    // Build regex list
    final matchers = categories.map((c) {
      return (
        regex: RegExp(c['pattern'] as String),
        id: c['id'] as String,
        displayName: c['displayName'] as String,
        yearGrouped: c['yearGrouped'] as bool? ?? false,
        sortKey: c['sortKey'] as int,
      );
    }).toList();

    final grouped = <String, List<Episode>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      var matched = false;
      for (final matcher in matchers) {
        if (matcher.regex.hasMatch(episode.title)) {
          grouped.putIfAbsent(matcher.id, () => []).add(episode);
          matched = true;
          break;
        }
      }
      if (!matched) {
        ungrouped.add(episode.id);
      }
    }

    if (grouped.isEmpty) return null;

    final playlists = matchers.where((m) => grouped.containsKey(m.id)).map((m) {
      final categoryEpisodes = grouped[m.id]!;
      final episodeIds = categoryEpisodes.map((e) => e.id).toList();

      // Resolve sub-categories if configured
      final categoryConfig = categories.firstWhere((c) => c['id'] == m.id);
      final subCategoriesConfig =
          categoryConfig['subCategories'] as List<dynamic>?;
      final subCategories = subCategoriesConfig != null
          ? _resolveSubCategories(subCategoriesConfig, categoryEpisodes)
          : null;

      return SmartPlaylist(
        id: 'playlist_${m.id}',
        displayName: m.displayName,
        sortKey: m.sortKey,
        episodeIds: episodeIds,
        yearGrouped: m.yearGrouped,
        subCategories: subCategories,
      );
    }).toList();

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  /// Groups episodes within a category into sub-categories by regex.
  ///
  /// Episodes not matching any sub-category pattern are placed into
  /// an implicit "Other" sub-category at the end.
  List<SmartPlaylistSubCategory>? _resolveSubCategories(
    List<dynamic> subCategoriesConfig,
    List<Episode> episodes,
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

    for (final episode in episodes) {
      var matched = false;
      for (final matcher in matchers) {
        if (matcher.regex.hasMatch(episode.title)) {
          grouped.putIfAbsent(matcher.id, () => []).add(episode.id);
          matched = true;
          break;
        }
      }
      if (!matched) {
        otherIds.add(episode.id);
      }
    }

    final result = <SmartPlaylistSubCategory>[];
    for (final matcher in matchers) {
      final ids = grouped[matcher.id];
      if (ids != null && ids.isNotEmpty) {
        result.add(
          SmartPlaylistSubCategory(
            id: matcher.id,
            displayName: matcher.displayName,
            episodeIds: ids,
          ),
        );
      }
    }

    if (otherIds.isNotEmpty) {
      result.add(
        SmartPlaylistSubCategory(
          id: 'other',
          displayName: 'Other',
          episodeIds: otherIds,
        ),
      );
    }

    return result.isEmpty ? null : result;
  }
}
