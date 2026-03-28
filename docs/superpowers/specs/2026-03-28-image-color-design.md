# Image Color: Adaptive Status Bar and App Bar Buttons

## Problem

The episode detail screen displays podcast artwork behind the `SliverAppBar`. The system status bar icons (clock, battery, signal) and app bar buttons (back, share) use fixed colors that can become invisible against certain artwork.

## Scope

**In scope:** Episode detail screen (`EpisodeDetailScreen`) only.

**Out of scope:** Podcast detail screen (standard `SearchableAppBar`, no artwork overlap), player screen (Cupertino sheet, no system app bar).

## Design decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Back/share button visibility | Background shape (not color-only) | Guarantees tap-target visibility on any artwork |
| Shape | Squircle (border-radius ~10, 36x36) | iOS-native feel |
| Icon + scrim adaptation | Adaptive (not fixed) | More polished; scrim and icon color flip based on artwork luminance |

## Color extraction

- Approach: top-edge pixel sampling via `ResizeImage` (24x24) + `toByteData`
- Samples the top 25% of pixels to determine brightness where buttons overlay
- Compute average luminance via ITU-R BT.709 relative luminance
- Threshold: `0.5` (below = dark artwork, above = light artwork)
- Extraction runs once on screen load (deferred via `addPostFrameCallback`), cached in widget state
- Fallback (no artwork or extraction failure): treat as dark artwork

### Placement

`ArtworkBrightnessResolver` utility in `audiflow_ui`. Returns a brightness enum (`Brightness.dark` or `Brightness.light`) from an `ImageProvider`. The episode detail screen consumes this to drive both status bar and button styling.

## Status bar icons

Set via `SliverAppBar.systemOverlayStyle`:

| Artwork brightness | `SystemUiOverlayStyle` | Status bar icons |
|--------------------|------------------------|------------------|
| Dark | `.light` | White |
| Light | `.dark` | Black |

## App bar buttons

Replace default `SliverAppBar` leading/actions with custom `OverlayActionButton` widget.

| Artwork brightness | Scrim color | Icon color |
|--------------------|-------------|------------|
| Dark | `rgba(255,255,255,0.2)` | White |
| Light | `rgba(0,0,0,0.25)` | Dark (`#1a1a1a`) |

### `OverlayActionButton` widget

- Location: `audiflow_ui/lib/src/widgets/buttons/overlay_action_button.dart`
- Props: `icon` (IconData), `onTap` (VoidCallback?), `collapseRatio` (double), `artworkBrightness` (Brightness), `semanticLabel` (String?)
- Visual size: 36x36, hit target: 48x48, border-radius 10 (squircle)
- Exported from `audiflow_ui`

## Affected files

| File | Change |
|------|--------|
| `audiflow_ui/pubspec.yaml` | No new dependencies (uses built-in `ResizeImage` + pixel sampling) |
| `audiflow_ui/lib/src/widgets/buttons/overlay_action_button.dart` | New: squircle button widget |
| `audiflow_ui/lib/src/utils/artwork_brightness_resolver.dart` | New: color extraction utility |
| `audiflow_ui/lib/audiflow_ui.dart` | Export new files |
| `audiflow_app/.../episode_detail_screen.dart` | Use `ArtworkBrightnessResolver`, `SliverAppBar.systemOverlayStyle`, custom leading/actions |

## Testing

- Unit test `ArtworkBrightnessResolver` with dark/light/error-fallback image scenarios
- Widget test `OverlayActionButton` renders correct colors for each brightness, hit target size, semantics enabled state, and disabled opacity
