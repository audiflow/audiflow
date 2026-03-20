# Overview: audiflow_app

## Purpose

`audiflow_app` is the presentation layer of the Audiflow podcast player. It owns all user-facing screens, Riverpod controllers, navigation routing, and app lifecycle management. It delegates all business logic and data access to `audiflow_domain`, and all shared visual components to `audiflow_ui`.

This package is the Flutter application target -- it contains `main_*.dart` entry points, platform configurations (Android/iOS/macOS), and build flavor setup.

## Responsibilities

- App bootstrap: Isar database opening, Dio client creation, ProviderContainer assembly
- Three flavor entry points (dev, stg, prod) with distinct smart playlist config base URLs
- GoRouter navigation with four tab branches and nested detail routes
- Adaptive navigation shell for phone and tablet form factors
- Feature-specific screens and Riverpod controllers
- Audio handler initialization (`AudiflowAudioHandler` wrapping `just_audio` + `audio_service`)
- Last-played episode restore for mini player on cold start
- Background feed refresh via Workmanager
- Localization (English, Japanese) via Flutter gen-l10n
- OPML file import interception via `OpmlFileReceiver` (app_links)
- App lifecycle feed sync (force on launch, conditional on resume)
- Cache eviction of stale non-subscribed podcasts at startup

## Non-responsibilities

- Repository interfaces and implementations (owned by `audiflow_domain`)
- Isar collections and data models (owned by `audiflow_domain`)
- Reusable widgets, themes, color scheme (owned by `audiflow_ui`)
- RSS feed parsing (owned by `audiflow_podcast`)
- Core config, extensions, error types (owned by `audiflow_core`)
- Smart playlist schema and authoring (owned by external editor repo)

## Main concepts

- **Flavor**: Build variant (dev/stg/prod) that determines the smart playlist config base URL and Sentry settings. Defined in `audiflow_core` as `Flavor` enum; selected in `main_dev.dart`, `main_stg.dart`, `main_prod.dart`.
- **Feature module**: A directory under `lib/features/{name}/presentation/` containing controllers, screens, and widgets for one user-facing concern.
- **StatefulShellRoute.indexedStack**: GoRouter pattern that gives each tab its own navigator stack, preserving scroll position and sub-navigation state when switching tabs.
- **ScaffoldWithNavBar**: Adaptive shell widget that renders bottom NavigationBar (phone), top tab bar (tablet portrait), or NavigationRail (tablet landscape).
- **AnimatedMiniPlayer**: Slide-in mini player positioned above the bottom navigation bar. Taps open a full-screen `PlayerScreen` via `showCupertinoSheet`.

## Entry points

| File | Purpose |
|------|---------|
| `lib/main.dart` | Shared `appMain()` function: binds Flutter, opens Isar, creates Dio, builds ProviderContainer, initializes audio handler, restores last-played, registers background tasks, runs `MyApp` |
| `lib/main_dev.dart` | Calls `appMain(flavor: Flavor.dev)` with default dev config base URL |
| `lib/main_stg.dart` | Calls `appMain(flavor: Flavor.stg)` with staging config base URL |
| `lib/main_prod.dart` | Calls `appMain(flavor: Flavor.prod)` with production config base URL |

## Feature modules

| Feature | Directory | Screens | Key controllers |
|---------|-----------|---------|-----------------|
| search | `features/search/` | `SearchScreen` | `SearchController` (manages query + results state) |
| library | `features/library/` | `LibraryScreen`, `SubscriptionsListScreen` | `LibraryController`, `ContinueListeningController` |
| podcast_detail | `features/podcast_detail/` | `PodcastDetailScreen`, `EpisodeDetailScreen`, `SmartPlaylistEpisodesScreen`, `SmartPlaylistGroupEpisodesScreen` | `PodcastDetailController`, `PodcastViewModeController`, `SmartPlaylistSortController` |
| player | `features/player/` | `PlayerScreen`, `TranscriptScreen` | `AudiflowAudioHandler` (audio_service bridge) |
| queue | `features/queue/` | `QueueScreen` | `QueueController` |
| download | `features/download/` | `DownloadManagementScreen` | `DownloadManagementController` |
| settings | `features/settings/` | `SettingsScreen`, `AppearanceSettingsScreen`, `PlaybackSettingsScreen`, `DownloadsSettingsScreen`, `FeedSyncSettingsScreen`, `StorageSettingsScreen`, `AboutScreen`, `OpmlImportPreviewScreen` | `ThemeController`, `TextScaleController`, `OpmlExportController`, `OpmlImportController`, `OpmlFileReceiverController` |
| station | `features/station/` | `StationDetailScreen`, `StationEditScreen` | `StationDetailController`, `StationEditController`, `StationListController` |
| subscription | `features/subscription/` | (no screens) | `SubscriptionController` |
| voice | `features/voice/` | (no screens, overlay widget) | `VoiceCommandController` |

