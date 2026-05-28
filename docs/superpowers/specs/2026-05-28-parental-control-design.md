# Parental Control — Design Spec

**Date:** 2026-05-28
**FR:** [fr:18-parental-control](../../fr/18-parental-control.md)
**Status:** Draft (awaiting user review)
**Author:** Tohru Hanai (with Claude)

## Summary

PIN-gated Restricted Mode for the device owner to curate the listening environment for a child or shared user. The gate sits at the content-entry boundary only: Search tab hidden, Subscribe / Unsubscribe / OPML import / non-subscribed deep-link follow / Parental Control settings / Developer settings all require entering the current PIN. Downstream surfaces (playback, queue, downloads, library, sleep timer, transcript/chapters, background refresh) stay open over the parent-curated subscription set. One optional per-podcast filter — `hideExplicitEpisodes` — gives the parent a belt-and-suspenders option on a specific show.

## Goals

1. Single in-app switch the owner can flip to hide discovery and lock subscription changes.
2. Domain-layer gate so every content-entry call site (UI, deep link resolver, OPML importer, router redirect) consults the same lock; no UI-only enforcement.
3. PIN stored hashed (PBKDF2-HMAC-SHA256, 100k iters, per-install salt); rate-limited with exponential backoff after 5 failures.
4. Idle-timeout auto-relock (default 5 min, configurable); immediate relock on app background.
5. Optional per-podcast "Hide explicit episodes" filter on subscribed shows.
6. Fail-closed on storage error: behave as restricted-and-locked, never silently disable.

## Non-Goals

- Global `<itunes:explicit>` filter (publisher data is unreliable; parent has already vetted via subscribe).
- Category or keyword blocklists.
- Cross-device sync, account-based PIN recovery.
- Tamper-proof enforcement against device reinstall / factory reset / app deletion (defer to iOS Screen Time + Android Family Link).
- Gating playback, queue, downloads, sleep timer, library, transcript/chapters, voice commands, background refresh.
- Voice command integration (FR 10 not yet implemented).

## Architecture

### Module layout

```
audiflow_domain
  src/features/parental_control/
    models/
      parental_control_settings.dart        # @collection Isar singleton
      podcast_parental_flags.dart           # @collection per-podcast flags
      unlock_state.dart                     # sealed: Locked / Unlocked / LockedOut
    repositories/
      parental_control_repository.dart      # interface
      parental_control_repository_impl.dart
    datasources/local/
      parental_control_local_datasource.dart
    services/
      pin_hasher.dart                       # PBKDF2 wrapper
      parental_control_gate.dart            # @riverpod Notifier
    providers/
      parental_control_providers.dart

audiflow_app
  features/parental_control/
    presentation/
      controllers/
        parental_control_controller.dart    # screen state
        unlock_controller.dart              # PIN-entry flow
      screens/
        parental_control_settings_screen.dart
        pin_setup_screen.dart
        pin_change_screen.dart
      widgets/
        pin_entry_sheet.dart                # bottom sheet for unlock
        biometric_unlock_button.dart        # opt-in path
```

### Layer split

- **Domain**: models, repository (interface + impl), `PinHasher`, `ParentalControlGate` notifier, Isar datasource. Business logic only — no `BuildContext`.
- **App**: screens, controllers, `PinEntrySheet`. The sheet talks to `parentalControlGateProvider.notifier.tryUnlock(pin)` and returns a `bool` to the caller via `Navigator.pop`.

### Riverpod provider graph

```
parentalControlRepositoryProvider          (Provider<ParentalControlRepository>)
parentalControlSettingsStreamProvider      (StreamProvider<ParentalControlSettings>)
parentalControlGateProvider                (NotifierProvider<UnlockState>)  keepAlive
isRestrictedModeOnProvider                 (Provider<bool>)
isUnlockedProvider                         (Provider<bool>)
hideExplicitForPodcastProvider(itunesId)   (StreamProvider.family<bool>)
parentalControlGateGuardProvider           (Provider<GateGuard>)            keepAlive
```

