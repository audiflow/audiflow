# Backup and Restore (#718)

Step M5 of [User data: device continuity and sync](../architecture/user-data-sync.md).

## Overview

Write the data a user must not lose to one file, and restore it on the same device, another device, or across iOS and Android. A broken or unsupported file never touches existing data.

## Prerequisites

- M1 to M4 of the architecture are done: stable keys (podcastKey, episodeKey), HLC, user state collections, outbox.
- M0 (#773) ships independently, earlier.

This plan builds:

- Export and import of the compacted snapshot. Manual backup, the continuity snapshot, and the initial sync download all use it.
- Manual backup and restore screens.
- Automatic snapshot and restore detection.

## Decisions

| ID | Topic | Decision |
|----|-------|----------|
| D2 | Parental control | Include only the per-podcast "hide explicit" flags. No PIN and no restricted mode; a guardian sets them again on the new device. Including the PIN hash would let anyone holding the file brute-force it offline |
| D3 | Synced vs device-scoped settings | Sync only listening-related settings: playback speed and recent speeds, skip intervals, auto-complete threshold, continuous playback, play order, interruption behavior, remaining-time display, silence skip, voice boost, new-episode notifications, search country, auto-download retention, library sort, last sleep timer value. Everything else is device-scoped: theme, language, text size, haptics, download and sync network conditions, concurrent downloads, last tab, privacy consent, developer display |
| D4 | File type | `audiflow-YYYYMMDD.audiflow-backup`, picked from inside the app. No file type registration in the first version, so `ios/` and `android/` config is unchanged |
| D5 | Automatic snapshot location | App-internal only. OS backup covers same-platform migration (C1); cross-platform migration uses the manual file or sync |

## File contents

| Target | Included | Notes |
|--------|----------|-------|
| `PodcastUserState` | Yes | Subscriptions, URL aliases, all per-podcast settings. Show title and artwork URL added for display |
| `EpisodeUserState` | Yes | Position, completion, favorite, per-device counters. Locator (guid, audioUrl, publishedAt), title, and duration added for display. No descriptions |
| `QueueEntry`, `StationState`, `StationMember` | Yes | Including tombstones, so restoring an old backup does not resurrect deleted items. For backups older than the 90-day tombstone retention from the same history, the merge applies the local tombstone horizon; backups from an independent history merge as a plain union (see the architecture merge rules) |
| `SyncedSetting` | Yes | Synced settings only (D3) |
| `OpaqueField` | Yes | Unknown future fields are exported as is |
| Catalog (episodes, feeds, transcripts, chapters) | No | Refetched from feeds after restore |
| Downloads, device-scoped settings | No | Per device |
| `deviceId`, install ID, sync key | Never | The file is not encrypted; including the sync key would let anyone with the file read synced data |
| Parental control | Flags only (D2) | Never the PIN hash |

## File format

Header, one JSON line:

```json
{ "format": "audiflow-backup",
  "formatVersion": 1,
  "createdAt": "2026-11-15T10:00:00Z",
  "historyId": "...",
  "app": { "version": "2.x.y", "platform": "ios" },
  "counts": { "podcasts": 52, "episodes": 3810, "queue": 14, "stations": 3 },
  "payloadSha256": "..." }
```

Body: `gzip(protobuf Snapshot)`:

```
repeated PodcastState  podcasts
repeated EpisodeState  episodes
repeated QueueEntry    queue
repeated StationState  stations
repeated StationMember station_members
repeated Setting       settings
repeated OpaqueField   opaque
(every field carries its HLC)
```

- The confirmation screen needs only the header; counts and creation time are shown before the body is decompressed.
- The body is the same protobuf as the automatic snapshot and initial sync download, so there is one codec, and fieldIds are never reused.
- A `formatVersion` that is too new shows "This file was made by a newer version of Audiflow. Please update the app." Older versions are read by applying migrations in order.
- Uses Dart `GZipCodec` and the existing `crypto` dependency; protobuf comes from M2.

## Flow

Export: `SnapshotExporter` reads user state -> `SnapshotCodec` writes header, gzip, sha256 -> share sheet (Files, AirDrop, mail).

Restore:

1. Pick the file (same mechanism as OPML).
2. **Phase A (no writes):** decompress and validate sha256, version, and types.
3. Confirmation screen: counts, creation time, source platform. In restricted mode, the parental PIN is required.
4. **Phase B:** merge in one `writeTxn`.
5. Post-processing: `syncFeedsByUrls` refetches the catalog, and `reconcileFull` runs for each station. Until the catalog is back, lists use the display fields included in the file.

Rules:

- Restore is always a merge with the sync rules: the newer value wins per field, so data on this device that is newer than the backup stays.
- To restore from a clean state, reset all data first; the screen says so.
- Phase B first stops playback and suspends writers, the same way `DataResetService.resetAll` does. User state and outbox are written in one `writeTxn`.
- On a device with sync enabled, fields changed by the merge land in the outbox and reach other devices.
- `DataResetService.resetAll` also deletes the automatic snapshot file while writers are suspended. Otherwise the next launch sees an empty database with a snapshot and restores the data the user just reset.

## Failures

| Situation | Detected in | Result and message |
|-----------|-------------|--------------------|
| Not gzip or JSON, or wrong `format` | A | "This is not an Audiflow backup file" |
| Truncated, sha256 mismatch, missing required fields | A | "The backup file is damaged". Logs record the field location, never values |
| `formatVersion` too new | A | Asks the user to update the app |
| Isar throws during merge (for example, out of space) | B | The transaction rolls back and nothing changes. "Restore failed. Your data was not changed" |
| App terminated during merge | B | Nothing changed unless the transaction committed. The merge is idempotent, so retrying is safe |
| Feed refetch fails in post-processing | Post | Restore still counts as succeeded; regular feed refresh fetches later |

## Modules

`audiflow_domain/.../features/snapshot/`:

- `SnapshotExporter`: builds a snapshot from user state.
- `SnapshotCodec`: header, gzip, sha256, per-version migration. Failures are a sealed `SnapshotReadFailure`.
- `SnapshotMerger`: applies the architecture merge rules, sharing the function used by the sync engine's receive path.
- `AutoSnapshotScheduler`: writes on moving to the background when something changed, at most every 15 minutes.
- `RestoreDetector`: compares `deviceId` at launch; finds an empty database with a snapshot and restores automatically.

`audiflow_app/.../features/settings/`:

- On the "Storage and data" screen, next to OPML: "Export backup", "Restore from backup", and "Last automatic backup: date".
- `BackupExportController`, `BackupRestoreController`, built like `OpmlExportController`.
- Confirmation screen: counts, creation time, source platform. In restricted mode, restore requires the parental PIN.
- Generalize `OpmlFilePicker` to take the file type as a parameter.
- Strings in `app_en.arb` and `app_ja.arb`.

## Tests (written first)

- Round trip: seed, export, clear, restore, compare by stable keys.
- Merge: two states with mixed old and new fields converge regardless of order (property test).
- Broken files: fixtures for truncated, sha256 mismatch, version 99, and missing fields each produce the right failure, and Isar is never written.
- Rollback: an exception mid-merge leaves the original data intact.
- Reset then relaunch: after `resetAll`, no snapshot remains and restore detection does nothing.
- Old backup, same history: restoring a backup older than the tombstone horizon does not bring back items deleted since.
- Other installation's backup: items unknown locally are kept even when added before the local horizon.
- A v1 fixture file lives in the repository and must keep reading in future versions.
- Unknown fields: `OpaqueField` survives export and restore.
- Widget tests for the confirmation screen and the PIN check.

## PRs

1. Snapshot format, codec, merge, tests (domain).
2. Export screen, controller, strings (app).
3. Restore screen, confirmation, post-processing (app). Add FR `docs/fr/20-backup-restore.md`; update FR 14 and `docs/fr/index.md`.
4. Automatic snapshot, restore detection, exclude the Isar database from iOS backup (C1).

Before the last PR, try a round trip on two simulators (export on A, restore on B through a file) and get design approval for the confirmation screen.
