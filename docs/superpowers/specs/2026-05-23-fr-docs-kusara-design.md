# Design: kusara-managed Functional Requirements docs for audiflow

> Establish `docs/fr/` as the canonical per-feature narrative layer for the audiflow Flutter app, extracted from existing specs/architecture/plans/codebase, and wire kusara so the doc cross-reference graph stays valid and prompts for doc updates when code changes.

## Goal

Ground the audiflow repository with AI-friendly Functional Requirements (FR) documents that future development can be invested against. FRs answer "what is this feature, why does it exist, how does it behave" in a single file per feature. kusara maintains the machine-checked cross-reference graph over those docs and surfaces doc-staleness prompts during normal development.

This adopts the pattern proven in `reedom/roki`: a `docs/fr/` directory of per-feature narrative files, kusara `refs:` frontmatter forming a graph, and a `PostToolUse` hook that runs `kusara validate` / `touched` after every edit and injects judgment prompts.

## Scope

In scope:

- A kusara kinds manifest (`docs/kinds.md`) declaring the doc kinds and their path globs.
- A full FR set (~16 files) under `docs/fr/`, extracted from current documentation and code.
- `refs:` frontmatter on existing `docs/architecture/`, `docs/integration/preset.md`, and the 7 package `CLAUDE.md` files.
- A `PostToolUse` hook (`.claude/hooks/refs-postedit.sh`) and a project rule (`.claude/rules/project/refs.md`) for doc-freshness automation.
- Migration of `docs/specs/` content into FRs, then deletion of `docs/specs/`.

Out of scope:

- `docs/superpowers/plans/` and `docs/superpowers/specs/` joining the graph. They remain plain Markdown and serve only as extraction sources.
- `docs/development/` and `docs/overview.md` joining the graph.
- Installing the kusara Claude plugin. That is an optional user action, noted in §6.
- Authoring requirements/design documents below the FR layer. FR carries the contract directly for now.

## Locations

All graph documents live at the **repository root** `docs/` directory. `KUSARA_DOC_ROOT=docs` (the default). kusara commands run from the repository root, not from `packages/audiflow_app`.

audiflow is a Melos monorepo with 8 packages. FRs use a single flat `docs/fr/` at the repo root; per-feature `modules:` entries point across packages (`packages/<pkg>/lib/features/<x>/`).

## kusara kinds manifest

`docs/kinds.md` declares these kinds:

| kind | path glob | index output | role |
|---|---|---|---|
| `fr` | `docs/fr/[0-9]*.md` | `docs/fr/index.md` | per-feature narrative |
| `architecture` | `docs/architecture/[a-z]*.md` | `docs/architecture/index.md` | design-of-record for code |
| `integration` | `docs/integration/*.md` | (none) | external integration contracts |
| `package` | `packages/*/CLAUDE.md` | `packages/index.md` | per-package surface docs |
| `index` | generated | — | reserved, written by `kusara index` |

ID grammar:

- `fr:NN-<slug>` — e.g. `fr:04-audio-playback`
- `arch:<slug>` — e.g. `arch:playback-pipeline`
- `integration:<slug>` — e.g. `integration:preset`
- `pkg:<name>` — e.g. `pkg:audiflow_domain`

`modules:` usage:

- FR files list the source directories implementing the feature (`packages/<pkg>/lib/features/<x>/`, plus relevant domain/core paths).
- `architecture` files list the source areas they are design-of-record for.
- `package` files list `packages/<name>/`.

`[0-9]*` and `[a-z]*` globs deliberately exclude `README.md` (uppercase) and `_template.md` (underscore) from graph membership, matching roki's convention. The generated `index.md` carries its own `kind: index` frontmatter and is matched separately.

## FR set

Flat layout `docs/fr/NN-<feature>.md`, plus `docs/fr/README.md` (layer explanation and update flow), `docs/fr/_template.md` (skeleton), and generated `docs/fr/index.md`.

