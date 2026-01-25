# Season View Feature Design

## Overview

Add a "Seasons" view to the podcast detail screen that groups episodes by season. Supports podcasts with proper RSS season metadata and those with broken/missing metadata via custom pattern matching.

## Goals

- Show season view toggle only when meaningful grouping is possible
- Support multiple grouping strategies with configurable priority
- Handle podcasts with broken season metadata via custom patterns
- Architecture extensible for server-downloaded and user-defined patterns (future)

## Non-Goals (V1)

- Server-downloadable patterns
- User-editable patterns
- Pattern editing UI

---

## Architecture

### Pattern Chain System

A prioritized chain of "season resolvers" attempts to group episodes. The chain stops at the first resolver that succeeds (groups at least one episode).

```
┌─────────────────────────────────────────────────────────┐
│                    SeasonResolver Chain                 │
├─────────────────────────────────────────────────────────┤
│  Priority 1: CustomPatternResolver (podcast-specific)  │
│       ↓ (no match)                                      │
│  Priority 2: RssMetadataResolver (uses seasonNumber)   │
│       ↓ (no match)                                      │
│  Priority 3: TitlePatternResolver (regex extraction)   │
│       ↓ (no match)                                      │
│  Result: No season view available for this podcast     │
└─────────────────────────────────────────────────────────┘
```

### Pattern Matching to Podcasts

Patterns are matched to podcasts using:
1. GUID first (if RSS provides it)
2. Fall back to feed URL pattern (regex)

---

## Data Models

### Core Models

```dart
/// Season grouping result from a resolver
@freezed
class SeasonGrouping with _$SeasonGrouping {
  const factory SeasonGrouping({
    required List<Season> seasons,
    @Default([]) List<Episode> ungroupedEpisodes,
    required String resolverType, // "rss", "custom", "title_pattern"
  }) = _SeasonGrouping;
}

/// A single season with its episodes
@freezed
class Season with _$Season {
  const factory Season({
    required String id,           // Unique within podcast
    required String displayName,  // "Season 2", "The Vanishing"
    required int sortKey,         // For ordering
    required List<Episode> episodes,
  }) = _Season;
}

/// Computed at runtime via extension
extension SeasonMetadata on Season {
  int get episodeCount => episodes.length;
  DateTime? get newestEpisodeDate;
  DateTime? get oldestEpisodeDate;
  String? get thumbnailUrl;
  // Progress computed by joining with playback history
}
```

### Pattern Definition

```dart
@freezed
class SeasonPattern with _$SeasonPattern {
  const factory SeasonPattern({
    required String id,
    String? podcastGuid,          // Match by GUID first
    String? feedUrlPattern,       // Fall back to URL regex
    required String resolverType, // Which resolver to use
    required Map<String, dynamic> config, // Resolver-specific params
    @Default(0) int priority,
    SeasonSortSpec? customSort,   // Pattern-defined default sort
  }) = _SeasonPattern;
}
```

### Sort Specification

Supports complex sorting rules per pattern (e.g., "sort by season number if > 0, else by date").

```dart
@freezed
sealed class SeasonSortSpec with _$SeasonSortSpec {
  /// Single field sort
  const factory SeasonSortSpec.simple(
    SeasonSortField field,
    SortOrder order,
  ) = SimpleSeasonSort;

  /// Multi-rule with conditions
  const factory SeasonSortSpec.composite(
    List<SeasonSortRule> rules,
  ) = CompositeSeasonSort;
}

@freezed
class SeasonSortRule with _$SeasonSortRule {
  const factory SeasonSortRule({
    required SeasonSortField field,
    required SortOrder order,
    SeasonCondition? when,  // e.g., "seasonNumber > 0"
  }) = _SeasonSortRule;
}
```

---

## Built-in Resolvers

| Resolver | Type ID | Logic | Default Sort |
|----------|---------|-------|--------------|
| `RssMetadataResolver` | `rss` | Groups by `episode.seasonNumber` | Season number asc |
| `TitleSeasonExtractor` | `title_sNNeMM` | Regex: `S(\d+)E(\d+)`, `Season (\d+)` | Season number asc |
| `TitleArcExtractor` | `title_arc` | Groups by title prefix before delimiter | Alphabetical |
| `TitleAppearanceOrderResolver` | `title_appearance` | Regex captures name; order by first appearance | Season number asc |
| `YearResolver` | `year` | Groups by `publishedAt.year` | Year desc |

### Title Appearance Order Resolver

Handles podcasts like:
```
- [Rome 1] First Steps
- [Rome 2] The Colosseum
- [Venezia 1] Arrival
- [Venezia 2] The Canals
- [Firenze 1] Renaissance
```

