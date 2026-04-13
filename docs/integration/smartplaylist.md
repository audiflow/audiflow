# Smart Playlist Integration

## Purpose

Documents how audiflow consumes smart playlist configurations from external static hosting. This is the primary cross-repo integration in the audiflow ecosystem.

## Scope

This document covers:
- How the app fetches and caches smart playlist config JSON
- The resolver chain that groups episodes into smart playlists
- Model alignment requirements with the editor repo

This document does not cover:
- Schema definition (see `audiflow-smartplaylist-editor/crates/sp_core/assets/`)
- Config authoring workflow (see editor repo docs)
- CI deployment pipelines for data repos

## Responsibilities

- Fetch config JSON from flavor-specific base URL
- Cache config files locally (mirrors remote directory structure)
- Version-based cache invalidation via `meta.json`
- Resolve episodes into smart playlist groups using the resolver chain
- Display resolved smart playlists in podcast detail screens

## Non-responsibilities

- Defining or modifying the JSON Schema
- Creating or editing smart playlist configurations
- Hosting or deploying config data
- Validating config against schema at runtime (trusted input from CI-validated repos)

## Data sources

| Environment | Base URL | Source repo |
|-------------|----------|-------------|
| Production | `https://audiflow.github.io/audiflow-smartplaylist/assets/v5/` | `audiflow-smartplaylist` |
| Staging | `https://audiflow.github.io/audiflow-smartplaylist/assets-stg/v5/` | `audiflow-smartplaylist` |
| Development | `https://audiflow.github.io/audiflow-smartplaylist/assets-dev/v5/` | `audiflow-smartplaylist` |

All environments use the same GitHub Pages host with different asset paths. The base URL is injected via `smartPlaylistConfigBaseUrlProvider`.

## Key files in audiflow_domain

| File | Role |
|------|------|
| `features/feed/datasources/remote/smart_playlist_remote_datasource.dart` | HTTP fetch of config JSON |
| `features/feed/datasources/local/smart_playlist_cache_datasource.dart` | Local file cache |
| `features/feed/datasources/local/smart_playlist_local_datasource.dart` | Isar-backed metadata |
| `features/feed/repositories/smart_playlist_config_repository.dart` | Repository interface |
| `features/feed/repositories/smart_playlist_config_repository_impl.dart` | Cache-vs-remote coordination |
| `features/feed/services/smart_playlist_resolver_service.dart` | Resolver chain orchestration |
| `features/feed/providers/smart_playlist_providers.dart` | Riverpod providers |

## Resolver chain

`SmartPlaylistResolverService` matches a podcast against pattern configs (by GUID or feed URL), then routes each playlist definition to the appropriate resolver:

| Resolver | Type ID | Grouping logic |
|----------|---------|----------------|
| Season number | `seasonNumber` | Groups by season number from RSS metadata |
| Title classifier | `titleClassifier` | Groups by category tags |
| Year | `year` | Groups by publication year |
| Title discovery | `titleDiscovery` | Groups by title pattern matching and appearance order |

Valid resolver types: `seasonNumber`, `titleClassifier`, `year`, `titleDiscovery`. Legacy names (`rss`, `category`, `titleAppearanceOrder`) are not valid.

## Model files

| File | Type | Purpose |
|------|------|---------|
| `models/smart_playlist.dart` | Freezed | Resolved smart playlist with episodes |
| `models/smart_playlist_definition.dart` | Freezed | Config definition (from JSON) |
| `models/smart_playlist_pattern.dart` | Freezed | Pattern matching config |
| `models/smart_playlist_groups.dart` | Isar + Freezed | Resolved group hierarchy (Isar collection for caching) |
| `models/smart_playlist_group_def.dart` | Freezed | Group definition (from JSON) |
| `models/smart_playlist_sort.dart` | Freezed | Sort configuration |
| `models/smart_playlists.dart` | Isar | Smart playlist Isar collection for local persistence |

## Integration rules

- Model JSON keys must match `sp_core` models in the editor repo exactly
- Enum string values must match schema `oneOf`/`enum` definitions
- Schema conformance tests validate round-trip serialization: `packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
- Vendored schemas at `packages/audiflow_domain/test/fixtures/` (`playlist-definition.schema.json`, `pattern-index.schema.json`, `pattern-meta.schema.json`) must be kept in sync with upstream (v5 schema)

## Schema update procedure

1. Copy all `*.schema.json` from `audiflow-smartplaylist-schema` (canonical source) to `packages/audiflow_domain/test/fixtures/`
2. Run conformance tests: `flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
3. Fix any drift (update models, enums, or test data to match)
4. Run full domain test suite: `flutter test packages/audiflow_domain`

## Related documents

- docs/overview.md -- app-level context
- docs/architecture/system-overview.md -- where smart playlist fits in data flow
- docs/specs/smart-playlist.md -- detailed resolver specification

## When to update

Update this document when:
- Smart playlist config fetch or cache strategy changes
- New resolver types are added
- Base URLs or hosting strategy changes
- Model alignment requirements change
- Schema update procedure changes
