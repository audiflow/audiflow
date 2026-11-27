---
refs:
  id: arch:user-data-sync
  kind: architecture
  title: "User data: device continuity and sync"
  related:
    - arch:state-flow
    - arch:system-overview
  modules:
    - packages/audiflow_domain/lib/src/features/
---
# User Data: Device Continuity and Sync

Status: accepted design, being implemented (M0 to M5 landed). Work is split into migration steps M0 to M7 (see [Migration steps](#migration-steps)). Tracking: #773 (M0, done), #777 (M1, done), #778 (M2, done), #779 (M3), #780 (M4), #718 (M5), #781 (M6), #782 (M7).

## Goals

1. **Device continuity (always on).** Moving to a new phone of the same platform carries the user's data over through the OS backup and transfer mechanisms. No server and no account are involved.
2. **Internet sync (opt-in).** Playback position and other user state reach the user's other devices within about a second, across iOS and Android.

The two features work independently but share one data model.

## Decisions

| ID | Topic | Decision |
|----|-------|----------|
| S1 | Relay server | Cloudflare Workers with one Durable Object per account, using WebSocket hibernation |
| S2 | Accounts | No account for now: a sync key shared by QR code, plus a printable recovery code. The schema allows adding Apple / Google sign-in later |
| S3 | Encryption | End-to-end. Op values and keys are encrypted on the device; the server cannot read them |
| S4 | Order | Data model migration (M1 to M4) first; #718 backup is built on the new model as M5 |
| C1 | iOS backup | The Isar database is not part of the OS backup on either platform. Only the snapshot file is carried over |
| C2 | iCloud Keychain | The sync key is stored with `kSecAttrSynchronizable`, so devices on the same Apple ID can join sync without a QR code |

## Three classes of data

| Class | Contents | Synced | Carried to a new device |
|-------|----------|--------|-------------------------|
| Catalog (derived) | Episodes, feed cache, smart playlist results, transcripts, chapters | No | No; rebuilt from RSS and presets. Keeps local auto-increment IDs |
| User state | Subscriptions and per-podcast settings, playback position, completion, favorites, queue, stations, synced settings | Yes | Yes, via the snapshot. Identified by stable keys, with a timestamp per field |
| Device-scoped | Downloads, `deviceId`, install ID, consent, network policy, haptics, last tab | No | Per item (see below) |

Today an `Episode` row mixes catalog data (title, audio URL) with user intent (`isFavorited`), and `PlaybackHistory` points at episodes by local auto-increment ID. Sync requires separating user intent and addressing it by keys that are the same on every device.

## Device continuity

### Where each item lives

On iOS, Keychain items whose accessibility does not include `ThisDeviceOnly` migrate with encrypted and iCloud backups; `ThisDeviceOnly` items never migrate. On Android, Google Play services Block Store carries small secrets through device-to-device setup and cloud restore (confirm size limits before implementation).

| Item | Carried over | iOS | Android |
|------|--------------|-----|---------|
| User state snapshot | Yes | Application Support (backed up) | Only this file is included via `data_extraction_rules.xml` (fits the 25 MB cloud cap) |
| Isar database | No | Stays in Documents, marked `isExcludedFromBackup` (C1) | Excluded (easily exceeds 25 MB) |
| Downloaded audio | No | `isExcludedFromBackup` | Excluded |
| Sync key | Yes | Keychain, `AfterFirstUnlock`, synchronizable (C2) | Block Store with cloud backup enabled |
| Sync device record (device private key, relay token, data key) | Must not | Keychain, `AfterFirstUnlockThisDeviceOnly` (`SecureSyncKeyStore`) | `flutter_secure_storage` (Android Keystore), `FlutterSecureStorage.xml` excluded by the backup rules |
| `deviceId` | Must not | Keychain, `ThisDeviceOnly` | `files/device_only_store/`, excluded by the backup rules |
| Install ID, analytics identifiers | Must not | Keychain, `ThisDeviceOnly` | `files/device_only_store/`, excluded by the backup rules |
| Synced settings | Yes | Isar user state, included in the snapshot | same |
| Device-scoped settings | Yes | SharedPreferences (backed up, as today) | SharedPreferences (included in backup rules) |

### Continuity snapshot (as built for M5)

The snapshot is `<Application Support>/continuity.audiflow-backup`, the same file format as a manual backup (`buildBackupFile`). Application Support is backed up on iOS and is the `file` domain on Android, which the backup rules keep.

- **C1 on iOS**: the Isar database stays where it was (`Documents/audiflow.isar` and its lock file `audiflow.isar-lck`; moving it would be a data migration of file locations) and is marked `isExcludedFromBackup`. Dart lists the files with `isarDatabaseFiles` right after `openAppDatabase` and sends them over the `audiflow/backup_exclusion` channel in `AppDelegate.swift` (`DatabaseBackupExclusion` in the app). The call runs after the open, not from Swift for fixed paths at launch, because Isar creates the files on first open and schema recovery re-creates them; both would otherwise stay in the backup until the next launch. The flag is set again on every launch. The channel only accepts paths inside the app container.
- **C1 on Android**: `data_extraction_rules.xml` (cloud backup and device transfer) and `full_backup_content.xml` exclude `app_flutter/audiflow.isar` and `app_flutter/audiflow.isar-lck` by name, since the rules take no wildcards.
- **Writing** (`AutoSnapshotScheduler`): see [When the snapshot is written](#when-the-snapshot-is-written).
- **Restoring** (`RestoreDetector`): see [Restore detection](#restore-detection).
- **Reset**: "Reset All Data" deletes the snapshot while writers are suspended, before the database is cleared, and the scheduler is one of the suspended writers so a write in flight cannot bring the file back.

### Restore detection

At launch, compare `SyncMeta.deviceId` in Isar with the `deviceId` in device-only storage.

- If the device-only `deviceId` is missing or differs, the data is a copy restored from another device. Generate a new `deviceId`, drop the sync cursor and refetch, and reset downloads whose file is missing to not downloaded.
- If Isar is empty and a snapshot exists (the state right after a device migration on either platform), merge the snapshot automatically without asking, and show "Your data was carried over from your previous device". The OS restored the user's own data, so no confirmation is needed.
- If the sync key came back from Keychain or Block Store, sync stays enabled; the device only re-registers with the relay as a new device.

As built in M5, only the empty-database half exists. `RestoreDetector.restoreIfEmpty` runs in `bootstrapAppContainer` after the data migrations and the audio handler start (the restore stops playback through it) and before anything else reads user data. The database counts as empty when it has no `PodcastUserState`, `EpisodeUserState`, `QueueEntry`, or `StationState` row and no subscribed (not cached) `Subscription` (`hasNoUserData`); the last covers a podcast subscribed from search whose feed was not parsed yet, which has no user state row. `SyncMeta` and `SyncedSetting` do not count: launch creates the first, and copies the second from preferences (which the OS restores) only after the restore, since a copied key gets a fresh clock and would otherwise beat the restored value. A snapshot whose header counts are all zero is skipped (the scheduler never writes one, so a restore of it would rerun on every launch). The restore goes through `BackupRestoreService`, feed refetch continues in the background, and `ContinuityRestoreNotice` (a one-shot in-memory flag) makes the app show "Your data was carried over from your previous device" once. `SyncMeta.continuityRestorePending` is set before the merge and cleared once the library is rebuilt: the two commit separately, so a launch that finds the mark restores again even though the data no longer looks empty. The library projection also sets `SyncMeta.queueProjectionPending`, so a queue step that fails or never runs is retried by the next feed sync. A file that fails to read is moved to `continuity-retained.audiflow-backup` (the first one moved there stays), out of the scheduler's way; each launch tries it again and merges it, into whatever data exists by then, once an updated app can read it. "Reset All Data" deletes both files. Launch continues on any failure. The `deviceId` comparison is not built yet: M0 only records the device-only id in `SyncMeta.deviceId` when it is missing, and the comparison belongs to M6, where it drops the sync cursor.

### When the snapshot is written

Quick Start and Android device transfer run when the user decides to switch, so a daily snapshot is often stale. Write the snapshot when the app goes to the background and something changed, at most once every 15 minutes. Write to a temporary file and rename it, so a crash never leaves a broken snapshot. Expected size is 1 to 2 MB after ten years of use. Cross-platform migration is not possible through OS mechanisms; it uses the manual backup file (#718) or sync.

As built (`AutoSnapshotScheduler`): `AppLifecycleObserver` calls `onBackground` when the app is hidden. "Changed" means `SyncMeta.hlc` differs from `SyncMeta.lastSnapshotHlc`, the clock read just before the last successful export (a change landing during an export is in the file but not in the recorded clock, so the next backgrounding writes again). A missing file also counts as changed, and launch calls `onLaunch`, which writes only when the file is missing: the database is out of OS backups from the first launch of this version, so an upgraded install must not wait for its first backgrounding to have a snapshot. A database with no user data writes nothing. The 15-minute rule uses the time of the last successful write, kept in memory; a failed write is retried on the next backgrounding. The file is written as `continuity.audiflow-backup.tmp` in the same directory, flushed, and renamed over the target. Failures are logged and never thrown.

## Stable keys

**podcastKey**

- Use `podcast:guid` (Podcasting 2.0) when the feed declares it (`isolate_rss_parser.dart` reads it into `ParsedPodcastMeta.podcastGuid`).
- Otherwise, hash the feed URL normalized by `normalizeFeedUrlForKey` (scheme, host case, default port, fragment, and trailing slash ignored; credentials kept, since private feeds tell subscribers apart by them).
- The key is assigned by the first feed parse (`SubscriptionMetadataUpdater` calls `assignStableKeys`), since a subscription is usually created from search before its feed is read, and is never recomputed. If the feed moves later, the key stays and the new URL is kept as an alias. A subscription without a key skips conditional requests until a parse assigns one.
- When the same show is registered under two keys (one device saw the guid first, another the URL), each device joins the other's rows to its own key and records an alias (as built in M6f, below). The `merge-into` op first planned for this is not needed: no device has to give up its key.

**episodeKey**

- Hash of `podcastKey` plus the episode's storage guid: the item guid, or the enclosure URL for an item without one, as `isolate_rss_parser.dart` already does. An item that reuses another item's guid is stored under a duplicate-guid key (guid plus enclosure URL), so it gets a distinct key; which of those items holds the plain guid can still differ between devices, which the locator below resolves.
- Assigned when the episode is stored and its podcast has a key; `assignStableKeys` keys a podcast's existing episodes in the same transaction as the podcast. Never recomputed, even when the storage guid is rewritten.
- The current `Episode.guid` is a storage key influenced by each device's fetch history (`_FeedItemBatch.claim` in `episode_local_datasource.dart`). Two devices that fetched at different times can store the same episode under different keys, so it cannot be the sync key.
- Keys are `podcastKeyFor` / `episodeKeyFor` in `audiflow_domain` (`features/user_state/models/stable_keys.dart`): the first 128 bits of SHA-256 over a typed, versioned input, base64url without padding.
- Ops also carry a locator `{guid, audioUrl, publishedAt}`. When the key is unknown, the receiver searches the same way `_bestMatch` does and records the found key as an alias.

As built for M6f (`features/user_state/services/key_reconciler.dart`): `EpisodeUserState` carries the locator as three set-once fields (11 to 13: storage guid, enclosure URL, publish date), taken from the catalog episode when the row is made, sent with every change of the row, and filled in by a merge into a row that lacks it; migration step 6 fills it for existing rows from their episodes. `KeyReconciler` keeps each device's own keys. A podcast row whose key no subscription here has is joined to the keyed subscription with the same normalized feed URL, or else the same directory id; an episode row whose key no catalog episode has is joined to the episode of its podcast its locator finds (same enclosure URL; else, among items with the same guid, the same publish date; else, undated, the same storage guid first). Joining merges the foreign row into the local one under the sync rules (newer clock per field, counters by maximum per device, play orders per entry), deletes it, moves its station members, its episodes' podcastKey, its queue entries, and fields a newer app stored for it to the local key, and records a `SyncKeyAlias` (device-local, never synced, cleared by a data reset). Received sections are translated through the aliases before the merge and before `dropBeatenOps`, so later rows land on the local key directly. The same step checks each received episode row's locator against the local episode under its key: two devices can give the plain-guid key to different items of a feed that reuses a guid, so a row whose locator does not fit is moved to the episode its locator finds, or to a key of its own that stays hidden until the episode turns up, before it can overwrite another episode's state (its counters follow). A queue entry from such a device still names the key, which means another episode here; that rare case is not resolved; keys inside field values (an episode's podcastKey, a queue entry's episodeKey) are rewritten after the merge. Moving a queue entry marks `queueProjectionPending`, so a projection that fails after the join is retried. A local write to a row that lacks its locator fills it in. Nothing is queued to send: the other devices hold the foreign rows and join them on their own. The engine joins after the welcome snapshot (every podcast), after each frame (the podcasts and episodes it carried), and after the feed fetch a merge started, since state can arrive before its episodes; a manual or continuity restore joins after its merge and again after its feed fetch. The search runs under a read lock first and takes the write lock only when something is to be joined. Rows that find nothing stay under their foreign key, hidden as before, and are tried again on the next pass for their podcast.

## Local storage (Isar)

Every user-state field carries its own HLC timestamp.

| Collection | Key | Replaces | Contents |
|------------|-----|----------|----------|
| `PodcastUserState` | podcastKey | User fields of `Subscription`, `PodcastViewPreference`, `PodcastAudioPreference`, smart playlist group settings, `PodcastParentalFlags` | Subscribed, URL aliases, auto-download, view settings, play order, speed and effects, hide explicit |
| `EpisodeUserState` | episodeKey | `PlaybackHistory`, `Episode.isFavorited` | `positionMs`, `completedAt`, replaying, `favoritedAt`, `lastPlayedAt`, per-device counters |
| `QueueEntry` | entryId (ULID) | `QueueItem` | episodeKey, `rank` (fractional index), `isAdhoc`, `sourceContext`, deleted |
| `StationState`, `StationMember` | stationId (ULID) | `Station`, `StationPodcast` | All filter and sort fields, rank, `episodeLimit`, deleted |
| `SyncedSetting` | setting key | Synced `SettingsKeys` entries (moved from SharedPreferences) | Value. Kept in Isar so a setting change and its op share one transaction |
| `OutboxOp` | opId (ULID) | new | Unsent ops. Pending ops for the same field are coalesced into the latest. Deleted on ack |
| `OpaqueField` | (entity, key, fieldId) | new | Fields from future app versions, stored uninterpreted |
| `SyncKeyAlias` | (kind, foreignKey) | new | Another device's key for a podcast or episode this device keys otherwise. Local only, never synced (M6f) |
| `SyncMeta` | single row | new | Copy of `deviceId`, `historyId`, HLC state, server cursor, tombstone horizon, migration version |

M3 lands in PRs, one source at a time (plan in #779): `EpisodeUserState` (M3a), the per-podcast preferences in `PodcastUserState` (M3b), the subscription fields of `PodcastUserState` (M3c), `QueueEntry` (M3d), `StationState` and `StationMember` (M3e), then `SyncedSetting` (M3f). Each switches at the datasource layer:

- The datasource writes the old row and the new keyed row in one `UserStateStore.write`, and reads the new row, mapped back to the model its callers already use (for example `PlaybackHistory` by local episode id). Repositories and everything above them are unchanged.
- An episode or podcast without a stable key yet keeps using the old row. `assignStableKeys` copies its state into the new collection in the transaction that keys it, so keyed entities always have their state in the new collection. A `DataMigrationStep` per source copies existing data at launch.
- New rows whose episode is missing from the catalog are kept and hidden from reads. Fetching the feed for them waits for M6, where such state can first arrive from another device.
- Debug builds compare the old and new rows on each single-row read and log differences under `UserStateCompare`.
- Per-device counters are attributed to `SyncMeta.deviceId`, a copy of the id in device-only storage that the foreground launch records (`openAppDatabase(deviceId:)`).

As built for M3a: `EpisodeUserState` (`features/user_state/models/episode_user_state.dart`) replaces `PlaybackHistory` and `Episode.isFavorited`/`favoritedAt`, behind `PlaybackHistoryLocalDatasource`, the favorite repository, the station reconciler's completed and favorite filters, and cache eviction (which treats any `EpisodeUserState` of the podcast as listener data). `EpisodeUserStateAccess` holds the mapping; `EpisodeUserStateBackfill` is migration step 1.

As built for M3b: `PodcastUserState` (`features/user_state/models/podcast_user_state.dart`) replaces `PodcastViewPreference` (including the podcast play order), `PodcastAudioPreference`, `SmartPlaylistUserPreference`, `SmartPlaylistGroupUserPreference`, and `PodcastParentalFlags`, behind their datasources. Each old row maps to a section with a `has*` flag and timestamp, so a deleted row is a stamped removal rather than a missing row; playlist and group play orders are entries whose cleared order stays as a null. `PodcastUserStateAccess` holds the mapping; `PodcastUserStateBackfill` is migration step 2. `ParentalControlSettings` (PIN, lockout) stays device-scoped.

As built for M3c: `PodcastUserState` also holds the user fields of `Subscription`: subscribed (with `subscribedAt`), the feed URL and iTunes id another device needs to fetch the feed, auto-download, and the keep count. `SubscriptionLocalDatasource` records them on every write of the row, stamping only fields that changed, so device-scoped writes (last access, HTTP validators, auto-download activity) leave the state alone. Unlike the other sources, the `Subscription` row keeps these fields: the app queries and sorts on them, so the row stays the local copy and M6 writes merged remote state back into it. Unsubscribing and deleting the row are stamped `subscribed = false`. Migration step 3 reruns the section-wise copy for this section.

As built for M3d: `QueueEntry` (`features/user_state/models/queue_entry.dart`) records each queue item under a UUIDv7 `entryId` (time-ordered like a ULID, from the existing `uuid` dependency), with its `episodeKey`, `rank`, adhoc flag, and source context, each stamped, and a stamped `deleted` flag for removals. `QueueItem` gains `entryId` and, like `Subscription`, stays as the local copy the queue reads: callers address items by local id and join on local episode ids. `QueueLocalDatasource` records every write on the entries in the same transaction (`QueueEntryAccess`). `rank` encodes the item's integer position so that string order is numeric order; entries order by `rank`, then `entryId`, which is what M6 merges on. An item whose episode has no key gets its entry when the episode is keyed. Migration step 4 gives existing items their entries.

As built for M3e: `StationState` and `StationMember` (`features/user_state/models/station_state.dart`) record each station under a UUIDv7 `stationId`, which `Station` also stores, and each of its podcasts under (`stationId`, podcastKey). Every station field is stamped (the duration filter as one value), and both carry a stamped `deleted` flag. `Station` and `StationPodcast` stay as the local copies the app reads. The station datasources and the reconciler's link removals record every write in the same transaction (`StationStateAccess`). A station gets its id on its first write; a link to a podcast without a key gets its member when the podcast is keyed. `updatedAt` stays local, and `StationEpisode` stays derived. Migration step 5 records existing stations and links.

As built for M3f: `SyncedSetting` (`features/user_state/models/synced_setting.dart`) holds one row per synced settings key, with the value JSON-encoded, one stamp, and a `present` flag so a removal (back to the default) can win a merge. `SyncedSettingsStore` sits under `AppSettingsRepositoryImpl` and routes by key: the keys in `SyncedSettingsStore.syncedKeys` read from Isar (synchronously, so the repository's getters stay synchronous), falling back to SharedPreferences while a key has no row, and write both for one release. The synced keys are the listening-related ones (decision D3 of the backup and restore plan): playback speed and recent speeds, skip intervals, the completion threshold, continuous playback, the global play order, interruption behavior, the remaining-time label, skip silence, voice boost, auto-delete after playback, the auto-download keep count, new-episode notifications, the search country, and the last sleep timer values (`SleepTimerPreferencesDatasource` stores through the same store). Appearance, haptics, network and download limits, the feed sync schedule, the last tab, and privacy consent stay device-scoped in SharedPreferences. The library sort is not persisted, so there is nothing to sync. The copy of existing values runs at the foreground launch (`copyFromPreferences`), since migration steps have no access to SharedPreferences.

No op log is kept forever anywhere: a device holds the current state and the unsent ops. `StationEpisode` stays derived. `DownloadTask` stays device-scoped, switching to episodeKey and a path relative to the downloads directory.

## Merge rules

Ordering uses a Hybrid Logical Clock: 48-bit wall-clock milliseconds, a 16-bit logical counter, and `deviceId` as the tie-breaker. Causally related changes stay ordered even with skewed clocks. A remote HLC more than 24 hours in the future is clamped, so a device with a broken clock cannot win forever. All rules are pure functions in `audiflow_domain`, verified with property tests.

The clock is `Hlc` in `audiflow_domain` (`features/user_state/models/hlc.dart`). `send` stamps a local event and never moves backwards, even when the wall clock is set back; `receive` merges a remote stamp after clamping it to 24 hours past local time; `compareVersions` breaks ties by `deviceId`. The writer's `deviceId` is not part of the stored value: local writes are all this device's, so it is attached where data leaves the device. `SyncMeta.hlc` stores the latest stamp packed into 64 bits (millis high, counter low).

| Target | Rule | Why |
|--------|------|-----|
| Position, `completedAt`, favorite, settings | Per-field last-writer-wins | The last listening wins. Max-position would skip what the user rewound to hear again |
| Play count, completion count, total listened time | Per-device grow-only counters, summed for display | LWW would lose listening done on one of two devices |
| Subscriptions, station members, queue membership | LWW element set with add and remove timestamps; removals kept as tombstones | An old device must not resurrect an unsubscribed podcast |
| Queue order | Fractional-index `rank`, LWW per element | Moving one item rewrites only that item; concurrent moves converge |
| Tombstones | Kept 90 days, then purged. Each device records the purge horizon (`SyncMeta.tombstoneHorizon`, an HLC). The horizon applies only to data from the same history (see below): there, an incoming set element that is unknown locally and was added before the horizon is treated as deleted. Data from an independent history merges as a plain union | A device offline longer than that refetches from a snapshot instead of diffs. Within one history, absence before the horizon means deleted, so an old backup or a long-offline device cannot resurrect items whose tombstones are gone. Across independent histories absence means nothing, so valid items are kept |

### Histories

A `historyId` (random) names one lineage of user data. It is created when a device starts with empty data, and is inherited by every copy of that data: OS restore and continuity snapshot, a manual restore into an empty database, and joining a sync account (which adopts the account's `historyId`; the first device's becomes the account's). Snapshots and sync frames carry it. When a device with data merges data of another `historyId` (for example, a backup from a separate installation), the merge is a plain union and the local `historyId` stays.

### Snapshot format (as built for M5)

One format serves the manual backup, the continuity snapshot, and the first sync upload. The code is in `audiflow_domain/.../features/snapshot/`.

- **File** (`snapshot_file.dart`): a one-line JSON header (format, `formatVersion`, creation time, `historyId`, app version and platform, row counts, the sha256 of the payload, and the source's tombstone horizon when it is not 0), then the gzip-compressed body. The body is decompressed in chunks and rejected past 256 MB. The header can be read without the body, so a confirmation screen can show counts first. Reading throws a sealed `SnapshotReadFailure`: `NotASnapshot`, `DamagedSnapshot` (with a location, never a value), or `SnapshotTooNew`. Reading never writes.
- **Body** (`snapshot_body.dart`): sections by entity name, each a list of rows (key, entity message). The entity message is the same field encoding ops use, and each Value message also carries the field's packed HLC (Value field 15). A section of an entity this version does not know is kept and stored as opaque fields.
- **Contents** (`SnapshotExporter`): every user state row, tombstones included, and per-device counters, all read in one read transaction. Opaque fields go out with their clocks. A `podcastInfo` section (title, artist, artwork URL; no clock, never an op) lets a restore show podcasts before their feeds are fetched again. No catalog, downloads, device-scoped settings, `deviceId`, or parental PIN.
- **Merge** (`SnapshotMerger`): one write transaction through `UserStateStore`. A field with a clock takes the incoming value when its clock is newer. On equal clocks the larger encoded value wins, so both orders converge. Incoming clocks are clamped to 24 hours ahead. Grow-only counters take the maximum. A field without a clock is set only when the row is new. Within one history, a set element (podcast, queue entry, station, member) that is unknown locally and last changed before `SyncMeta.tombstoneHorizon` is skipped. An empty database adopts the snapshot's `historyId`. Within one history, the local horizon is raised to the snapshot's after the merge (not before, since the snapshot's own rows are live in its source). Unknown fields are stored without their embedded clock bytes, so the same field compares equal whichever copy it came from, and they produce ops too. A merged op never replaces a pending op with a newer clock. Changed fields go to the outbox with their incoming clocks (`UserStateTxn.touchMerged`), and the local clock moves past the newest merged one. A value of the wrong type, or a new row missing a required field, throws `DamagedSnapshot` and rolls everything back. The M6 receive path is meant to reuse these rules.
- `test/fixtures/snapshot/v1.audiflow-backup` was written by format version 1 and must keep restoring in every later version.

The merge writes keyed state only. Turning it back into the rows the app reads (`Subscription`, `QueueItem`, `Station`, `StationPodcast`) is the projection step (`RestoreProjector`). It writes those rows directly, not through the datasources, which would stamp the keyed state again with new clocks, and it writes a row only when it changes, so a second run does nothing.

- **Library** (`projectLibrary`, one write transaction): a subscribed podcast with a feed URL finds its `Subscription` by `podcastKey`, then feed URL, then iTunes id, and is marked subscribed and given the state's key verbatim if it had none; a missing one is inserted from `podcastInfo` (feed URL as title until the fetch). An unsubscribe (subscription clock set) marks subscribed rows cached; rows are never deleted. A deleted station loses its `Station`, links, and station episodes; a live one is upserted by `stationId`. Each live member is linked to its podcast's subscription; links to keyed podcasts that are no longer members are removed, links to unkeyed ones stay. It returns the feed URLs to fetch and the station ids to reconcile.
- **Queue** (`projectQueue`, its own write transaction, after the feeds are fetched): live entries in `rank`, then `entryId`, order become `QueueItem`s by `entryId`; items of deleted entries are removed. Positions are renumbered with the projected items first and other items after in their old order. An entry whose episode has no `episodeKey` here yet waits for a later run.

The restore screen (M5) and the receive path (M6) call it after the merge.

## Efficiency over ten years

Storage scales with the size of the current state, not with the length of use, and traffic scales with the fields that changed.

- One op is about 30 bytes: type 1 B, episodeKey 16 B (truncated HMAC), fieldId 1 B, value 2 to 4 B (varint), HLC 8 B.
- Encryption is per frame (a batch of ops), not per op. XChaCha20-Poly1305 nonce and tag cost 40 B per frame.
- Two hours of listening a day, with a position op every 30 seconds and on each pause or seek, is about 250 ops, 8 KB a day, about 3 MB a year.
- The WebSocket is open only while the app is in the foreground or playing.
- User state rows exist only for episodes the user touched (played, favorited, queued): about 20,000 in ten years at roughly 60 B each, 1 to 2 MB. A hundred subscriptions are negligible.
- The server keeps the latest value per field plus 90 days of ops and compacts older ops, so its storage is capped by state size.
- A new device downloads one compacted snapshot (under 1 MB compressed) and then receives only diffs.
- If ever needed, completed episodes untouched for years can be folded into a compact completed-only representation (not needed now).

## Evolution

| Change | How it is handled |
|--------|-------------------|
| Adding or retiring fields | Ops and snapshots are protobuf; a fieldId is never reused. Older app versions store unknown fields in `OpaqueField` and include them in backups, applying them after an upgrade. LWW is per field, so an older app never overwrites a newer field |
| Changing a merge rule | Rules are fixed per entity type and fieldId. A new rule gets a new fieldId; data moves over in an M-style migration |
| Protocol | `hello` exchanges `protocolVersion`; the server returns the minimum it supports. The server does not interpret content, so it rarely changes |
| Ciphers and keys | Frames carry `algId` and `keyVersion`. Revoking a device creates a new data key, rewraps it for the remaining devices, and re-encrypts and uploads the snapshot |
| HLC overflow | 48-bit milliseconds and a 16-bit counter last past the year 10000 |
| Moving the relay | The server only orders, stores, and fans out; meaning lives on devices. Migrating is uploading a compacted snapshot from any one device to the new server |

## Accounts: none now, Apple / Google later

Authentication (which account) is separate from decryption (reading data). An account can have any number of authentication methods, and the data key can have any number of wraps. Today only the sync key is used; adding sign-in later means adding an `auth_method` row.

```sql
-- Per Durable Object SQLite, plus a small sign-in lookup table
account(
  accountId  BLOB PRIMARY KEY,  -- random, fixed for the account's lifetime
  createdAt  INTEGER)
auth_method(
  accountId, kind,      -- 'sync_key' | 'apple' | 'google'
  subject,              -- key verifier / sub claim
  addedAt, revokedAt)
device(
  deviceId PRIMARY KEY, name, platform,
  addedAt, revokedAt, lastAckSeq)
key_wrap(
  keyVersion, wrapKind, -- 'device' | 'recovery_code' | later 'passkey_prf' etc.
  target, blob)         -- wrapped data key
op(seq PRIMARY KEY, entityHash, fieldId,
   hlc, deviceId, frame BLOB)  -- ciphertext
```

- **Account address:** `accountId` is random, created with the account, and never changes. The QR code and the recovery code carry it together with the sync key, so the Worker routes to the Durable Object without a lookup table, and rotating the sync key does not move the account.
- **Sync key:** 256 random bits, passed to other devices by QR code and shown as a printable recovery code. HKDF derives an authentication secret and the key-wrapping key from it.
- **Data key:** random, created once per account. Ops are encrypted with it; copies wrapped by each device key or the recovery code live in `key_wrap`.
- **Future Apple / Google sign-in:** add an `auth_method` row and a `sub` to accountId lookup (D1 or KV) in the Worker. Sign-in then identifies the account, but does not decrypt: the data key still comes from Keychain, Block Store, or the recovery code. If sign-in alone should decrypt, pick a wrap such as passkey PRF at that time; the schema does not change.
- **Stolen device:** the sync key is shared by all devices, so revoking a device must replace every secret derived from it, not only the data key. Revocation, run from a remaining device:
  1. Sets `device.revokedAt`, which also invalidates that device's per-device credential.
  2. Generates a new sync key and a new data key, and registers the new key's verifier in `auth_method` while revoking the old one, so the old authentication secret no longer opens the account.
  3. Wraps the new data key for each remaining device and for a new recovery code, and deletes the old recovery-code wrap. Remaining devices fetch their new wrap with their own device credential and store the new sync key; the user is shown the new recovery code.
  4. Re-encrypts and uploads the compacted snapshot under the new data key.

  Enrolling a device needs the current sync key, so a revoked device cannot re-enroll under a new `deviceId`.

As built for M6a (`audiflow_domain/.../features/sync/crypto/`): `SyncCredentials` holds the 16-byte `accountId` and the 32-byte sync key; `PairingCodec` encodes them as the QR payload `audiflow-sync:1:<base64url>` and as an 80-character Crockford base32 recovery code with a 16-bit checksum (case, separators, and O/I/L look-alikes are forgiven). `SyncKeyDerivation` derives `authSecret` and `wrapKey` with HKDF-SHA256 (empty salt, pinned by a test against an independent computation), and `authVerifier` is SHA-256 of `authSecret`: by the protocol contract, what the relay stores for enrollment (the relay itself lands in M6c). `SyncCipher` seals with XChaCha20-Poly1305 as algId, key version, nonce, ciphertext, and tag, binding format, purpose (frame, snapshot, presence, sync wrap, device wrap), account, algorithm, and key version into the associated data. `KeyWraps` seals the data key under `wrapKey`, and the sync key plus data key to a device's X25519 public key (`DeviceKeyPair`): an ephemeral key pair, HKDF-SHA256 over the shared secret and both public keys, then the same AEAD, with the ephemeral public key leading the blob.

## Write path and sync engine

```
Repositories (API unchanged)
  -> UserStateStore.write   one writeTxn: row + field HLCs + OutboxOp
  -> Riverpod watchers      UI, player, car
SyncEngine
  send:    from the outbox
  receive: ops after the server cursor
  merge:   rules above
SyncTransport: Noop (sync off) | WebSocket relay | snapshot
Relay (per account): assigns seq, stores, compacts, fans out, presence in memory
```

- `UserStateStore.write` (`features/user_state/services/user_state_store.dart`) runs its body in one `writeTxn` that also advances the clock in `SyncMeta`, and hands the body the `Hlc` stamp. The store holds no state of its own: the clock is read inside the transaction, which Isar serializes across isolates, so any number of instances (each datasource creates one) issue strictly increasing stamps.
- Since M2, every write to a user state collection goes through it: subscriptions (including cache eviction), playback history, favorites, queue, stations and their podcast links, view, play order, and audio preferences, and parental control. Catalog writes (episodes, smart playlists, transcripts, chapters, `StationEpisode`) and downloads use `writeTxn` directly. Synced settings moved into the store with M3f.
- State and op are written in the same transaction, so one never exists without the other. As built for M4: the body reports each row it writes with `UserStateTxn.touch`, and before the transaction commits the store writes an `OutboxOp` for every field of those rows stamped by this write (fields without a clock, such as an episode's `podcastKey` or the grow-only counters, go along with any change of their row). An op is keyed by (entity, key, fieldId), so a newer change of a field replaces its pending op: the outbox holds the latest value of each changed field, not a history.
- The field registry (`features/user_state/sync/user_state_fields.dart`) names each synced entity and gives every field a fieldId that is never reused; a test pins all of them. Ops are protobuf: each entity is a message whose field numbers are the fieldIds, every value is wrapped so a null still names its field, and an op is that message holding one field. The wire format is hand-written (`proto_wire.dart`) rather than generated, since the messages come from the registry; a reader keeps fields it does not know, and `keepUnknownFields` stores them in `OpaqueField` for a later version.
- While sync is off the outbox is bounded: coalescing leaves at most one op per changed field, and past `UserStateStore.outboxCap` (5000) the oldest ops are dropped. Turning sync on (M6) first uploads a full snapshot, so a dropped op loses nothing. For the same reason migration copies of existing data write no ops (`UserStateStore.write(recordOps: false)`).
- Applying a received op is an ordinary Isar write. Existing Riverpod watchers update the UI, so sync needs no UI code of its own.
- The continuity snapshot, the manual backup (#718), and the initial sync download are the same compacted snapshot. Restore is always a merge; "replace" means reset all data, then merge.

As built for M6b (`audiflow_domain/.../features/sync/engine/`, `protocol/`): `SyncEngine` runs every step on one serial queue over a `SyncTransport`. It opens with `create`, `enroll`, or `hello` (`SyncOpening`), merges the `welcome` snapshot (always after `enroll`, where the device first adopts its `historyId`) and the catch-up `frames`, moving `SyncMeta.serverCursor`, then sends. A `SyncFrame` is the snapshot body layout of outbox ops, each field with its clock (`fieldWithHlc`, shared with the exporter), plus `historyId` and `deviceId`, sealed with the data key. Received rows merge through `SnapshotMerger.mergeSections(recordOps: false)`, so nothing received is queued to be sent back, and `dropBeatenOps` removes pending ops the incoming values beat under the merge rules (clamped clocks; grow-only counters are never dropped). The library is projected again, with the merged podcast titles, when podcasts, stations, or members arrived, the queue when entries did, and stations are reconciled when episode favorites or completions arrived; new feeds are fetched. One push is in flight at a time and never splits a row, so a receiver always gets a new row's required fields together; rows go parents first (an episode before its counters, a podcast with its details), and frames are halved until they fit the relay's size limit. The ops it carried are deleted on `pushed` only when their clocks are unchanged. After `create` or `enroll`, and after the outbox cap dropped ops, the whole state goes out as frames, in pushes within the relay's limits, then a compacted snapshot. `SyncMeta.fullStateRequested` and `fullStateSent` keep the request durable: it counts as done only once the relay acknowledged every push, so an interrupted send is repeated on the next connection. `stored` acknowledges the snapshot; it deletes no ops, so a change made during the upload still goes out as a frame. Joining adopts the account's `historyId` and resets the old history's tombstone horizon, which the merge then raises to the account's once the snapshot's live rows are in; and is refused with `accountNotReady` while the account has no snapshot yet. The session (and its token) is handed to the caller only after the welcome is merged, so a join cut short is joined again. A frame that cannot be opened or merged ends the session with `unreadableFrame` and leaves the cursor before it, so a snapshot this device uploads never claims to cover it. A refused request, a dropped or failed connection, or a failed local step ends the engine with a `SyncRelayFailure` on `done`; the next connection resumes from the cursor. `SyncMeta` fields added after it shipped are stored nullable and read as 0, since Isar reads a missing int as its null sentinel. Two-device simulation tests run against an in-memory relay (`test/helpers/in_memory_relay.dart`) that goes through the JSON encoding both ways.

As built for M6c (`relay/`, TypeScript): the Worker routes `GET /v1/connect?account=<accountId>` to `idFromName(accountId)`. `AccountRelay` keeps SQLite tables `account` (verifier, sync key wrap, head `seq`), `device` (public key, SHA-256 of the token, revocation), `frame`, and `snapshot`, and holds sockets with the hibernation API. `enroll` compares SHA-256 of `authSecret` with the verifier in constant time and issues a random token. `push` stores frames under consecutive `seq` in one transaction and sends them to the other sessions before acknowledging, so every socket sees frames in `seq` order. A snapshot covering at most the head replaces an older one and deletes the frames it covers. Only failed attempts count against a limit, per source address: 30 failed resumes or creates a minute and 10 failed enrollments an hour, counted in memory (a woken object starts again), so a stranger who knows an account id cannot lock its devices out. Catch-up is read from storage in pages and sent in messages of at most 4 MB; all but the last carry `more: true`, and the engine counts itself caught up only after the last. Keys, secrets, and tokens must be exactly 32 bytes. Messages are capped at 8 MB, frames at 1 MB, pushes at 100 frames. Not yet built: device revocation and the `deviceWrap` in `welcome` (M6g).

As built for M6d part 1 (`features/sync/storage/`, `transport/`, `service/`):
- `SecureSyncKeyStore` keeps each account's credentials (the QR payload with the time stored) in a synchronizable Keychain item, so iCloud Keychain carries them to the user's other devices. It keeps the `StoredSyncDevice` record (account id, device id, private key, token, data key, and the opening pending until a token arrives) and an opt-out mark in `ThisDeviceOnly` items. On Android everything sits in `flutter_secure_storage`, which Auto Backup excludes; the credentials are also mirrored to Block Store (M6d part 3, below).
- `WebSocketTransport` connects to `<relay>/v1/connect?account=`. `https` becomes `wss`; cleartext is allowed only to a local relay (`localhost`, `127.0.0.1`, `::1`, `10.0.2.2`). The upgrade times out after 20 s. Any undecodable message is a stream error, which ends the session.
- `SyncController` owns this device's enrollment and one engine:
  - `turnOn` creates an account and `join` enrolls with scanned or typed credentials. Both write the enrollment record before anything is sent, so a new account is still created after a restart, and both reset the server cursor.
  - `turnOff` drops only this device's record and sets the opt-out mark. The shared credentials stay, since deleting a synchronizable item would turn sync off on every device. The relay keeps listing the device until revocation lands (M6g). "Reset All Data" turns sync off first.
  - It connects while `setActive(true)`; `AppLifecycleObserver` keeps that true while the app is in the foreground or playing (P10). Coming active again while a connection is closing reconnects.
  - Transient failures (`closed`, `internal`, `accountNotReady`, `rateLimited`, and any socket error) are retried after 2 s, doubling up to 5 minutes. Refusals stop in `SyncPhase.failed` until `onForeground`.
  - A device with no record of its own, or one from another install, joins the account its record names, else the credentials stored last, unless it opted out.
  - The relay URL is the build-time define `SYNC_RELAY_URL`; without it the phase is `unavailable`, and Settings hides sync.
As built for M6d part 2 (`audiflow_app/lib/features/sync/`): Settings > Sync Across Devices (`/settings/device-sync`). While off it offers Turn On Sync (a new account from this device's library) and Join from Another Device (`/join`: scan the QR code with `mobile_scanner`, or type the recovery code). While on it shows the status, with the reason when the relay refused the device, Add a Device (`/add`: the QR code via `qr_flutter`, and the recovery code behind a tap), the device list from the last `welcome`, and Turn Off Sync on This Device. Each change asks for confirmation first.
As built for M6d part 3: on Android, `SecureSyncKeyStore` mirrors each account's credentials entry (same key and JSON as the local item) to Block Store through `BlockStoreSyncKeyBackup` and the app's `audiflow/block_store` channel (`BlockStoreChannel.kt`, `play-services-auth-blockstore`), asking for cloud backup. Reads take the local item first and fall back to Block Store, keeping a restored entry locally (unchanged); the latest-credentials lookup considers both; and the first read of each launch copies to Block Store any local entry it lacks (from before the upgrade, or a failed write), so a reinstall or a new phone set up from the old one joins on its own. Block Store is best effort: without Play services, backup, or a screen lock the write or read fails, the failure is logged, and sync goes on with local storage. Credentials are never deleted from it, as on iOS.
- Known gap: a `create` cut short after the relay accepted it but before the token was stored leaves an account without a snapshot. Retrying `create` then returns `exists`, and the device stops in `failed` until sync is turned off and on again.

## Realtime playback position

Sending:

- Local saves stay as they are (`PlaybackHistoryService.saveIntervalMs = 5000`).
- Send immediately on pause, seek, stop, episode change, completion, and moving to the background; every 30 seconds while playing.
- Unsent position ops are coalesced to the latest per episode.
- While playing, iOS background audio or the Android foreground service keeps the app alive, so the WebSocket stays open.

Receiving:

- If the episode is playing here, store but do not apply to the player. This device's next op is newer and wins.
- If paused and the incoming op is newer, update the position silently, including the seek bar.
- If nothing is playing, the next play starts from the merged position.
- Presence (not stored) shows "Playing on iPhone, 12:34" in the mini player. Remote control of other devices is a future candidate.

As built for M6e part 1 (domain and relay): `SyncEngine` holds back a push when every pending op is one that playing rewrites (an episode's `hasPlayback`, `positionMs`, `durationMs`, `lastPlayedAt`, a counter's `listenedMs` and `realtimeMs`, and the clockless identity fields every write carries) and the last push went out less than `steadyInterval` (30 s) ago; a timer flushes them when the interval has passed. Any other op sends everything at once. The outbox already keeps the latest op per field, so a held position is coalesced. `sendSoon()` opens a 2-second window in which everything goes at once; `PlaybackHistoryService` calls it through `onUrgentSave` right after the save on pause, stop, marking played or unplayed, and a listen passing the completion threshold; after a seek, the next progress update saves however small the jump and sends it. Going to the background, `SyncController` calls `drain()` before closing: under one 3-second deadline it keeps sending, push after acknowledged push, until nothing waits for the relay. A new episode row waits with the position: starting playback is not on the send-at-once list, and the first pause or the 30-second flush carries it. Presence is `SyncPresence` (episodeKey, position, duration, playing, speed, sender time) sealed with the data key under the presence purpose; the client sends `presence {blob}` and the relay forwards `presence {deviceId, blob}` to the account's other authenticated sockets without storing it. `SyncController.setPresence` sends on a change of episode or play state, a jump of more than 3 seconds from where the last presence and its speed put the playhead, a paused position change, and every 30 seconds while playing; a stop sends one paused presence at the latest local position. Received presences are listed by `presences`/`presenceChanges`, expire 75 seconds after their last refresh, and are cleared whenever the connection ends. A presence that does not open is logged and dropped without ending the session, and a relay message of an unknown type decodes as `UnknownRelayMessage` and is ignored, so a relay may add messages within protocol version 1. The app wiring (publishing from the player, the mini player line, applying a newer position to a paused player) is part 2.

As built for M6e part 2 (app): `SyncEngine` reports the episode keys each merge stored, and `SyncController.episodesMerged` streams them. `syncPlaybackBridgeProvider`, started with sync, reads the stored history of the now-playing episode when its key is among them and calls `AudioPlayerController.adoptSyncedPosition`: with no audio loaded it moves the restored `savedPosition`; with the same episode paused it seeks when the stored position is more than 1.5 seconds away; while playing or loading it does nothing, so the device in use keeps its own position. The adopted position is not saved again, because the merge already stored it and a save would stamp it as this device's. The app does not publish presence or show another device's playback: a "playing on another device" line in the mini player was tried and dropped as giving the user nothing to act on. The presence path from part 1 stays unused until a feature needs it.

## Migration steps

`isar_community` handles added fields automatically but has no data-rewriting migrations. A `DataMigrationRunner` runs idempotent steps in order at launch, before providers start, and records progress in `SyncMeta.schemaVersion`. Both entry points open the database with `openAppDatabase`, which runs the runner (`features/user_state/services/data_migration_runner.dart`, steps in `dataMigrationSteps`) before returning; a failing step closes the database and is rethrown, earlier steps stay recorded, and the failed one reruns on the next launch. The runner also creates `SyncMeta` with a new `historyId` when it is missing: on first launch, and after "Reset All Data", which clears every collection including `SyncMeta` (the first user state write after a reset creates it if it comes before the next launch). Each step is one PR, and the app ships in a working state after every step.

| Step | Content |
|------|---------|
| M0 | Device continuity fixes, shippable now (#773): Android backup rules, exclude iOS downloads from backup, relative `DownloadTask.localPath`, move `deviceId` and install ID to device-only storage |
| M1 | Keys: read `podcast:guid`; add podcastKey and episodeKey and backfill existing data |
| M2 | Clock and write path: `SyncMeta` (HLC) and `UserStateStore`; route repository writes through it with no behavior change |
| M3 | User state collections: create, backfill, switch reads. Old collections stay read-only for one release so a rollback is possible |
| M4 | Outbox: write ops in the same transaction, used locally only |
| M5 | #718 and automatic snapshot: manual backup and restore, continuity snapshot, restore detection. Exclude the Isar database from iOS backup here (C1), not earlier: excluding it before the snapshot exists would break iOS device migration that works today |
| M6 | Relay and sync: QR pairing, recovery code, opt-in sync, realtime position, presence |
| M7 | Cleanup: remove `PlaybackHistory`, `QueueItem`, old settings collections, and user fields on `Subscription` and `Episode` |

The M5 implementation plan is in [`docs/plans/2026-11-16-backup-restore-plan.md`](../plans/2026-11-16-backup-restore-plan.md). The M6 plan is in [`docs/plans/2026-11-20-sync-plan.md`](../plans/2026-11-20-sync-plan.md); its decision P1 replaces the relay's per-op `op` table above with opaque frames and compacted snapshots.

## Risks

- M3 is the largest refactor in the app; history, queue, and settings are read from many places. For one release, debug builds compare old and new read results.
- User state can arrive before the catalog, so the queue may hold episodes of feeds not fetched yet. Unresolved rows are hidden and trigger a fetch of that feed.
- Joining keys (guid vs URL) is rare but tricky; it gets dedicated two-device simulation tests.
- Anonymous accounts can be abused: rate-limit `hello` and check app genuineness with App Attest and Play Integrity.
- Keychain and Block Store behavior can change between OS versions; migration and restore require acceptance tests on real devices.
