# System Overview

## Goal

Provide a reliable, offline-first podcast player for iOS and Android with smart playlist support. The system prioritizes fast startup, low memory usage during RSS parsing, and seamless background audio playback.

## Context

This repository is part of:
- The audiflow ecosystem (3 repos: app, editor, config data)
- A Flutter monorepo with 8 packages managed by Melos + Flutter workspace
- A consumer of smart playlist JSON configs hosted on GitHub Pages (all environments)

## High-level structure

- `audiflow_app`: Presentation layer -- screens, controllers, routing, localization
- `audiflow_domain`: Business logic -- repositories, datasources, Isar models, services, Riverpod providers
- `audiflow_core`: Foundation -- constants, extensions, error types, utilities, config
- `audiflow_podcast`: RSS parsing -- streaming XML parser, feed models, HTTP caching
- `audiflow_ui`: Shared UI -- reusable widgets, themes, styles
- `audiflow_ai`: On-device AI capabilities (Flutter plugin for iOS/Android)
- `audiflow_search`: Podcast search API client (iTunes API via Dio)
- `audiflow_cli`: CLI debugging tools for feed parsing and domain operations

## Main data flow

1. User subscribes to a podcast via search (iTunes API) or direct URL
2. `feed_remote_datasource` fetches RSS feed; `audiflow_podcast` parses it via streaming XML
3. Parsed episodes are stored in Isar via `feed_local_datasource`
4. Smart playlist configs are fetched from static hosting, cached locally, resolved into groups
5. User selects an episode; `audio_player_service` loads audio via `just_audio`
6. `audio_service` manages background playback, system controls, and audio focus
7. Playback position is persisted to Drift for resume-on-relaunch
8. Downloads are managed via `flutter_downloader` with queue and WiFi-only options

## Primary interfaces

- Input: RSS feed URLs, iTunes Search API, smart playlist config JSON (HTTP)
- Output: Audio playback (system audio), UI rendering, local database state
- External dependencies: iTunes Search API, static hosting (GitHub Pages), podcast RSS feeds

## Design constraints

- Offline-first: All data cached locally in Isar; app works without network
- No DTO layer: Isar collection classes used directly as domain entities (zero mapping overhead)
- Repository pattern: All data access behind repository interfaces
- Riverpod code generation: All providers use `@riverpod` annotation
- Feature-based modules: Each feature is a vertical slice in `audiflow_domain`
- Layer rules are strict: `App -> UI -> Domain -> Core`, `Domain -> Podcast -> Core`
- Mobile only: No web or desktop targets

## When to update

Update when: packages added/removed, data flow changes, new external dependencies introduced, layer rules modified.
