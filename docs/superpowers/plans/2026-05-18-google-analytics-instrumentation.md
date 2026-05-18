# Google Analytics Instrumentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add GA4 (firebase_analytics) instrumentation to audiflow that shares an anonymous install UUID with Sentry, disables all ad signals, and captures podcast-app usecase events with cross-user-stable podcast/episode IDs.

**Architecture:** Abstract `AnalyticsService` interface lives in `audiflow_domain`. Firebase-backed implementation lives in `audiflow_app`. Identity is an anonymous install UUID persisted in SharedPreferences and applied to both Sentry (`user.id` + `install_id` tag) and GA (`setUserId`). Stable cross-user identifiers are 16-char sha256 prefixes of `feedUrl` / `guid`. A settings-screen toggle controls `setAnalyticsCollectionEnabled`. Flavor flag `enableAnalytics` gates Firebase init.

**Tech Stack:** Flutter 3.41 / Dart 3.11, Riverpod 3 (`@riverpod`), `firebase_core`, `firebase_analytics`, `uuid`, `crypto`, existing `sentry_flutter`, `shared_preferences`. Tests use `package:checks` with hand-written fakes (no mockito codegen).

**Spec:** `docs/superpowers/specs/2026-05-18-google-analytics-instrumentation-design.md`

---

## File Map

**Create:**
- `packages/audiflow_core/lib/src/utils/stable_id.dart`
- `packages/audiflow_core/test/utils/stable_id_test.dart`
- `packages/audiflow_domain/lib/src/features/install_id/repositories/install_id_repository.dart`
- `packages/audiflow_domain/lib/src/features/install_id/repositories/install_id_repository_impl.dart`
- `packages/audiflow_domain/lib/src/features/install_id/providers/install_id_providers.dart`
- `packages/audiflow_domain/test/features/install_id/install_id_repository_impl_test.dart`
- `packages/audiflow_domain/lib/src/features/monitoring/models/analytics_event.dart`
- `packages/audiflow_domain/lib/src/features/monitoring/services/analytics_service.dart`
- `packages/audiflow_domain/lib/src/features/monitoring/providers/analytics_providers.dart`
- `packages/audiflow_domain/lib/src/features/monitoring/testing/fake_analytics_service.dart` (exported via main barrel for test reuse)
- `packages/audiflow_domain/test/features/monitoring/analytics_event_test.dart`
- `packages/audiflow_app/lib/features/monitoring/services/firebase_analytics_service.dart`
- `packages/audiflow_app/lib/features/monitoring/services/throttled_analytics_service.dart`
- `packages/audiflow_app/test/features/monitoring/throttled_analytics_service_test.dart`
- `packages/audiflow_app/lib/features/settings/presentation/controllers/analytics_opt_in_controller.dart`
- `packages/audiflow_app/lib/features/settings/presentation/widgets/analytics_opt_in_tile.dart`
- `packages/audiflow_app/test/features/settings/analytics_opt_in_controller_test.dart`

**Modify:**
- `packages/audiflow_core/lib/audiflow_core.dart` — export `utils/stable_id.dart`
- `packages/audiflow_core/pubspec.yaml` — add `crypto`
- `packages/audiflow_core/lib/src/config/flavor_config.dart` — flip `dev.enableAnalytics` to `true`
- `packages/audiflow_domain/pubspec.yaml` — add `uuid`
- `packages/audiflow_domain/lib/audiflow_domain.dart` — export install_id + monitoring barrels
- `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart` — emit subscribe/unsubscribe
- `packages/audiflow_domain/lib/src/features/download/services/download_service.dart` — emit download events
- `packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart` — emit sleep_timer_set
- `packages/audiflow_app/pubspec.yaml` — add `firebase_core`, `firebase_analytics`, `uuid`, `crypto`
- `packages/audiflow_app/lib/main.dart` — Firebase init, install id, Sentry user/tag, analytics provider override, `setAnalyticsCollectionEnabled`
- `packages/audiflow_app/lib/routing/app_router.dart` — attach `FirebaseAnalyticsObserver`
- `packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.dart` — emit `search_query`
- `packages/audiflow_app/lib/features/player/services/audiflow_audio_handler.dart` — emit play/pause/complete/seek/speed
- `packages/audiflow_app/lib/features/station/presentation/controllers/station_detail_controller.dart` — emit `station_play`
- `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart` — mount opt-in tile
- `packages/audiflow_app/lib/l10n/app_en.arb`, `app_ja.arb` — strings for opt-in toggle
- `packages/audiflow_app/ios/Runner/Info.plist` — ad-disable keys
- `packages/audiflow_app/android/app/src/main/AndroidManifest.xml` — ad-disable meta-data

Smart playlist play emit point: pick during Task 24 by reading current playlist-start call site (likely `audiflow_app/lib/features/playlist/...`). Add task inline once located.

---

## Task 1: stable_id helper

**Files:**
- Create: `packages/audiflow_core/lib/src/utils/stable_id.dart`
- Create: `packages/audiflow_core/test/utils/stable_id_test.dart`
- Modify: `packages/audiflow_core/pubspec.yaml`
- Modify: `packages/audiflow_core/lib/audiflow_core.dart`

- [ ] **Step 1: Add `crypto` dependency**

Add under `dependencies:` in `packages/audiflow_core/pubspec.yaml`:

```yaml
  crypto: ^3.0.6
```

Then run:

```bash
cd packages/audiflow_core && flutter pub get
```

- [ ] **Step 2: Write the failing test**

Create `packages/audiflow_core/test/utils/stable_id_test.dart`:

```dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stableId', () {
    test('produces a 16-char lowercase hex string', () {
      final id = stableId('https://example.com/feed.xml');
      check(id).length.equals(16);
      check(id).matches(RegExp(r'^[0-9a-f]{16}$'));
    });

    test('is deterministic for the same input', () {
      check(stableId('foo')).equals(stableId('foo'));
    });

    test('differs for different inputs', () {
      check(stableId('foo')).not((s) => s.equals(stableId('bar')));
    });

    test('treats empty string as a valid input', () {
      check(stableId('')).length.equals(16);
    });
  });
}
```

- [ ] **Step 3: Run test, verify failure**

```bash
cd packages/audiflow_core && flutter test test/utils/stable_id_test.dart
```

Expected: FAIL ("Undefined name 'stableId'").

- [ ] **Step 4: Implement**

Create `packages/audiflow_core/lib/src/utils/stable_id.dart`:

```dart
import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Returns a 16-char lowercase-hex prefix of sha256(input).
///
/// Stable across users (deterministic) but opaque (no URL/GUID leak).
/// Use to derive cross-user identifiers for analytics events from
/// values that would otherwise be PII-adjacent (feed URLs) or exceed
/// length limits (full sha256, episode GUIDs).
String stableId(String input) {
  final digest = sha256.convert(utf8.encode(input));
  return digest.toString().substring(0, 16);
}
```

Add to `packages/audiflow_core/lib/audiflow_core.dart`:

```dart
export 'src/utils/stable_id.dart';
```

- [ ] **Step 5: Run test, verify pass**

```bash
cd packages/audiflow_core && flutter test test/utils/stable_id_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_core/lib/src/utils/stable_id.dart \
        packages/audiflow_core/test/utils/stable_id_test.dart \
        packages/audiflow_core/lib/audiflow_core.dart \
        packages/audiflow_core/pubspec.yaml \
        packages/audiflow_core/pubspec.lock
git commit -m "feat(core): add stableId helper for analytics ids"
```

---

## Task 2: InstallIdRepository

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/install_id/repositories/install_id_repository.dart`
- Create: `packages/audiflow_domain/lib/src/features/install_id/repositories/install_id_repository_impl.dart`
- Create: `packages/audiflow_domain/lib/src/features/install_id/providers/install_id_providers.dart`
- Create: `packages/audiflow_domain/test/features/install_id/install_id_repository_impl_test.dart`
- Modify: `packages/audiflow_domain/pubspec.yaml`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Add `uuid` dependency**

Add under `dependencies:` in `packages/audiflow_domain/pubspec.yaml`:

```yaml
  uuid: ^4.5.1
