# Effective Thumbnail Visibility

## Purpose

Define a single, consistent rule for resolving the `showThumbnail` /
`showEpisodeThumbnail` flags introduced by smart playlist schema v6.
The pattern-level meta flag acts as the *default* for descendant
surfaces; explicit per-surface flags always win.

## Flags

Schema v6 exposes thumbnail visibility at four locations:

| Field | Surface |
|-------|---------|
| `PatternMeta.showEpisodeThumbnail` | Main podcast episode list (outside any smart playlist) |
| `SmartPlaylistDefinition.groupItem.showThumbnail` | Group cards in a smart playlist (default) |
| `SmartPlaylistGroupDef.groupItem.showThumbnail` | Per-group override for the group card |
| `SmartPlaylistDefinition.episodeItem.showThumbnail` | Episode rows inside a group (default) |
| `SmartPlaylistGroupDef.episodeItem.showThumbnail` | Per-group override for episode rows |

All fields are tri-state (`bool?`): `null` means unset, `true` / `false`
are explicit.

## Rule

Only `PatternMeta.showEpisodeThumbnail` flips the default for
unset descendants. Explicit `true` / `false` at any descendant level
always wins.

```
metaDefault(meta) =
  (meta?.showEpisodeThumbnail == false) ? false : true
```

Per surface:

| Surface | Resolution |
|---------|-----------|
| Main podcast episode list | `meta?.showEpisodeThumbnail ?? true` |
| Smart playlist group card | `group.groupItem.showThumbnail ?? playlist.groupItem.showThumbnail ?? metaDefault(meta)` |
| Episode row inside playlist group | `group.episodeItem.showThumbnail ?? playlist.episodeItem.showThumbnail ?? metaDefault(meta)` |

Group card visibility and episode row visibility are independent:
turning group cards off does not hide the episode rows inside that
group.

When no smart playlist pattern is matched (`meta == null`), all
surfaces default to `true`.

## Implementation

Single pure helper in `audiflow_domain`:

- File: `packages/audiflow_domain/lib/src/features/feed/services/effective_thumbnails.dart`
- Class: `EffectiveThumbnails` (private constructor, three static methods)
- Exported from `audiflow_domain.dart`

```dart
final class EffectiveThumbnails {
  const EffectiveThumbnails._();

  static bool _metaDefault(PatternMeta? meta) =>
      meta?.showEpisodeThumbnail != false;

  static bool podcastEpisodeList(PatternMeta? meta) =>
      meta?.showEpisodeThumbnail ?? true;

  static bool groupCard({
    PatternMeta? meta,
    required SmartPlaylistDefinition playlist,
    SmartPlaylistGroupDef? group,
  }) =>
      group?.groupItem?.showThumbnail ??
      playlist.groupItem?.showThumbnail ??
      _metaDefault(meta);

  static bool episodeRowInGroup({
    PatternMeta? meta,
    required SmartPlaylistDefinition playlist,
    SmartPlaylistGroupDef? group,
  }) =>
      group?.episodeItem?.showThumbnail ??
      playlist.episodeItem?.showThumbnail ??
      _metaDefault(meta);
}
```

No Isar schema change. No new Riverpod state. Resolution happens
at render time; cost is three null-coalesces.

## Tests

`packages/audiflow_domain/test/features/feed/services/effective_thumbnails_test.dart`

### `groupCard(meta, playlist, group)`

| meta | playlist.groupItem.showThumbnail | group.groupItem.showThumbnail | returns |
|------|----------------------------------|-------------------------------|---------|
| null | null | null | true |
| false | null | null | false |
| true | null | null | true |
| false | true | null | true |
| false | null | true | true |
| true | null | false | false |
| null | true | false | false |

### `episodeRowInGroup(meta, playlist, group)`

Same matrix as above but read from `episodeItem.showThumbnail`.

### `podcastEpisodeList(meta)`

| meta.showEpisodeThumbnail | returns |
|---|---|
| null | true |
| true | true |
| false | false |

### Independence

`episodeRowInGroup` ignores any `groupItem.showThumbnail` value:
setting the group-card flag must not change episode-row resolution.

## Integration points

UI consumers (assigned to a follow-up implementation task):

- `audiflow_app` podcast detail main episode list widget →
  `EffectiveThumbnails.podcastEpisodeList(meta)`.
- `audiflow_app` smart playlist group list (group cards) →
  `EffectiveThumbnails.groupCard(meta:, playlist:, group:)`.
- `audiflow_app` smart playlist episode list (episode rows inside
  groups) → `EffectiveThumbnails.episodeRowInGroup(...)`.

`PatternMeta` is sourced from the existing `SmartPlaylistConfigRepository`
and surfaced via a Riverpod provider keyed by podcast id.

When the helper returns `false`, the widget skips artwork rendering
entirely (no placeholder, no extra whitespace).

## Non-goals

- No persisted user preference for thumbnail visibility (config-driven only).
- No animation when toggling visibility.
- No Isar cache invalidation (flag is read-time only).
- No editor-side validation (owned by `audiflow-smartplaylist-editor`).
- No fallback / placeholder customization.

## Open questions

None.
