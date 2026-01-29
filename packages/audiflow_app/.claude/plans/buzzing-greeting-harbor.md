# NewsConnect Sub-Categories + Accordion Year Grouping

## Summary

Two changes:
1. **NewsConnect `programs` category** gains sub-categories (土曜版, ニュース小話) rendered as grouped sections inside the playlist episode screen
2. **Year-grouped playlists** use `ExpansionTile` accordion UI with current year expanded by default

## Changes

### 1. Add `subCategories` to NewsConnect pattern config

**File:** `packages/audiflow_domain/lib/src/features/feed/patterns/news_connect_pattern.dart`

Add `subCategories` list to the `programs` category config:

```dart
{
  'id': 'programs',
  'displayName': '特集',
  'pattern': r'【(?!\d+月\d+日)\S+',
  'yearGrouped': false,
  'sortKey': 2,
  'subCategories': [
    {
      'id': 'saturday',
      'displayName': '土曜版',
      'pattern': r'【土曜版',
    },
    {
      'id': 'news_talk',
      'displayName': 'ニュース小話',
      'pattern': r'【ニュース小話',
    },
  ],
}
```

### 2. Add `subCategories` to SmartPlaylist model

**File:** `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist.dart`

Add optional `subCategories` field to `SmartPlaylist`:

```dart
final List<SmartPlaylistSubCategory>? subCategories;
```

New class:
```dart
final class SmartPlaylistSubCategory {
  const SmartPlaylistSubCategory({
    required this.id,
    required this.displayName,
    required this.episodeIds,
  });
  final String id;
  final String displayName;
  final List<int> episodeIds;
}
```

### 3. CategoryResolver: populate subCategories

**File:** `packages/audiflow_domain/lib/src/features/feed/resolvers/category_resolver.dart`

When a category has `subCategories` config, after grouping episodes into the category, further sub-group them by sub-category regex. Store results in `SmartPlaylist.subCategories`. Episodes not matching any sub-category go into an implicit "Other" sub-category.

### 4. Provider: propagate subCategories from cache rebuild

**File:** `packages/audiflow_domain/lib/src/features/feed/providers/smart_playlist_providers.dart`

In `_buildCategoryGroupingFromCache`, also re-resolve sub-categories from the pattern config.

### 5. Accordion UI for year-grouped playlists

**File:** `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`

Replace `_buildYearGroupedList` flat list with `ExpansionTile` accordion:

```dart
Widget _buildYearGroupedList(...) {
  // Group by year, sort descending
  // Current year = initially expanded
  return SliverList(
    delegate: SliverChildListDelegate([
      for (final year in sortedYears)
        ExpansionTile(
          key: PageStorageKey('year_$year'),
          title: Text('$year'),
          initiallyExpanded: year == DateTime.now().year,
          children: [
            for (final data in byYear[year]!)
              SmartPlaylistEpisodeListTile(...)
          ],
        ),
    ]),
  );
}
```

### 6. Sub-category grouped UI for non-yearGrouped playlists with subCategories

**File:** `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/smart_playlist_episodes_screen.dart`

Add rendering branch: when `smartPlaylist.subCategories` is non-null and non-empty, render sub-category sections (accordion or simple headers with episode lists under each).

### 7. Feed-based resolution support

**File:** `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart`

Update `_resolveFromFeedByCategory` to also populate `subCategories` when present in pattern config.

## Verification

1. Run `dart run build_runner build --delete-conflicting-outputs` in audiflow_domain
2. Run `analyze_files` on both domain and app packages
3. Run `run_tests` on domain package
4. Manually verify on device: NewsConnect shows 平日版 (accordion by year, current year expanded) and 特集 (sub-grouped by 土曜版, ニュース小話)
