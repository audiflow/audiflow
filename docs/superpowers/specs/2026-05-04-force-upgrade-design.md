# Force Upgrade

Remote-controlled minimum/recommended version enforcement and maintenance mode for the Audiflow app.

## Problem

Critical bugs, breaking schema changes (e.g., smartplaylist v6→v7), or backend outages may require the app to refuse to run on stale builds, nudge users to update, or display a maintenance message. Today the app has no remote kill-switch or version gate.

## Scope

- Remote-fetched config (single global rule set, not per-platform)
- Hard block (modal splash, no dismiss) below `minVersion`
- Soft nudge (dismissible banner) below `recommendedVersion`
- Maintenance mode (full-screen splash, ignores version)
- Localized message via i18n keys with optional ad-hoc override
- Optional custom update URL with platform-store fallback
- Cold-start fetch + foreground-resume refresh

Out of scope: per-platform thresholds, per-build exclusions, staged rollout %, A/B targeting, push-triggered refresh, in-app update download (iOS lacks this; Android `in_app_update` deferred).

## Architecture

Feature module under `packages/audiflow_app/lib/features/force_update/`. Reuses existing Dio, `package_info_plus`, `shared_preferences`, Riverpod, intl. No new top-level dependencies beyond what already ships in the app.

```
packages/audiflow_app/lib/features/force_update/
├── data/
│   ├── force_update_config.dart              # Freezed model + fromJson
│   ├── force_update_remote_data_source.dart  # Dio fetch
│   ├── force_update_local_data_source.dart   # SharedPreferences cache
│   └── force_update_repository.dart          # Coordinates remote + cache
├── domain/
│   ├── update_decision.dart                  # Sealed: None | Soft | Hard | Maintenance
│   └── force_update_evaluator.dart           # Pure fn: (config, currentVersion) -> Decision
├── presentation/
│   ├── force_update_controller.dart          # Riverpod async controller
│   ├── force_update_gate.dart                # Wraps router; renders splash if Hard/Maintenance
│   ├── force_update_banner.dart              # Soft banner widget (used in shell)
│   └── force_update_screen.dart              # Full-screen hard/maintenance splash
├── constants.dart
└── force_update.dart                         # Barrel
```

## Config Schema

Hosted as static JSON on GitHub Pages, separate from the smartplaylist endpoint. URL is environment-specific, injected via `--dart-define=FORCE_UPDATE_CONFIG_URL=...` from `.env.dev` / `.env.stg` / `.env.prod`.

```json
{
  "schemaVersion": 1,
  "minVersion": "2.0.0",
  "recommendedVersion": "2.1.0",
  "maintenanceMode": false,
  "messageKey": "default",
  "messageOverride": null,
  "updateUrl": null
}
```

| Field | Type | Required | Purpose |
|---|---|---|---|
| `schemaVersion` | int | yes | Client rejects unknown future schemas (treats as no-op, fail-open) |
| `minVersion` | semver | yes | App version below this → hard block |
| `recommendedVersion` | semver | yes | App version below this (and at-or-above `minVersion`) → soft banner |
| `maintenanceMode` | bool | yes | True → maintenance splash; takes precedence over version checks |
| `messageKey` | string | yes | i18n key suffix (e.g. `security_critical`, `breaking_change`, `maintenance`, `default`) |
| `messageOverride` | nullable `{en: string, ja: string}` | no | Ad-hoc override; trumps key when present |
| `updateUrl` | nullable string | no | Custom URL (TestFlight, web). Null → platform store deeplink fallback |

Invariants enforced at parse time: `minVersion <= recommendedVersion`. Violation → drop config, log to Sentry, fail-open.

## Hosting

New repo `audiflow/audiflow-app-config` (or new path within an existing config repo — coordinate with smartplaylist hosting). Path convention:

- `https://<host>/audiflow-app-config/v1/app_config.json` (prod)
- `https://<host>/audiflow-app-config/v1/app_config.dev.json` (dev)
- `https://<host>/audiflow-app-config/v1/app_config.stg.json` (stg)