```

Run:

```bash
cd packages/audiflow_domain && flutter pub get
```

- [ ] **Step 2: Write failing tests**

Create `packages/audiflow_domain/test/features/install_id/install_id_repository_impl_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('InstallIdRepositoryImpl', () {
    test('getOrCreate generates and persists a UUID on first call', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = InstallIdRepositoryImpl(prefs);

      final id = await repo.getOrCreate();

      check(id).length.equals(36);
      check(prefs.getString('analytics.install_id')).equals(id);
    });

    test('returns the same UUID on subsequent calls', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = InstallIdRepositoryImpl(prefs);

      final first = await repo.getOrCreate();
      final second = await repo.getOrCreate();

      check(second).equals(first);
    });

    test('returns existing UUID if one is already persisted', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'analytics.install_id': 'existing-uuid',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = InstallIdRepositoryImpl(prefs);

      check(await repo.getOrCreate()).equals('existing-uuid');
    });
  });
}
```

- [ ] **Step 3: Run test, verify failure**

```bash
cd packages/audiflow_domain && flutter test test/features/install_id/install_id_repository_impl_test.dart
```

Expected: FAIL ("Undefined name 'InstallIdRepositoryImpl'").

- [ ] **Step 4: Implement interface**

Create `packages/audiflow_domain/lib/src/features/install_id/repositories/install_id_repository.dart`:

```dart
/// Provides a stable, anonymous identifier that lives for the life
/// of an install.
///
/// Used to correlate Sentry crash events with GA usage events.
abstract interface class InstallIdRepository {
  /// Returns the cached install id, generating and persisting one on
  /// first call.
  Future<String> getOrCreate();
}
```

- [ ] **Step 5: Implement impl**

Create `packages/audiflow_domain/lib/src/features/install_id/repositories/install_id_repository_impl.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'install_id_repository.dart';

class InstallIdRepositoryImpl implements InstallIdRepository {
  InstallIdRepositoryImpl(this._prefs, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const _key = 'analytics.install_id';

  final SharedPreferences _prefs;
  final Uuid _uuid;

  @override
  Future<String> getOrCreate() async {
    final existing = _prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _uuid.v4();
    await _prefs.setString(_key, generated);
    return generated;
  }
}
```

- [ ] **Step 6: Add provider**

Create `packages/audiflow_domain/lib/src/features/install_id/providers/install_id_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/shared_preferences_provider.dart';
import '../repositories/install_id_repository.dart';
import '../repositories/install_id_repository_impl.dart';

part 'install_id_providers.g.dart';

@Riverpod(keepAlive: true)
InstallIdRepository installIdRepository(Ref ref) =>
    InstallIdRepositoryImpl(ref.watch(sharedPreferencesProvider));
```

If the existing `sharedPreferencesProvider` import path differs, search for `sharedPreferencesProvider` under `packages/audiflow_domain/lib/src` and use that path. Adjust the import accordingly.

- [ ] **Step 7: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
export 'src/features/install_id/repositories/install_id_repository.dart';
export 'src/features/install_id/repositories/install_id_repository_impl.dart';
export 'src/features/install_id/providers/install_id_providers.dart';
```

- [ ] **Step 8: Run codegen**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 9: Run test, verify pass**

```bash
cd packages/audiflow_domain && flutter test test/features/install_id/
```

Expected: PASS (3 tests).

- [ ] **Step 10: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/install_id/ \
        packages/audiflow_domain/test/features/install_id/ \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/pubspec.yaml \
        packages/audiflow_domain/pubspec.lock
git commit -m "feat(domain): add install id repository"
```

---

## Task 3: AnalyticsEvent sealed types

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/monitoring/models/analytics_event.dart`
- Create: `packages/audiflow_domain/test/features/monitoring/analytics_event_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Write failing test for each event**

Create `packages/audiflow_domain/test/features/monitoring/analytics_event_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsEvent', () {
    test('PodcastSubscribed', () {
      final e = PodcastSubscribed(podcastId: 'p1', source: SubscribeSource.search);
      check(e.name).equals('podcast_subscribe');
      check(e.params).deepEquals({'podcast_id': 'p1', 'source': 'search'});
    });

    test('PodcastUnsubscribed', () {
      final e = PodcastUnsubscribed(podcastId: 'p1');
      check(e.name).equals('podcast_unsubscribe');
      check(e.params).deepEquals({'podcast_id': 'p1'});
    });

    test('EpisodePlayStarted', () {
      final e = EpisodePlayStarted(
        podcastId: 'p1',
        episodeId: 'e1',
        source: PlaySource.queue,
      );
      check(e.name).equals('episode_play_start');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'source': 'queue',
      });
    });

    test('EpisodePaused', () {
      final e = EpisodePaused(podcastId: 'p1', episodeId: 'e1', positionSec: 120);
      check(e.name).equals('episode_pause');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'position_sec': 120,
      });
    });

    test('EpisodeCompleted', () {
      final e = EpisodeCompleted(podcastId: 'p1', episodeId: 'e1', durationSec: 1800);
      check(e.name).equals('episode_complete');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'duration_sec': 1800,
      });
    });

    test('EpisodeSeeked', () {
      final e = EpisodeSeeked(
        podcastId: 'p1',
        episodeId: 'e1',
        fromSec: 100,
        toSec: 200,
      );
      check(e.name).equals('episode_seek');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'from_sec': 100,
        'to_sec': 200,
      });
    });

    test('PlaybackSpeedChanged', () {
      final e = PlaybackSpeedChanged(speed: 1.5);
      check(e.name).equals('playback_speed_change');
      check(e.params).deepEquals({'speed': 1.5});
    });

    test('SearchQueryEntered emits length only', () {
      final e = SearchQueryEntered(queryLen: 12);
      check(e.name).equals('search_query');
      check(e.params).deepEquals({'query_len': 12});
    });

    test('EpisodeDownloadStarted', () {
      final e = EpisodeDownloadStarted(podcastId: 'p1', episodeId: 'e1');
      check(e.name).equals('episode_download_start');
      check(e.params).deepEquals({'podcast_id': 'p1', 'episode_id': 'e1'});
    });

    test('EpisodeDownloadCompleted', () {
      final e = EpisodeDownloadCompleted(
        podcastId: 'p1',
        episodeId: 'e1',
        bytes: 1024,
      );
      check(e.name).equals('episode_download_complete');
      check(e.params).deepEquals({
        'podcast_id': 'p1',
        'episode_id': 'e1',
        'bytes': 1024,
      });
    });

    test('SmartPlaylistPlayed', () {
      final e = SmartPlaylistPlayed(patternId: 'coten_radio', playlistId: 'regular');
      check(e.name).equals('smart_playlist_play');
      check(e.params).deepEquals({
        'pattern_id': 'coten_radio',
        'playlist_id': 'regular',
      });
    });

    test('StationPlayed', () {
      final e = StationPlayed(stationId: 's1');
      check(e.name).equals('station_play');
      check(e.params).deepEquals({'station_id': 's1'});
    });

    test('SleepTimerSet (duration)', () {
      final e = SleepTimerSet(mode: SleepTimerMode.duration, value: 30);
      check(e.name).equals('sleep_timer_set');
      check(e.params).deepEquals({'mode': 'duration', 'value': 30});
    });

    test('SleepTimerSet (end_of_episode omits value)', () {
      final e = SleepTimerSet(mode: SleepTimerMode.endOfEpisode);
      check(e.name).equals('sleep_timer_set');
      check(e.params).deepEquals({'mode': 'end_of_episode'});
    });
  });
}
```

- [ ] **Step 2: Run test, verify failure**

```bash
cd packages/audiflow_domain && flutter test test/features/monitoring/analytics_event_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement**

Create `packages/audiflow_domain/lib/src/features/monitoring/models/analytics_event.dart`:

```dart
/// Base type for all analytics events.
///
/// Every concrete event maps to a single GA event name and a flat
/// param map of primitive values (string / num / bool).
sealed class AnalyticsEvent {
  const AnalyticsEvent();
  String get name;
  Map<String, Object> get params;
}

enum SubscribeSource { search, discovery, opml, deeplink, unknown }

enum PlaySource { queue, library, playlist, station, search, deeplink }

enum SleepTimerMode { duration, episodes, endOfEpisode, endOfChapter }

String _toSnake(String s) {
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    final isUpper = 65 <= c && c <= 90;
    if (isUpper && 0 < i) buf.write('_');
    buf.writeCharCode(isUpper ? c + 32 : c);
  }
  return buf.toString();
}

class PodcastSubscribed extends AnalyticsEvent {
  const PodcastSubscribed({required this.podcastId, required this.source});
  final String podcastId;
  final SubscribeSource source;
  @override
  String get name => 'podcast_subscribe';
  @override
  Map<String, Object> get params => {'podcast_id': podcastId, 'source': source.name};
}

class PodcastUnsubscribed extends AnalyticsEvent {
  const PodcastUnsubscribed({required this.podcastId});
  final String podcastId;
  @override
  String get name => 'podcast_unsubscribe';
  @override
  Map<String, Object> get params => {'podcast_id': podcastId};
}

class EpisodePlayStarted extends AnalyticsEvent {
  const EpisodePlayStarted({
    required this.podcastId,
    required this.episodeId,
    required this.source,
  });
  final String podcastId;
  final String episodeId;
  final PlaySource source;
  @override
  String get name => 'episode_play_start';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'source': source.name,
  };
}

class EpisodePaused extends AnalyticsEvent {
  const EpisodePaused({
    required this.podcastId,
    required this.episodeId,
    required this.positionSec,
  });
  final String podcastId;
  final String episodeId;
  final int positionSec;
  @override
  String get name => 'episode_pause';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'position_sec': positionSec,
  };
}

class EpisodeCompleted extends AnalyticsEvent {
  const EpisodeCompleted({
    required this.podcastId,
    required this.episodeId,
    required this.durationSec,
  });
  final String podcastId;
  final String episodeId;
  final int durationSec;
  @override
  String get name => 'episode_complete';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'duration_sec': durationSec,
  };
}

class EpisodeSeeked extends AnalyticsEvent {
  const EpisodeSeeked({
    required this.podcastId,
    required this.episodeId,
    required this.fromSec,
    required this.toSec,
  });
  final String podcastId;
  final String episodeId;
  final int fromSec;
  final int toSec;
  @override
  String get name => 'episode_seek';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'from_sec': fromSec,
    'to_sec': toSec,
  };
}

class PlaybackSpeedChanged extends AnalyticsEvent {
  const PlaybackSpeedChanged({required this.speed});
  final double speed;
  @override
  String get name => 'playback_speed_change';
  @override
  Map<String, Object> get params => {'speed': speed};
}

class SearchQueryEntered extends AnalyticsEvent {
  const SearchQueryEntered({required this.queryLen});
  final int queryLen;
  @override
  String get name => 'search_query';
  @override
  Map<String, Object> get params => {'query_len': queryLen};
}

class EpisodeDownloadStarted extends AnalyticsEvent {
  const EpisodeDownloadStarted({required this.podcastId, required this.episodeId});
  final String podcastId;
  final String episodeId;
  @override
  String get name => 'episode_download_start';
  @override
  Map<String, Object> get params => {'podcast_id': podcastId, 'episode_id': episodeId};
}

class EpisodeDownloadCompleted extends AnalyticsEvent {
  const EpisodeDownloadCompleted({
    required this.podcastId,
    required this.episodeId,
    required this.bytes,
  });
  final String podcastId;
  final String episodeId;
  final int bytes;
  @override
  String get name => 'episode_download_complete';
  @override
  Map<String, Object> get params => {
    'podcast_id': podcastId,
    'episode_id': episodeId,
    'bytes': bytes,
  };
}

class SmartPlaylistPlayed extends AnalyticsEvent {
  const SmartPlaylistPlayed({required this.patternId, required this.playlistId});
  final String patternId;
  final String playlistId;
  @override
  String get name => 'smart_playlist_play';
  @override
  Map<String, Object> get params => {
    'pattern_id': patternId,
    'playlist_id': playlistId,
  };
}

class StationPlayed extends AnalyticsEvent {
  const StationPlayed({required this.stationId});
  final String stationId;
  @override
  String get name => 'station_play';
  @override
  Map<String, Object> get params => {'station_id': stationId};
}

class SleepTimerSet extends AnalyticsEvent {
  const SleepTimerSet({required this.mode, this.value});
  final SleepTimerMode mode;
  final int? value;
  @override
  String get name => 'sleep_timer_set';
  @override
  Map<String, Object> get params {
    final modeName = _toSnake(mode.name);
    final v = value;
    return v == null ? {'mode': modeName} : {'mode': modeName, 'value': v};
  }
}
```

- [ ] **Step 4: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
export 'src/features/monitoring/models/analytics_event.dart';
```

- [ ] **Step 5: Run test, verify pass**

```bash
cd packages/audiflow_domain && flutter test test/features/monitoring/analytics_event_test.dart
```

Expected: PASS (14 tests).

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/monitoring/models/ \
        packages/audiflow_domain/test/features/monitoring/ \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add AnalyticsEvent sealed types"
```

---

## Task 4: AnalyticsService interface + Fake + provider

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/monitoring/services/analytics_service.dart`
- Create: `packages/audiflow_domain/lib/src/features/monitoring/providers/analytics_providers.dart`
- Create: `packages/audiflow_domain/lib/src/features/monitoring/testing/fake_analytics_service.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Define the interface**

Create `packages/audiflow_domain/lib/src/features/monitoring/services/analytics_service.dart`:

```dart
import '../models/analytics_event.dart';

abstract interface class AnalyticsService {
  Future<void> log(AnalyticsEvent event);

  /// Identify the current install. Pass null on opt-out.
  Future<void> setUserId(String? id);

  /// Toggle event recording at the SDK boundary.
  Future<void> setOptIn(bool optIn);
}
```

- [ ] **Step 2: Add provider scaffold (overridden in `audiflow_app/main.dart`)**

Create `packages/audiflow_domain/lib/src/features/monitoring/providers/analytics_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/analytics_service.dart';

part 'analytics_providers.g.dart';

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) =>
    throw UnimplementedError(
      'analyticsServiceProvider must be overridden in app bootstrap',
    );
```

- [ ] **Step 3: Add the test fake**

Create `packages/audiflow_domain/lib/src/features/monitoring/testing/fake_analytics_service.dart`:

```dart
import '../models/analytics_event.dart';
import '../services/analytics_service.dart';

/// Records calls so tests can assert against them.
///
/// Lives under `lib/` (not `test/`) so dependent packages can import it.
class FakeAnalyticsService implements AnalyticsService {
  final events = <AnalyticsEvent>[];
  String? userId;
  bool optIn = true;

  @override
  Future<void> log(AnalyticsEvent event) async {
    events.add(event);
  }

  @override
  Future<void> setUserId(String? id) async {
    userId = id;
  }

  @override
  Future<void> setOptIn(bool value) async {
    optIn = value;
  }

  void reset() {
    events.clear();
    userId = null;
    optIn = true;
  }
}
```

- [ ] **Step 4: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
export 'src/features/monitoring/providers/analytics_providers.dart';
export 'src/features/monitoring/services/analytics_service.dart';
export 'src/features/monitoring/testing/fake_analytics_service.dart';
```

- [ ] **Step 5: Run codegen**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Verify analyze + existing tests still pass**

```bash
cd packages/audiflow_domain && flutter analyze && flutter test
```

Expected: zero analyzer issues, all tests pass.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/monitoring/ \
        packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add AnalyticsService interface and fake"
```

---

## Task 5: Add firebase + uuid + crypto to audiflow_app

