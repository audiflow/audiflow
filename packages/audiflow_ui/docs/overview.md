# audiflow_ui -- Overview

## Purpose

`audiflow_ui` is the shared UI layer for the Audiflow podcast player. It provides reusable widgets, the Material 3 theme system, design tokens (spacing, borders, text styles, colors), and UI utility functions. All visual components that appear in two or more app features belong here. Feature-specific or single-use widgets belong in `audiflow_app`.

## Responsibilities

- Reusable widgets for cards, player chrome, download indicators, list grouping, queue actions, and search
- Material 3 theme configuration with light and dark color schemes
- Design token constants (spacing scale, border radii)
- Responsive grid calculation and search filtering utilities

## Non-responsibilities

- Feature screens, routing, navigation (owned by `audiflow_app`)
- Riverpod providers, controllers, state management (owned by `audiflow_app`)
- Business logic, repositories, Isar models (owned by `audiflow_domain`)
- Widgets used in only one feature (belong in `audiflow_app/lib/features/`)

## Main concepts

- **Design tokens**: Static constant classes (`Spacing`, `AppBorders`) that define the spacing and border-radius scale. All widgets reference these instead of raw values.
- **Theme system**: `AppTheme` assembles `ThemeData` from `AppColorScheme` and `AppTextStyles`. The app applies `AppTheme.light()` or `AppTheme.dark()` at the `MaterialApp` level.
- **Widget placement rule**: A widget moves to `audiflow_ui` when it is consumed by two or more distinct features in `audiflow_app`. Until then, it stays in the feature directory.

## Directory structure

```
lib/
  audiflow_ui.dart              # Barrel export (all public API)
  src/
    themes/
      app_theme.dart            # AppTheme.light() / AppTheme.dark()
      color_scheme.dart         # AppColorScheme -- light/dark ColorScheme
      text_styles.dart          # AppTextStyles.textTheme (Material 3 type scale)
    styles/
      spacing.dart              # Spacing.xxs..xxl (2..48 dp)
      borders.dart              # AppBorders.xs..xl (4..24 radius)
    widgets/
      cards/
        episode_card.dart       # EpisodeCard -- fixed-height episode row for sliver lists
        podcast_artwork_grid_item.dart  # PodcastArtworkGridItem -- artwork card for grids
      indicators/
        episode_progress_indicator.dart # EpisodeProgressIndicator -- played/in-progress/unplayed
      player/
        mini_player_artwork.dart       # MiniPlayerArtwork -- artwork with placeholder fallback
        mini_player_progress_bar.dart  # MiniPlayerProgressBar -- thin playback + buffer bar
      downloads/
        download_status_icon.dart      # DownloadStatusIcon -- icon per DownloadTask state
      queue/
        add_to_queue_button.dart       # AddToQueueButton -- tap=Play Later, long-press=Play Next
      lists/
        year_grouped_slivers.dart      # buildYearGroupedSlivers() -- sticky year headers + jump-to-year
        sub_category_slivers.dart      # buildSubCategorySlivers() -- two-level grouped slivers
        year_divider.dart              # YearDivider -- inline year separator
        year_picker_bottom_sheet.dart  # showYearPickerBottomSheet() -- modal year picker
      search/
        searchable_app_bar.dart        # SearchableAppBar -- title/search toggle with debounce
    utils/
      responsive_grid.dart      # ResponsiveGrid.columnCount() -- adaptive column count
      search_filter.dart        # filterBySearchQuery() -- two-tier title/description filter
```

## Widget catalog

| Widget | Location | Inputs | Behavior |
|--------|----------|--------|----------|
| `EpisodeCard` | `widgets/cards/` | title, subtitle, description, thumbnailUrl, play/new/completed flags, action buttons | Fixed-height row with standardized 44dp touch targets: thumbnail (hidden when same as podcast art), title, metadata, play button, action row. Uses `extended_image` for caching. |
| `PodcastArtworkGridItem` | `widgets/cards/` | title, artworkUrl, onTap | Grid cell with artwork image + title label. Placeholder on load/error. |
| `EpisodeProgressIndicator` | `widgets/indicators/` | isCompleted, isInProgress, remainingTimeFormatted | Shows "Played" checkmark, remaining time text, or nothing. |
| `MiniPlayerArtwork` | `widgets/player/` | imageUrl, size, borderRadius | Rounded artwork with podcast-icon placeholder fallback. |
| `MiniPlayerProgressBar` | `widgets/player/` | progress, bufferedProgress, height | Three-layer bar: background track, buffered overlay, playback fill. |
| `DownloadStatusIcon` | `widgets/downloads/` | DownloadTask?, size, onTap | Icon per state: download, pending, progress ring, paused, completed, failed, cancelled. Depends on `audiflow_domain.DownloadTask`. |
| `AddToQueueButton` | `widgets/queue/` | onPlayLater, onPlayNext | Tap adds to end of queue; long-press adds to front with haptic feedback. |
| `SearchableAppBar` | `widgets/search/` | title, onSearchChanged, debounceDuration | AppBar that toggles between title and debounced search field (default 300ms). |