Edit by PR; merge → GH Pages deploy. CDN cache TTL short (e.g., 5 min) so emergency rollouts propagate.

## Decision Evaluator

Pure function, no I/O, fully unit-testable.

```dart
sealed class UpdateDecision {
  const UpdateDecision();
}
class NoUpdate extends UpdateDecision { const NoUpdate(); }
class SoftUpdate extends UpdateDecision {
  final String messageKey;
  final Map<String, String>? messageOverride;
  final String? updateUrl;
  const SoftUpdate({...});
}
class HardUpdate extends UpdateDecision { /* same fields */ }
class Maintenance extends UpdateDecision { /* same fields */ }

UpdateDecision evaluate({
  required ForceUpdateConfig config,
  required Version currentVersion,
}) {
  if (config.maintenanceMode) return Maintenance(...);
  if (currentVersion < config.minVersion) return HardUpdate(...);
  if (currentVersion < config.recommendedVersion) return SoftUpdate(...);
  return const NoUpdate();
}
```

Use `pub_semver` (already transitively available; verify and add explicitly if not) for semver comparison.

## Data Flow

1. **App boot** (`main.dart` after Riverpod container init, before router):
   - `forceUpdateControllerProvider` triggers initial fetch.
   - Controller asks repository for current decision.
2. **Repository.refresh()**:
   - Fetch via Dio with 5s timeout.
   - On 200 + valid JSON + valid `schemaVersion`: persist to cache (`SharedPreferences` key `force_update_config_v1` + `force_update_last_fetch_at`), return parsed config.
   - On any failure (network, parse, schema mismatch): return cached config if any; else null.
3. **Evaluator** runs against (config, `package_info_plus` current version) → `UpdateDecision`.
4. **`ForceUpdateGate` widget** (wraps `MaterialApp.router`):
   - `Maintenance` or `HardUpdate` → render `ForceUpdateScreen`, do not mount router.
   - `SoftUpdate` → mount router; soft banner injected via app shell.
   - `NoUpdate` → mount router transparently.
5. **Foreground resume** (via `WidgetsBindingObserver` in controller):
   - If `forceUpdateRefreshInterval <= (now - lastFetchAt)` → trigger background refresh; UI reacts to new decision (e.g., user has been in soft state for hours, server flips to hard → splash takes over).

## Fail Behavior