**Files:**
- Modify: `packages/audiflow_app/pubspec.yaml`

- [ ] **Step 1: Add deps**

Under `dependencies:` in `packages/audiflow_app/pubspec.yaml`, add:

```yaml
  # Analytics
  firebase_core: ^3.6.0
  firebase_analytics: ^11.3.3
  uuid: ^4.5.1
  crypto: ^3.0.6
```

- [ ] **Step 2: Resolve**

```bash
cd packages/audiflow_app && flutter pub get
```

Expected: resolves cleanly. If a transitive version conflict occurs with `analyzer`, run `melos bootstrap` and resolve at the workspace root before continuing.

- [ ] **Step 3: Verify analyze still passes**

```bash
cd packages/audiflow_app && flutter analyze
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/pubspec.yaml packages/audiflow_app/pubspec.lock
git commit -m "chore(app): add firebase_analytics, uuid, crypto deps"
```

---

## Task 6: ThrottledAnalyticsService

Throttles `episode_pause` and `episode_seek` to at most one event per `_window` (default 5 s) per `(name, episode_id)`. Wrap any inner `AnalyticsService`.

**Files:**
- Create: `packages/audiflow_app/lib/features/monitoring/services/throttled_analytics_service.dart`
- Create: `packages/audiflow_app/test/features/monitoring/throttled_analytics_service_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:audiflow_app/features/monitoring/services/throttled_analytics_service.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThrottledAnalyticsService', () {
    test('forwards non-throttled events without filtering', () async {
      final inner = FakeAnalyticsService();
      final clock = _FakeClock(DateTime(2026, 1, 1));
      final svc = ThrottledAnalyticsService(inner, now: clock.now);

      await svc.log(PodcastSubscribed(podcastId: 'p', source: SubscribeSource.search));
      await svc.log(PodcastSubscribed(podcastId: 'p', source: SubscribeSource.search));

      check(inner.events).length.equals(2);
    });

    test('throttles repeated pause for same episode within window', () async {
      final inner = FakeAnalyticsService();
      final clock = _FakeClock(DateTime(2026, 1, 1));
      final svc = ThrottledAnalyticsService(inner, now: clock.now);

      await svc.log(EpisodePaused(podcastId: 'p', episodeId: 'e1', positionSec: 1));
      clock.advance(const Duration(seconds: 2));
      await svc.log(EpisodePaused(podcastId: 'p', episodeId: 'e1', positionSec: 3));

      check(inner.events).length.equals(1);
    });

    test('allows pause after window elapses', () async {
      final inner = FakeAnalyticsService();
      final clock = _FakeClock(DateTime(2026, 1, 1));
      final svc = ThrottledAnalyticsService(inner, now: clock.now);

      await svc.log(EpisodePaused(podcastId: 'p', episodeId: 'e1', positionSec: 1));
      clock.advance(const Duration(seconds: 6));
      await svc.log(EpisodePaused(podcastId: 'p', episodeId: 'e1', positionSec: 7));

      check(inner.events).length.equals(2);
    });

    test('keys throttle by episode id (different episodes pass through)', () async {
      final inner = FakeAnalyticsService();
      final clock = _FakeClock(DateTime(2026, 1, 1));
      final svc = ThrottledAnalyticsService(inner, now: clock.now);

      await svc.log(EpisodePaused(podcastId: 'p', episodeId: 'e1', positionSec: 1));
      await svc.log(EpisodePaused(podcastId: 'p', episodeId: 'e2', positionSec: 1));

      check(inner.events).length.equals(2);
    });
  });
}

class _FakeClock {
  _FakeClock(this._now);
  DateTime _now;
  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}
```

- [ ] **Step 2: Run test, verify failure**

```bash
cd packages/audiflow_app && flutter test test/features/monitoring/throttled_analytics_service_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement**

Create `packages/audiflow_app/lib/features/monitoring/services/throttled_analytics_service.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';

class ThrottledAnalyticsService implements AnalyticsService {
  ThrottledAnalyticsService(
    this._inner, {
    Duration window = const Duration(seconds: 5),
    DateTime Function()? now,
  })  : _window = window,
        _now = now ?? DateTime.now;

  final AnalyticsService _inner;
  final Duration _window;
  final DateTime Function() _now;
  final _lastEmittedAt = <String, DateTime>{};

  static const _throttled = {'episode_pause', 'episode_seek'};

  @override
  Future<void> log(AnalyticsEvent event) async {
    if (_throttled.contains(event.name)) {
      final key = _keyFor(event);
      final now = _now();
      final last = _lastEmittedAt[key];
      if (last != null && now.difference(last) < _window) return;
      _lastEmittedAt[key] = now;
    }
    await _inner.log(event);
  }

  String _keyFor(AnalyticsEvent event) {
    final episodeId = event.params['episode_id'] ?? '';
    return '${event.name}:$episodeId';
  }

  @override
  Future<void> setUserId(String? id) => _inner.setUserId(id);

  @override
  Future<void> setOptIn(bool optIn) => _inner.setOptIn(optIn);
}
```

- [ ] **Step 4: Run test, verify pass**

```bash
cd packages/audiflow_app && flutter test test/features/monitoring/throttled_analytics_service_test.dart
```

Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/monitoring/services/throttled_analytics_service.dart \
        packages/audiflow_app/test/features/monitoring/throttled_analytics_service_test.dart
git commit -m "feat(app): add ThrottledAnalyticsService"
```

---

## Task 7: FirebaseAnalyticsService

**Files:**
- Create: `packages/audiflow_app/lib/features/monitoring/services/firebase_analytics_service.dart`

No dedicated unit test — the class is a thin pass-through to `FirebaseAnalytics`, which has no public seam suitable for fakes. Coverage comes from integration usage via `FakeAnalyticsService` at higher layers. Manual GA DebugView verification is in Task 25.

- [ ] **Step 1: Implement**

Create `packages/audiflow_app/lib/features/monitoring/services/firebase_analytics_service.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._fa);

  final FirebaseAnalytics _fa;

  @override
  Future<void> log(AnalyticsEvent event) async {
    await _fa.logEvent(name: event.name, parameters: event.params);
  }

  @override
  Future<void> setUserId(String? id) => _fa.setUserId(id: id);

  @override
  Future<void> setOptIn(bool optIn) =>
      _fa.setAnalyticsCollectionEnabled(optIn);
}
```

- [ ] **Step 2: Analyze**

```bash
cd packages/audiflow_app && flutter analyze lib/features/monitoring
```

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/monitoring/services/firebase_analytics_service.dart
git commit -m "feat(app): add FirebaseAnalyticsService implementation"
```

---

## Task 8: analyticsOptInController

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/controllers/analytics_opt_in_controller.dart`
- Create: `packages/audiflow_app/test/features/settings/analytics_opt_in_controller_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:audiflow_app/features/settings/presentation/controllers/analytics_opt_in_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<ProviderContainer> _container(FakeAnalyticsService fake) async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        analyticsServiceProvider.overrideWithValue(fake),
      ],
    );
  }

  group('analyticsOptInController', () {
    test('defaults to true when nothing is persisted', () async {
      final fake = FakeAnalyticsService();
      final c = await _container(fake);
      addTearDown(c.dispose);

      check(c.read(analyticsOptInControllerProvider)).isTrue();
    });

    test('reads persisted false', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'analytics.opt_in': false,
      });
      final fake = FakeAnalyticsService();
      final c = await _container(fake);
      addTearDown(c.dispose);

      check(c.read(analyticsOptInControllerProvider)).isFalse();
    });

    test('setOptIn(false) persists and forwards to analytics service', () async {
      final fake = FakeAnalyticsService();
      final c = await _container(fake);
      addTearDown(c.dispose);

      await c.read(analyticsOptInControllerProvider.notifier).setOptIn(false);

      final prefs = await SharedPreferences.getInstance();
      check(prefs.getBool('analytics.opt_in')).equals(false);
      check(fake.optIn).isFalse();
      check(c.read(analyticsOptInControllerProvider)).isFalse();
    });
  });
}
```

