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

Status: accepted design, being implemented (M0 to M2 landed; M3 in progress). Work is split into migration steps M0 to M7 (see [Migration steps](#migration-steps)). Tracking: #773 (M0, done), #777 (M1, done), #778 (M2, done), #779 (M3), #780 (M4), #718 (M5), #781 (M6), #782 (M7).

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
| Isar database | No | Moved to Application Support with `isExcludedFromBackup` (C1) | Excluded (easily exceeds 25 MB) |
| Downloaded audio | No | `isExcludedFromBackup` | Excluded |
| Sync key | Yes | Keychain, `AfterFirstUnlock`, synchronizable (C2) | Block Store with cloud backup enabled |
| `deviceId` | Must not | Keychain, `ThisDeviceOnly` | `files/device_only_store/`, excluded by the backup rules |
| Install ID, analytics identifiers | Must not | Keychain, `ThisDeviceOnly` | `files/device_only_store/`, excluded by the backup rules |
| Synced settings | Yes | Isar user state, included in the snapshot | same |
| Device-scoped settings | Yes | SharedPreferences (backed up, as today) | SharedPreferences (included in backup rules) |

### Restore detection

At launch, compare `SyncMeta.deviceId` in Isar with the `deviceId` in device-only storage.

- If the device-only `deviceId` is missing or differs, the data is a copy restored from another device. Generate a new `deviceId`, drop the sync cursor and refetch, and reset downloads whose file is missing to not downloaded.
- If Isar is empty and a snapshot exists (the state right after a device migration on either platform), merge the snapshot automatically without asking, and show "Your data was carried over from your previous device". The OS restored the user's own data, so no confirmation is needed.
- If the sync key came back from Keychain or Block Store, sync stays enabled; the device only re-registers with the relay as a new device.

### When the snapshot is written

Quick Start and Android device transfer run when the user decides to switch, so a daily snapshot is often stale. Write the snapshot when the app goes to the background and something changed, at most once every 15 minutes. Write to a temporary file and rename it, so a crash never leaves a broken snapshot. Expected size is 1 to 2 MB after ten years of use. Cross-platform migration is not possible through OS mechanisms; it uses the manual backup file (#718) or sync.

## Stable keys

**podcastKey**

- Use `podcast:guid` (Podcasting 2.0) when the feed declares it (`isolate_rss_parser.dart` reads it into `ParsedPodcastMeta.podcastGuid`).
- Otherwise, hash the feed URL normalized by `normalizeFeedUrlForKey` (scheme, host case, default port, fragment, and trailing slash ignored; credentials kept, since private feeds tell subscribers apart by them).
- The key is assigned by the first feed parse (`SubscriptionMetadataUpdater` calls `assignStableKeys`), since a subscription is usually created from search before its feed is read, and is never recomputed. If the feed moves later, the key stays and the new URL is kept as an alias. A subscription without a key skips conditional requests until a parse assigns one.
- When the same show is registered under two keys (one device saw the guid first, another the URL), a `merge-into` op joins them.

**episodeKey**

- Hash of `podcastKey` plus the episode's storage guid: the item guid, or the enclosure URL for an item without one, as `isolate_rss_parser.dart` already does. An item that reuses another item's guid is stored under a duplicate-guid key (guid plus enclosure URL), so it gets a distinct key; which of those items holds the plain guid can still differ between devices, which the locator below resolves.
- Assigned when the episode is stored and its podcast has a key; `assignStableKeys` keys a podcast's existing episodes in the same transaction as the podcast. Never recomputed, even when the storage guid is rewritten.
- The current `Episode.guid` is a storage key influenced by each device's fetch history (`_FeedItemBatch.claim` in `episode_local_datasource.dart`). Two devices that fetched at different times can store the same episode under different keys, so it cannot be the sync key.
- Keys are `podcastKeyFor` / `episodeKeyFor` in `audiflow_domain` (`features/user_state/models/stable_keys.dart`): the first 128 bits of SHA-256 over a typed, versioned input, base64url without padding.
- Ops also carry a locator `{guid, audioUrl, publishedAt}`. When the key is unknown, the receiver searches the same way `_bestMatch` does and records the found key as an alias.

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
- Since M2, every write to a user state collection goes through it: subscriptions (including cache eviction), playback history, favorites, queue, stations and their podcast links, view, play order, and audio preferences, and parental control. Catalog writes (episodes, smart playlists, transcripts, chapters, `StationEpisode`) and downloads use `writeTxn` directly. Synced settings still live in SharedPreferences and move into the store with M3.
- State and op are written in the same transaction, so one never exists without the other.
- Applying a received op is an ordinary Isar write. Existing Riverpod watchers update the UI, so sync needs no UI code of its own.
- The continuity snapshot, the manual backup (#718), and the initial sync download are the same compacted snapshot. Restore is always a merge; "replace" means reset all data, then merge.

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

The M5 implementation plan is in [`docs/plans/2026-11-16-backup-restore-plan.md`](../plans/2026-11-16-backup-restore-plan.md).

## Risks

- M3 is the largest refactor in the app; history, queue, and settings are read from many places. For one release, debug builds compare old and new read results.
- User state can arrive before the catalog, so the queue may hold episodes of feeds not fetched yet. Unresolved rows are hidden and trigger a fetch of that feed.
- Joining keys (guid vs URL) is rare but tricky; it gets dedicated two-device simulation tests.
- Anonymous accounts can be abused: rate-limit `hello` and check app genuineness with App Attest and Play Integrity.
- Keychain and Block Store behavior can change between OS versions; migration and restore require acceptance tests on real devices.