| Situation | Behavior |
|---|---|
| First launch, fetch fails, no cache | Fail-open: `NoUpdate`, app runs normally. Log to Sentry. |
| Fetch fails, cache exists | Use cached config. Decision honors cache (e.g., cached `HardUpdate` blocks even offline). |
| Cache deserialization fails | Discard cache, treat as no-cache. Log to Sentry. |
| `schemaVersion` newer than client supports | Fail-open: `NoUpdate`, log to Sentry. (Future client must handle older schemas it doesn't recognize.) |
| Invariant violation (`recommendedVersion < minVersion`) | Drop config, fail-open, log to Sentry. |

Rationale: bricking users on first launch by a transient outage is unacceptable. Once the client has seen a "block" config, it must honor it offline so an attacker/user can't bypass by toggling airplane mode.

## UI States

### Hard Update Splash (`ForceUpdateScreen` in hard mode)

- Full-screen, no app bar, no back button, no system gesture dismiss.
- App icon + title (i18n: `forceUpdate.<messageKey>.title`, fallback to `forceUpdate.default.title`).
- Body text (i18n: `forceUpdate.<messageKey>.body`, fallback `forceUpdate.default.body`). If `messageOverride` present, use override instead.
- Single primary button: "Update now" → `url_launcher` opens `updateUrl ?? platformStoreUrl()`.
- Secondary "Quit" button on Android (Android allows app exit; iOS HIG forbids — hide on iOS).

### Maintenance Splash

- Same `ForceUpdateScreen`, different title/body keys (`forceUpdate.maintenance.*`).
- "Update now" replaced with "Retry" button → triggers manual refresh of config.
- No quit button.

### Soft Banner (`ForceUpdateBanner`)

- Material banner pinned at top of app shell (under existing app bar) when decision = `SoftUpdate`.
- Text: `forceUpdate.<messageKey>.softBody` (or default).
- Two actions: "Update" (opens URL), "Later" (dismiss for this app session; reappears next cold start).
- Dismissed state stored in-memory only — no persistent skip list per version.

### Update URL Resolution

```dart
Future<Uri> resolveUpdateUrl(String? configUrl) async {
  if (configUrl != null) return Uri.parse(configUrl);
  if (Platform.isIOS) return Uri.parse('https://apps.apple.com/app/idAUDIFLOW_APP_ID');
  if (Platform.isAndroid) return Uri.parse('market://details?id=AUDIFLOW_PACKAGE_NAME');
  throw UnsupportedError('platform');
}
```

App ID / package name pulled from existing build config — confirmed during plan phase.

## Localization

New keys in `packages/audiflow_app/lib/l10n/app_en.arb` and `app_ja.arb`. Keys grouped under `forceUpdate.*`:

- `forceUpdate.default.title` / `.body` / `.softBody`
- `forceUpdate.security_critical.title` / `.body` / `.softBody`
- `forceUpdate.breaking_change.title` / `.body` / `.softBody`
- `forceUpdate.os_drift.title` / `.body` / `.softBody`
- `forceUpdate.maintenance.title` / `.body`
- `forceUpdate.actions.updateNow` / `.later` / `.retry` / `.quit`

Key resolution: `forceUpdate.<messageKey>.title` → fallback `forceUpdate.default.title` if key missing. (Older client + newer server `messageKey` must not crash.)

`messageOverride` map, when present, bypasses keys entirely. Picks `override[locale.languageCode] ?? override['en']`.

## Constants & Configuration

```dart
// packages/audiflow_app/lib/features/force_update/constants.dart
const forceUpdateRefreshInterval = Duration(hours: 6);
const forceUpdateFetchTimeout = Duration(seconds: 5);
const forceUpdateCacheKey = 'force_update_config_v1';
const forceUpdateLastFetchKey = 'force_update_last_fetch_at';
const forceUpdateConfigUrlEnv = 'FORCE_UPDATE_CONFIG_URL';
```

Add `FORCE_UPDATE_CONFIG_URL` to each `.env.{dev,stg,prod}` file. Wire through existing `--dart-define-from-file` build flow.

## Sentry Instrumentation

Breadcrumbs / events for:

- Fetch failure (with status code, error type)
- Parse failure (with truncated payload)
- Schema mismatch (`schemaVersion` value)
- Invariant violation
- Decision transitions (NoUpdate → Soft, → Hard, → Maintenance) — for ops visibility

No PII; config is global and public.

## Testing

| Layer | Test |
|---|---|
| Evaluator (pure) | Unit: each decision branch (none, soft, hard, maintenance, edge cases at version boundaries) |
| Repository | Unit with fake remote + fake local: success, network fail with cache, network fail no cache, parse fail, schema mismatch, invariant violation |
| Local data source | Unit: round-trip serialization, corrupt cache discarded |
| Controller | Riverpod test: initial fetch, foreground refresh trigger after 6h |
| Gate widget | Widget: renders router for `NoUpdate`, splash for `Hard`/`Maintenance`, soft banner appears in shell for `Soft` |
| Splash | Widget: i18n key fallback, override map preference, Android quit button hidden on iOS |
| URL resolver | Unit: configUrl preferred, store fallback per platform |

Coverage target ≥ 80% per project rule.

## Rollout

1. Land code with `maintenanceMode: false`, `minVersion: 2.0.0`, `recommendedVersion: 2.0.0` in prod config (no-op).
2. Verify fetch + cache + decision wiring in dev/stg with synthetic configs.
3. Use feature in production by raising `recommendedVersion` first (soft banner) for a release, observe metrics.
4. Reserve `minVersion` bumps for genuine breaking changes (schema, security).
