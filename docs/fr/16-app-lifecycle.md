---
refs:
  id: fr:16-app-lifecycle
  kind: fr
  title: "App lifecycle, updates and observability"
  related:
    - fr:01-app-foundation
  modules:
    - packages/audiflow_app/lib/features/force_update/
    - packages/audiflow_app/lib/features/monitoring/
    - packages/audiflow_app/lib/features/review_prompt/
    - packages/audiflow_domain/lib/src/features/force_update/
    - packages/audiflow_domain/lib/src/features/monitoring/
    - packages/audiflow_domain/lib/src/features/review_prompt/
---

# FR 16: App lifecycle, updates and observability

> Remote-controlled version gating, anonymous error and usage observability, and an in-app store-review prompt — the cross-cutting concerns that keep shipped builds healthy and measurable.

## Purpose

A shipped mobile app is no longer under the team's direct control: stale builds keep running in the wild, failures happen on devices the team never sees, and the team has little signal about which features people actually use. This feature bundles the three lifecycle concerns that address that gap.

The **force-update gate** gives the team a remote kill-switch. Critical bugs, breaking schema changes (for example a smart playlist config schema bump), or backend outages may require the app to refuse to run on out-of-date builds, nudge users toward a newer release, or display a maintenance message — all without shipping a new binary. **Observability** (Sentry crash reporting plus Google Analytics usage instrumentation) gives the team eyes on production: which builds crash, where, and which podcast-app workflows are exercised. The **review prompt** asks engaged listeners to rate the app at a natural moment, improving store ranking without nagging. All three are anonymous-by-design: no accounts, no PII, only a per-install UUID that ties a crash report to its usage trail.

## User-visible Behavior

- **Normal case (up-to-date app)**: The force-update gate fetches its config at cold start, finds the installed version is current, and mounts the app transparently. The user sees nothing. Sentry and Analytics run silently in the background.
- **Soft update available**: When the installed version is at or above the minimum but below the recommended version, the app runs normally with a dismissible banner pinned below the app bar. The banner offers "Update" (opens the store or a custom URL) and "Later" (dismisses for the current session; it reappears on the next cold start). No persistent per-version skip list is kept.
- **Hard update required**: When the installed version is below the configured minimum, the app shows a full-screen blocking splash before the router ever mounts — no app bar, no back gesture, no dismissal. A single primary "Update now" button opens the store; on Android a secondary "Quit" button is offered (hidden on iOS, where the platform guidelines forbid programmatic exit).
- **Maintenance mode**: When the remote config flags maintenance, the same full-screen splash appears regardless of installed version, with a "Retry" button that re-checks the config instead of opening the store.
- **Foreground resume**: If the app has been backgrounded long enough that its cached decision is stale, returning to the foreground triggers a background config refresh. A user who has been sitting in the soft-banner state can transition to the hard splash if the server escalates the rule.
- **Failure / offline case**: On a first launch where the config fetch fails and nothing is cached, the app fails open and runs normally — a transient outage must never brick a fresh install. Once the app has seen a blocking config, that decision is honored from cache even offline, so toggling airplane mode cannot bypass a hard block.
- **Review prompt**: After a listener has accumulated enough total listening time, a modal dialog appears shortly after playback begins, asking them to rate the app. It offers "Rate now" (opens the store listing), "Later", and "Don't ask again". The dialog only appears while the app is in the foreground; a trigger that fires in the background is dropped and re-armed on the next playback session. Choosing "Rate now" or "Don't ask again" ends the auto-prompt permanently.
- **Analytics opt-out**: A "Share usage data" toggle in Settings lets the user turn usage-event collection off. It is on by default; crash reporting is independent of it.

## Capabilities

- **Remote version gating**: Fetches a single global config (minimum version, recommended version, maintenance flag, message key) from environment-specific static JSON hosting and evaluates it against the installed version into a no-update / soft / hard / maintenance decision.
- **Fail-open-then-closed caching**: Persists the last good config so decisions survive offline use; fails open when nothing has ever been fetched, but honors a previously seen blocking decision even without connectivity. Corrupt caches, unsupported config schema versions, and invariant violations are dropped and reported.
- **Localized, overridable messaging**: Resolves update and maintenance copy from localized message keys (en / ja) with fallback to a default key for unknown server-supplied keys, and supports an ad-hoc per-language message override embedded in the config. Update destination resolves to a custom URL when provided, otherwise the platform store.
- **Crash and error reporting**: Wires Sentry across all flavors for unhandled exceptions and zone errors, with HTTP request tracing enabled for dev and staging only. The force-update feature additionally records breadcrumbs and exceptions through a thin Sentry seam covering fetch failures, parse failures, schema mismatches, and decision transitions.
- **Anonymous usage instrumentation**: Sends Google Analytics 4 events for podcast-app workflows — discovery, subscription, playback, download, smart playlist, station, search, and sleep timer — with cross-user-stable podcast/episode identifiers and event-scoped title dimensions. High-frequency pause and seek events are throttled. All ad signals are disabled.
- **Shared anonymous identity**: Generates and persists an install-scoped UUID, applied as both the Sentry user id (and an `install_id` tag) and the Analytics user id, so a crash report can be correlated with the same install's usage trail without any personal data.
- **Usage opt-out and flavor gating**: A SharedPreferences-backed Settings toggle controls analytics collection at the SDK boundary; a flavor flag gates whether the analytics SDK initializes at all.
- **Store-review prompting**: Accumulates real content-listening time (unaffected by playback speed), and once a milestone threshold is reached arms a one-shot, foreground-only prompt after playback starts. The prompt has a terminal state — once the user rates or opts out it never reappears.

## Boundaries

- This feature does **not** cover general app bootstrap — Riverpod container setup, Isar/Dio/SharedPreferences wiring, audio handler init, and router construction belong to FR 01 (App foundation). FR 16 only adds the pre-router force-update gate and the bootstrap-time identity and SDK initialization.
- It does **not** define the force-update config schema or host the config data — those are owned externally; the app only consumes a static JSON document at a build-time-injected URL.
- It does **not** perform in-app update downloads. "Update now" hands off to the platform store or a custom URL; it never installs an update itself.
- It does **not** apply per-platform, per-build, or staged-rollout version rules; the remote config is a single global rule set.
- It does **not** capture authenticated identity (the app has no accounts), advertising or attribution signals, screen recordings, or raw search query text — only a query length is recorded.
- It does **not** route expected user-facing errors (form validation, normal empty states) to Sentry; those stay in the UI layer.
- The review prompt does **not** track wall-clock time or replace the manual "Rate the app" entry in Settings; it is the automatic counterpart to it.

## Traceability

- **Source docs**:
  - `docs/superpowers/plans/2026-05-04-force-update.md`
  - `docs/superpowers/specs/2026-05-04-force-update-design.md`
  - `docs/superpowers/plans/2026-05-18-google-analytics-instrumentation.md`
  - `docs/superpowers/specs/2026-05-18-google-analytics-instrumentation-design.md`
  - `docs/plans/2026-02-23-sentry-integration.md`
  - Source inspected: `packages/audiflow_app/lib/features/force_update/`, `packages/audiflow_app/lib/features/monitoring/`, `packages/audiflow_app/lib/features/review_prompt/`, `packages/audiflow_domain/lib/src/features/force_update/`, `packages/audiflow_domain/lib/src/features/monitoring/`, `packages/audiflow_domain/lib/src/features/review_prompt/`
- **Related FR**: `01-app-foundation.md`
