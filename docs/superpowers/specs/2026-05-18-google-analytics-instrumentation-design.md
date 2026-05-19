# Google Analytics Instrumentation — Design

Date: 2026-05-18
Status: Approved (pending spec self-review + user sign-off)

## 1. Goal

Instrument audiflow with Google Analytics 4 to observe real-world usecase coverage (which features are touched, which podcasts/episodes are played), while:

- Not pulling in any ads SDK or ad-personalization signals.
- Sharing the same anonymous user identifier between Sentry and GA so crashes can be joined with usage events.
- Capturing event signal for a podcast app: discovery, subscription, playback, download, smart playlist / station / sleep timer.

## 2. Non-goals

- No authenticated user identity (app has no accounts).
- No advertising attribution, no ad personalization.
- No analytics for purely cosmetic UI state (scrolling, tab clicks beyond top-level screens).
- No screen recording / session replay.
- No raw search-query capture (only `query_len`).

## 3. SDK choice

`firebase_analytics` (GA4 via Firebase) + `firebase_core`.

Rationale:
- Auto-collects `screen_view`, sessions, first_open, app_update without manual plumbing.
- Native iOS + Android support with the existing build flavors.
- Ads SDK is a separate package (`google_mobile_ads`) and is NOT added.
- Ad-related signals are explicitly disabled (see §8).

## 4. User identity

App has no accounts. Generate an anonymous install UUID and share it with both Sentry and GA.

- `InstallIdRepository` (in `audiflow_domain/features/install_id/`):
  - `Future<String> getOrCreate()` — reads SharedPreferences key `analytics.install_id`. If absent, generates `Uuid().v4()` and persists. Stable for life of install, regenerates on uninstall/reinstall.
- Bootstrap (`audiflow_app/lib/main.dart`):
  1. `Firebase.initializeApp()`.
  2. `final installId = await installIdRepo.getOrCreate()`.
  3. Before any event is captured: `Sentry.configureScope((s) => s.setUser(SentryUser(id: installId)))`.
  4. `FirebaseAnalytics.instance.setUserId(id: installId)`.
- Same string in both systems → trivially joinable.

The install UUID is also persisted as a Sentry tag `install_id` so it appears in crash searches without expanding the user object.

## 5. Module layout

```
audiflow_core/
  lib/src/utils/stable_id.dart                                # sha256-truncate helper

audiflow_domain/
  lib/src/features/
    install_id/
      repositories/
        install_id_repository.dart                            # interface
        install_id_repository_impl.dart                       # SharedPreferences-backed
    monitoring/
      models/
        analytics_event.dart                                  # sealed event types
      services/
        analytics_service.dart                                # abstract + Riverpod provider

audiflow_app/
  lib/features/
    monitoring/services/firebase_analytics_service.dart      # FirebaseAnalytics impl
    settings/presentation/
      controllers/analytics_opt_in_controller.dart           # @riverpod bool
      widgets/analytics_opt_in_tile.dart                     # SwitchListTile
  lib/main.dart                                               # Firebase init, identity wiring
  lib/routing/app_router.dart                                 # FirebaseAnalyticsObserver
```

Rationale: only `audiflow_app` depends on Firebase SDK. `audiflow_domain` depends on the abstract `AnalyticsService` interface so it can be faked in tests and so the domain stays free of Flutter plugin coupling.

## 6. Stable cross-user identifiers

Isar `Id` is per-install autoincrement and useless across users. Use raw RSS-derived identifiers so reports in the GA console read directly without external joins. feedUrl, RSS guid, and titles are all public from the RSS feed -- there is no PII to protect by hashing.

- `podcast_id`: iTunes ID when available (non-OPML import), else the raw feedUrl. Truncated to GA4's 100-char param limit at the event boundary.
- `episode_id`: raw RSS guid. Truncated to 100 chars.
- `podcast_title`: subscription / now-playing podcast title. Event-scoped dimension, truncated to 100 chars. Joins with `podcast_id` so reports read like "<channel>".
- `episode_title`: episode title. Event-scoped dimension, truncated to 100 chars. Joins with `episode_id` so reports read like "<channel> / <episode>".
- `stationId = sha256("$installId:$stationName").hex.substring(0, 16)` — stations are per-user; hash with installId so the same name across users does not collide on the GA side as "same station". Stays hashed: per-user station names are not RSS-public.
- `pattern_id`, `playlist_id` — already SSoT-stable identifiers from smart playlist config, pass raw.