`GateGuard` is the App-facing convenience that owns `BuildContext`-bound flow:

```dart
abstract class GateGuard {
  /// If Restricted Mode is off, returns true immediately.
  /// If on and already unlocked, returns true and extends idle.
  /// Otherwise shows PIN entry sheet, returns true on success / false on cancel or wrong PIN.
  Future<bool> requireUnlock(BuildContext context, {required GateReason reason});
}
```

`GateReason` is an enum used for the sheet's headline copy and for analytics tagging: `subscribe`, `unsubscribe`, `opmlImport`, `deepLink`, `parentalSettings`, `developerSettings`.

## Data Model

```dart
@collection
class ParentalControlSettings {
  Id id = 0; // singleton: always 0; upsert on first read

  String? pinHashBase64;             // null = no PIN configured
  String? pinSaltBase64;             // null = no PIN configured
  int pinIterations = 100000;        // for future rotation
  bool restrictedModeEnabled = false;
  int unlockTimeoutSeconds = 300;    // 5 min default
  bool biometricUnlockEnabled = false;
  int failedAttempts = 0;
  DateTime? lockoutUntil;
}

@collection
class PodcastParentalFlags {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int itunesId;

  bool hideExplicitEpisodes = false;
}
```

### Why singleton row (id = 0)

Matches existing `app_settings.dart` pattern in `audiflow_domain`. `getSettings()` upserts a default row on first read. All writes go through the repository to keep stream watchers consistent.

### Why per-podcast in a separate collection

Keeps the singleton row stable for repo `watchSettings()` subscribers. Per-podcast flags are queried by `itunesId` index. Pruned in `SubscriptionRepository.unsubscribe()` to avoid orphan rows.

## Components

### `PinHasher` (domain)

```dart
class PinHasher {
  PinHasher({required Random secureRandom});

  Uint8List generateSalt({int length = 16});
  Uint8List hash({required String pin, required Uint8List salt, required int iterations});
  bool verify({required String pin, required ParentalControlSettings settings});
}
```

PBKDF2-HMAC-SHA256 via `package:cryptography` (or `package:crypto` + manual PBKDF2 — decided at impl time based on which is already transitively in the lockfile). Output: 32 bytes. Salt: 16 bytes from `Random.secure()`.

Constant-time comparison required for `verify`.

### `ParentalControlGate` (domain Notifier, keepAlive)

```dart
sealed class UnlockState {
  const UnlockState();
}
class Locked extends UnlockState { const Locked(); }
class Unlocked extends UnlockState {
  final DateTime expiresAt;
  const Unlocked(this.expiresAt);
}
class LockedOut extends UnlockState {
  final DateTime retryAt;
  final int attemptCount;
  const LockedOut({required this.retryAt, required this.attemptCount});
}

@Riverpod(keepAlive: true)
class ParentalControlGate extends _$ParentalControlGate {
  Timer? _idleTimer;

  @override
  UnlockState build() {
    ref.onDispose(() => _idleTimer?.cancel());
    return const Locked();
  }

  /// Returns true if pin verifies; updates state to Unlocked and starts the idle timer.
  /// Returns false if pin is wrong; increments failed attempts; transitions to LockedOut after 5.
  Future<bool> tryUnlock(String pin) async { ... }

  /// Resets the idle timer to the configured timeout. No-op if not unlocked.
  void extendIdle() { ... }

  /// Forces relock. Called from AppLifecycleObserver on paused.
  void lock() { ... }
}
```

### `ParentalControlRepository` (domain)

```dart
abstract class ParentalControlRepository {
  Stream<ParentalControlSettings> watchSettings();
  Future<ParentalControlSettings> getSettings();

  Future<void> setPin(String pin);              // also clears failedAttempts + lockoutUntil
  Future<bool> verifyPin(String pin);           // pure verify; does NOT mutate gate state
  Future<void> clearPin();                      // wiped only via "Reset all data" path
  Future<void> setRestrictedMode(bool enabled);
  Future<void> setUnlockTimeout(Duration timeout);
  Future<void> setBiometricUnlockEnabled(bool enabled);

  Future<void> registerFailedAttempt();
  Future<void> clearFailedAttempts();

  Stream<bool> watchHideExplicit(int itunesId);
  Future<void> setHideExplicit(int itunesId, bool hide);
  Future<void> pruneFlagsFor(int itunesId);    // called from SubscriptionRepository.unsubscribe
}
```

