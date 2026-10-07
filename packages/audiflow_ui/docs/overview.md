# audiflow_ui -- Overview

## Purpose

`audiflow_ui` is the shared UI layer for the Audiflow podcast player. It provides reusable widgets, the Material 3 theme system, design tokens (spacing, borders, text styles, colors), and UI utility functions. All visual components that appear in two or more app features belong here. Feature-specific or single-use widgets belong in `audiflow_app`.

## Responsibilities

- Reusable widgets for cards, player chrome, download indicators, list grouping, queue actions, and search
- Material 3 theme configuration with light and dark color schemes
- Design token constants (colors, spacing, border radii, shadows)
- Responsive grid calculation and search filtering utilities

## Non-responsibilities

- Feature screens, routing, navigation (owned by `audiflow_app`)
- Riverpod providers, controllers, state management (owned by `audiflow_app`)
- Business logic, repositories, Isar models (owned by `audiflow_domain`)
- Widgets used in only one feature (belong in `audiflow_app/lib/features/`)

## Main concepts

- **Design tokens**: Static constant classes (`Spacing`, `AppBorders`, `AppShadows`) and the `AppColors` theme extension. All widgets reference these instead of raw values.
- **Theme system**: `AppTheme` assembles `ThemeData` from `AppColors`, `AppColorScheme`, and `AppTextStyles`. The app applies `AppTheme.light()` or `AppTheme.dark()` at the `MaterialApp` level.
- **Widget placement rule**: A widget moves to `audiflow_ui` when it is consumed by two or more distinct features in `audiflow_app`. Until then, it stays in the feature directory.

## Directory structure