Assigns season numbers by first appearance order: Rome = 1, Venezia = 2, Firenze = 3.

```dart
class TitleAppearanceOrderResolver extends SeasonResolver {
  @override
  String get type => "title_appearance";

  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern) {
    final regex = RegExp(pattern!.config['pattern']);
    final sorted = episodes.sortedBy((e) => e.publishedAt);

    final seasonOrder = <String>[];
    final grouped = <String, List<Episode>>{};

    for (final episode in sorted) {
      final match = regex.firstMatch(episode.title);
      if (match != null) {
        final seasonName = match.group(1)!;
        if (!seasonOrder.contains(seasonName)) {
          seasonOrder.add(seasonName);
        }
        grouped.putIfAbsent(seasonName, () => []).add(episode);
      }
    }

    return SeasonGrouping(
      seasons: seasonOrder.mapIndexed((index, name) => Season(
        id: 'season_${index + 1}',
        displayName: name,
        sortKey: index + 1,
        episodes: grouped[name]!,
      )).toList(),
      ungroupedEpisodes: episodes.where(/* no match */).toList(),
    );
  }
}
```

---

## Resolver Interface

```dart
abstract class SeasonResolver {
  /// Unique identifier for this resolver type
  String get type;

  /// Attempts to group episodes into seasons
  /// Returns null if this resolver cannot handle the podcast
  SeasonGrouping? resolve(List<Episode> episodes, SeasonPattern? pattern);

  /// Default sort for seasons produced by this resolver
  SeasonSortSpec get defaultSort;
}
```

---

## UI Design

### Podcast Detail Screen

```
┌─────────────────────────────────────────┐
│  Podcast Header (artwork, title, etc.)  │
├─────────────────────────────────────────┤
│  ┌──────────────┬──────────────┐        │
│  │   Episodes   │   Seasons    │        │  <- Segmented control
│  └──────────────┴──────────────┘        │
├─────────────────────────────────────────┤
│  (Filter chips: All | Unplayed | ...)   │
├─────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐               │
│  │Season 1 │  │Season 2 │               │
│  │ 12 eps  │  │ 8 eps   │               │  <- Grid of cards
│  │ ████░░  │  │ ██████░ │               │
│  │Jan-Mar  │  │Apr-Jun  │               │
│  └─────────┘  └─────────┘               │
│                                         │
│  ┌─────────┐  ┌───────────┐             │
│  │Season 3 │  │Ungrouped  │             │
│  │ 4 eps   │  │ 2 eps     │             │
│  └─────────┘  └───────────┘             │
├─────────────────────────────────────────┤
│                              [Sort]     │  <- Icon button
└─────────────────────────────────────────┘
```

### Season Card Content

- Season name/number
- Episode count
- Progress indicator (e.g., "5/12 played")
- Date range (oldest to newest episode)
- Thumbnail from first episode

### Sort Bottom Sheet

Tap sort icon opens bottom sheet with options:
- Season number (ascending/descending)
- Newest episode date
- Progress (least complete first)
- Alphabetical

### Season Episodes Screen (Drill-down)

```
┌─────────────────────────────────────────┐
│  ← Back       Season 2: Venezia         │
├─────────────────────────────────────────┤
│  8 episodes · Apr-Jun 2024 · 3/8 played │
├─────────────────────────────────────────┤
│                              [Sort]     │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────┐    │
│  │ E1 · [Venezia 1] First Steps    │    │
│  │ 45 min · Apr 1 · Played         │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │ E2 · [Venezia 2] The Canals     │    │
│  │ 52 min · Apr 8 · In Progress    │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

Episode sort: by episode number, fallback to publish date.

### UI Decisions

- **Segmented control**: Fixed-width segments, no layout shift on toggle
- **Sort button**: Fixed icon button, options in bottom sheet (not inline dropdown)
- **Toggle visibility**: Hidden when no resolver succeeds
- **Ungrouped card**: Only shown when ungrouped episodes exist

---

## Sorting

### Season Level Options

1. Season number (ascending/descending)
2. Newest episode date (most recently updated first)
3. Progress (least complete first)
4. Alphabetical

### Episode Level Options

1. Episode number (ascending/descending) - primary
2. Publish date - fallback when no episode numbers

### Custom Sort Per Pattern

Patterns can define custom default sorts for complex cases:

```dart
// Example: Sort by season number if > 0, else by publish date
SeasonSortSpec.composite([
  SeasonSortRule(
    field: SeasonSortField.seasonNumber,
    order: SortOrder.ascending,
    when: SeasonCondition.seasonNumberGreaterThan(0),
  ),
  SeasonSortRule(
    field: SeasonSortField.newestEpisodeDate,
    order: SortOrder.descending,
  ),
])
```

---

## State Management

### Providers (audiflow_domain)

```dart
/// Resolves seasons for a podcast - cached per podcast
@riverpod
SeasonGrouping? podcastSeasons(Ref ref, int podcastId) {
  final podcast = ref.watch(podcastByIdProvider(podcastId));
  final episodes = ref.watch(episodesByPodcastIdProvider(podcastId));
  final resolver = ref.watch(seasonResolverServiceProvider);

  return resolver.resolveSeasons(
    podcast.guid,
    podcast.feedUrl,
    episodes,
  );
}