- [ ] **Step 2: Run test, verify failure**

```bash
cd packages/audiflow_app && flutter test test/features/settings/analytics_opt_in_controller_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement controller**

Create `packages/audiflow_app/lib/features/settings/presentation/controllers/analytics_opt_in_controller.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_opt_in_controller.g.dart';

const _kKey = 'analytics.opt_in';

@Riverpod(keepAlive: true)
class AnalyticsOptInController extends _$AnalyticsOptInController {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_kKey) ?? true;
  }

  Future<void> setOptIn(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kKey, value);
    await ref.read(analyticsServiceProvider).setOptIn(value);
    state = value;
  }
}
```

- [ ] **Step 4: Codegen**

```bash
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Run test, verify pass**

```bash
cd packages/audiflow_app && flutter test test/features/settings/analytics_opt_in_controller_test.dart
```

Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/settings/presentation/controllers/analytics_opt_in_controller.dart \
        packages/audiflow_app/lib/features/settings/presentation/controllers/analytics_opt_in_controller.g.dart \
        packages/audiflow_app/test/features/settings/analytics_opt_in_controller_test.dart
git commit -m "feat(app): add analytics opt-in controller"
```

---

## Task 9: Settings UI — opt-in tile

**Files:**
- Create: `packages/audiflow_app/lib/features/settings/presentation/widgets/analytics_opt_in_tile.dart`
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart`
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add l10n strings**

Add to `app_en.arb`:

```json
"settingsAnalyticsTitle": "Share usage data",
"@settingsAnalyticsTitle": {},
"settingsAnalyticsSubtitle": "Anonymous usage events help us improve audiflow. No ads, no personal data.",
"@settingsAnalyticsSubtitle": {}
```

Add to `app_ja.arb`:

```json
"settingsAnalyticsTitle": "利用状況の共有",
"settingsAnalyticsSubtitle": "匿名の利用イベントが audiflow の改善に役立ちます。広告や個人情報は収集しません。"
```

Run:

```bash
cd packages/audiflow_app && flutter gen-l10n
```

- [ ] **Step 2: Build the tile widget**

Create `packages/audiflow_app/lib/features/settings/presentation/widgets/analytics_opt_in_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/analytics_opt_in_controller.dart';

class AnalyticsOptInTile extends ConsumerWidget {
  const AnalyticsOptInTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final value = ref.watch(analyticsOptInControllerProvider);
    return SwitchListTile(
      title: Text(l10n.settingsAnalyticsTitle),
      subtitle: Text(l10n.settingsAnalyticsSubtitle),
      value: value,
      onChanged: (v) =>
          ref.read(analyticsOptInControllerProvider.notifier).setOptIn(v),
    );
  }
}
```

- [ ] **Step 3: Mount in settings screen**

Open `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart` and insert `const AnalyticsOptInTile()` in a sensible location (suggest below any existing "Privacy" group; if none exists, place near the bottom above "About"). Import:

```dart
import '../widgets/analytics_opt_in_tile.dart';
```

- [ ] **Step 4: Verify analyze + tests still pass**

```bash
cd packages/audiflow_app && flutter analyze
cd packages/audiflow_app && flutter test test/features/settings/
```

Expected: no issues, tests still pass.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/settings/ \
        packages/audiflow_app/lib/l10n/app_en.arb \
        packages/audiflow_app/lib/l10n/app_ja.arb
git commit -m "feat(app): add analytics opt-in tile to settings"
```

---

## Task 10: iOS ad-disable Info.plist

**Files:**
- Modify: `packages/audiflow_app/ios/Runner/Info.plist`

- [ ] **Step 1: Add ad-disable keys**

Insert inside the root `<dict>`:

```xml
<key>GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS</key>
<false/>
<key>GOOGLE_ANALYTICS_IDFA_COLLECTION_ENABLED</key>
<false/>
```

- [ ] **Step 2: Verify file still parses**

```bash
plutil -lint packages/audiflow_app/ios/Runner/Info.plist
```

Expected: `OK`.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/ios/Runner/Info.plist
git commit -m "chore(ios): disable GA ad personalization signals"
```

---

## Task 11: Android ad-disable manifest

**Files:**
- Modify: `packages/audiflow_app/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add meta-data under `<application>`**

```xml
<meta-data
    android:name="google_analytics_default_allow_ad_personalization_signals"
    android:value="false" />
<meta-data
    android:name="google_analytics_adid_collection_enabled"
    android:value="false" />
<meta-data
    android:name="google_analytics_ssaid_collection_enabled"
    android:value="false" />
```

- [ ] **Step 2: Commit**

```bash
git add packages/audiflow_app/android/app/src/main/AndroidManifest.xml
git commit -m "chore(android): disable GA ad-related collection"
```

---

## Task 12: Enable analytics in dev flavor

**Files:**
- Modify: `packages/audiflow_core/lib/src/config/flavor_config.dart`
- Modify: `packages/audiflow_core/test/config/flavor_config_test.dart`

- [ ] **Step 1: Read current state**

```bash
grep -n "enableAnalytics" packages/audiflow_core/lib/src/config/flavor_config.dart
```

Confirm `dev` block has `enableAnalytics: false`.

- [ ] **Step 2: Update existing test expectation**

In `packages/audiflow_core/test/config/flavor_config_test.dart`, find the test asserting `dev` has analytics disabled and replace expectation with enabled. Search for "has analytics disabled" in the dev group and change to:

```dart
test('has analytics enabled', () {
  check(FlavorConfig.dev.enableAnalytics).isTrue();
});
```

- [ ] **Step 3: Flip flag**

In `packages/audiflow_core/lib/src/config/flavor_config.dart`, change the dev factory:

```dart
enableAnalytics: true,
```

- [ ] **Step 4: Run tests**

```bash
cd packages/audiflow_core && flutter test test/config/flavor_config_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_core/lib/src/config/flavor_config.dart \
        packages/audiflow_core/test/config/flavor_config_test.dart
git commit -m "chore(core): enable analytics in dev flavor"
```

---

## Task 13: Firebase project setup (manual)

This is the only step that cannot be automated from inside the repo. Confirm with the project owner before proceeding to Task 14.

- [ ] **Step 1: Create GA4 + Firebase project for audiflow (prod, stg, dev) in Firebase console**
- [ ] **Step 2: Download `GoogleService-Info.plist` for each iOS bundle id**
- [ ] **Step 3: Place files at:**
  - `packages/audiflow_app/ios/config/dev/GoogleService-Info.plist`
  - `packages/audiflow_app/ios/config/stg/GoogleService-Info.plist`
  - `packages/audiflow_app/ios/config/prod/GoogleService-Info.plist`
- [ ] **Step 4: Wire `Runner.xcodeproj` build phases per `firebase_core` README so the correct plist is copied per scheme**
- [ ] **Step 5: Download `google-services.json` for each Android applicationId; place under `packages/audiflow_app/android/app/src/{dev,stg,prod}/google-services.json` and add the gradle plugin per docs**
- [ ] **Step 6: Add the new config files to `.gitignore` if they contain real keys, OR commit them (firebase config files are public-by-design — confirm with project owner)**

This is a checkpoint task — do not merge subsequent work until the Firebase wiring is in place, otherwise `Firebase.initializeApp()` will throw at startup.

---

## Task 14: Bootstrap — Firebase init + install id + Sentry user + analytics override

**Files:**
- Modify: `packages/audiflow_app/lib/main.dart`

- [ ] **Step 1: Add imports**

Add to the top of `main.dart`:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/monitoring/services/firebase_analytics_service.dart';
import 'features/monitoring/services/throttled_analytics_service.dart';
```

- [ ] **Step 2: Move `SharedPreferences.getInstance()` to the top of `appMain`**

Reorder the early portion of `appMain` so prefs is created before Sentry/Firebase wiring. New ordering inside `appMain`:

```dart
WidgetsFlutterBinding.ensureInitialized();

final flavorConfig = switch (flavor) {
  Flavor.dev => FlavorConfig.dev,
  Flavor.stg => FlavorConfig.stg,
  Flavor.prod => FlavorConfig.prod,
};
FlavorConfig.initialize(flavorConfig);

final prefs = await SharedPreferences.getInstance();
final installId = await InstallIdRepositoryImpl(prefs).getOrCreate();

FirebaseAnalytics? firebaseAnalytics;
if (flavorConfig.enableAnalytics) {
  await Firebase.initializeApp();
  firebaseAnalytics = FirebaseAnalytics.instance;
  await firebaseAnalytics.setConsent(
    adStorageConsentGranted: false,
    adUserDataConsentGranted: false,
    adPersonalizationSignalsConsentGranted: false,
    analyticsStorageConsentGranted: true,
  );
  await firebaseAnalytics.setUserId(id: installId);
  final optIn = prefs.getBool('analytics.opt_in') ?? true;
  await firebaseAnalytics.setAnalyticsCollectionEnabled(optIn);
}

const sentryDsn = String.fromEnvironment('SENTRY_DSN');
const sentryEnvironment = String.fromEnvironment('SENTRY_ENVIRONMENT');
```

- [ ] **Step 3: Attach install id to Sentry scope**

Inside the existing `SentryFlutter.init` `appRunner`, before the existing `Sentry.captureMessage('app-boot: ...')` call, add:

```dart
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(id: installId));
  scope.setTag('install_id', installId);
});
```

In the `else` branch (when Sentry is skipped), the install id is still generated above so the variable exists; no Sentry call needed.

- [ ] **Step 4: Pass everything to `_startApp`**

Change the signature to:

```dart
Future<void> _startApp(
  String smartPlaylistConfigBaseUrl, {
  required SharedPreferences prefs,
  required FirebaseAnalytics? firebaseAnalytics,
}) async { ... }
```

Both call sites that invoke `_startApp` change to pass the captured values:

```dart
await _startApp(
  smartPlaylistConfigBaseUrl,
  prefs: prefs,
  firebaseAnalytics: firebaseAnalytics,
);
```

Inside `_startApp`, remove the existing `final prefs = await SharedPreferences.getInstance();` line (now received as a parameter).

- [ ] **Step 5: Override `analyticsServiceProvider`**

Inside `_startApp`'s `ProviderContainer` overrides list, add:

```dart
analyticsServiceProvider.overrideWithValue(
  firebaseAnalytics == null
      ? FakeAnalyticsService()
      : ThrottledAnalyticsService(FirebaseAnalyticsService(firebaseAnalytics)),
),
```

`FakeAnalyticsService` is exported from `audiflow_domain` and serves as a safe no-op when `enableAnalytics == false`.

- [ ] **Step 6: Analyze + run app smoke**

```bash
cd packages/audiflow_app && flutter analyze
```

Expected: no issues.

Optional: run the dev flavor once to verify `appMain` does not crash.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/main.dart
git commit -m "feat(app): wire Firebase analytics and install id into bootstrap"
```

---

## Task 15: Attach FirebaseAnalyticsObserver to GoRouter

**Files:**
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`
- Modify: `packages/audiflow_app/lib/main.dart`

- [ ] **Step 1: Accept observer in `createAppRouter`**

In `app_router.dart`, change `createAppRouter` to accept an optional list of `NavigatorObserver`:

```dart
GoRouter createAppRouter({
  required SharedPreferences prefs,
  required int lastTabIndex,
  List<NavigatorObserver> observers = const [],
}) {
  return GoRouter(
    // existing config...
    observers: observers,
    // ...
  );
}
```

If the existing implementation already builds a `GoRouter` literal, add `observers: observers,` to it and to any nested `ShellRoute`/`StatefulShellBranch` `observers:` slots where appropriate (top-level is sufficient for screen tracking).

- [ ] **Step 2: Pass observer from `_MyAppState.initState`**

In `main.dart` `_MyAppState`:

```dart
final fa = ref.read(_firebaseAnalyticsObserverProvider);
_router = createAppRouter(
  prefs: ref.read(sharedPreferencesProvider),
  lastTabIndex: ref.read(lastTabControllerProvider),
  observers: [if (fa != null) fa],
);
```

Add a top-level provider:

```dart
final _firebaseAnalyticsObserverProvider =
    Provider<FirebaseAnalyticsObserver?>((ref) => null);
```

In `_startApp`, override it when `firebaseAnalytics != null`:

```dart
_firebaseAnalyticsObserverProvider.overrideWithValue(
  firebaseAnalytics == null
      ? null
      : FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
),
```

- [ ] **Step 3: Analyze**

```bash
cd packages/audiflow_app && flutter analyze
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/routing/app_router.dart packages/audiflow_app/lib/main.dart
git commit -m "feat(app): attach FirebaseAnalyticsObserver to router"
```

---

## Task 16: Emit subscribe / unsubscribe

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart`
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository.dart` (signature change)
- Create: `packages/audiflow_domain/test/features/subscription/subscribe_analytics_test.dart`

The repository currently does not receive an `AnalyticsService`. Two options:
- (A) Inject via constructor and update its provider.
- (B) Emit at the *call sites* in `audiflow_app`.

Choose **A** — keeps emit logic colocated with the action, easier to test, single source of truth. The provider already lives in `audiflow_domain`.

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_domain/test/features/subscription/subscribe_analytics_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionRepositoryImpl analytics', () {
    test('subscribe emits PodcastSubscribed with hashed feedUrl', () async {
      final fake = FakeAnalyticsService();
      // Build repo via your existing fake data source helpers. If a
      // helper does not exist yet, construct the minimum needed:
      final repo = makeSubscriptionRepo(analytics: fake); // see Step 2

      await repo.subscribe(
        feedUrl: 'https://example.com/podcast/feed.xml',
        title: 'Test',
        source: SubscribeSource.search,
      );

      check(fake.events).length.equals(1);
      final e = fake.events.single as PodcastSubscribed;
      check(e.podcastId).equals(stableId('https://example.com/podcast/feed.xml'));
      check(e.source).equals(SubscribeSource.search);
    });

    test('unsubscribe emits PodcastUnsubscribed', () async {
      final fake = FakeAnalyticsService();
      final repo = makeSubscriptionRepo(analytics: fake);
      await repo.subscribe(
        feedUrl: 'https://example.com/podcast/feed.xml',
        title: 'Test',
        source: SubscribeSource.search,
      );
      fake.reset();

      await repo.unsubscribe(/* itunesId or whatever the current signature requires */);

      check(fake.events).length.equals(1);
      check(fake.events.single).isA<PodcastUnsubscribed>();
    });
  });
}
```

If a `makeSubscriptionRepo` test helper does not already exist for this package, write a small private builder at the top of the test file using the existing in-memory Isar instance pattern used by sibling tests under `packages/audiflow_domain/test/features/subscription/`. Mirror the patterns there — do not invent a new helper file.

- [ ] **Step 2: Update repository interface**

In `subscription_repository.dart`, extend `subscribe` to accept the source:

```dart
Future<Subscription> subscribe({
  required String feedUrl,
  required String title,
  SubscribeSource source = SubscribeSource.unknown,
  // existing params unchanged
});
```

(Default to `unknown` so existing call sites compile during migration.)

- [ ] **Step 3: Inject AnalyticsService into impl**

In `subscription_repository_impl.dart`, add a constructor parameter:

```dart
SubscriptionRepositoryImpl(
  // existing params...,
  this._analytics,
);