```
lib/
  audiflow_ui.dart              # Barrel export (all public API)
  src/
    themes/
      app_colors.dart           # AppColors ThemeExtension, NowPlayingColors
      app_theme.dart            # AppTheme.light() / AppTheme.dark()
      color_scheme.dart         # AppColorScheme -- explicit light/dark ColorScheme
      text_styles.dart          # AppTextStyles -- redesign type roles + textTheme
    styles/
      spacing.dart              # Spacing.xxs..xxl (2..48 dp)
      borders.dart              # AppBorders -- radius scale + named radii
      shadows.dart              # AppShadows -- grouped and floating shadows
    widgets/
      artwork_image.dart        # ArtworkImage -- network artwork decoded at its displayed size
      cards/
        episode_card.dart       # EpisodeCard -- fixed-height episode row for sliver lists
        podcast_artwork_grid_item.dart  # PodcastArtworkGridItem -- artwork card for grids
      indicators/
        episode_progress_indicator.dart # EpisodeProgressIndicator -- played/in-progress/unplayed
        progress_line.dart             # ProgressLine, BottomEdgeProgress -- bottom-edge progress
      player/
        mini_player_artwork.dart       # MiniPlayerArtwork -- artwork with placeholder fallback
        mini_player_card.dart          # MiniPlayerCard -- floating mini player card
      headers/
        screen_headers.dart            # LargeTitle, SectionHeader -- top-level title and section rows
      navigation/
        app_tab_bar.dart               # AppTabBar, AppTabBarItem -- bottom tab bar
        floating_nav_button.dart       # FloatingNavButton, FloatingNavActions -- floating nav controls
        floating_nav_scroll.dart       # FloatingNavScroll, CollapsingHero -- scroll-driven hero/bar state
        floating_navigation_bar.dart   # FloatingNavigationBar -- overlay bar for detail screens
        navigation_search_field.dart   # NavigationSearchField -- in-navigation search row
      downloads/
        download_status_icon.dart      # DownloadStatusIcon -- icon per DownloadTask state
      queue/
        add_to_queue_button.dart       # AddToQueueButton -- tap=Play Later, long-press=Play Next
      lists/
        grouped_section.dart           # GroupedSection, SliverGroupedSection -- rounded surface with hairline-separated rows
        settings_row.dart              # SettingsRow -- icon tile, title/subtitle, trailing control
        settings_trailing.dart         # SettingsTrailing -- chevron / picker / toggle / stepper
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
| `ArtworkImage` | `widgets/` | url, width, height, fit, placeholder, loading | Every network artwork goes through this. Decodes at `width` (or the layout constraint's max width) times the device pixel ratio, so 1400-3000 px channel artwork never lands in the image cache at full size; downloaded bytes are disk-cached once per URL. Pass `width` explicitly inside a `Hero`, whose flight animates constraints. A failed load shows `placeholder`, or ExtendedImage's tap-to-retry message when none is given. |
| `EpisodeCard` | `widgets/cards/` | title, subtitle, description, thumbnailUrl, play/new/completed flags, progressFraction, action buttons | Fixed-height row with standardized 44dp touch targets: thumbnail (hidden when same as podcast art), title, metadata, play pill, action row. Thumbnail via `ArtworkImage`. Started rows get a `BottomEdgeProgress` line; completed rows show it full. |
| `EpisodePlayPill` | `widgets/buttons/` | label, isPlaying, isLoading, isCompleted, onPressed | 32dp pill (44dp touch target) with state glyph and tabular time label: play on `surfaceMuted`, pause on `accentTint` in `accent`, check in `inkTertiary`, spinner while loading. Never shows progress. |
| `ProgressLine` / `BottomEdgeProgress` | `widgets/indicators/` | fraction, fillColor | 3dp line (hairline track, accent fill; overridable, e.g. `brand`). `BottomEdgeProgress` overlays it on a child's bottom edge once fraction is above 0 (full at 1), without changing the child's size. |
| `PodcastArtworkGridItem` | `widgets/cards/` | title, artworkUrl, onTap | Grid cell with artwork image + title label. Placeholder on load/error. |
| `EpisodeProgressIndicator` | `widgets/indicators/` | isCompleted, isInProgress, remainingTimeFormatted | Shows "Played" checkmark, remaining time text, or nothing. |
| `MiniPlayerArtwork` | `widgets/player/` | imageUrl, size, borderRadius | Rounded artwork with podcast-icon placeholder fallback. |
| `MiniPlayerCard` | `widgets/player/` | artwork, title, subtitle, actions, progress, onTap, semanticLabel | Floating `surface` card (radius 16, floating shadow) 64dp tall: 44dp artwork, one-line title and subtitle, caller-supplied action buttons, and a `brand` bottom-edge progress line once started. No remaining-time text. |
| `LargeTitle` / `SectionHeader` | `widgets/headers/` | title, trailing | Left-aligned `displayTitle` for top-level tabs and 44dp `sectionTitle` rows, both with a 20dp gutter, header semantics, and an optional trailing control. |
| `AppTabBar` | `widgets/navigation/` | items (`AppTabBarItem`: icon, label, selected, onTap) | `bg` bar with a top hairline, 56dp plus the bottom inset. Active tab: `accent`, filled icon, 600 label; inactive: `inkTertiary`. Callers pass only visible tabs. |
| `FloatingNavigationBar` | `widgets/navigation/` | leading, title, titleOpacity, backgroundOpacity, trailing, search | Overlay bar for detail screens. Title and `bg` + hairline background fade in by opacity; a `NavigationSearchField` replaces the whole row. Use `heightOf(context)` to inset content. |
| `FloatingNavButton` / `FloatingNavActions` | `widgets/navigation/` | icon, tooltip, onPressed / actions | 44dp white circle, or a white pill of 44dp icon buttons, both with the floating shadow. |
| `FloatingNavScroll` / `CollapsingHero` | `widgets/navigation/` | offset, heroExtent / progress, child | Maps scroll offset to hero, title and background progress (title fades in over the next 24dp after the hero scrolls away). The hero fades and shrinks to 85% toward its bottom edge. |
| `NavigationSearchField` | `widgets/navigation/` | controller, hintText, cancelLabel, onCancel, onChanged | Autofocused search field with an `accent` cancel button that clears the query. |
| `DownloadStatusIcon` | `widgets/downloads/` | DownloadTask?, size, onTap | Icon per state: download, pending, progress ring, paused, completed, failed, cancelled. Depends on `audiflow_domain.DownloadTask`. |
| `AddToQueueButton` | `widgets/queue/` | onPlayLater, onPlayNext | Tap adds to end of queue; long-press adds to front with haptic feedback. |
| `GroupedSection` | `widgets/lists/` | children, header, footer, separatorIndent, margin | Rows on one rounded `surface` (radius 18, grouped shadow) separated by `hairline` dividers; overline header (semantics header) and meta footer in `inkTertiary`; 20dp screen gutter by default. |
| `SliverGroupedSection` | `widgets/lists/` | itemCount, itemBuilder, separatorIndent, margin | Sliver form of `GroupedSection` for long lists: rows build lazily as they scroll in, on the same surface (a `DecoratedSliver`) with the same separators; each row gets its own transparent `Material` so ink splashes show above the surface. |
| `SettingsRow` | `widgets/lists/` | title, subtitle, icon, trailing, onTap | Row of min height 54 (60 with subtitle): optional 32dp `accentTint` icon tile, title, one-line subtitle, optional `SettingsTrailing`. Use `separatorIndentWithIcon` on the section when rows carry icons. |
| `SettingsTrailing` | `widgets/lists/` | `.chevron()`, `.picker(value)`, `.toggle(value, onChanged)`, `.stepper(valueLabel, decrementLabel, incrementLabel, onDecrement, onIncrement)` | Sealed trailing control. Toggle makes the whole row flip the switch and merges semantics; stepper buttons are 44dp with accessible names. |
| `SearchableAppBar` | `widgets/search/` | title, onSearchChanged, debounceDuration | AppBar that toggles between title and debounced search field (default 300ms). |

## List grouping functions

| Function | Purpose |
|----------|---------|
| `buildYearGroupedSlivers()` | Returns slivers with a pinned sticky year header that updates on scroll, inline year dividers, and jump-to-year via `showYearPickerBottomSheet()`. Uses `SliverFixedExtentList` for O(1) scroll offset. Falls back to flat list when fewer than 2 years. |
| `buildSubCategorySlivers()` | Returns slivers with two-level sticky headers: subcategory (expand/collapse) and optional year dividers within each subcategory. Uses `SubCategoryData<T>` as input model. |
| `showYearPickerBottomSheet()` | Modal bottom sheet listing years with current-year highlight. Returns selected year or null. |

## Theme system

Tokens and theme follow `docs/design/redesign.md` section 2 (the source of truth for values and roles).

### AppTheme

`AppTheme.light()` and `AppTheme.dark()` return complete `ThemeData` instances built from `AppColors` tokens and `AppColorScheme`. Both:
- register `AppColors` as a `ThemeExtension`
- use `bg` for scaffold, app bar, and navigation bar backgrounds; `surface` for cards, sheets, dialogs, menus
- give cards the grouped-surface radius (18) and a faint 1dp shadow; sheets get 28 top corners
- render buttons, chips, and the FAB as fully rounded pills; filled actions use `accent`
- color selected tabs and navigation destinations with `accent`, inactive ones with `inkTertiary`
- fill text fields with `surfaceSunken`, borderless until focused

### AppColors

`ThemeExtension` carrying every token from redesign 2.1 (`bg`, `surface`, `surfaceSunken`, `surfaceMuted`, `ink`..`inkQuaternary`, `hairline`, `outline`, `progressTrack`, `accent`, `onAccent`, `accentTint`, `brand`). Read with `AppColors.of(context)`; it falls back to the palette matching the theme brightness when the extension is absent. `accentTint` is stored opaque (accent composited over `surface`). `progressTrack` is the second light `outline` value in the spec. `brand` is for non-text marks only.

`NowPlayingColors` holds the full-screen player constants (fallback ground `#22304F`, white controls, translucent track and labels).

