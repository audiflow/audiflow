---
refs:
  id: integration:preset
  kind: integration
  title: "Preset config consumption contract"
  related:
    - arch:smart-playlist-cache
  modules:
    - packages/audiflow_domain/lib/src/features/feed/datasources/remote/preset_remote_datasource.dart
    - packages/audiflow_domain/lib/src/features/feed/datasources/local/preset_cache_datasource.dart
    - packages/audiflow_domain/lib/src/features/feed/datasources/local/smart_playlist_local_datasource.dart
    - packages/audiflow_domain/lib/src/features/feed/repositories/preset_config_repository.dart
    - packages/audiflow_domain/lib/src/features/feed/repositories/preset_config_repository_impl.dart
    - packages/audiflow_domain/lib/src/features/feed/services/smart_playlist_resolver_service.dart
    - packages/audiflow_domain/lib/src/features/feed/providers/preset_providers.dart
    - packages/audiflow_domain/lib/src/features/feed/resolvers/
---

# Preset Integration

## Purpose

Documents how audiflow consumes preset configurations from external static hosting. This is the primary cross-repo integration in the audiflow ecosystem.

## Scope

This document covers:
- How the app fetches and caches preset config JSON
- The resolver chain that groups episodes into smart playlists
- Model alignment requirements with the editor repo

This document does not cover:
- Schema definition (see `audiflow-preset-editor/crates/preset_core/assets/`)
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
- Creating or editing preset configurations
- Hosting or deploying config data
- Validating config against schema at runtime (trusted input from CI-validated repos)

## Data sources

| Environment | Base URL | Source repo |
|-------------|----------|-------------|
| Production | `https://audiflow.github.io/audiflow-preset/assets/v7/` | `audiflow-preset` |
| Staging | `https://audiflow.github.io/audiflow-preset/assets-stg/v7/` | `audiflow-preset` |
| Development | `https://audiflow.github.io/audiflow-preset/assets-dev/v7/` | `audiflow-preset` |

All environments use the same GitHub Pages host with different asset paths. The base URL is injected via `presetConfigBaseUrlProvider`.

## Key files in audiflow_domain

| File | Role |
|------|------|
| `features/feed/datasources/remote/preset_remote_datasource.dart` | HTTP fetch of config JSON |
| `features/feed/datasources/local/preset_cache_datasource.dart` | Local file cache |
| `features/feed/datasources/local/smart_playlist_local_datasource.dart` | Isar-backed metadata |
| `features/feed/repositories/preset_config_repository.dart` | Repository interface |
| `features/feed/repositories/preset_config_repository_impl.dart` | Cache-vs-remote coordination |
| `features/feed/services/smart_playlist_resolver_service.dart` | Resolver chain orchestration |
| `features/feed/providers/preset_providers.dart` | Riverpod providers |

## Resolver chain

`SmartPlaylistResolverService` matches a podcast against preset configs (by GUID or feed URL), then routes each playlist definition to the appropriate resolver:

| Resolver | Type ID | Grouping logic |
|----------|---------|----------------|
| Season number | `seasonNumber` | Groups by season number from RSS metadata |
| Title classifier | `titleClassifier` | Groups by matching episode titles against configured `groups` patterns (first match wins) |
| Year | `year` | Groups by publication year |
| Title discovery | `titleDiscovery` | Groups by title pattern matching and appearance order |

Valid resolver types: `seasonNumber`, `titleClassifier`, `year`, `titleDiscovery`. Legacy names (`rss`, `category`, `titleAppearanceOrder`) are not valid.

## Model files

| File | Type | Purpose |
|------|------|---------|
| `models/preset_config.dart` | Plain | Top-level preset config (matchers + playlists) |
| `models/preset_meta.dart` | Plain | Per-preset meta.json |
| `models/preset_summary.dart` | Plain | Summary entry in root meta.json |
| `models/smart_playlist.dart` | Freezed | Resolved smart playlist with episodes |
| `models/smart_playlist_definition.dart` | Freezed | Playlist definition (from JSON) |
| `models/smart_playlist_groups.dart` | Isar + Freezed | Resolved group hierarchy (Isar collection for caching) |
| `models/smart_playlist_group_def.dart` | Freezed | Group definition (from JSON) |
| `models/smart_playlist_sort.dart` | Freezed | Sort configuration |
| `models/smart_playlists.dart` | Isar | Smart playlist Isar collection for local persistence |

## Integration rules

- Model JSON keys must match `preset_core` models in the editor repo exactly
- Enum string values must match schema `oneOf`/`enum` definitions
- Schema conformance tests validate round-trip serialization: `packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
- Vendored schemas at `packages/audiflow_domain/test/fixtures/` (`playlist-definition.schema.json`, `preset-index.schema.json`, `preset-meta.schema.json`) must be kept in sync with upstream (v7 schema)

## Schema update procedure

1. Copy all `*.schema.json` from `audiflow-preset-editor/crates/preset_core/assets/` (SSoT) to `packages/audiflow_domain/test/fixtures/`
2. Run conformance tests: `flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart`
3. Fix any drift (update models, enums, or test data to match)
4. Run full domain test suite: `flutter test packages/audiflow_domain`

**Never edit vendored schema files directly.** If the schema has a bug, fix it in the SSoT and re-vendor.

## Related documents

- docs/overview.md -- app-level context
- docs/architecture/system-overview.md -- where smart playlist fits in data flow
- docs/fr/06-preset.md -- preset consumption Functional Requirements (matcher and resolver chain)

## When to update

Update this document when:
- Preset config fetch or cache strategy changes
- New resolver types are added
- Base URLs or hosting strategy changes
- Model alignment requirements change
- Schema update procedure changes