/// Whether season view toggle should be visible
@riverpod
bool hasSeasonView(Ref ref, int podcastId) {
  return ref.watch(podcastSeasonsProvider(podcastId)) != null;
}
```

### Controllers (audiflow_app)

```dart
/// View mode toggle state
@riverpod
class PodcastViewMode extends _$PodcastViewMode {
  @override
  PodcastViewModeState build(int podcastId) => PodcastViewModeState.episodes;

  void setEpisodes() => state = PodcastViewModeState.episodes;
  void setSeasons() => state = PodcastViewModeState.seasons;
}

enum PodcastViewModeState { episodes, seasons }

/// Season sort preference (per podcast, persisted)
@riverpod
class SeasonSortPreference extends _$SeasonSortPreference {
  @override
  SeasonSortConfig build(int podcastId) {
    // Load from storage, or use pattern's default, or fallback
  }

  void setSortField(SeasonSortField field, SortOrder order) { ... }
}

/// Sorted seasons for display
@riverpod
List<Season> sortedSeasons(Ref ref, int podcastId) {
  final grouping = ref.watch(podcastSeasonsProvider(podcastId));
  final sortPref = ref.watch(seasonSortPreferenceProvider(podcastId));

  return _applySorting(grouping?.seasons ?? [], sortPref);
}
```

---

## File Structure

### audiflow_domain

```
lib/src/features/feed/
├── models/
│   ├── season.dart                        # Season, SeasonGrouping
│   └── season_pattern.dart                # SeasonPattern, SeasonSortSpec
├── resolvers/
│   ├── season_resolver.dart               # Abstract interface
│   ├── rss_metadata_resolver.dart
│   ├── title_season_extractor.dart
│   ├── title_arc_extractor.dart
│   ├── title_appearance_order_resolver.dart
│   └── year_resolver.dart
├── services/
│   └── season_resolver_service.dart       # Chain orchestration
├── registries/
│   └── season_pattern_registry.dart       # V1: hardcoded patterns
└── providers/
    └── season_providers.dart              # podcastSeasons, hasSeasonView
```

### audiflow_app

```
lib/features/podcast_detail/
├── presentation/
│   ├── controllers/
│   │   ├── podcast_view_mode_controller.dart
│   │   └── season_sort_controller.dart
│   ├── screens/
│   │   ├── podcast_detail_screen.dart     # Modified: add toggle
│   │   └── season_episodes_screen.dart    # New: drill-down
│   └── widgets/
│       ├── season_view_toggle.dart        # New
│       ├── season_grid.dart               # New
│       ├── season_card.dart               # New
│       └── season_sort_sheet.dart         # New
```

---

## Future Extensibility

### Server-Downloaded Patterns

```dart
class SeasonPatternRegistry {
  List<SeasonPattern> _builtIn = [...];
  List<SeasonPattern> _serverPatterns = [];

  Future<void> syncFromServer() async {
    // GET /api/v1/season-patterns
    // Store in local database
    // Invalidate affected podcast caches
  }
}
```

### User-Defined Patterns

```dart
class SeasonPatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get podcastId => integer().references(Subscriptions, #id)();
  TextColumn get resolverType => text()();
  TextColumn get configJson => text()();
  TextColumn get customSortJson => text().nullable()();
  BoolColumn get isUserDefined => boolean().withDefault(const Constant(true))();
}
```

### Pattern Priority (Future)

```
1. User-defined (highest - user's choice wins)
2. Server-downloaded (curated fixes)
3. Built-in (fallback)
```

### V1 Code Requirements for Future Support

- `SeasonPatternRegistry` uses interface, not concrete list
- Providers invalidate correctly when patterns change
- No hardcoded assumptions about pattern source

---

## Open Questions

None - all decisions made during design session.

---

## Revision History

- 2026-01-24: Initial design
