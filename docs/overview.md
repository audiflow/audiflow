# Overview

## Purpose

Audiflow is a mobile podcast player for iOS and Android, built with Flutter. It provides podcast discovery, subscription management, audio playback with background support, episode downloads, queue management, smart playlist consumption, podcast transcript display, voice commands, station (custom multi-podcast playlist) management, and background feed refresh with new episode notifications. The app follows an offline-first architecture using Isar for local storage.

## Responsibilities

- Podcast discovery via iTunes Search API
- Podcast subscription and feed refresh (RSS parsing)
- Background audio playback with system media controls
- Episode download management (WiFi-only option, batch downloads)
- Queue building and reordering
- Smart playlist config fetching, caching, and rendering
- Playback position persistence and resume
- Sleep timer and playback speed control
- Podcast transcript and chapter display
- On-device voice command processing
- Station management (custom multi-podcast playlists with duration filters and episode sorting)
- Background feed refresh with prioritized sync and new episode notifications

## Non-responsibilities

- JSON Schema definition (owned by `audiflow-smartplaylist-editor`)
- Smart playlist config authoring or editing (owned by editor)
- Config data hosting (owned by `audiflow-smartplaylist` via GitHub Pages, all environments)

## Main concepts

- **Pattern**: A smart playlist config matched to a podcast by GUID or feed URL. Contains one or more playlist definitions.
- **Resolver**: A strategy that groups episodes into smart playlists. Types: `rss`, `category`, `year`, `titleAppearanceOrder`.
- **Isar collection**: A class annotated with `@collection` that serves as both database schema and domain entity (no separate DTOs).
- **Feature module**: A vertical slice containing models, repositories, datasources, services, and events within `audiflow_domain`.
- **Presentation layer**: Screens, controllers, and widgets in `audiflow_app` that consume domain providers via Riverpod.
- **Station**: A user-created playlist that aggregates episodes from multiple subscribed podcasts, with configurable duration filters and episode sorting.

## Primary entry points

- `packages/audiflow_app/lib/main.dart`: Default app entry point
- `packages/audiflow_app/lib/main_dev.dart`: Development flavor
- `packages/audiflow_app/lib/main_stg.dart`: Staging flavor
- `packages/audiflow_app/lib/main_prod.dart`: Production flavor
- `packages/audiflow_app/lib/routing/app_router.dart`: Route definitions (GoRouter)
- `packages/audiflow_domain/lib/audiflow_domain.dart`: Domain public API

## Key dependencies

- `riverpod` (v3) + code generation: State management
- `isar_community` + `isar_community_flutter_libs`: Local database
- `just_audio` + `audio_service`: Audio playback and background support
- `dio` + `dio_cache_interceptor`: HTTP client with caching
- `go_router` + `go_router_builder`: Type-safe routing
- `freezed` + `json_serializable`: Immutable models and JSON serialization
- `sentry_flutter`: Error tracking and performance monitoring
- `url_launcher`: In-app browser and external link handling
- `workmanager`: Background task scheduling for periodic feed refresh
- `flutter_local_notifications`: New episode notification delivery
- `connectivity_plus`: Network connectivity detection

## Read next

- docs/architecture/system-overview.md
- docs/architecture/module-boundaries.md
- docs/architecture/state-flow.md
- docs/architecture/playback-pipeline.md
- docs/integration/smartplaylist.md
- docs/development/change-workflow.md

## When to update

Update this document when:
- Repository purpose or scope changes
- New packages are added to the monorepo
- Major dependencies are added or replaced
- Responsibility boundaries shift between this repo and sibling repos
