---
refs:
  id: fr:14-settings
  kind: fr
  title: "Settings and developer preferences"
  related:
    - fr:10-voice-commands
  modules:
    - packages/audiflow_app/lib/features/settings/
    - packages/audiflow_domain/lib/src/features/settings/
---

# FR 14: Settings and developer preferences

> A category-organized settings surface that hosts every user preference in the app, plus a dedicated developer section for inspecting the smart playlist ecosystem.

## Purpose

Audiflow has many tunable behaviors — playback speed, skip durations, download policy, feed sync cadence, analytics consent, play order — and each of these needs a stable, discoverable home. The settings feature exists to give users a single predictable place to find and change every preference, and to give the rest of the app a single persistence-backed source of truth for those preferences so that services no longer rely on hard-coded values.

It also serves a secondary audience: audiflow contributors and podcast creators. A developer section surfaces the smart playlist (preset) ecosystem — which presets exist, where they live in the GitHub repo, and how a given podcast's RSS feed maps to a preset — so that anyone wanting to understand or contribute to that ecosystem can do so from inside the app.

## User-visible Behavior

- Normal case: The user opens the Settings tab and sees a responsive grid of category cards (Appearance, Playback, Downloads, Feed Sync, Storage & Data, About, Getting Started, Privacy, Developer). Tapping a card drills into a detail screen with the relevant controls. Each control applies its change immediately — there is no save button — and the new value persists across app restarts.
- Appearance, Playback, Downloads, and Feed Sync detail screens present toggles, dropdowns, sliders, and segmented buttons. Changing theme mode or text size updates the app's look immediately; a language change shows a restart-recommended notice.
- The Storage & Data screen reports cache and database size, offers cache and search-history clearing with confirmation dialogs, exposes OPML import/export, and gates a destructive "reset all data" action behind a double confirmation. When Restricted Mode (FR 18) is on, the reset action is additionally PIN-gated, since the reset would otherwise wipe the parental PIN hash and provide a bypass.
- The Developer screen lists every smart playlist preset (pull-to-refresh fetches a fresh copy), links each to its versioned directory in the preset GitHub repo, offers a contribute link to the repo root, and carries a toggle that, when enabled, reveals an RSS-feed-URL and preset-link block at the bottom of episode detail screens.
- Edge / failure case: A preferences write that fails to persist (disk error) does not update the in-memory value, so the displayed state never diverges from what was actually stored. Preset links are disabled until the schema version has been seeded. External links that fail to launch are reported rather than crashing.
- Recovery / fallback: Every preference falls back to a defined default value when nothing has been stored yet. "Reset all data" restores all settings to their defaults alongside clearing the database and caches.

## Capabilities

- Presents all preferences as a navigable grid of category cards drilling into per-category detail screens, adapting column count to available width.
- Persists every preference through a single `AppSettingsRepository` backed by SharedPreferences, with synchronous getters that return the stored value or a defined default and asynchronous setters that persist changes.
- Acts as the source of truth that feature services read instead of hard-coded constants (sync interval, completion threshold, skip durations, download concurrency, Wi-Fi policy, and similar).
- Hosts general preferences directly: appearance (theme mode, locale, text scale), playback tuning, download policy, feed sync cadence, new-episode notifications, search country, last-selected tab, and privacy/analytics opt-in.
- Provides a Storage & Data screen for cache and database inspection, search-history clearing, OPML import/export, and a guarded full-reset action.
- Provides an About screen showing version and build, open-source licenses, feedback, and app-store rating links.
- Provides a Developer screen that browses all smart playlist presets, links them to their versioned GitHub repo directories, and exposes a persisted toggle controlling developer info in episode detail.

## Boundaries

- This FR covers the settings surface itself plus the general and developer preferences. Feature-specific preference sections are owned by their own FRs and are only cross-referenced here: play-order preferences belong to FR 11 (play order), audio-interruption preferences belong to FR 04 (audio playback), download and queue policy semantics belong to FR 05, and background feed refresh behavior belongs to FR 12.
- Settings does not implement the behaviors it configures — it only stores and exposes the values; the consuming services apply them.
- Settings does not define the smart playlist schema or host preset config data; the Developer screen only reads and links to that externally-owned ecosystem.
- OPML import/export, cache clearing, and data reset delegate the actual work to the relevant domain repositories; the Storage screen is the entry point, not the implementation.

## Traceability

- **Source docs**: `docs/plans/2026-02-14-settings-page.md`, `docs/plans/2026-02-14-settings-page-design.md`, `docs/superpowers/plans/2026-04-07-developer-preferences.md`, `docs/superpowers/specs/2026-04-07-developer-preferences-design.md`
- **Source code**: `packages/audiflow_app/lib/features/settings/`, `packages/audiflow_domain/lib/src/features/settings/`
- **Related FR**: `10-voice-commands.md` (historical spec only — voice commands were removed and are not implemented; no voice settings exist in this surface)