Each FR follows the roki template sections: **Purpose**, **User-visible Behavior**, **Capabilities**, **Boundaries**, **Traceability**.

| File | Feature area | Primary extraction sources |
|---|---|---|
| `01-app-foundation.md` | bootstrap, flavor entry points, GoRouter tab navigation, adaptive nav shell | `docs/specs/foundation.md`, `docs/architecture/system-overview.md`, `docs/plans/2026-03-01-tablet-support-*`, codebase |
| `02-podcast-discovery.md` | podcast search, search-as-you-type, discovery API | `docs/superpowers/{plans,specs}/2026-03-22-search-as-you-type*`, `audiflow_search` |
| `03-subscription-feeds.md` | subscribe/unsubscribe, OPML import/export, feed management | `docs/plans/2026-02-15-opml-*`, `docs/specs/foundation.md` |
| `04-audio-playback.md` | playback, background audio, system controls, interruption behavior (duck / pause-and-rewind) | `docs/specs/playback-system.md`, `docs/architecture/playback-pipeline.md` |
| `05-download-and-queue.md` | episode download, download-all, queue management | `docs/specs/episode-management.md`, `docs/superpowers/{plans,specs}/2026-04-07-download-all-episodes-*` |
| `06-preset.md` | preset (smart playlist) config consumption, local caching, schema migration, matcher | `docs/specs/smart-playlist.md`, `docs/architecture/smart-playlist-cache.md`, `docs/integration/preset.md`, `docs/superpowers/**/2026-04-1*-schema-*`, `2026-04-14-schema-matcher-update` |
| `07-stations.md` | custom multi-podcast playlists (station v1 and v2) | `docs/superpowers/{plans,specs}/2026-03-20-station*`, `2026-04-05-station-v2*` |
| `08-transcript-chapters.md` | transcript and chapter display, text selection and copy | `docs/plans/2026-03-01-podcast-transcript-*`, `docs/superpowers/**/2026-04-07-text-selection-copy*` |
| `09-sleep-timer.md` | sleep timer (duration / episode-count / end-of-episode / end-of-chapter), fade-out | `docs/superpowers/{plans,specs}/2026-04-14-sleep-timer*` |
| `10-voice-commands.md` | on-device voice commands, pluggable intent, voice settings, debug overlay | `docs/superpowers/**/2026-03-2*-voice-*`, `2026-03-30-voice-debug-overlay*`, `audiflow_ai` |
| `11-play-order.md` | per-scope play order cascade, podcast sort order, auto play order | `docs/superpowers/**/2026-04-16-scope-level-play-order*`, `2026-04-04-podcast-sort-order*`, `docs/plans/2026-03-07-auto-play-order.md` |
| `12-background-refresh.md` | background feed refresh, dropped-episode cleanup, new-episode notifications | `docs/plans/2026-03-20-background-refresh-*`, `docs/superpowers/**/2026-04-02-per-episode-notification-*` |
| `13-library.md` | library screen, inline podcasts, year grouping | `docs/superpowers/**/2026-05-11-library-inline-podcasts*`, `2026-05-04-year-grouping-min-episodes*` |
| `14-settings.md` | settings page, developer preferences | `docs/plans/2026-02-14-settings-page*`, `docs/superpowers/{plans,specs}/2026-04-07-developer-preferences*` |
| `15-links-and-sharing.md` | universal links, share URL with timestamp | `docs/superpowers/**/2026-03-22-universal-links*`, `2026-04-17-share-url-timestamp*` |
| `16-app-lifecycle.md` | force-update, observability (Sentry, Google Analytics instrumentation) | `docs/superpowers/**/2026-05-04-force-update*`, `2026-05-18-google-analytics-instrumentation*`, `docs/plans/2026-02-23-sentry-integration.md` |

Notes on grouping decisions:

- FR boundaries follow **feature narrative**, not historical plan boundaries. Multiple plans/specs covering the same feature collapse into one FR (e.g. station v1 + v2 → `07-stations.md`).
- Visual/UI-polish plans (`image-color`, `episode-play-pill-redesign`, `play-button-content`, `voice-ui-redesign`) are folded into the FR of the feature they touch rather than getting their own FR — they are behavior refinements, not standalone features.
- The number `06` is `preset` (the feature formerly called "smart playlist"; renamed). The FR uses "preset" terminology throughout. Existing filenames `docs/architecture/smart-playlist-cache.md` and `docs/integration/preset.md` are left as-is; renaming files is out of scope for this effort.

## Freshness automation

### Hook

`.claude/hooks/refs-postedit.sh`, adapted from roki's `refs-postedit.sh`:

- Reads the Claude Code `PostToolUse` JSON payload from stdin, extracts `tool_input.file_path` and `tool_name`.
- Mechanical checks:
  - `*.md` edit → `kusara validate` (silent on clean `OK`).
  - source edit under `packages/*/lib/**` or `packages/*/test/**`, or `docs/kinds.md` → `kusara touched <file>`.
- Judgment-trigger excerpts injected via `hookSpecificOutput.additionalContext`:
  1. New `.md` file → how to pick a kind and add `refs:`.
  2. Source change under a `modules:` path → which doc kind (if any) to update.
  3. `docs/kinds.md` edit → glob/rename risk table.
  4. Existing graph-linked `.md` edited → `kusara show` output as a content-drift checklist.
- roki's "requirements.md / provides" trigger is **dropped** — audiflow has no `.kiro` spec layer.
- Never exits non-zero; purely informational. Falls back to a setup hint if the `kusara` binary is absent.

The hook is added as a **second** `PostToolUse` entry in the repo-root `.claude/settings.json`, alongside the existing `format-dart.sh` hook. The existing hook is not modified.

### Rule

`.claude/rules/project/refs.md` — judgment guidance the hook cannot mechanically decide (kind selection, doc-drift sweep decisions, kinds.md edit risks). Placed under `.claude/rules/project/` so it auto-loads with the other project rules. Adapted from roki's `.claude/rules/refs.md`, with `.kiro` references removed.

## Build order

1. **System scaffold** — `docs/kinds.md`, `docs/fr/_template.md`, `docs/fr/README.md`, `.claude/hooks/refs-postedit.sh`, `.claude/settings.json` update, `.claude/rules/project/refs.md`, and a minimal `packages/audiflow_ai/CLAUDE.md` (the only package currently missing one, required for a clean `package` glob).
2. **Annotate existing graph docs** — add `refs:` frontmatter to the 5 `docs/architecture/*.md` files, `docs/integration/preset.md`, and the 7 package `CLAUDE.md` files (8 after step 1 adds `audiflow_ai`).
3. **Author the 16 FRs** — extraction pass over `docs/specs/`, `docs/architecture/`, `docs/superpowers/**`, `docs/plans/`, and the codebase. Each FR gets `refs:` frontmatter with `modules:`.
4. **Migrate and finalize** — confirm all `docs/specs/` content is represented in FRs, delete `docs/specs/`, run `kusara index` (generates `docs/fr/index.md`, `docs/architecture/index.md`, `packages/index.md`) and `kusara validate` until clean.

## Validation

- `kusara validate` reports `OK (N docs)` with no dangling refs, duplicate IDs, unknown kinds, or missing-frontmatter files under a declared glob.
- `kusara index` regenerates all index files; re-running produces no diff.
- The `PostToolUse` hook fires on a test `.md` edit and a test source edit, producing expected `additionalContext`.
- No `docs/specs/` references remain elsewhere in the repo (CLAUDE.md files, other docs).
- `flutter analyze` remains clean (no code changes expected, but `audiflow_ai/CLAUDE.md` addition is verified harmless).

## Open questions

None. FR grouping (16 files), superpowers exclusion from the graph, and the `06-preset` rename were confirmed during brainstorming.