### `GateGuard` (app)

Lives in `audiflow_app` because it owns the `BuildContext` and the `PinEntrySheet` push. Provides `requireUnlock(context, reason)`. Internally:

1. Read `isRestrictedModeOnProvider` — if false, return true.
2. Read `parentalControlGateProvider` — if `Unlocked`, call `extendIdle()` and return true.
3. If `LockedOut`, show sheet in countdown-only mode.
4. Else show `PinEntrySheet(reason: reason)` and await result.
5. On success the sheet has already called `tryUnlock` → state is `Unlocked` → return true.

### `PinEntrySheet` (app)

Modal bottom sheet. 4-8 digit numeric input. Submit disabled until ≥4 digits. Shows reason headline ("Subscribe to this podcast", "Open imported list", etc.). Wrong PIN: shake animation + error text + remaining-attempt counter. Lockout: countdown timer, input disabled. Optional biometric button when `biometricUnlockEnabled` and platform supports it.

## Integration Points

### 1. Router redirect (`packages/audiflow_app/lib/routing/app_router.dart`)

Add a top-level `redirect` callback that consults the gate. If `restrictedModeEnabled && currentUnlockState is Locked`, block these paths:

- `/search` and `/search/**`
- `/settings/developer`
- `/settings/parental-control` (the screen redirects only when locked-and-restricted; the user can always reach the PIN sheet from it)

Redirect target: `/library`.

Router listens to `parentalControlSettingsStreamProvider` via a `Listenable` adapter (existing pattern for router refresh on auth state).

### 2. Nav bar (`packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`)

Bottom-nav item list filtered by `isRestrictedModeOnProvider && isLockedProvider`. Search tab removed (not hidden behind a disabled button) so the child cannot tap it. Library / Queue / Settings remain.

### 3. Subscribe / Unsubscribe (`features/subscription/.../subscription_controller.dart`)

In `toggleSubscription(podcast, source)`: before either branch:

```dart
final ok = await ref.read(gateGuardProvider).requireUnlock(
  context,
  reason: isCurrentlySubscribed ? GateReason.unsubscribe : GateReason.subscribe,
);
if (!ok) return;
```

Controller signature changes to take `BuildContext` from the widget. Matches the existing OPML import controller's pattern; gate prompt fires from the widget, controller stays one layer up.

### 4. OPML import (`features/settings/.../opml_import_controller.dart`)

Gate at `import(file)` entry. Same `requireUnlock` call.

### 5. Deep link (`features/share/.../deep_link_screen.dart`)

After `deepLinkResolverProvider.resolve(uri)` returns a target:

```dart
final subscribed = await ref.read(subscriptionRepositoryProvider).isSubscribed(itunesId);
if (!subscribed) {
  final ok = await ref.read(gateGuardProvider).requireUnlock(context, reason: GateReason.deepLink);
  if (!ok) {
    context.go(AppRoutes.library);
    return;
  }
}
context.go('${AppRoutes.search}/podcast/$itunesId', extra: {...});
```

### 6. Storage Settings "Reset all data" (existing FR 14 screen)

No new gate. Existing double-confirmation dialog stays. Add a paragraph in the confirmation: "This will also clear the Parental Control PIN." Reset wipes the whole Isar instance, which removes the singleton row, so PIN clears naturally.

### 7. AppLifecycleObserver (`packages/audiflow_app/lib/app/app_lifecycle_observer.dart`)

On `AppLifecycleState.paused`:

```dart
ref.read(parentalControlGateProvider.notifier).lock();
```

