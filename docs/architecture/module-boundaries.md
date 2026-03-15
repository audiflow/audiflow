# Module Boundaries

## Dependency graph

```
audiflow_app -> audiflow_ui -> audiflow_domain -> audiflow_podcast -> audiflow_core
                                    |
                                    +-> audiflow_search -> audiflow_core
                                    +-> audiflow_ai     -> audiflow_core
                                    +-> audiflow_core

audiflow_cli -> audiflow_domain, audiflow_podcast
```

## Modules

### Module: audiflow_app

#### Responsibilities
- App entry points and flavor configuration (dev, stg, prod)
- GoRouter route definitions and navigation guards
- Feature presentation: screens, controllers, feature-scoped widgets
- Localization (ARB files for en, ja)
- Root ProviderScope and app-level observers

#### Non-responsibilities
- Business logic, data access, model definitions
- Reusable widgets shared across features (those belong in audiflow_ui)

#### Depends on
- audiflow_ui, audiflow_domain, audiflow_core

#### Used by
- Nothing (top-level app)

---

### Module: audiflow_domain

#### Responsibilities
- Feature modules: feed, player, queue, download, subscription, settings, voice, transcript
- Repository interfaces and implementations (co-located)
- Datasources: local (Isar) and remote (HTTP via Dio)
- Isar collection definitions (serve as domain entities)
- Freezed models for non-persisted state (PlaybackState, NowPlayingInfo, PlaybackProgress)
- Services for business logic orchestration
- Riverpod providers for dependency injection and state
- Cross-feature event streams

#### Non-responsibilities
- UI rendering, navigation, routing
- RSS XML parsing (delegated to audiflow_podcast)
- Core utilities, constants, error types (delegated to audiflow_core)

#### Depends on
- audiflow_podcast, audiflow_search, audiflow_ai, audiflow_core

#### Used by
- audiflow_app, audiflow_ui, audiflow_cli

---

### Module: audiflow_core

#### Responsibilities
- App constants and asset paths
- Flavor configuration and feature flags
- Error types: AppException hierarchy (NetworkException, StorageException, etc.)
- Extension methods: String, DateTime, Duration
- Utilities: validators, formatters, helpers
- Logger configuration

#### Non-responsibilities
- Business logic, data access, UI rendering
- No dependencies on any other workspace package

#### Depends on
- Nothing (foundation package)

#### Used by
- All other packages

---

### Module: audiflow_podcast

#### Responsibilities
- Streaming RSS XML parsing (memory-efficient)
- RSS 2.0 and iTunes namespace support
- Podcast transcript and chapter tag extraction (`<podcast:transcript>`, `<podcast:chapters>`)
- HTTP feed fetching with caching and conditional requests
- Builder interface (`PodcastEntityBuilder`) for zero-copy entity construction
- Graceful handling of malformed feeds

#### Non-responsibilities
- Podcast subscription management, episode storage
- Smart playlist logic, playback

#### Depends on
- audiflow_core

#### Used by
- audiflow_domain, audiflow_cli

---

### Module: audiflow_ui

#### Responsibilities
- Reusable widgets: buttons, cards, indicators, dialogs, player components, layouts
- App theme (Material 3, dynamic color, light/dark)
- Color scheme, text styles, spacing, borders, shadows

#### Non-responsibilities
- Feature-specific screens or controllers
- Business logic or data access

#### Depends on
- audiflow_domain, audiflow_core

#### Used by
- audiflow_app

---

### Module: audiflow_ai

#### Responsibilities
- On-device AI capabilities (native plugin for iOS/Android)

#### Non-responsibilities
- App UI, business logic, data access

#### Depends on
- audiflow_core

#### Used by
- audiflow_domain

---

### Module: audiflow_search

#### Responsibilities
- Podcast search and discovery API client
- Search result models (Freezed + JSON serializable)
- HTTP client configuration for search endpoints

#### Non-responsibilities
- Subscription management, feed parsing, UI

#### Depends on
- audiflow_core

#### Used by
- audiflow_domain

---

### Module: audiflow_cli

#### Responsibilities
- CLI tools for debugging domain and podcast features
- Feed parsing inspection, data exploration

#### Non-responsibilities
- Production app functionality

#### Depends on
- audiflow_domain, audiflow_podcast

#### Used by
- Developers only (not part of app build)

## Boundary rules

- `audiflow_core` must never import any other workspace package
- `audiflow_app` must never be imported by any other package
- Isar collection definitions live exclusively in `audiflow_domain`
- Reusable widgets (used by 2+ features) must live in `audiflow_ui`, not `audiflow_app`
- Cross-feature communication uses event streams in `audiflow_domain`, not direct provider coupling
- Repository interfaces and implementations are co-located in `audiflow_domain` (no separate interface package)

## When to update

Update when: packages added/removed, dependency direction changes, responsibility shifts between packages, new boundary rules established.
