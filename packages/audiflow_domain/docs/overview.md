# Overview

## Purpose

`audiflow_domain` is the business logic and data layer for the Audiflow podcast player app. It owns all repository interfaces and implementations, Isar database collections, local and remote data sources, domain services, and Riverpod providers for shared state. The package merges the traditional domain and data layers into one for performance: Isar models serve directly as domain entities with zero conversion overhead.

## Responsibilities

- Define and persist all Isar collections (Episode, Subscription, Station, QueueItem, DownloadTask, PlaybackHistory, SmartPlaylistGroups, EpisodeChapter, EpisodeTranscript, TranscriptSegmentTable, PodcastViewPreference)
- Provide repository interfaces (abstract classes) and their implementations for every feature
- Manage local data sources (Isar queries) and remote data sources (Dio HTTP)
- Implement business services: feed sync, playback control, download queue, voice command orchestration, station reconciliation, background refresh
- Consume and cache smart playlist configs from GitHub Pages static hosting
- Resolve smart playlist groupings via a strategy-pattern resolver pipeline
- Expose common Riverpod providers: Isar instance, Dio client, logger, connectivity, platform info

## Non-responsibilities

- RSS parsing logic (owned by `audiflow_podcast`; this package calls `FeedParserService` which delegates to `audiflow_podcast`)
- Podcast search API (owned by `audiflow_search`; re-exported types only)
- AI inference (owned by `audiflow_ai`; re-exported types only)
- UI rendering, routing, theming (owned by `audiflow_app` and `audiflow_ui`)
- Schema definitions for smart playlists (owned by `audiflow-smartplaylist-editor`)

## Main concepts

- **Isar collection**: Annotated with `@collection`. Serves as both database model and domain entity. Uses `late` fields and cascade assignment for construction. No separate DTOs.
- **Freezed model**: Annotated with `@freezed`. Used for transient/computed data not persisted to Isar (e.g., `PlaybackState`, `NowPlayingInfo`, `PlaybackProgress`, `DownloadStatus`, `VoiceRecognitionState`).
- **Repository**: Abstract interface + `Impl` class in the same feature directory. Interface defines the contract; implementation coordinates local/remote data sources.
- **Data source**: Encapsulates a single storage mechanism. `local/` subdirectory for Isar operations, `remote/` for HTTP operations.
- **Service**: Orchestrates business logic across repositories and data sources. Examples: `AudioPlayerController`, `BackgroundRefreshService`, `StationReconciler`.
- **Resolver**: Strategy-pattern classes implementing `SmartPlaylistResolver` to group episodes. Types: `rss`, `category`, `year`, `titleAppearanceOrder`. Each resolver returns a `SmartPlaylistGrouping` or null if it cannot handle the episodes.
- **ConfigAssembler**: Combines split config files (PatternMeta + playlist definitions) into the unified `SmartPlaylistPatternConfig` that resolvers consume.
- **Result type**: Sealed class (`Success<T>` / `Failure<T>`) for error handling without exceptions. Defined in `src/common/models/result.dart`.
- **patterns.dart**: Secondary barrel file exporting only pure-Dart smart playlist types (no Flutter dependency), used by `audiflow_cli`.

## Feature modules

Each feature follows the directory structure: `models/`, `datasources/local/`, `datasources/remote/`, `repositories/`, `services/`, `providers/`, `extensions/`, `builders/`, `resolvers/`, `events/`. Not every feature uses all subdirectories.