### 8. Episode list filter (FR 17 podcast detail)

`PodcastDetailController` or `EpisodeListController` watches `hideExplicitForPodcastProvider(itunesId)`. If true, filter episodes where `episode.itunesExplicit == true` from the rendered list. Filter is presentation-only; queue / downloads / cache hold the unfiltered set so toggling the flag does not destroy state.

### 9. SubscriptionRepository unsubscribe hook

`SubscriptionRepositoryImpl.unsubscribe(itunesId)` calls `parentalControlRepository.pruneFlagsFor(itunesId)` in the same transaction (or immediately after) to avoid orphan flag rows.

## Lockout Backoff Policy

Stored in `ParentalControlSettings`:

- `failedAttempts`: incremented on each wrong PIN; cleared on successful unlock or `setPin`.
- `lockoutUntil`: set when `failedAttempts == 5` and again after each subsequent failure.

Backoff:

```
attempts < 5     -> no lockout
attempts == 5    -> 30s
attempts == 6    -> 1min
attempts == 7    -> 2min
attempts == 8    -> 4min
9 <= attempts    -> 5min (cap)
```

Lockout window persists across app restart. During lockout, `tryUnlock` returns false immediately without hashing.

## Idle Timeout Reset Policy

Reset *only* on:

- Successful `tryUnlock`.
- Any `GateGuard.requireUnlock` call that returns true via the "already unlocked" path (because the user explicitly initiated a gated action).

Not reset on general navigation, scroll, tap. Rationale: child interacting with playback should not extend parent's unlock.

Lock immediately on:

- `AppLifecycleState.paused` (any background event).
- Idle timer expiry.
- User-initiated relock from Parental Control screen.

## Error Handling

| Scenario | Behavior |
|---|---|
| Isar read fails on `getSettings` | Gate returns `Locked` permanently in-session. PIN sheet shows "Settings unavailable — restart app". Logged via `namedLoggerProvider('ParentalControl')` + Sentry. |
| Isar write fails on `setPin` / `setRestrictedMode` | Setter throws; UI shows snackbar; in-memory state unchanged so display matches disk. |
| Wrong PIN | `tryUnlock` returns false; counter increments; sheet shows "Incorrect PIN, N attempts remaining". |
| Lockout active | `tryUnlock` short-circuits to false; sheet shows countdown. |
| Forgotten PIN | Banner on Parental Control screen: "Forgot PIN? Reset all app data" → link to FR 14 storage screen. |
| Cold launch while restricted | Gate `Locked`. Router redirects `/search/*` → `/library`. No auto-PIN sheet. |
| Restricted toggled on while Search tab active | Router redirect catches it; pushes `/library`. Existing controllers dispose normally. |
| Background refresh during restricted | Unchanged; only user-facing surfaces gated. |
| Deep link to already-subscribed podcast while restricted | Opens normally; subscription check passes. |
| Subscribe call site missing `BuildContext` | Compile-time error; signature change forces all call sites to adapt. |

## Testing

### Unit (`audiflow_domain/test/features/parental_control/`)

- `PinHasherTest`: hash determinism with same salt+pin+iters, salt uniqueness, `verify` round-trip, wrong-PIN rejection, iteration count honored, constant-time `verify` (smoke).
- `ParentalControlRepositoryImplTest` (with real Isar in test mode): setPin/verifyPin round-trip, salt rotates on PIN change, `failedAttempts` increment + clear on success, `lockoutUntil` set at 5 failures with correct backoff sequence, singleton upsert, `setHideExplicit` round-trip and stream emission, `pruneFlagsFor` removes the row.
- `ParentalControlGateTest`: idle timer expiry transitions to `Locked`, `extendIdle` resets timer, `lock()` clears state, `tryUnlock` during `LockedOut` returns false without calling hasher.

### Widget (`audiflow_app/test/features/parental_control/`)

