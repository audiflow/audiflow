---
refs:
  id: fr:01-app-foundation
  kind: fr
  title: "App foundation"
  related:
    - arch:system-overview
  modules:
    - packages/audiflow_app/lib/app/
    - packages/audiflow_app/lib/routing/
    - packages/audiflow_app/lib/main.dart
    - packages/audiflow_app/lib/features/onboarding/
---
# FR 01: App foundation

> The startup, navigation shell, flavor configuration, and onboarding that every other feature is built on top of.

## Purpose

Every feature in the audiflow podcast player needs a running app process, an open local database, a configured set of shared services, and a way for the user to move between the major areas of the app. This FR covers that foundation: the work that happens between the user tapping the app icon and the first interactive screen appearing.

The foundation exists so feature code never has to worry about how the app boots, which environment it runs in, or how navigation is wired. It guarantees that by the time a screen mounts, the database is open, audio controls are ready, the last-played episode has been restored into the mini player, and the user is on the correct tab. It also gives first-time users a guided introduction before they reach the main app.

## User-visible Behavior

- **Normal launch**: The app starts, opens its local database, restores any partially played episode into the mini player, and lands the user on one of four tabs — Search, Library, Queue, or Settings. The app reopens on whichever tab the user last used (Search, Library, or Queue; Settings is not remembered as a launch tab).
- **First launch**: A new user is redirected to an onboarding carousel before reaching the main app. Once they finish, the onboarding-completed flag is persisted, and subsequent launches skip straight to the main app. A returning user can never accidentally land back on the onboarding screen.
- **Switching tabs**: Each tab keeps its own navigation history. Moving from a deep screen in Library over to Search and back returns the user exactly where they left off in Library — no tab resets another tab's stack.
- **Tablet layout**: On a phone the app is portrait-only with a bottom navigation bar. On a tablet it also allows landscape; tablet portrait shows a top tab bar and tablet landscape shows a persistent side navigation rail. The four destinations and the mini player remain available in every layout.
- **Cold start from a notification**: If the app is launched by tapping a new-episode notification, after boot it navigates directly to the relevant episode instead of the default tab.
- **Database recovery**: If the local database fails to open because its schema is stale, the app recovers by recreating the database rather than crashing. Genuinely unrecoverable open failures are reported to crash monitoring.
- **Unknown route**: Navigating to a route the app does not recognise quietly redirects to the Search tab instead of showing an error.

## Capabilities

- **Flavor entry points**: Three entry points — development, staging, and production — each select a flavor configuration that controls environment-specific behavior such as analytics, crash reporting, HTTP tracing, and which smart playlist config source to read.
- **Bootstrap sequence**: A single ordered startup path initializes the Flutter binding and flavor config, opens the local database (with schema-mismatch recovery), constructs shared infrastructure (HTTP client, cache directory, preferences, package info), builds the root service container, starts the background audio handler, restores the last-played episode, fetches and reconciles the smart playlist config cache, schedules background feed refresh, and finally renders the app.
- **Root service container**: A single application-wide container supplies shared dependencies to all feature code, so features depend on stable provider seams rather than constructing their own database, HTTP client, or analytics services.
- **Tab navigation**: Four top-level destinations — Search, Library, Queue, Settings — each backed by an independent navigation stack so per-tab history is preserved across tab switches.
- **Adaptive navigation shell**: One shell renders the appropriate navigation chrome for the device — bottom bar on phones, top tab bar on tablet portrait, side rail on tablet landscape — while keeping the same destinations and mini player in all three.
- **Orientation policy**: Phones are locked to portrait; tablets are allowed all orientations, decided once at startup from the device's shortest screen side.
- **Onboarding gate**: A router-level redirect sends first-time users through an onboarding carousel and persists a completion flag so the gate fires exactly once per install.
- **Non-blocking startup work**: Best-effort tasks — stale-podcast cache eviction, background refresh registration, last-played restore — are tolerant of failure and never block or abort the app launch.

## Boundaries

- **Not feature behavior**: This FR covers how features are reached and bootstrapped, not what they do. Search, playback, downloads, stations, transcripts, and settings each have their own FR.
- **Not business logic**: No repositories, data sources, or domain services live here. Those belong to `audiflow_domain`.
- **Not background execution**: The foundation registers the background feed-refresh task at startup, but the periodic refresh, episode-drop cleanup, and new-episode notifications are a separate feature.
- **Not the smart playlist contract**: The foundation triggers the initial config fetch and cache reconciliation; the config schema and consumption contract are owned elsewhere.
- **Not implementation detail**: Provider wiring, container overrides, and database collection structure are architecture concerns documented under `docs/architecture/`, not restated here.

## Traceability

- **Source docs**: `docs/specs/foundation.md`, `docs/architecture/system-overview.md`, `docs/plans/2026-03-01-tablet-support-plan.md`, `docs/plans/2026-03-01-tablet-support-design.md`, `packages/audiflow_app/CLAUDE.md`, `packages/audiflow_app/lib/main.dart`, `packages/audiflow_app/lib/routing/app_router.dart`
- **Related FR**: none yet (other FRs cover the individual features reached through this foundation)