Helper: `audiflow_core/lib/src/utils/stable_id.dart` (still used by `station_id` only).

```dart
String stableId(String input) =>
    sha256.convert(utf8.encode(input)).toString().substring(0, 16);
```

Truncation helper lives at the event boundary in `AnalyticsEvent.params`:

```dart
String _trim(String s) => s.length <= 100 ? s : s.substring(0, 100);
```

## 7. Event catalog

All events use lower_snake_case names per GA convention. Param names are also lower_snake_case. All string params are truncated to GA4's 100-char limit at the event boundary.

| Event | Params | Trigger site |
|---|---|---|
| `screen_view` (auto) | `screen_name`, `screen_class` | `FirebaseAnalyticsObserver` attached to GoRouter |
| `podcast_subscribe` | `podcast_id`, `podcast_title`, `source` ∈ {`search`, `discovery`, `opml`, `deeplink`, `unknown`} | `SubscriptionRepositoryImpl.subscribe` |
| `podcast_unsubscribe` | `podcast_id`, `podcast_title` | `SubscriptionRepositoryImpl.unsubscribe` |
| `episode_play_start` | `podcast_id`, `episode_id`, `podcast_title`, `episode_title`, `source` ∈ {`queue`, `library`, `playlist`, `station`, `search`, `deeplink`} | `AudioPlayerService` start |
| `episode_pause` | `podcast_id`, `episode_id`, `podcast_title`, `episode_title`, `position_sec` | pause |
| `episode_complete` | `podcast_id`, `episode_id`, `podcast_title`, `episode_title`, `duration_sec` | completion event |
| `episode_seek` | `podcast_id`, `episode_id`, `podcast_title`, `episode_title`, `from_sec`, `to_sec` | seek |
| `playback_speed_change` | `speed` (e.g., 1.5) | speed setter |
| `search_query` | `query_len` (int) | `SearchController` (raw query never sent) |
| `episode_download_start` | `podcast_id`, `episode_id`, `podcast_title`, `episode_title` | `DownloadService.start` |
| `episode_download_complete` | `podcast_id`, `episode_id`, `podcast_title`, `episode_title`, `bytes` | `DownloadService.complete` |
| `smart_playlist_play` | `pattern_id`, `playlist_id` | playlist start |
| `station_play` | `station_id` | station start |
| `sleep_timer_set` | `mode` ∈ {`duration`, `episodes`, `end_of_episode`, `end_of_chapter`}, `value` (int, omitted for end_of_* modes) | timer set |

Anti-spam: `episode_pause` and `episode_seek` may fire frequently. Throttle to at most one per 5 seconds per episode in the implementation layer (a tiny stateful wrapper inside `FirebaseAnalyticsService`).

## 8. Ads disabled

Code (called once during Firebase init, before any event):

```dart
await FirebaseAnalytics.instance.setConsent(
  adStorageConsentGranted: false,
  adUserDataConsentGranted: false,
  adPersonalizationSignalsConsentGranted: false,
  analyticsStorageConsentGranted: true,
);
```

iOS `ios/Runner/Info.plist`:

```xml
<key>GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS</key>
<false/>
<key>GOOGLE_ANALYTICS_IDFA_COLLECTION_ENABLED</key>
<false/>
```

Android `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data android:name="google_analytics_default_allow_ad_personalization_signals" android:value="false" />
<meta-data android:name="google_analytics_adid_collection_enabled" android:value="false" />
<meta-data android:name="google_analytics_ssaid_collection_enabled" android:value="false" />
```

`google_mobile_ads` package: NOT added.

## 9. Opt-out

