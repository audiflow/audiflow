# Play Button (Episode Pill) Content Design

**Status:** approved
**Date:** 2026-05-08
**Owner:** UI / `audiflow_ui`

## Background

`EpisodeCard` recently moved its play affordance from a bare `IconButton` into an outlined pill (`EpisodePlayPill`). The pill currently renders a single combined `subtitle` string ("32:50  Apr 29") inside the pill, which:

- Mixes two semantically different pieces (play state vs publish date) inside the one element that represents play state.
- Truncates with ellipsis on narrower devices.
- Cannot vary by playback state without callers concatenating state-specific copy.

This spec defines the canonical contents of the pill, the visual treatment per state, and the relocation of the publish date.

## Goals

- Pill conveys playback state and remaining/total duration only.
- Date is rendered outside the pill, in the same action row.
- Pill icon visibly reflects progress for in-progress episodes.
- Localization for English and Japanese.

## Non-goals

- Changing the player screen, mini-player, or queue tile visuals.
- Adding new playback affordances (e.g. seek, mark-as-played) to the pill.
- Animating the progress ring (renders at the latest known progress only).

## States

The pill has five mutually exclusive visual states, derived from existing flags on `EpisodeCard` plus one new `progressFraction` value.

| Resolution priority | State | Trigger | Leading visual | Pill text (en / ja) |
|---|---|---|---|---|
| 1 | Loading | `isLoading` | indeterminate spinner | _(no label change while loading; falls back to most recent label)_ |
| 2 | Completed | `isCompleted` | `Icons.check_circle_outline`, color `onSurfaceVariant` | `Completed` / `再生済み` |
| 3 | Playing | `isPlaying` | progress ring (determinate) wrapping `Icons.pause` (12 dp), color `primary` | `{time} left` / `残り {time}` |
| 4 | In-progress paused | `isInProgress && !isPlaying && !isCompleted` | progress ring wrapping `Icons.play_arrow` (12 dp), color `primary` | `{time} left` / `残り {time}` |
| 5 | Not played | _(default)_ | `Icons.play_circle_filled`, color `primary` | `{time}` / `{time}` |

Resolution is top-down: completed beats in-progress, loading beats both. `isInProgress` and `isPlaying` may co-occur but the visual rules above already disambiguate.

`progressFraction` is consumed only by the playing and in-progress-paused states. It is silently clamped to `[0.0, 1.0]`. When null, the ring degrades to a faint full circle (`backgroundColor` only) so the icon does not jump in size between states.

### Border / pill chrome

- Stadium border, 1 dp.
- Border color: `outline` for active states, `outlineVariant` for completed.
- Background: transparent.
- Padding: 10 dp horizontal, 4 dp vertical.

## Time format

Single helper, applied to both remaining time (in-progress) and total duration (not-played):

```dart
String podcastShortLabel(Duration d) {
  final secs = d.inSeconds;
  if (secs < 60) {
    return '0:${secs.toString().padLeft(2, '0')}';
  }
  return '${d.inMinutes}m';
}
```

- ≥ 60 s → `{minutes truncated}m` (e.g. `33m`, `9999m`). No ceiling — long-form episodes that exceed four digits remain readable.
- < 60 s → `0:ss` zero-padded (e.g. `0:45`, `0:09`). The leading `0:` is intentional so the form is unambiguous as mm:ss.
- Negative or null inputs treated as 0 → `0:00`. Callers guarantee non-null where reachable; this is defense-in-depth, not a fallback.

The helper lives in `audiflow_core` because it has no Flutter dependency and is reused outside `audiflow_ui`. Suggested location: `packages/audiflow_core/lib/src/extensions/duration_extensions.dart` as a `Duration` extension getter `podcastShortLabel`.

## Layout

`EpisodeCard._buildActionRow` becomes:

```
Row(
  children: [
    Flexible(fit: loose, child: EpisodePlayPill(...)),
    if (dateLabel != null) ...[
      SizedBox(width: Spacing.sm),
      Text(dateLabel, style: bodySmall, color: onSurfaceVariant, ellipsis),
    ],
    if (hasTranscript) ...[ SizedBox(width: Spacing.xs), TranscriptBadge ],
    if (isNew) ...[ SizedBox(width: Spacing.xs), NewBadge ],
    Spacer(),
    ...actionButtons,
  ],
)
```

- `Flexible(fit: loose)` on pill keeps it at its natural size up to the available width, no flex tug-of-war with `Spacer`.
- Date is `Text` not a chip, single line, ellipsis. Cap width to whatever remains; in normal traffic the pill plus action buttons leave room for a 6-character date like `Apr 29` or `5月8日`.
- `Spacer` after badges absorbs slack so action buttons sit flush right.

## API changes

### `EpisodePlayPill` (`audiflow_ui`)

```dart
EpisodePlayPill({
  required String label,
  required bool isPlaying,
  required bool isLoading,
  required bool isCompleted,
  required bool isInProgress,
  double? progressFraction,
  VoidCallback? onPressed,
})
```

- New: `isInProgress`, `progressFraction`.
- `label` continues to be caller-formatted; no l10n strings inside the widget.

### `EpisodeCard` (`audiflow_ui`)

Replace the single `subtitle` parameter with two:

```dart
EpisodeCard({
  ...,
  required String pillLabel,
  String? dateLabel,
  required bool isInProgress,
  double? progressFraction,
  ...
})
```

- `pillLabel`: pre-formatted state label (e.g. `12m left`, `残り 12m`, `Completed`, `33m`).
- `dateLabel`: pre-formatted date string, or `null` to omit the date entirely.
- `isInProgress`, `progressFraction`: forwarded into `EpisodePlayPill`.
- Old `subtitle` parameter is removed (single-package widget; no compat shim).

### l10n keys (`audiflow_app`)

`packages/audiflow_app/lib/l10n/app_en.arb`:

```json
"episodePillCompleted": "Completed",
"@episodePillCompleted": { "description": "Pill label for completed episode" },
"episodePillRemaining": "{time} left",
"@episodePillRemaining": {
  "description": "Pill label for in-progress episode showing remaining time",
  "placeholders": { "time": { "type": "String", "example": "12m" } }
}
```

`packages/audiflow_app/lib/l10n/app_ja.arb`:

```json
"episodePillCompleted": "再生済み",
"episodePillRemaining": "残り {time}"
```

### `audiflow_app` callers

Both `EpisodeListTile` and `SmartPlaylistEpisodeListTile` lose `_buildSubtitleText` and gain two helpers:

```dart
String _buildPillLabel(EpisodeWithProgress? p, PodcastItem ep, bool isCompleted, AppLocalizations l10n) {
  if (isCompleted) return l10n.episodePillCompleted;
  final remaining = p?.remainingDuration;       // see "Progress data" below
  final total = ep.duration;
  if (p != null && p.isInProgress && remaining != null) {
    return l10n.episodePillRemaining(remaining.podcastShortLabel);
  }
  return total?.podcastShortLabel ?? '';
}

String? _buildDateLabel(PodcastItem ep, AppLocalizations l10n) {
  if (ep.publishDate == null) return null;
  return ep.publishDate!.formatEpisodeDate(
    todayLabel: l10n.dateToday,
    yesterdayLabel: l10n.dateYesterday,
  );
}

double? _buildProgressFraction(EpisodeWithProgress? p) {
  if (p == null || p.durationMs == 0) return null;
  return (p.positionMs / p.durationMs).clamp(0.0, 1.0);
}
```

These are called inline in the two existing `EpisodeCard(...)` builds. No state, no controller changes.

## Progress data

`EpisodeWithProgress` already carries `positionMs`, `durationMs`, and `remainingTimeFormatted`. The spec depends on:

- `remainingDuration`: a `Duration` derived from `(durationMs - positionMs)`. If this getter does not exist, add it as a computed property next to `remainingTimeFormatted`.
- `durationMs == 0` is treated as "no progress" (returns null fraction). The existing `isInProgress` flag already filters this case but defense-in-depth is cheap.