| Feature | Directory | Key classes | Purpose |
|---------|-----------|-------------|---------|
| feed | `src/features/feed/` | `Episode`, `EpisodeRepository`, `FeedParserService`, `FeedSyncService`, `BackgroundRefreshService`, `SmartPlaylistConfigRepositoryImpl`, `ConfigAssembler`, resolvers | Episode management, feed sync, smart playlist config consumption and resolution |
| player | `src/features/player/` | `AudioPlayerController`, `NowPlayingController`, `PlaybackHistoryService`, `PlaybackState`, `PlaybackProgress` | Audio playback control, progress tracking, history persistence |
| download | `src/features/download/` | `DownloadTask`, `DownloadService`, `DownloadQueueService`, `DownloadFileService` | Episode download queue, file management, WiFi-only enforcement |
| queue | `src/features/queue/` | `QueueItem`, `QueueService`, `PlaybackQueue` | Adhoc playback queue with reordering and auto-advance |
| subscription | `src/features/subscription/` | `Subscription`, `SubscriptionRepository`, `OpmlImportService`, `PodcastCacheEvictionService` | Podcast subscription CRUD, OPML import, cache eviction |
| station | `src/features/station/` | `Station`, `StationPodcast`, `StationEpisode`, `StationReconciler` | Custom multi-podcast playlists with filter conditions and materialized episode views |
| transcript | `src/features/transcript/` | `EpisodeChapter`, `EpisodeTranscript`, `TranscriptSegmentTable`, `TranscriptService` | Chapter and transcript storage, full-text search across transcript segments |
| voice | `src/features/voice/` | `VoiceCommandOrchestrator`, `VoiceCommandExecutor`, `PlayPodcastByNameService` | Speech recognition state machine, AI-powered command parsing and execution |
| settings | `src/features/settings/` | `AppSettingsRepository` | User preferences (playback speed, skip durations, notification toggle) |

## Primary entry points

- `lib/audiflow_domain.dart`: Main barrel file. All public types are exported here. Consumers import this single file.
- `lib/patterns.dart`: Pure-Dart barrel file for CLI tools. Exports smart playlist pattern types without Flutter dependencies.
- `lib/src/common/providers/database_provider.dart`: `isarProvider` -- must be overridden at app startup with initialized Isar instance.
- `lib/src/common/providers/http_client_provider.dart`: Dio client provider.
- `lib/src/features/player/services/audio_player_service.dart`: `AudioPlayerController` -- keepAlive Riverpod notifier wrapping just_audio with queue auto-advance.
- `lib/src/features/feed/services/background_refresh_service.dart`: Constructor-injected (no Riverpod) for background isolate use.
- `lib/src/features/feed/resolvers/smart_playlist_resolver.dart`: `SmartPlaylistResolver` interface implemented by four resolver strategies.

## Key dependencies

| Dependency | Purpose |
|------------|---------|
| `audiflow_core` | Shared constants, extensions, error types, `SimpleEpisodeData` |
| `audiflow_podcast` | RSS parsing (streaming parser, `PodcastFeed`, `PodcastItem`) |
| `audiflow_search` | Podcast search API client (`Podcast` model re-exported) |
| `audiflow_ai` | On-device AI for voice command parsing (`VoiceCommand`, `VoiceIntent`) |
| `isar_community` | Local database (collections, queries, watchers) |
| `riverpod` + `riverpod_annotation` | State management and dependency injection |
| `freezed_annotation` | Immutable data classes for transient models |
| `dio` | HTTP client for remote data sources |
| `just_audio` | Audio playback engine |
| `rxdart` | Stream combinators (e.g., `Rx.combineLatest3` for playback progress) |
| `speech_to_text` | Speech recognition for voice commands |
| `flutter_local_notifications` | Background new-episode notifications |

## Cross-feature communication

- `AudioPlayerController` reads from `QueueService` for auto-advance on playback completion
- `AudioPlayerController` reads from `DownloadService` to prefer local files over streaming
- `AudioPlayerController` updates `PlaybackHistoryService` on play/pause/stop/progress
- `BackgroundRefreshService` uses `SubscriptionRepository` and `EpisodeRepository` with priority ordering
- `StationReconciler` queries `Episode`, `PlaybackHistory`, and `DownloadTask` collections to evaluate filter conditions

## Read next

- `../CLAUDE.md` -- package entry point, validation commands
- Parent repo `docs/architecture/module-boundaries.md` -- full package dependency graph
- Parent repo `docs/integration/smartplaylist.md` -- smart playlist consumption contract
- `test/fixtures/schema.json` -- vendored schema for conformance testing

## When to update

Update this document when:
- A new feature module is added or an existing one is renamed
- The public API barrel file (`audiflow_domain.dart`) gains new export categories
- Repository or service interfaces change their contracts
- New Isar collections are added
- Smart playlist resolver types change
- Cross-feature dependencies are added or removed
- Package dependencies change in `pubspec.yaml`