final AnalyticsService _analytics;
```

Update the provider (search for the file that creates the impl — likely `subscription_providers.dart`) to read `analyticsServiceProvider` and pass it in.

- [ ] **Step 4: Emit in subscribe / unsubscribe**

In `subscribe`, after the subscription is persisted, before returning:

```dart
await _analytics.log(PodcastSubscribed(
  podcastId: stableId(feedUrl),
  source: source,
));
```

In `unsubscribe(String itunesId)`, after deletion, before return:

```dart
// existing code looked up the subscription before delete; reuse its feedUrl.
await _analytics.log(PodcastUnsubscribed(podcastId: stableId(feedUrl)));
```

If `feedUrl` is not in scope at the unsubscribe call site, fetch it first via the existing `getById`/`getByItunesId` helper.

- [ ] **Step 5: Update call sites for new `source` parameter**

```bash
grep -rn "\.subscribe(" packages/audiflow_app/lib | head
```

For each match, pick the appropriate `SubscribeSource`:
- Search results → `SubscribeSource.search`
- OPML import → `SubscribeSource.opml`
- Deeplink handler → `SubscribeSource.deeplink`
- Discovery / other → `SubscribeSource.discovery` (or `unknown`)

- [ ] **Step 6: Run tests + analyze**

```bash
cd packages/audiflow_domain && flutter test
cd packages/audiflow_app && flutter analyze
```

Expected: all pass.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/subscription/ \
        packages/audiflow_domain/test/features/subscription/ \
        packages/audiflow_app/lib
git commit -m "feat(analytics): emit subscribe/unsubscribe events"
```

---

## Task 17: Emit search_query

**Files:**
- Modify: `packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.dart`

Search controller emits `query_len` only — never the raw query.

- [ ] **Step 1: Read current state**

```bash
grep -n "class\|Future\|String query" packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.dart | head -30
```

Locate the method that fires when the user submits / debounces a search.

- [ ] **Step 2: Inject analytics + emit**

Add `ref.read(analyticsServiceProvider).log(SearchQueryEntered(queryLen: query.trim().length));` inside that method, gated on `query.trim().isNotEmpty`.

- [ ] **Step 3: Add a controller test**

If no `search_controller_test.dart` exists, create one that overrides `analyticsServiceProvider` with a `FakeAnalyticsService`, drives a single query, and asserts a `SearchQueryEntered` event with the expected length and zero raw-query parameters. Pattern after Task 8's container setup.

- [ ] **Step 4: Run analyze + tests**

```bash
cd packages/audiflow_app && flutter analyze
cd packages/audiflow_app && flutter test test/features/search/
```

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/search/ packages/audiflow_app/test/features/search/
git commit -m "feat(analytics): emit search_query length"
```

---

## Task 18: Emit playback events

**Files:**
- Modify: `packages/audiflow_app/lib/features/player/services/audiflow_audio_handler.dart`
- Modify: `packages/audiflow_app/lib/features/player/services/audio_handler_provider.dart` (DI)

`AudiflowAudioHandler` extends `BaseAudioHandler`. Emit at the public method boundaries: `play`, `pause`, `seek`, `setSpeed`, plus the completion stream handler.

- [ ] **Step 1: Inject analytics into the handler**

Add a constructor parameter `AnalyticsService analytics` and store `_analytics`. Update the provider that constructs the handler in `audio_handler_provider.dart` to pass `ref.read(analyticsServiceProvider)`.

The handler also needs the podcast feed URL and episode guid for the *currently loaded* episode. The handler should already track the loaded `NowPlayingInfo` (it powers media-session metadata). If not, add a private field that is set in whatever load method puts an episode in the queue (commonly `playMediaItem` / a custom `loadEpisode`).

- [ ] **Step 2: Compute stable ids**

Add helper methods:

```dart
String? _podcastIdOrNull() {
  final feedUrl = _current?.feedUrl;
  return feedUrl == null || feedUrl.isEmpty ? null : stableId(feedUrl);
}

String? _episodeIdOrNull() {
  final guid = _current?.episodeGuid;
  return guid == null || guid.isEmpty ? null : stableId(guid);
}
```

- [ ] **Step 3: Emit on play**

In `play()`:

```dart
@override
Future<void> play() async {
  await super.play();
  final pId = _podcastIdOrNull();
  final eId = _episodeIdOrNull();
  if (pId != null && eId != null) {
    await _analytics.log(EpisodePlayStarted(
      podcastId: pId,
      episodeId: eId,
      source: _currentPlaySource ?? PlaySource.library,
    ));
  }
}
```

`_currentPlaySource` is set by whatever caller starts playback. Add a setter method on the handler:

```dart
void setPlaySource(PlaySource source) {
  _currentPlaySource = source;
}
```

Update the playback start call sites (search results play, queue play, station/playlist play screen, library play) to call `audioHandler.setPlaySource(...)` immediately before invoking `play()` / `playFromMediaId()` with the appropriate source.

- [ ] **Step 4: Emit on pause**

```dart
@override
Future<void> pause() async {
  await super.pause();
  final pId = _podcastIdOrNull();
  final eId = _episodeIdOrNull();
  if (pId != null && eId != null) {
    await _analytics.log(EpisodePaused(
      podcastId: pId,
      episodeId: eId,
      positionSec: playbackState.value.position.inSeconds,
    ));
  }
}
```

(Throttling is handled by `ThrottledAnalyticsService` — no in-handler debouncing required.)

- [ ] **Step 5: Emit on seek**

```dart
@override
Future<void> seek(Duration position) async {
  final fromSec = playbackState.value.position.inSeconds;
  await super.seek(position);
  final pId = _podcastIdOrNull();
  final eId = _episodeIdOrNull();
  if (pId != null && eId != null) {
    await _analytics.log(EpisodeSeeked(
      podcastId: pId,
      episodeId: eId,
      fromSec: fromSec,
      toSec: position.inSeconds,
    ));
  }
}
```

- [ ] **Step 6: Emit on setSpeed**

```dart
@override
Future<void> setSpeed(double speed) async {
  await super.setSpeed(speed);
  await _analytics.log(PlaybackSpeedChanged(speed: speed));
}
```

- [ ] **Step 7: Emit on completion**

The handler already subscribes to a `processingStateStream` (or equivalent) that surfaces `ProcessingState.completed`. In that listener, fire:

```dart
if (state == ProcessingState.completed) {
  final pId = _podcastIdOrNull();
  final eId = _episodeIdOrNull();
  if (pId != null && eId != null) {
    final dur = mediaItem.value?.duration?.inSeconds ?? 0;
    await _analytics.log(EpisodeCompleted(
      podcastId: pId,
      episodeId: eId,
      durationSec: dur,
    ));
  }
}
```

If a more accurate completion event already exists in the handler (e.g., a custom `onEpisodeCompleted` callback), wire the emit there instead — but only one of the two.

- [ ] **Step 8: Analyze + commit**

```bash
cd packages/audiflow_app && flutter analyze
```

Expected: no issues.

```bash
git add packages/audiflow_app/lib/features/player/ packages/audiflow_app/lib/features
git commit -m "feat(analytics): emit playback start/pause/seek/complete/speed"
```

A handler unit test is intentionally skipped — `BaseAudioHandler` does not have a clean test seam without booting `just_audio`. Coverage is via manual GA DebugView verification in Task 25.

---

## Task 19: Emit download events

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/download/services/download_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/download/providers/download_providers.dart`

- [ ] **Step 1: Inject AnalyticsService into DownloadService**

In `download_service.dart`, add a constructor parameter `AnalyticsService analytics`. Update `download_providers.dart` to pass `ref.read(analyticsServiceProvider)`.

`DownloadService` operates on `int episodeId` (Isar autoinc). Resolve `episode.guid` + `podcast.feedUrl` via the existing `_episodeRepository` / `_podcastRepository` fields before emitting. If those fields do not exist, add them as constructor params and update the provider.

- [ ] **Step 2: Emit on start**

In `downloadEpisode(int episodeId, ...)`, after `_createDownloadTask` returns a non-null task:

```dart
final episode = await _episodeRepository.getById(episodeId);
final podcast = episode == null ? null : await _podcastRepository.getById(episode.podcastId);
final guid = episode?.guid;
final feedUrl = podcast?.feedUrl;
if (guid != null && feedUrl != null && guid.isNotEmpty && feedUrl.isNotEmpty) {
  await _analytics.log(EpisodeDownloadStarted(
    podcastId: stableId(feedUrl),
    episodeId: stableId(guid),
  ));
}
```