## List grouping functions

| Function | Purpose |
|----------|---------|
| `buildYearGroupedSlivers()` | Returns slivers with a pinned sticky year header that updates on scroll, inline year dividers, and jump-to-year via `showYearPickerBottomSheet()`. Uses `SliverFixedExtentList` for O(1) scroll offset. Falls back to flat list when fewer than 2 years. |
| `buildSubCategorySlivers()` | Returns slivers with two-level sticky headers: subcategory (expand/collapse) and optional year dividers within each subcategory. Uses `SubCategoryData<T>` as input model. |
| `showYearPickerBottomSheet()` | Modal bottom sheet listing years with current-year highlight. Returns selected year or null. |

## Theme system

### AppTheme

`AppTheme.light()` and `AppTheme.dark()` return complete `ThemeData` instances. Both use:
- `useMaterial3: true`
- `AppColorScheme.light()` / `AppColorScheme.dark()`
- `AppTextStyles.textTheme` (shared across both themes)
- Centered app bar with zero elevation
- Card with 12dp corner radius and elevation 2
- Elevated button with 8dp corner radius

### AppColorScheme

| Role | Light | Dark |
|------|-------|------|
| primary | `Colors.blue.shade700` | `Colors.blue.shade300` |
| secondary | `Colors.teal.shade600` | `Colors.teal.shade300` |
| tertiary | `Colors.purple.shade600` | `Colors.purple.shade300` |
| error | `Colors.red.shade700` | `Colors.red.shade300` |
| surface | `Colors.white` | `Colors.grey.shade900` |
| surfaceContainerHighest | `Colors.grey.shade100` | `Colors.grey.shade800` |

Note: The project also defines a palette in `.claude/rules/flutter/theming.md` (Primary #0D47A1, Secondary #1976D2, Accent #FFC107). The `AppColorScheme` values above are what the code actually uses.

### AppTextStyles

Full Material 3 type scale from `displayLarge` (57sp) through `labelSmall` (11sp). All use default font family. Weights are M3-standard (400 for body/display, 500 for title/label).

### Design tokens

**Spacing** (`Spacing` class): `xxs`=2, `xs`=4, `sm`=8, `md`=16, `lg`=24, `xl`=32, `xxl`=48

**Border radii** (`AppBorders` class): `xs`=4, `sm`=8, `md`=12, `lg`=16, `xl`=24

## Key dependencies

| Package | Used for |
|---------|----------|
| `audiflow_core` | `LayoutConstants.podcastGridItemWidth` in `ResponsiveGrid` |
| `audiflow_domain` | `DownloadTask` model in `DownloadStatusIcon` |
| `extended_image` | Cached network images in `EpisodeCard` |
| `material_symbols_icons` | Icons in `MiniPlayerArtwork`, `AddToQueueButton`, `EpisodeCard` |
| `sliver_tools` | `SliverPinnedHeader`, `MultiSliver` in list grouping widgets |
| `cached_network_image` | Declared in pubspec (available for image widgets) |
| `dynamic_color` | Declared in pubspec (available for Material You integration) |
| `flutter_screenutil` | Declared in pubspec (available for responsive sizing) |

## Widget placement decision tree

1. Is the widget used by 2+ features in `audiflow_app`? -- Yes: place in `audiflow_ui`
2. Does the widget depend on feature-specific state (Riverpod controller, route params)? -- Yes: keep in `audiflow_app/lib/features/{feature}/presentation/widgets/`
3. Is it a layout-level widget (scaffold, nav bar)? -- Yes: keep in `audiflow_app`
4. Is it a pure visual component with no business logic dependency beyond model types? -- Yes: candidate for `audiflow_ui`

Example: `MiniPlayerArtwork` (pure visual, reusable) lives here. `MiniPlayer` (uses `NowPlayingController` via Riverpod) lives in `audiflow_app/lib/features/player/presentation/widgets/`.

## Read next

- Parent repo `CLAUDE.md` -- monorepo structure and package roles
- `audiflow_app` docs -- how widgets are consumed in features
- `.claude/rules/flutter/theming.md` -- project visual design palette and guidelines

## When to update

Update this document when:
- New widgets are added to or removed from `audiflow_ui`
- Theme configuration changes (colors, text styles, component themes)
- Design tokens (spacing, borders) are modified
- New dependencies are added to `pubspec.yaml`
- The widget placement rule changes