- `analyticsOptInControllerProvider` (`@riverpod`, SharedPreferences-backed `bool`, default `true`).
- Settings screen: `SwitchListTile` "Share usage data" + supporting text explaining what is collected (no ads, no PII, anonymous ID).
- On toggle:
  - `true` → `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)`.
  - `false` → `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false)`.
- Inside `FirebaseAnalyticsService.logEvent`, short-circuit when opt-out is false (defence-in-depth — SDK toggle alone is enough but the early-return keeps the trace clean in dev/debug view).
- Sentry crash reporting is independent of this toggle (crashes ≠ usage analytics).

## 10. Flavor gating

Existing `FlavorConfig.enableAnalytics`:

- `dev.enableAnalytics` flipped to `true` (was `false`) so the integration is exercised in development.
- `stg.enableAnalytics` and `prod.enableAnalytics` remain `true`.

`enableAnalytics == false` short-circuits the entire Firebase init path. When `true`, the opt-out toggle (default ON) controls actual event sending.

## 11. AnalyticsService interface

```dart
sealed class AnalyticsEvent {
  String get name;
  Map<String, Object?> get params;
}

class PodcastSubscribed extends AnalyticsEvent { ... }
class EpisodePlayStarted extends AnalyticsEvent { ... }
// ... one class per event in the catalog

abstract interface class AnalyticsService {
  Future<void> log(AnalyticsEvent event);
  Future<void> setUserId(String? id);
  Future<void> setOptIn(bool optIn);
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) =>
    throw UnimplementedError('Override in main.dart');
```

`audiflow_app` overrides the provider in `ProviderContainer` with `FirebaseAnalyticsService(FirebaseAnalytics.instance)`. Tests override with `FakeAnalyticsService` that records events to a list.

## 12. Testing strategy

- `audiflow_domain/test/features/install_id/install_id_repository_test.dart` — get-or-create idempotency, persistence.
- `audiflow_core/test/utils/stable_id_test.dart` — determinism, length, ASCII-hex output.
- `audiflow_domain/test/features/monitoring/analytics_event_test.dart` — every sealed event subclass returns the spec'd `name` + `params`.
- `audiflow_domain/test/features/subscription/subscription_repository_impl_test.dart` — `subscribe()` triggers `PodcastSubscribed` on the injected `FakeAnalyticsService`.
- Similar wired-call tests for playback, search, download, smart playlist, station, sleep timer.
- Widget test for the settings toggle: flipping the switch invokes `analyticsService.setOptIn(false)`.

Per `.claude/rules/flutter/testing.md`: prefer `package:checks`, prefer fakes over mocks, no `mockito`-generated code.

## 13. Sentry-side wiring

Existing `SentryFlutter.init` call in `audiflow_app/lib/main.dart` extended:

```dart
appRunner: () async {
  final installId = await installIdRepo.getOrCreate();
  Sentry.configureScope((scope) {
    scope.setUser(SentryUser(id: installId));
    scope.setTag('install_id', installId);
  });
  await _startApp(...);
}
```

`installIdRepo` is constructed standalone (mirrors the existing `isarOpenLogger` pattern) because `ProviderContainer` is not yet available pre-Isar. Bootstrap reorder: call `SharedPreferences.getInstance()` once at the top of `appMain`, build `InstallIdRepositoryImpl(prefs)`, fetch the UUID, then both `SentryFlutter.init` (with the scope setter inside `appRunner`) and `_startApp` reuse the same `prefs` instance via the existing `sharedPreferencesProvider` override. Same install ID later wired into GA via the analytics service inside `_startApp` after the container is built.

## 14. Out-of-scope follow-ups

- Crashlytics (we already have Sentry; revisit if Sentry coverage drops).
- BigQuery export of GA data (linked in console, no app-side work).
- Per-event consent UI (current binary opt-out is sufficient).
- Raw search query capture (requires separate consent UX).

## 15. Verification

- `melos run test` green.
- `flutter analyze` zero issues.
- Manual: run dev flavor with debug view enabled, toggle opt-out, exercise each event, confirm appearance in GA DebugView with the install UUID as `user_id`.
- Sentry: trigger a manual `Sentry.captureMessage`, confirm event in Sentry UI carries the same `install_id` as the GA `user_id`.