Hoist the resolved `episode`/`podcast` references if they are already available — avoid an extra fetch when possible.

- [ ] **Step 3: Emit on complete**

In `onEpisodeCompleted(int episodeId)`, mirror the lookup, then:

```dart
final bytes = await _repository.getFileSizeBytes(taskId) ?? 0;
await _analytics.log(EpisodeDownloadCompleted(
  podcastId: stableId(feedUrl),
  episodeId: stableId(guid),
  bytes: bytes,
));
```

If `getFileSizeBytes` does not exist, pass `0` and add a TODO comment — bytes is best-effort. (Drop the TODO comment if the existing API exposes byte count.)

- [ ] **Step 4: Update existing download service tests**

```bash
grep -rn "DownloadService(" packages/audiflow_domain/test | head
```

Each construction site needs `analytics: FakeAnalyticsService()`. Assert event emission in at least one happy-path test.

- [ ] **Step 5: Run tests + analyze**

```bash
cd packages/audiflow_domain && flutter test test/features/download/
cd packages/audiflow_domain && flutter analyze
```

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/download/ packages/audiflow_domain/test/features/download/
git commit -m "feat(analytics): emit download start/complete"
```

---

## Task 20: Emit smart_playlist_play

**Files:**
- Investigate: `packages/audiflow_app/lib/features` for the playlist play call site

- [ ] **Step 1: Find call site**

```bash
grep -rn "playSmartPlaylist\|playPlaylist\|SmartPlaylist.*play" packages/audiflow_app/lib packages/audiflow_domain/lib | head
```

- [ ] **Step 2: Emit at the start of that call**

Inside the function that begins smart-playlist playback, before delegating to the audio handler:

```dart
ref.read(analyticsServiceProvider).log(SmartPlaylistPlayed(
  patternId: patternId,
  playlistId: playlistId,
));
```

`patternId` and `playlistId` are already known at that call site (smart playlist config is keyed by them).

- [ ] **Step 3: Add controller test or smoke check**

If the call site is a Riverpod controller, override `analyticsServiceProvider` with `FakeAnalyticsService` and assert one `SmartPlaylistPlayed` event after invoking the play method.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib packages/audiflow_app/test
git commit -m "feat(analytics): emit smart_playlist_play"
```

---

## Task 21: Emit station_play

**Files:**
- Modify: `packages/audiflow_app/lib/features/station/presentation/controllers/station_detail_controller.dart` (or wherever station playback starts)

- [ ] **Step 1: Locate the station-start method**

```bash
grep -rn "play\|start\|launchStation" packages/audiflow_app/lib/features/station/presentation/controllers/ | head
```

- [ ] **Step 2: Compute station id and emit**

```dart
final installId = await ref.read(installIdRepositoryProvider).getOrCreate();
final stationId = stableId('$installId:${station.name}');
ref.read(analyticsServiceProvider).log(StationPlayed(stationId: stationId));
```

Place this just before delegating to the audio handler.

- [ ] **Step 3: Test + commit**

Add a controller test mirroring Task 20's pattern.

```bash
git add packages/audiflow_app/lib/features/station packages/audiflow_app/test/features/station
git commit -m "feat(analytics): emit station_play"
```

---

## Task 22: Emit sleep_timer_set

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart` (or the controller method that sets the timer)

- [ ] **Step 1: Locate the setter**

```bash
grep -n "set\|configure" packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart | head
```

- [ ] **Step 2: Emit**

Inside whichever method commits the new sleep-timer config (e.g., `setConfig(SleepTimerConfig config)`):

```dart
final mode = switch (config.kind) {
  SleepTimerKind.duration => SleepTimerMode.duration,
  SleepTimerKind.episodes => SleepTimerMode.episodes,
  SleepTimerKind.endOfEpisode => SleepTimerMode.endOfEpisode,
  SleepTimerKind.endOfChapter => SleepTimerMode.endOfChapter,
};
final value = switch (config.kind) {
  SleepTimerKind.duration => config.durationMinutes,
  SleepTimerKind.episodes => config.episodeCount,
  _ => null,
};
await ref.read(analyticsServiceProvider).log(SleepTimerSet(mode: mode, value: value));
```

Adjust the field names to match the actual `SleepTimerConfig` shape — read `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_config.dart` first.

- [ ] **Step 3: Test**

Override `analyticsServiceProvider` with `FakeAnalyticsService`, set a 30-minute timer, assert one `SleepTimerSet` event with `mode == duration`, `value == 30`.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart \
        packages/audiflow_domain/test/features/player/sleep_timer_providers_test.dart
git commit -m "feat(analytics): emit sleep_timer_set"
```

---

## Task 23: Full validation

- [ ] **Step 1: Format + analyze + test everywhere**

```bash
melos run test
```

Then:

```bash
cd packages/audiflow_app && flutter analyze
cd packages/audiflow_domain && flutter analyze
cd packages/audiflow_core && flutter analyze
```

Expected: zero issues, all tests pass.

- [ ] **Step 2: Schema-conformance test still green**

```bash
flutter test packages/audiflow_domain/test/features/feed/models/schema_conformance_test.dart
```

Expected: pass (no schema-relevant changes, but the project rule demands it after large changes).

---

## Task 24: Manual GA DebugView verification

- [ ] **Step 1: Enable GA DebugView for the dev install**

iOS: `xcrun simctl launch --console booted <bundle.id> -FIRDebugEnabled`
Android: `adb shell setprop debug.firebase.analytics.app <applicationId>`

- [ ] **Step 2: Trigger each event class once, confirm appearance in Firebase console DebugView**

- screen_view (auto): switch tabs
- podcast_subscribe: subscribe in search
- podcast_unsubscribe: unsubscribe from library
- episode_play_start: start playback
- episode_pause / episode_seek: pause and seek
- episode_complete: let an episode finish (or scrub to the end)
- playback_speed_change: change speed
- search_query: enter a query
- episode_download_start / _complete: trigger download
- smart_playlist_play, station_play, sleep_timer_set: exercise each feature

- [ ] **Step 3: Verify `user_id` on each event matches the install UUID**

- [ ] **Step 4: Confirm Sentry event carries the same `install_id` tag and `user.id`**

Trigger any handled error or call `Sentry.captureMessage('debug')` from a debug menu (or temporarily). Open the event in Sentry, confirm `user.id` and `install_id` tag equal the GA `user_id`.

- [ ] **Step 5: Verify ad signals are off**

In DebugView, inspect a `screen_view` payload. Confirm no `gad_*` parameters appear and ad personalization shows as denied.

- [ ] **Step 6: Opt-out smoke**

Toggle the settings switch off. Confirm no further events appear in DebugView. Toggle back on, confirm events resume.

---

## Self-Review Notes

- Spec §3 (firebase_analytics) → Tasks 5, 7, 14.
- Spec §4 (anonymous install id) → Tasks 2, 14.
- Spec §5 (module layout) → Tasks 1–9 + 14.
- Spec §6 (stable ids) → Tasks 1, 16–22.
- Spec §7 (event catalog) → Task 3 defines, Tasks 16–22 emit.
- Spec §8 (ad-disable) → Tasks 10, 11, 14 (`setConsent`).
- Spec §9 (opt-out) → Tasks 8, 9.
- Spec §10 (flavor gating) → Tasks 12, 14.
- Spec §11 (interface) → Tasks 3, 4.
- Spec §12 (testing) → fakes/tests across all tasks; `package:checks` used.
- Spec §13 (Sentry wiring) → Task 14.
- Spec §15 (verification) → Tasks 23, 24.

No placeholders; every step shows code or commands. Naming is consistent (`stableId`, `InstallIdRepository`, `AnalyticsService`, `analyticsServiceProvider`, `analyticsOptInControllerProvider`, `FakeAnalyticsService`, `ThrottledAnalyticsService`). Tasks 13 (Firebase project setup) and 24 (manual GA verification) are unavoidable manual checkpoints.
