---
refs:
  id: fr:20-backup-restore
  kind: fr
  title: "Backup and restore"
  related:
    - fr:14-settings
    - fr:18-parental-control
    - fr:03-subscription-feeds
    - fr:07-stations
  modules:
    - packages/audiflow_domain/lib/src/features/snapshot/
    - packages/audiflow_app/lib/features/settings/
---

# FR 20: Backup and restore

> Saves the data a user must not lose to one file and merges it back on the same device, another device, or across iOS and Android.

## Purpose

Subscriptions, listening progress, the queue, stations, and listening settings are built up over months and cannot be recovered from feeds. OS backup carries them only between devices of the same platform, and only when the user set it up. A backup file the user controls covers moving between iOS and Android, reinstalling, and keeping a copy before risky changes. Restoring must never damage what is already on the device: a broken or unsupported file changes nothing, and data newer on the device than in the file stays.

## User-visible Behavior

- Export: On Storage & Data, "Export Backup" builds `audiflow-YYYYMMDD.audiflow-backup` and opens the share sheet (Files, AirDrop, mail, Drive). Closing the sheet without saving is not an error. If some subscribed podcasts have not had their feed read since the upgrade that added stable keys (offline or dead feeds), the success message says how many were left out and to refresh them first.
- Restore: "Restore from Backup" opens the system file picker showing every file. A picked file is validated before anything is written. A confirmation screen then shows when and on which platform the backup was made and how many podcasts, episodes with progress, queued episodes, and stations it holds, with a note that restore merges and that resetting all data first gives a clean start.
- Merge rules: Restore is always a merge under the sync rules. Per field, the newer value wins, so anything changed on this device after the backup stays. Deleted queue entries, stations, and station members in the backup stay deleted. Restoring the same file again changes nothing.
- After restore: Subscriptions and stations appear right away, titled from the file until their feeds load. Feeds are then fetched again, and the queue fills in as each episode becomes known. A feed that fails to load does not fail the restore; the regular refresh fetches it later, and queued episodes from that feed join the queue then.
- Failure cases: A file that is not a backup, a damaged or truncated file, a file made by a newer app version (asks to update), and a file that cannot be read each show their own message and write nothing. If the restore itself fails (for example, the disk is full), the message asks to try again: a failed merge rolls back, and restoring the same file again is always safe because the merge is idempotent.
- Restricted Mode (FR 18): restoring requires the parental PIN, since it can change per-podcast parental flags.

## Capabilities

- One snapshot format for manual backup, the automatic continuity snapshot, and the first sync download: a JSON header line (format, version, creation time, history id, source app and platform, counts, checksum) followed by a gzipped protobuf body in which every field carries its clock.
- Validation without writes: format, version, checksum, size limits, and value types are checked before the confirmation screen.
- Restore stops playback, cancels background tasks, and suspends the download queue and feed sync for the merge, as a data reset does, then projects the merged state into the subscription, station, and queue rows the app reads.
- Fields the running app version does not know are kept and exported again, so a backup from a newer version loses nothing when it passes through an older one.

## Boundaries

- The file is not encrypted and holds no `deviceId`, install id, sync key, or parental PIN. Parental per-podcast flags are included; the PIN and Restricted Mode are not.
- Not included: the catalog (episodes, transcripts, chapters), downloads, and device-scoped settings (appearance, haptics, network and download limits, feed sync schedule, privacy consent). These are refetched or set per device.
- No file type registration in this version: the picker shows all files and validation rejects the wrong ones.
- OS device migration: the app keeps a continuity snapshot in its own storage, rewritten when the app goes to the background after a change (at most every 15 minutes). The OS backup and device transfer carry that file, not the database. When a new device of the same platform starts with no user data and finds the snapshot, the app restores it without asking and says once that the data was carried over from the previous device. "Reset All Data" deletes the snapshot, so a reset is not undone on the next launch. Downloads and the catalog are not carried; feeds are fetched again.

## Traceability

- **Source docs**: `docs/plans/2026-11-16-backup-restore-plan.md`, `docs/architecture/user-data-sync.md` (snapshot format, merge rules, projection step)
- **Related FR**: 14-settings.md (Storage & Data screen), 18-parental-control.md (PIN gate), 03-subscription-feeds.md, 07-stations.md
