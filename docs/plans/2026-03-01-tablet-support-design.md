# Tablet Support Design

## Goal

Support iPad and Android tablets with landscape orientation, following Apple Podcasts' iPad design language. Phones remain portrait-only.

## Device Classification

Two form factors: **phone** and **tablet**.

Tablet threshold: `600dp <= shortestSide`. This matches iPad Mini (744pt logical width) and standard Android tablet breakpoints.

- **Phone**: portrait only (current behavior)
- **Tablet**: portrait + landscape

## Navigation

Three navigation modes based on form factor and orientation:

| Device | Orientation | Navigation |
|--------|-------------|------------|
| Phone | Portrait | Bottom `NavigationBar` (current) |
| Tablet | Portrait | Top floating tab bar in `AppBar` with sidebar toggle |
| Tablet | Landscape | Persistent sidebar on left |

### Tab bar items (4 destinations, unchanged)

Search, Library, Queue, Settings

### Sidebar (tablet landscape)

Left-aligned, 280dp wide. Shows the same 4 destinations with icons + labels. Future expansion: Library sub-sections (Recently Updated, Shows).

### Mini Player position

- Phone: above bottom `NavigationBar`
- Tablet portrait: bottom of content area (no bottom nav)
- Tablet landscape: bottom of content area, right of sidebar

## Content Layout Adaptation

### Podcast grids (Library, Search, Browse)

Responsive column count derived from available width:

```
columnCount = availableWidth ~/ podcastGridItemWidth (130dp)
```

Approximate results:
- Phone portrait (~390dp): 3 columns
- Tablet portrait (~744dp): 5 columns
- Tablet landscape (~1024dp minus sidebar): 5-6 columns

### Episode lists (Podcast detail, Queue)

- Phone: compact rows (small artwork, title, duration)
- Tablet: wider rows with description preview visible, larger artwork thumbnail

### Settings

Same single-column list, centered with 560dp max-width constraint on tablets.

## Full Player Screen

Opens as a modal sheet from the mini player. Same stacked layout on all devices:

1. Large artwork (dynamic background colors from cover art)
2. Episode title + podcast name
3. Seek bar
4. Playback controls (rewind 15s, play/pause, forward 30s)
5. Speed control + sleep timer
6. Show notes / transcript tabs

### Tablet adjustments (sizing only, not layout)

- Artwork max width constraint (prevents stretching on wide screens)
- Controls and text centered with 560dp max content width
- Sheet may not span full width in landscape (narrower centered sheet)

## Responsive Utilities

### Constants (`audiflow_core`)

| Constant | Value | Usage |
|----------|-------|-------|
| `tabletBreakpoint` | 600dp | Phone vs tablet threshold |
| `contentMaxWidth` | 560dp | Max width for centered content |
| `podcastGridItemWidth` | 130dp | Target width per grid item |
| `sidebarWidth` | 280dp | Tablet landscape sidebar |

### Device detection (`audiflow_core`)

`DeviceFormFactor` enum (`phone`, `tablet`) with utility function that reads `MediaQuery.shortestSide`.

### Responsive grid (`audiflow_ui`)

Column count calculator: takes available width and item target width, returns column count.

### Riverpod provider (`audiflow_app`)

`deviceFormFactorProvider` reads `MediaQuery` shortest side once at app startup.

## Implementation Scope

### New files

- `audiflow_core/lib/src/constants/layout_constants.dart`
- `audiflow_core/lib/src/utils/device_utils.dart`
- `audiflow_ui/lib/src/utils/responsive_grid.dart`

### Modified files

- `audiflow_app/lib/main.dart` (conditional orientation lock)
- `audiflow_app/lib/routing/scaffold_with_nav_bar.dart` (adaptive navigation shell)
- `audiflow_app/lib/features/player/presentation/screens/player_screen.dart` (max-width)
- `audiflow_app/lib/features/player/presentation/widgets/mini_player.dart` (tablet sizing)
- `audiflow_app/lib/features/library/presentation/` (responsive podcast grid)
- `audiflow_app/lib/features/discovery/presentation/` (search results grid)
- `audiflow_app/lib/features/queue/presentation/` (wider episode rows)
- `audiflow_app/lib/features/settings/presentation/` (centered max-width)

### Unchanged

- `audiflow_domain` (no business logic changes)
- `audiflow_podcast` (no parsing changes)
- iOS `Info.plist` (already declares iPad orientations)
- Android `AndroidManifest.xml` (respects Dart-level orientation)

## Adaptive Navigation Approach

`ScaffoldWithNavBar` reads `deviceFormFactorProvider` and `MediaQuery.orientation`:

1. **Phone portrait**: current `Scaffold` + bottom `NavigationBar` + `AnimatedMiniPlayer`
2. **Tablet portrait**: `Scaffold` with top `AppBar` containing tab buttons + sidebar toggle, `AnimatedMiniPlayer` at bottom of body
3. **Tablet landscape**: `Row` with sidebar on left + `Scaffold` body on right, `AnimatedMiniPlayer` at bottom of body

Hand-rolled with Material 3 components. No third-party adaptive scaffold packages.

## Out of Scope

- Master-detail (list + detail side-by-side) -- future enhancement
- Sidebar customization (drag items between sidebar and tab bar)
- Library sub-sections in sidebar (Recently Updated, Shows, Channels)
- Desktop/web support
