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

Status: accepted design, not yet implemented. Work is split into migration steps M0 to M7 (see [Migration steps](#migration-steps)). Tracking: #773 (M0), #718 (M5).

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
| `deviceId` | Must not | Keychain, `ThisDeviceOnly` | `noBackupFilesDir` |
| Install ID, analytics identifiers | Must not | Keychain, `ThisDeviceOnly` | `noBackupFilesDir` |
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

- Use `podcast:guid` (Podcasting 2.0) when the feed declares it. The parser does not read it today (`isolate_rss_parser.dart` reads only item `guid`); M1 adds it.
- Otherwise, hash the normalized feed URL at subscription time. If the feed moves later, the key stays and the new URL is kept as an alias.
- When the same show is registered under two keys (one device saw the guid first, another the URL), a `merge-into` op joins them.

**episodeKey**

- Hash of `podcastKey` plus the raw item guid. Without a guid, fall back to the enclosure URL, as `isolate_rss_parser.dart` already does.
- The current `Episode.guid` is a storage key influenced by each device's fetch history (`_FeedItemBatch.claim` in `episode_local_datasource.dart`). Two devices that fetched at different times can store the same episode under different keys, so it cannot be the sync key.
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
| `SyncMeta` | single row | new | Copy of `deviceId`, HLC state, server cursor, migration version |

No op log is kept forever anywhere: a device holds the current state and the unsent ops. `StationEpisode` stays derived. `DownloadTask` stays device-scoped, switching to episodeKey and a path relative to the downloads directory.

## Merge rules

Ordering uses a Hybrid Logical Clock: 48-bit wall-clock milliseconds, a 16-bit logical counter, and `deviceId` as the tie-breaker. Causally related changes stay ordered even with skewed clocks. A remote HLC more than 24 hours in the future is clamped, so a device with a broken clock cannot win forever. All rules are pure functions in `audiflow_domain`, verified with property tests.

| Target | Rule | Why |
|--------|------|-----|
| Position, `completedAt`, favorite, settings | Per-field last-writer-wins | The last listening wins. Max-position would skip what the user rewound to hear again |
| Play count, completion count, total listened time | Per-device grow-only counters, summed for display | LWW would lose listening done on one of two devices |
| Subscriptions, station members, queue membership | LWW element set with add and remove timestamps; removals kept as tombstones | An old device must not resurrect an unsubscribed podcast |
| Queue order | Fractional-index `rank`, LWW per element | Moving one item rewrites only that item; concurrent moves converge |
| Tombstones | Kept 90 days, then purged | A device offline longer than that refetches from a snapshot instead of diffs |

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
  accountId  BLOB PRIMARY KEY,  -- derived from the sync key
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

- **Sync key:** 256 random bits, passed to other devices by QR code and shown as a printable recovery code. HKDF derives the accountId, an authentication secret, and the key-wrapping key. Because the accountId comes from the key, no lookup table is needed.
- **Data key:** random, created once per account. Ops are encrypted with it; copies wrapped by each device key or the recovery code live in `key_wrap`.
- **Future Apple / Google sign-in:** add an `auth_method` row and a `sub` to accountId lookup (D1 or KV) in the Worker. Sign-in then identifies the account, but does not decrypt: the data key still comes from Keychain, Block Store, or the recovery code. If sign-in alone should decrypt, pick a wrap such as passkey PRF at that time; the schema does not change.
- **Stolen device:** set `device.revokedAt` and rotate the data key.

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

`isar_community` handles added fields automatically but has no data-rewriting migrations. A `DataMigrationRunner` runs idempotent steps in order at launch, before providers start, and records progress in `SyncMeta.schemaVersion`. Each step is one PR, and the app ships in a working state after every step.

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