### AppColorScheme

Explicit `ColorScheme` per mode (no seed). Mapped roles follow the spec table: `primary`=`accent`, `primaryContainer`=`accentTint`, `surface`=`bg`, `surfaceContainerLowest`=`surface`, `surfaceContainer`=`surfaceMuted`, `surfaceContainerHigh`=`surfaceSunken`, `onSurface`=`ink`, `onSurfaceVariant`=`inkSecondary`, `outline`=`outline`, `outlineVariant`=`hairline`. Unmapped roles: secondary and tertiary reuse the accent family (one-accent rule), error uses the M3 baseline reds, `surfaceTint` is transparent.

### AppTextStyles

Named redesign roles: `displayTitle` (34/700), `heroTitle` (22/700), `heroTitleLong` (19/700), `sectionTitle` (20/700), `rowTitle` (15/600), `body` (15/400), `meta` (13/400), `caption` (12/400), `overline` (12/600, tracked), `label` (14/600). `AppTextStyles.tabular(style)` adds tabular figures for changing numbers. `textTheme` maps the Material slots onto these roles (`displaySmall`=displayTitle, `headlineSmall`=heroTitle, `titleLarge`=sectionTitle, `titleMedium`=rowTitle, `bodyLarge`=body, `bodyMedium`=meta, `bodySmall`=caption, `labelLarge`=label, `labelSmall`=overline). Font family is the platform default.

### Design tokens

**Spacing** (`Spacing` class): `xxs`=2, `xs`=4, `sm`=8, `md`=16, `lg`=24, `xl`=32, `xxl`=48; layout values `screenHorizontal`=20, `rowVertical`=12, `rowHorizontal`=16, `sectionGap`=24, `minTouchTarget`=44

**Border radii** (`AppBorders` class): `xs`=4, `sm`=8, `md`=12, `lg`=16, `xl`=24; named `groupedSurface`=18, `card`=16, `artworkList`=12, `artworkHero`=20, `sheet`=28 (top only), `pill`=fully rounded

**Shadows** (`AppShadows` class): `groupedSurface` (single `0 1px 2px` at 5%), `floating` (two-layer neutral)

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
