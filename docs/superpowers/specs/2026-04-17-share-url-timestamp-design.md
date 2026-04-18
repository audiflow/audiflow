# Timestamped Episode Share URLs

## Problem

Users occasionally want to share "listen to this bit at 34:20" — a
specific moment in an episode, not the whole episode. The existing
universal link (`/p/:itunesId/e/:encodedGuid`) always opens at position 0
or the saved-resume position, with no way to convey a chosen time.

Pairs naturally with the future "bookmarks inside episodes" feature:
sharing a bookmark = sharing the episode URL + bookmark position.

## URL Shape

```
https://audiflow.reedom.com/p/<itunesId>/e/<encodedGuid>?t=<seconds>
```

- `t` = non-negative integer seconds.
- Reuses the existing `deepLinkEpisode` route; `t` is a query param.
- Omitted when the position is 0, unknown, or not requested.
- On receive: ignored when malformed; clamped to episode duration.

## Decisions

| Decision | Choice | Why |
|---------|--------|-----|
| Param name | `t` | De-facto convention (YouTube, Spotify). |
| Unit | Integer seconds | Matches bookmark mental model; no `1h2m3s`. |
| Location | Query string | Fragments (`#t=`) get stripped by some chats. |
| Target URL | Our `/p/.../e/...` only | Third-party URLs ignored — best-effort. |
| Precision | Whole seconds | Sub-second unnecessary for audio navigation. |

## Changes by Layer

### `audiflow_domain` — `ShareLinkBuilder`

`buildEpisodeLink` gains an optional `startAt`:

```dart
Future<String?> buildEpisodeLink({
  required String itunesId,
  required String episodeGuid,
  Duration? startAt,
});
```

Emits `?t=N` only when `startAt` is non-null and `0 < startAt.inSeconds`.

### `audiflow_domain` — `DeepLinkTarget.episode`

Adds a nullable `startAt: Duration?` field (freezed regeneration required).

### `audiflow_domain` — `DeepLinkResolverImpl`

Parses `uri.queryParameters['t']`. Valid iff all digits and
`0 <= parsed`. Otherwise ignored. Always forwarded as `Duration.seconds`.

### `audiflow_domain` — `AudioPlayerController.play`

New optional `startAt`:

```dart
Future<void> play(
  String url, {
  NowPlayingInfo? metadata,
  Duration? startAt,
});
```

Semantics:

- When `startAt != null`, the saved-position resume path is skipped.
- After `setUrl`, await `durationStream` one frame if needed, then seek
  to `startAt.clamp(0, duration)`.
- Fires `SeekLifecycle` as usual.

### `audiflow_app` — share helpers

`buildEpisodeShareUrl` and `shareEpisode` accept optional `startAt`
and forward it to `buildEpisodeLink`.

### `audiflow_app` — `EpisodeDetailScreen`

New optional `startAt` constructor param, routed from `extra['startAt']`.
State keeps a one-shot `_pendingStartAt` seeded from `widget.startAt`; on
the first user-initiated play, it's passed into `controller.play(startAt:)`
and then cleared. Subsequent pause/resume cycles use saved history.

### `audiflow_app` — `DeepLinkScreen`

Threads `target.startAt` into the episode-detail route extras.

## Edge Cases

| Case | Behavior |
|---|---|
| `t` larger than duration | Clamp to `duration` (just_audio handles). |
| `t` not an integer | Ignore; fall back to saved-position resume. |
| `t` negative | Ignore (validated by all-digits regex). |
| Multiple `t` params | First wins (Uri.queryParameters semantics). |
| Episode not downloaded | Stream; seek applies once duration is known. |
| Saved resume + `t` present | `t` wins — explicit user intent over history. |

## Test Plan

- `share_link_builder_impl_test` — emission cases (null / 0s / 1s / 3600s).
- `deep_link_resolver_impl_test` — `t=0`, `t=42`, `t=abc`, `t=-5`,
  missing, whitespace, and propagation into `EpisodeDeepLinkTarget`.
- `audio_player_service_test` — `play(startAt:)` overrides saved resume
  and seeks after source load. (Existing test harness permitting.)
- `share_helper_test` — `startAt` forwarded to the builder.

## Out of Scope (v1)

- Composite time formats (`1h2m3s`).
- Fragment form (`#t=`).
- Stamping `t=` onto third-party URLs.
- Sharing from bookmarks (bookmarks feature doesn't exist yet).
