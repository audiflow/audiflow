---
refs:
  id: fr:06-preset
  kind: fr
  title: "Preset (smart playlist) consumption"
  related:
    - integration:preset
    - arch:smart-playlist-cache
  modules:
    - packages/audiflow_domain/lib/presets.dart
    - packages/audiflow_domain/lib/src/features/feed/models/
    - packages/audiflow_domain/lib/src/features/feed/resolvers/
    - packages/audiflow_domain/lib/src/features/feed/services/preset_loader.dart
    - packages/audiflow_domain/lib/src/features/feed/services/config_assembler.dart
    - packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart
    - packages/audiflow_domain/lib/src/features/feed/services/episode_extractor_resolver.dart
    - packages/audiflow_domain/lib/src/features/feed/repositories/preset_config_repository.dart
    - packages/audiflow_domain/lib/src/features/feed/repositories/preset_config_repository_impl.dart
    - packages/audiflow_domain/lib/src/features/feed/datasources/remote/preset_remote_datasource.dart
    - packages/audiflow_domain/lib/src/features/feed/datasources/local/preset_cache_datasource.dart
    - packages/audiflow_domain/lib/src/features/feed/datasources/local/smart_playlist_local_datasource.dart
    - packages/audiflow_domain/lib/src/features/feed/providers/preset_providers.dart
---
# FR 06: Preset (smart playlist) consumption

> Fetches curated preset configurations from external hosting, caches them on-device, and resolves a podcast's episodes into structured playlists and groups.

## Purpose

Raw RSS feeds present episodes as one flat, reverse-chronological list. For long-running or multi-strand shows that is a poor experience: listeners cannot find a season, a recurring segment, or a particular year without scrolling endlessly. Preset — formerly called "smart playlist" — solves this by letting the audiflow ecosystem ship hand-tuned grouping rules for individual podcasts, so a podcast detail screen can present episodes organized into seasons, categories, or year-bound groups instead of an undifferentiated stream.

This FR covers the *consumption* side: how the audiflow app fetches the preset config JSON from external static hosting, caches it locally so it survives offline use, keeps it fresh across upstream schema and data revisions, and runs the matcher and resolver chain that decides which preset applies to a given podcast and how its episodes are grouped. The preset schema itself, and the tooling that authors and hosts these configs, live in separate repositories and are out of scope here.

## User-visible Behavior

- **Normal case**: When a listener opens a podcast that has a published preset, the detail screen shows its episodes organized according to the preset — for example, separate season playlists, a category breakdown, or year-grouped sections with sticky year headers — rather than a single flat list. The grouping appears automatically; the listener never configures anything.
- **No preset published**: If no preset matches the podcast, the detail screen falls back gracefully. The app still works: episodes are shown as a normal list, and auto-detect heuristics may still group obvious cases (such as RSS season numbers) without any remote config.
- **Offline / fetch failure**: If the device is offline or the remote host is unreachable, the app uses the most recently cached config. A previously visited podcast keeps its preset grouping with no network access. If nothing was ever cached, the podcast simply shows the plain episode list — preset absence is never an error surfaced to the listener.
- **Config updated upstream**: When the ecosystem republishes a podcast's preset with a new data version, the app detects the version bump on the next refresh (root meta is fetched at app launch), evicts the stale cached copy, and re-fetches. Because episode numbering is extracted at ingest, the app also re-extracts numbering for already-stored episodes under the new rules before regrouping, so episodes ingested under the old config move into newly added groups. The listener sees the updated grouping on their next visit without any manual cache clearing.
- **Recovery / manual reset**: The Storage & Data settings screen exposes a "Podcast Cache" clear action that purges all cached preset configs and resolved-grouping data, forcing a clean re-fetch and re-resolve on subsequent podcast views.

## Capabilities

- **Remote config fetch**: Retrieves preset configuration JSON from a flavor-specific base URL on external static hosting. A lightweight root `meta.json` is fetched first to enumerate available presets and their versions; per-podcast configs are fetched lazily, only when a podcast that matches is actually opened.
- **Split-file assembly**: Preset configs are stored as a small file hierarchy — a root index, per-preset metadata, and individual playlist definition files. The app assembles these pieces into a single in-memory config that the resolver chain consumes, preserving the playlist order declared in the preset metadata.
- **Local caching**: Fetched config files are persisted to disk, mirroring the remote directory structure, so presets remain available offline and across app restarts. Resolved grouping results are additionally cached in the on-device database to avoid re-running resolvers on every podcast view.
- **Version-based invalidation**: A locally tracked version map is compared against the root meta on each refresh. Unchanged presets are served straight from cache; presets whose version has bumped are evicted and re-fetched. Stale presets no longer listed upstream are removed during cache reconciliation.
- **Schema version migration**: The preset schema has evolved through successive versions, and the consuming models have been migrated to match each one — from the early flat structure (v1/v2), through field and resolver renames (v3/v4), to a pipeline-oriented nested config (v5) and a structured matcher type. Each migration is a clean cut aligned to the upstream schema; vendored schema fixtures and round-trip conformance tests guard against drift.
- **Podcast matching**: A matcher resolves which preset, if any, applies to a podcast by comparing the podcast's GUID or feed URL against each preset's declared identifiers, using a feed-URL hint for fast pre-filtering before loading a full config.
- **Resolver chain**: Once a preset matches, each of its playlist definitions is routed to the appropriate resolver — grouping by season number, by classified title patterns, by publication year, or by discovered title patterns — which filters and groups episodes into the structured playlists and groups the UI renders.
- **Heuristic-version cache safety**: Auto-detect resolvers (those used when no preset matches) declare a heuristic version so that cached groupings are invalidated and recomputed when their grouping logic changes.

## Boundaries

- **Does not define the schema.** The preset JSON Schema is owned and versioned by the external editor repository. This feature only consumes it; it never authors or modifies schema definitions, and vendored schema copies inside the app are read-only mirrors kept in sync with upstream.
- **Does not author or host config data.** Creating, editing, validating, or deploying preset configurations is the responsibility of the editor and hosting repositories. The app trusts the published JSON as CI-validated input and does not validate it against the schema at runtime.
- **Does not own playback or queueing.** Preset only decides how episodes are *organized* for display. Selecting, playing, downloading, or queueing the resulting episodes belongs to the audio playback and download/queue features.
- **Does not own RSS feed ingestion.** Fetching and parsing the podcast feed itself is the subscription/feed feature's concern; preset consumption operates on episodes that feed sync has already stored.
- **Does not own the podcast detail UI.** Sticky year headers, group cards, and the playlist selector are presentation concerns rendered by the app layer; this FR covers the domain-side fetch, cache, migration, and resolution that feeds them.

## Traceability

- **Source docs**: `docs/architecture/smart-playlist-cache.md`, `docs/integration/preset.md`, `docs/plans/2026-03-08-schema-v2-migration-design.md`, `docs/plans/2026-03-08-schema-v2-migration.md`, `docs/superpowers/plans/2026-04-11-schema-v4-migration.md`, `docs/superpowers/plans/2026-04-13-schema-v5-migration.md`, `docs/superpowers/plans/2026-04-14-schema-matcher-update.md`
- **Related**: `integration:preset` (cross-repo config consumption contract), `arch:smart-playlist-cache` (cache invalidation design)