## Routing structure

The router is defined in `lib/routing/app_router.dart` via `createAppRouter()`. It uses `StatefulShellRoute.indexedStack` with four branches. The initial location is `/search`.

```
/ (StatefulShellRoute.indexedStack -> ScaffoldWithNavBar)
  /search                           -> SearchScreen
    /search/podcast/:id             -> PodcastDetailScreen
      .../smart-playlist/:playlistId -> SmartPlaylistEpisodesScreen
        .../group/:groupId          -> SmartPlaylistGroupEpisodesScreen
      .../episode/:episodeGuid      -> EpisodeDetailScreen
  /library                          -> LibraryScreen
    /library/podcast/:id            -> PodcastDetailScreen (+ same nested routes)
    /library/station/new            -> StationEditScreen (create)
    /library/station/:stationId     -> StationDetailScreen
      .../edit                      -> StationEditScreen (edit)
    /library/subscriptions          -> SubscriptionsListScreen
      .../podcast/:id               -> PodcastDetailScreen (+ same nested routes)
  /queue                            -> QueueScreen
  /settings                         -> SettingsScreen
    /settings/appearance            -> AppearanceSettingsScreen
    /settings/playback              -> PlaybackSettingsScreen
    /settings/downloads             -> DownloadsSettingsScreen
      .../management                -> DownloadManagementScreen
    /settings/feed-sync             -> FeedSyncSettingsScreen
    /settings/storage               -> StorageSettingsScreen
    /settings/about                 -> AboutScreen
/transcript (root navigator, full-screen) -> TranscriptScreen
```

Route data is passed via `GoRouterState.extra` as typed objects or `Map<String, dynamic>`. Each builder function validates the extra data and falls back to a "not found" screen if required parameters are missing.

## Localization

- ARB source files: `lib/l10n/app_en.arb` (English, template), `lib/l10n/app_ja.arb` (Japanese)
- Configuration: `l10n.yaml` at package root
- Generated output: `lib/l10n/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_ja.dart`
- Access pattern: `AppLocalizations.of(context).keyName`
- Locale resolution: matches device locale to `supportedLocales`; falls back to first supported locale (English)

## App bootstrap sequence

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `FlavorConfig.initialize()` from flavor enum
3. Sentry initialization (if enabled and DSN present)
4. Device orientation configuration (portrait-only on phones, all orientations on tablets)
5. Isar database open with all collection schemas
6. Dio HTTP client creation with timeouts
7. `ProviderContainer` creation with overrides for Isar, Dio, cache dir, SharedPreferences, PackageInfo, smart playlist config base URL
8. Audio handler initialization (`audioHandlerProvider`)
9. Last-played episode restore into `NowPlayingController`
10. Smart playlist root meta fetch and cache reconciliation
11. Background feed refresh registration via Workmanager (if auto-sync enabled)
12. Cache eviction (fire-and-forget)
13. `runApp()` with `UncontrolledProviderScope` wrapping `AppLifecycleObserver` and `MyApp`

## Key dependencies

| Dependency | Role in this package |
|------------|---------------------|
| `flutter_riverpod` | `UncontrolledProviderScope`, `ConsumerWidget`/`ConsumerStatefulWidget` in all screens |
| `go_router` | `GoRouter`, `StatefulShellRoute`, `GoRoute` for all navigation |
| `audio_service` | `BaseAudioHandler` subclass for platform media controls |
| `just_audio` | `AudioPlayer` instance used by `AudiflowAudioHandler` |
| `sentry_flutter` | Error tracking initialization in `appMain()` |
| `workmanager` | Periodic background feed refresh registration |
| `app_links` | OPML file URI interception in `OpmlFileReceiverController` |
| `audiflow_domain` | All repositories, services, models, providers |
| `audiflow_ui` | Shared widgets, themes |
| `audiflow_core` | `FlavorConfig`, `Flavor`, `DeviceUtils`, extensions |

## Read next

- Parent repo `docs/architecture/system-overview.md` -- full system architecture
- Parent repo `docs/architecture/module-boundaries.md` -- package dependency rules
- Parent repo `docs/integration/smartplaylist.md` -- smart playlist config consumption

## When to update

Update this document when:
- A new feature module is added under `lib/features/`
- Routes are added or restructured in `app_router.dart`
- A new localization language is added
- The bootstrap sequence changes (new provider overrides, new initialization steps)
- Navigation shell layout changes (new form factor support)
- New external dependencies are added that affect app-level behavior