- `PinEntrySheet`: 4-8 digit input, submit disabled <4 digits, wrong PIN shows shake + remaining-attempt counter, lockout shows countdown and disables input, biometric button visible only when enabled+supported.
- `ParentalControlSettingsScreen`: toggle requires unlock, change-PIN flow requires current PIN before allowing new, timeout dropdown persists.
- Router redirect: `restrictedMode=true && locked` + nav to `/search` → ends at `/library`; nav bar omits Search tab.
- `PodcastDetailScreen` Subscribe button: tap while locked → PIN sheet appears; success → subscribe completes; cancel → no-op.
- `DeepLinkScreen`: resolve to non-subscribed podcast while restricted → PIN sheet; cancel → redirect to `/library`; success → normal navigation.

### Integration (`audiflow_app/integration_test/`)

End-to-end: set PIN → enable Restricted Mode → background app → reopen → confirm Search tab gone + nav to `/search` redirects → tap Subscribe on subscribed podcast detail (re-entered via library) → PIN sheet → unlock → subscribe completes → background → reopen → confirm re-locked.

### Test doubles

Per `.claude/rules/flutter/testing.md`: fakes, not mocks. `FakeParentalControlRepository` and `FakePinHasher` in `test/fakes/`. No mockito.

## Dependencies

- `crypto` (already transitive via `dio` / `http`) for HMAC-SHA256 primitive, or `cryptography` if PBKDF2 isn't directly exposed. Decision at impl time; both are pure-Dart.
- `local_auth` (new) — opt-in biometric. Added only when biometric toggle is implemented; can be deferred to a follow-up if scope creep is a concern.

## Localization

New ARB keys in `app_en.arb` + `app_ja.arb`:

- `parentalControlTitle`
- `parentalControlEnable`
- `parentalControlPinSetupTitle` / `parentalControlPinSetupSubtitle`
- `parentalControlPinChange`
- `parentalControlPinEntryReasonSubscribe` / `Unsubscribe` / `OpmlImport` / `DeepLink` / `ParentalSettings` / `DeveloperSettings`
- `parentalControlPinIncorrect` (with `{remaining}` placeholder)
- `parentalControlLockoutCountdown` (with `{seconds}` placeholder)
- `parentalControlForgotPinBanner`
- `parentalControlHideExplicitToggle`
- `parentalControlBiometricToggle`
- `parentalControlUnlockTimeoutLabel`

## Migration

First launch after upgrade: `getSettings()` returns the default row (Restricted Mode off, no PIN). Existing users see no change until they opt in via Settings.

No schema migration needed beyond adding the two new collections — Isar `openAsync` accepts new schemas automatically.

## Observability

- `analyticsService.emit('parental_control.enabled')` when Restricted Mode toggles on.
- `analyticsService.emit('parental_control.disabled')` when toggled off.
- `analyticsService.emit('parental_control.unlock_success', {'reason': reason})` on successful unlock.
- `analyticsService.emit('parental_control.unlock_failed', {'attempts': n})` on wrong PIN.
- `analyticsService.emit('parental_control.lockout', {'duration_seconds': s})` on lockout transition.
- Sentry capture for storage failures only; PIN-related events stay in analytics.
- **Never log the plaintext PIN, hash, or salt.**

## Open Questions for Implementation

1. **`crypto` vs `cryptography` package**: confirm at impl which one is already in the lockfile and exposes PBKDF2. If neither, prefer `crypto` (smaller, already transitive) + manual PBKDF2 implementation.
2. **Biometric scope**: ship in initial PR or follow-up? Recommend ship in initial PR if `local_auth` adds < 1MB; otherwise follow-up.
3. **iTunes-explicit field on `Episode`**: confirm `audiflow_domain/lib/src/features/feed/models/episode.dart` already carries an `itunesExplicit` flag. If not, add it as part of this work (FR 17 episode list filter needs it).

## Out of scope (deferred)

- Voice command gate (FR 10 not yet implemented).
- Cross-device sync of PIN / settings.
- Account-based PIN recovery.
- Per-podcast scheduling (e.g. "allow this show only between 4 and 6 PM").
- Time-budget controls ("max 30 min/day").