## Testing

### `audiflow_core`

`packages/audiflow_core/test/extensions/duration_extensions_test.dart`:

- `Duration.zero.podcastShortLabel` → `0:00`
- `Duration(seconds: 9).podcastShortLabel` → `0:09`
- `Duration(seconds: 59).podcastShortLabel` → `0:59`
- `Duration(seconds: 60).podcastShortLabel` → `1m`
- `Duration(seconds: 90).podcastShortLabel` → `1m` (truncates)
- `Duration(minutes: 33).podcastShortLabel` → `33m`
- `Duration(minutes: 9999).podcastShortLabel` → `9999m`

Use `package:checks` per project rule.

### `audiflow_ui`

`packages/audiflow_ui/test/widgets/cards/episode_card_test.dart` updates:

- Replace existing tests that reference `subtitle`, `IconButton`, or `play_circle_filled` size assertions.
- Cover each pill state by flag combination:
  - Not played: assert `Icons.play_circle_filled` present, no spinner, no check icon, label = `33m`.
  - In-progress paused: assert determinate `CircularProgressIndicator` with `value` near 0.5, inner `Icons.play_arrow`, label = `12m left`.
  - Playing: same ring, inner `Icons.pause`, label = `12m left`.
  - Completed: assert `Icons.check_circle_outline` present, label = `Completed`, color matches `onSurfaceVariant`.
  - Loading: assert indeterminate spinner present.
- Date rendering: when `dateLabel: 'Apr 29'`, assert text is found outside the pill (not inside `EpisodePlayPill` widget).
- Tap: `onPlayPause` fires when tapping anywhere inside the pill.

`packages/audiflow_ui/test/widgets/buttons/episode_play_pill_test.dart` (new):

- State-by-state visual rendering, isolated from card layout.

### `audiflow_app`

Spot-check widget tests for the two list tiles, parameterized over states × locale (en, ja):

- Verify pill text and date text resolve to the expected localized strings.
- Verify the date is omitted when `episode.publishDate == null`.

## Files touched

1. `packages/audiflow_core/lib/src/extensions/duration_extensions.dart` — add `podcastShortLabel`.
2. `packages/audiflow_core/test/extensions/duration_extensions_test.dart` — new tests.
3. `packages/audiflow_domain/lib/src/features/feed/models/episode_with_progress.dart` — confirm `remainingDuration` getter (add if missing).
4. `packages/audiflow_ui/lib/src/widgets/buttons/episode_play_pill.dart` — accept `isInProgress` + `progressFraction`, swap completed icon, add ring rendering.
5. `packages/audiflow_ui/lib/src/widgets/cards/episode_card.dart` — split `subtitle` into `pillLabel` + `dateLabel`, add `isInProgress` + `progressFraction`, layout update.
6. `packages/audiflow_ui/test/widgets/cards/episode_card_test.dart` — refactored.
7. `packages/audiflow_ui/test/widgets/buttons/episode_play_pill_test.dart` — new file.
8. `packages/audiflow_app/lib/l10n/app_en.arb` + `app_ja.arb` — `episodePillCompleted`, `episodePillRemaining`.
9. `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart` — split helpers, new params on `EpisodeCard`.
10. `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart` — same.

## Out of scope / explicit non-changes

- The `EpisodeProgressIndicator` widget in `audiflow_ui/lib/src/widgets/indicators/` is still used elsewhere (player screen, etc.) and is unchanged.
- No animation curves or staggered ring updates. The ring redraws when the parent rebuilds.
- The pill never collapses to icon-only on narrow widths; the design accepts that very narrow rows will ellipsize the date.

## Risks

- **Subtitle semantics change is breaking** for any test or screen that constructs `EpisodeCard` directly. Mitigation: only two production callers + one widget test file consume `subtitle` today; both are updated in the same change set.
- **Progress fraction without animation may feel static.** Acceptable because the card list rebuilds on playback ticks via existing Riverpod streams.
