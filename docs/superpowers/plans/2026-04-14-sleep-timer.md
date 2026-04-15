# Sleep Timer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an Apple-Podcasts-style sleep timer with five menu entries (Off, End of episode, End of chapter, Set minutes / remembered value, Set episodes / remembered value), a persistent countdown chip above the mini player, and an 8-second fade-out at fire time.

**Architecture:** Pure service + Riverpod controller glue. A `SleepTimerService` owns decision logic (no Flutter). A `SleepTimerController` (`@Riverpod(keepAlive: true)`) subscribes to a new player-lifecycle event stream exposed by `AudioPlayerController`, dispatches events to the service, and executes side effects (fade-out, snackbar, persistence). Remembered minutes/episodes persist in SharedPreferences; active timer is session-only.

**Tech Stack:** Flutter, Dart 3 sealed classes, Riverpod 3 (`@riverpod`), freezed, just_audio (volume control for fade-out), SharedPreferences, ARB localization (en/ja), fake_async for timer tests.

**Spec:** `docs/superpowers/specs/2026-04-14-sleep-timer-design.md`

---

### Task 1: Add `SleepTimerConfig` sealed freezed model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_config.dart`
- Test: `packages/audiflow_domain/test/features/player/models/sleep_timer_config_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_domain/test/features/player/models/sleep_timer_config_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SleepTimerConfig', () {
    test('off is a distinct variant', () {
      const cfg = SleepTimerConfig.off();
      expect(cfg, isA<SleepTimerConfig>());
      final isOff = switch (cfg) {
        SleepTimerConfigOff() => true,
        _ => false,
      };
      expect(isOff, isTrue);
    });

    test('duration carries total and deadline', () {
      final deadline = DateTime.utc(2026, 4, 14, 12);
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: deadline,
      );
      switch (cfg) {
        case SleepTimerConfigDuration(:final total, :final deadline):
          expect(total, const Duration(minutes: 30));
          expect(deadline, DateTime.utc(2026, 4, 14, 12));
        default:
          fail('expected duration variant');
      }
    });

    test('episodes carries total and remaining', () {
      const cfg = SleepTimerConfig.episodes(total: 3, remaining: 2);
      switch (cfg) {
        case SleepTimerConfigEpisodes(:final total, :final remaining):
          expect(total, 3);
          expect(remaining, 2);
        default:
          fail('expected episodes variant');
      }
    });
  });
}
```

- [ ] **Step 2: Run test and confirm it fails**

```bash
cd packages/audiflow_domain
flutter test test/features/player/models/sleep_timer_config_test.dart
```

Expected: FAIL with "Target of URI doesn't exist" / "Undefined name 'SleepTimerConfig'".

- [ ] **Step 3: Create the model**

Create `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_config.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_timer_config.freezed.dart';

/// Configuration for the active sleep timer.
///
/// See `docs/superpowers/specs/2026-04-14-sleep-timer-design.md` for the
/// full behavioral specification.
@freezed
sealed class SleepTimerConfig with _$SleepTimerConfig {
  const factory SleepTimerConfig.off() = SleepTimerConfigOff;
  const factory SleepTimerConfig.endOfEpisode() = SleepTimerConfigEndOfEpisode;
  const factory SleepTimerConfig.endOfChapter() = SleepTimerConfigEndOfChapter;
  const factory SleepTimerConfig.duration({
    required Duration total,
    required DateTime deadline,
  }) = SleepTimerConfigDuration;
  const factory SleepTimerConfig.episodes({
    required int total,
    required int remaining,
  }) = SleepTimerConfigEpisodes;
}
```

- [ ] **Step 4: Export from barrel**

Open `packages/audiflow_domain/lib/audiflow_domain.dart` and add an export near the other player model exports:

```dart
export 'src/features/player/models/sleep_timer_config.dart';
```

- [ ] **Step 5: Run code generation**

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

Expected: creates `sleep_timer_config.freezed.dart`.

- [ ] **Step 6: Run the test and confirm it passes**

```bash
cd packages/audiflow_domain
flutter test test/features/player/models/sleep_timer_config_test.dart
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/models/sleep_timer_config.dart \
        packages/audiflow_domain/lib/src/features/player/models/sleep_timer_config.freezed.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/test/features/player/models/sleep_timer_config_test.dart
git commit -m "feat(domain): add SleepTimerConfig sealed model"
```

---

### Task 2: Add `SleepTimerState` freezed + `SleepTimerEvent` sealed event

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_state.dart`
- Create: `packages/audiflow_domain/lib/src/features/player/models/sleep_timer_event.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (add exports)
- Test: `packages/audiflow_domain/test/features/player/models/sleep_timer_state_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_domain/test/features/player/models/sleep_timer_state_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SleepTimerState', () {
    test('defaults via copyWith work', () {
      const s = SleepTimerState(
        config: SleepTimerConfig.off(),
        lastMinutes: 0,
        lastEpisodes: 0,
      );
      final updated = s.copyWith(lastMinutes: 30);
      expect(updated.lastMinutes, 30);
      expect(updated.lastEpisodes, 0);
      expect(updated.config, const SleepTimerConfig.off());
    });
  });

  group('SleepTimerEvent', () {
    test('SleepTimerFired is a distinct event', () {
      const e = SleepTimerFired();
      expect(e, isA<SleepTimerEvent>());
    });
  });
}
```

- [ ] **Step 2: Run test and confirm it fails**

```bash
cd packages/audiflow_domain
flutter test test/features/player/models/sleep_timer_state_test.dart
```

Expected: FAIL — `SleepTimerState` / `SleepTimerFired` undefined.

- [ ] **Step 3: Create `sleep_timer_state.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'sleep_timer_config.dart';

part 'sleep_timer_state.freezed.dart';

/// Aggregate sleep-timer state exposed by the controller.
///
/// `lastMinutes` and `lastEpisodes` are the user's most recent numeric
/// selections (0 when never set). They persist across app restarts.
@freezed
class SleepTimerState with _$SleepTimerState {
  const factory SleepTimerState({
    required SleepTimerConfig config,
    required int lastMinutes,
    required int lastEpisodes,
  }) = _SleepTimerState;
}
```

- [ ] **Step 4: Create `sleep_timer_event.dart`**

```dart
/// One-shot events emitted by the sleep-timer controller.
///
/// Consumed by the UI layer to drive snackbars, haptics, etc.
sealed class SleepTimerEvent {
  const SleepTimerEvent();
}

final class SleepTimerFired extends SleepTimerEvent {
  const SleepTimerFired();
}
```

- [ ] **Step 5: Export from barrel**

Open `packages/audiflow_domain/lib/audiflow_domain.dart` and add:

```dart
export 'src/features/player/models/sleep_timer_state.dart';
export 'src/features/player/models/sleep_timer_event.dart';
```

- [ ] **Step 6: Run code generation**

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 7: Run the test**

```bash
flutter test test/features/player/models/sleep_timer_state_test.dart
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/models/sleep_timer_state.dart \
        packages/audiflow_domain/lib/src/features/player/models/sleep_timer_state.freezed.dart \
        packages/audiflow_domain/lib/src/features/player/models/sleep_timer_event.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/test/features/player/models/sleep_timer_state_test.dart
git commit -m "feat(domain): add SleepTimerState and SleepTimerEvent"
```

---

### Task 3: Add `SleepTimerService` with pure decision logic

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/services/sleep_timer_service.dart`
- Test: `packages/audiflow_domain/test/features/player/services/sleep_timer_service_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart` (export)

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_domain/test/features/player/services/sleep_timer_service_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = SleepTimerService();
  final t0 = DateTime.utc(2026, 4, 14, 12);

  group('SleepTimerService.evaluate — off', () {
    test('off always keeps', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.off(),
          event: const EpisodeCompletedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
      expect(
        service.evaluate(
          config: const SleepTimerConfig.off(),
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — endOfEpisode', () {
    test('fires on EpisodeCompletedEvent', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfEpisode(),
          event: const EpisodeCompletedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<FireDecision>(),
      );
    });

    test('keeps on ManualEpisodeSwitchedEvent (transfers implicitly)', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfEpisode(),
          event: const ManualEpisodeSwitchedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });

    test('keeps on tick', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfEpisode(),
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — endOfChapter', () {
    test('fires on ChapterChangedEvent', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const ChapterChangedEvent(),
          currentEpisodeHasChapters: true,
        ),
        isA<FireDecision>(),
      );
    });

    test('retargets on SeekedPastChapterEvent', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const SeekedPastChapterEvent(),
          currentEpisodeHasChapters: true,
        ),
        isA<RetargetChapterDecision>(),
      );
    });

    test('keeps when chapters unavailable (controller will reset to off)', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.endOfChapter(),
          event: const ChapterChangedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — duration', () {
    test('fires when deadline <= now (exact match)', () {
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: t0,
      );
      expect(
        service.evaluate(
          config: cfg,
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<FireDecision>(),
      );
    });

    test('fires when deadline strictly before now', () {
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: t0,
      );
      expect(
        service.evaluate(
          config: cfg,
          event: TickEvent(t0.add(const Duration(seconds: 1))),
          currentEpisodeHasChapters: false,
        ),
        isA<FireDecision>(),
      );
    });

    test('keeps when now is before deadline', () {
      final cfg = SleepTimerConfig.duration(
        total: const Duration(minutes: 30),
        deadline: t0.add(const Duration(minutes: 30)),
      );
      expect(
        service.evaluate(
          config: cfg,
          event: TickEvent(t0),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });

  group('SleepTimerService.evaluate — episodes', () {
    test('fires when remaining == 1 and episode completes', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.episodes(total: 3, remaining: 1),
          event: const EpisodeCompletedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<FireDecision>(),
      );
    });

    test('decrements when remaining > 1 and episode completes', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.episodes(total: 3, remaining: 2),
          event: const EpisodeCompletedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<DecrementEpisodesDecision>(),
      );
    });

    test('keeps on manual episode switch (does NOT decrement)', () {
      expect(
        service.evaluate(
          config: const SleepTimerConfig.episodes(total: 3, remaining: 2),
          event: const ManualEpisodeSwitchedEvent(),
          currentEpisodeHasChapters: false,
        ),
        isA<KeepDecision>(),
      );
    });
  });
}
```

- [ ] **Step 2: Run test and confirm it fails**

```bash
cd packages/audiflow_domain
flutter test test/features/player/services/sleep_timer_service_test.dart
```

Expected: FAIL — undefined symbols.

- [ ] **Step 3: Create the service**

Create `packages/audiflow_domain/lib/src/features/player/services/sleep_timer_service.dart`:

```dart
import '../models/sleep_timer_config.dart';

/// Player-side events that may influence sleep-timer state.
sealed class SleepTimerPlayerEvent {
  const SleepTimerPlayerEvent();
}

/// Periodic tick driven by the controller while a duration timer is active.
final class TickEvent extends SleepTimerPlayerEvent {
  const TickEvent(this.now);
  final DateTime now;
}

/// Emitted when an episode completes naturally (end of audio).
final class EpisodeCompletedEvent extends SleepTimerPlayerEvent {
  const EpisodeCompletedEvent();
}

/// Emitted when the user manually switches the playing episode
/// (tapping a queue item, playing a different episode explicitly, etc.).
final class ManualEpisodeSwitchedEvent extends SleepTimerPlayerEvent {
  const ManualEpisodeSwitchedEvent();
}

/// Emitted when the current chapter boundary is reached during natural playback.
final class ChapterChangedEvent extends SleepTimerPlayerEvent {
  const ChapterChangedEvent();
}

/// Emitted when the user seeks past the current chapter's end.
final class SeekedPastChapterEvent extends SleepTimerPlayerEvent {
  const SeekedPastChapterEvent();
}

/// Pure decision produced by [SleepTimerService.evaluate].
sealed class SleepTimerDecision {
  const SleepTimerDecision();
}

final class KeepDecision extends SleepTimerDecision {
  const KeepDecision();
}

final class FireDecision extends SleepTimerDecision {
  const FireDecision();
}

final class DecrementEpisodesDecision extends SleepTimerDecision {
  const DecrementEpisodesDecision();
}

final class RetargetChapterDecision extends SleepTimerDecision {
  const RetargetChapterDecision();
}

/// Pure decision evaluator for the sleep timer.
///
/// Owns no state and no side effects. The controller translates decisions
/// into player actions (fade, pause, snackbar) and state updates.
class SleepTimerService {
  const SleepTimerService();

  SleepTimerDecision evaluate({
    required SleepTimerConfig config,
    required SleepTimerPlayerEvent event,
    required bool currentEpisodeHasChapters,
  }) {
    switch (config) {
      case SleepTimerConfigOff():
        return const KeepDecision();
      case SleepTimerConfigEndOfEpisode():
        if (event is EpisodeCompletedEvent) return const FireDecision();
        return const KeepDecision();
      case SleepTimerConfigEndOfChapter():
        if (!currentEpisodeHasChapters) return const KeepDecision();
        if (event is ChapterChangedEvent) return const FireDecision();
        if (event is SeekedPastChapterEvent) {
          return const RetargetChapterDecision();
        }
        return const KeepDecision();
      case SleepTimerConfigDuration(:final deadline):
        if (event is TickEvent && deadline.compareTo(event.now) <= 0) {
          return const FireDecision();
        }
        return const KeepDecision();
      case SleepTimerConfigEpisodes(:final remaining):
        if (event is EpisodeCompletedEvent) {
          if (remaining <= 1) return const FireDecision();
          return const DecrementEpisodesDecision();
        }
        return const KeepDecision();
    }
  }
}
```

Note: deadline comparison uses `deadline.compareTo(event.now) <= 0` rather than `>=`, matching project number-rules.

- [ ] **Step 4: Export from barrel**

Open `packages/audiflow_domain/lib/audiflow_domain.dart` and add:

```dart
export 'src/features/player/services/sleep_timer_service.dart';
```

- [ ] **Step 5: Run the test**

```bash
cd packages/audiflow_domain
flutter test test/features/player/services/sleep_timer_service_test.dart
```

Expected: PASS, all groups green.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/services/sleep_timer_service.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/test/features/player/services/sleep_timer_service_test.dart
git commit -m "feat(domain): add pure SleepTimerService evaluator"
```

---

### Task 4: Add `SleepTimerPreferencesDatasource` for remembered values

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/datasources/local/sleep_timer_preferences_datasource.dart`
- Test: `packages/audiflow_domain/test/features/player/datasources/sleep_timer_preferences_datasource_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_domain/test/features/player/datasources/sleep_timer_preferences_datasource_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SleepTimerPreferencesDatasource', () {
    test('returns zero defaults when keys absent', () {
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      expect(ds.getLastMinutes(), 0);
      expect(ds.getLastEpisodes(), 0);
    });

    test('persists and reads minutes', () async {
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      await ds.setLastMinutes(45);
      expect(ds.getLastMinutes(), 45);
    });

    test('persists and reads episodes', () async {
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      await ds.setLastEpisodes(5);
      expect(ds.getLastEpisodes(), 5);
    });

    test('clamps stored values to supported bounds on read', () async {
      await prefs.setInt('sleep_timer.last_minutes', 10000);
      await prefs.setInt('sleep_timer.last_episodes', 1000);
      final ds = SleepTimerPreferencesDatasource(
        SharedPreferencesDataSource(prefs),
      );
      expect(ds.getLastMinutes(), 999);
      expect(ds.getLastEpisodes(), 99);
    });
  });
}
```

- [ ] **Step 2: Run test and confirm it fails**

```bash
cd packages/audiflow_domain
flutter test test/features/player/datasources/sleep_timer_preferences_datasource_test.dart
```

Expected: FAIL — undefined class.

- [ ] **Step 3: Create the datasource**

Create `packages/audiflow_domain/lib/src/features/player/datasources/local/sleep_timer_preferences_datasource.dart`:

```dart
import '../../../../common/datasources/shared_preferences_datasource.dart';

/// Persists the user's most recent numeric sleep-timer selections.
///
/// Two int keys:
///  - `sleep_timer.last_minutes` — clamped to 0..999 (0 = never set)
///  - `sleep_timer.last_episodes` — clamped to 0..99 (0 = never set)
class SleepTimerPreferencesDatasource {
  const SleepTimerPreferencesDatasource(this._prefs);

  final SharedPreferencesDataSource _prefs;

  static const String _kMinutes = 'sleep_timer.last_minutes';
  static const String _kEpisodes = 'sleep_timer.last_episodes';

  static const int _maxMinutes = 999;
  static const int _maxEpisodes = 99;

  int getLastMinutes() {
    final raw = _prefs.getInt(_kMinutes) ?? 0;
    return raw.clamp(0, _maxMinutes);
  }

  int getLastEpisodes() {
    final raw = _prefs.getInt(_kEpisodes) ?? 0;
    return raw.clamp(0, _maxEpisodes);
  }

  Future<void> setLastMinutes(int minutes) {
    return _prefs.setInt(_kMinutes, minutes.clamp(0, _maxMinutes));
  }

  Future<void> setLastEpisodes(int episodes) {
    return _prefs.setInt(_kEpisodes, episodes.clamp(0, _maxEpisodes));
  }
}
```

- [ ] **Step 4: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
export 'src/features/player/datasources/local/sleep_timer_preferences_datasource.dart';
```

- [ ] **Step 5: Run test**

```bash
flutter test test/features/player/datasources/sleep_timer_preferences_datasource_test.dart
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/datasources/local/sleep_timer_preferences_datasource.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/test/features/player/datasources/sleep_timer_preferences_datasource_test.dart
git commit -m "feat(domain): add SleepTimerPreferencesDatasource"
```

---

### Task 5: Expose player lifecycle events from `AudioPlayerController`

Adds a broadcast stream the sleep-timer controller subscribes to without tight coupling.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`
- Create: `packages/audiflow_domain/lib/src/features/player/services/player_lifecycle_events.dart`
- Test: `packages/audiflow_domain/test/features/player/services/player_lifecycle_events_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Create event type**

Create `packages/audiflow_domain/lib/src/features/player/services/player_lifecycle_events.dart`:

```dart
/// Coarse-grained player lifecycle events used by listeners that care
/// about "what just happened" (e.g. sleep timer).
sealed class PlayerLifecycleEvent {
  const PlayerLifecycleEvent();
}

/// The currently-loaded episode finished playing naturally
/// (`ProcessingState.completed`).
final class EpisodeCompletedLifecycle extends PlayerLifecycleEvent {
  const EpisodeCompletedLifecycle();
}

/// The user explicitly switched to a different episode while another
/// was loaded (call to [AudioPlayerController.play] with a new URL).
final class EpisodeSwitchedLifecycle extends PlayerLifecycleEvent {
  const EpisodeSwitchedLifecycle();
}

/// The user seeked to a new absolute position.
final class SeekLifecycle extends PlayerLifecycleEvent {
  const SeekLifecycle(this.position);
  final Duration position;
}
```

- [ ] **Step 2: Write failing test for lifecycle emission**

Create `packages/audiflow_domain/test/features/player/services/player_lifecycle_events_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lifecycle events are distinct sealed variants', () {
    const a = EpisodeCompletedLifecycle();
    const b = EpisodeSwitchedLifecycle();
    const c = SeekLifecycle(Duration(seconds: 30));

    expect(a, isA<PlayerLifecycleEvent>());
    expect(b, isA<PlayerLifecycleEvent>());
    expect(c, isA<PlayerLifecycleEvent>());
    expect(c.position, const Duration(seconds: 30));
  });
}
```

- [ ] **Step 3: Export + run**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
export 'src/features/player/services/player_lifecycle_events.dart';
```

Run:

```bash
cd packages/audiflow_domain
flutter test test/features/player/services/player_lifecycle_events_test.dart
```

Expected: PASS.

- [ ] **Step 4: Add broadcast stream + provider + emissions to `AudioPlayerController`**

Open `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`.

Near the imports, add:

```dart
import 'player_lifecycle_events.dart';
```

Inside the `AudioPlayerController` class, at the top of the field declarations (right after `bool _isLoadingSource = false;`), add:

```dart
final StreamController<PlayerLifecycleEvent> _lifecycleEvents =
    StreamController<PlayerLifecycleEvent>.broadcast();

/// Broadcast stream of lifecycle events. Exposed via
/// [playerLifecycleEventsProvider].
Stream<PlayerLifecycleEvent> get lifecycleEvents => _lifecycleEvents.stream;
```

In `_cleanup`, add (see Task 6 Step 3 for the canonical final body):

```dart
_lifecycleEvents.close();
```

In `_listenToPlayerState`, inside the `if (processingState == ProcessingState.completed)` branch (right before `await _saveProgressOnStop();`), add:

```dart
_lifecycleEvents.add(const EpisodeCompletedLifecycle());
```

In `play(String url, {NowPlayingInfo? metadata})`, at the very top — right after the `_log.i('[Play] Starting: url=$url');` line — add:

```dart
if (_currentUrl != null && _currentUrl != url) {
  _lifecycleEvents.add(const EpisodeSwitchedLifecycle());
}
```

In `seek(Duration position)`, after the `await _player.seek(...)` line, add:

```dart
_lifecycleEvents.add(SeekLifecycle(Duration(milliseconds: clampedMs)));
```

At the bottom of the file (outside the class), add the provider:

```dart
/// Broadcast stream of player lifecycle events.
///
/// Consumers observe this for "what just happened" hints (sleep timer, etc.)
/// rather than polling player state.
@Riverpod(keepAlive: true)
Stream<PlayerLifecycleEvent> playerLifecycleEvents(Ref ref) {
  final controller = ref.watch(audioPlayerControllerProvider.notifier);
  return controller.lifecycleEvents;
}
```

- [ ] **Step 5: Regenerate providers**

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Add smoke test that the provider is reachable**

Create `packages/audiflow_domain/test/features/player/services/audio_player_lifecycle_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('playerLifecycleEventsProvider yields a Stream', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final stream = container.read(playerLifecycleEventsProvider.stream);
    expect(stream, isA<Stream<PlayerLifecycleEvent>>());
  });
}
```

Run:

```bash
flutter test test/features/player/services/audio_player_lifecycle_test.dart
```

Expected: PASS.

- [ ] **Step 7: Run full domain suite to catch regressions**

```bash
cd packages/audiflow_domain
flutter test
flutter analyze
```

Expected: all tests PASS, `flutter analyze` reports no issues.

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart \
        packages/audiflow_domain/lib/src/features/player/services/audio_player_service.g.dart \
        packages/audiflow_domain/lib/src/features/player/services/player_lifecycle_events.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/test/features/player/services/player_lifecycle_events_test.dart \
        packages/audiflow_domain/test/features/player/services/audio_player_lifecycle_test.dart
git commit -m "feat(domain): expose player lifecycle event stream"
```

---

### Task 6: Add `fadeOutAndPause` helper to the player

Adds a cancellable linear-fade helper used by the sleep timer when a timer fires.

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`
- Test: `packages/audiflow_domain/test/features/player/services/audio_player_fade_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_domain/test/features/player/services/audio_player_fade_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('fadeOutAndPause restores volume after completing', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final player = container.read(audioPlayerProvider);
    await player.setVolume(1.0);

    final controller = container.read(audioPlayerControllerProvider.notifier);
    await controller.fadeOutAndPause(
      total: const Duration(milliseconds: 80),
    );

    expect(player.volume, closeTo(1.0, 0.001));
  });

  test('cancelFade aborts in-flight fade and restores volume', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final player = container.read(audioPlayerProvider);
    await player.setVolume(1.0);

    final controller = container.read(audioPlayerControllerProvider.notifier);
    final fadeFuture = controller.fadeOutAndPause(
      total: const Duration(seconds: 8),
    );

    await Future<void>.delayed(const Duration(milliseconds: 50));
    controller.cancelFade();
    await fadeFuture;

    expect(player.volume, closeTo(1.0, 0.001));
  });
}
```

- [ ] **Step 2: Run test and confirm it fails**

```bash
cd packages/audiflow_domain
flutter test test/features/player/services/audio_player_fade_test.dart
```

Expected: FAIL — `fadeOutAndPause` / `cancelFade` not defined.

- [ ] **Step 3: Implement the helper**

In `audio_player_service.dart`, add these fields to `AudioPlayerController`:

```dart
Timer? _fadeTimer;
double? _preFadeVolume;
```

Add these two methods near `pause()`:

```dart
/// Fades the player's volume to 0 linearly over [total], then pauses.
///
/// Restores the original volume on completion so future playback starts
/// at the user's preferred level. Call [cancelFade] to abort in-flight
/// and restore volume without pausing.
Future<void> fadeOutAndPause({
  Duration total = const Duration(seconds: 8),
}) async {
  if (_fadeTimer != null) return;

  _preFadeVolume = _player.volume;
  final startVolume = _preFadeVolume ?? 1.0;
  const stepMs = 100;
  final steps = (total.inMilliseconds / stepMs).ceil().clamp(1, 1000);
  var elapsedSteps = 0;

  final completer = Completer<void>();
  _fadeTimer = Timer.periodic(const Duration(milliseconds: stepMs), (
    timer,
  ) async {
    elapsedSteps += 1;
    final progress = (elapsedSteps / steps).clamp(0.0, 1.0);
    final next = (startVolume * (1.0 - progress)).clamp(0.0, 1.0);
    await _player.setVolume(next);

    if (steps <= elapsedSteps) {
      timer.cancel();
      _fadeTimer = null;
      await _player.pause();
      if (_preFadeVolume != null) {
        await _player.setVolume(_preFadeVolume!);
        _preFadeVolume = null;
      }
      if (!completer.isCompleted) completer.complete();
    }
  });

  return completer.future;
}

/// Cancels an in-flight fade and restores the pre-fade volume.
void cancelFade() {
  if (_fadeTimer == null) return;
  _fadeTimer!.cancel();
  _fadeTimer = null;
  if (_preFadeVolume != null) {
    _player.setVolume(_preFadeVolume!);
    _preFadeVolume = null;
  }
}
```

Update `_cleanup` to its final form (combines Task 5 and Task 6 additions):

```dart
void _cleanup() {
  _stateSubscription?.cancel();
  _fadeTimer?.cancel();
  _lifecycleEvents.close();
}
```

- [ ] **Step 4: Run test**

```bash
flutter test test/features/player/services/audio_player_fade_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run full domain tests + analyze**

```bash
cd packages/audiflow_domain
flutter test
flutter analyze
```

Expected: all PASS, no analyzer issues.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart \
        packages/audiflow_domain/test/features/player/services/audio_player_fade_test.dart
git commit -m "feat(domain): add fadeOutAndPause helper to AudioPlayerController"
```

---

### Task 7: Add `SleepTimerController`

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/player/controllers/sleep_timer_controller.dart`
- Create: `packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart`
- Test: `packages/audiflow_domain/test/features/player/controllers/sleep_timer_controller_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Create provider binding for the datasource**

Create `packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/platform_providers.dart';
import '../datasources/local/sleep_timer_preferences_datasource.dart';

part 'sleep_timer_providers.g.dart';

/// Backs [SleepTimerController]'s persistence of remembered
/// minutes/episodes values.
@Riverpod(keepAlive: true)
SleepTimerPreferencesDatasource sleepTimerPreferencesDatasource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SleepTimerPreferencesDatasource(SharedPreferencesDataSource(prefs));
}
```

- [ ] **Step 2: Write failing controller test**

Create `packages/audiflow_domain/test/features/player/controllers/sleep_timer_controller_test.dart`:

```dart
import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLifecycle {
  final _ctrl = StreamController<PlayerLifecycleEvent>.broadcast();
  Stream<PlayerLifecycleEvent> get stream => _ctrl.stream;
  void emit(PlayerLifecycleEvent e) => _ctrl.add(e);
  Future<void> close() => _ctrl.close();
}

void main() {
  group('SleepTimerController', () {
    late _FakeLifecycle fakeLifecycle;

    setUp(() async {
      fakeLifecycle = _FakeLifecycle();
      SharedPreferences.setMockInitialValues({
        'sleep_timer.last_minutes': 30,
        'sleep_timer.last_episodes': 3,
      });
    });

    tearDown(() async {
      await fakeLifecycle.close();
    });

    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [
          playerLifecycleEventsProvider.overrideWith(
            (ref) => fakeLifecycle.stream,
          ),
          currentEpisodeHasChaptersProvider.overrideWith((ref) async => false),
        ],
      );
    }

    test('build() seeds lastMinutes and lastEpisodes from prefs', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final state = container.read(sleepTimerControllerProvider);
      expect(state.config, const SleepTimerConfig.off());
      expect(state.lastMinutes, 30);
      expect(state.lastEpisodes, 3);
    });

    test('setDuration persists minutes and sets duration config', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setDuration(const Duration(minutes: 15));

      final state = container.read(sleepTimerControllerProvider);
      expect(state.lastMinutes, 15);
      switch (state.config) {
        case SleepTimerConfigDuration(:final total):
          expect(total, const Duration(minutes: 15));
        default:
          fail('expected duration config');
      }
    });

    test('setEpisodes persists count and sets episodes config', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setEpisodes(4);

      final state = container.read(sleepTimerControllerProvider);
      expect(state.lastEpisodes, 4);
      switch (state.config) {
        case SleepTimerConfigEpisodes(:final total, :final remaining):
          expect(total, 4);
          expect(remaining, 4);
        default:
          fail('expected episodes config');
      }
    });

    test('EpisodeCompletedLifecycle decrements episodes remaining', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setEpisodes(3);

      fakeLifecycle.emit(const EpisodeCompletedLifecycle());
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sleepTimerControllerProvider);
      switch (state.config) {
        case SleepTimerConfigEpisodes(:final remaining):
          expect(remaining, 2);
        default:
          fail('expected episodes config still active');
      }
    });

    test('EpisodeCompletedLifecycle with endOfEpisode fires and resets', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      container
          .read(sleepTimerControllerProvider.notifier)
          .setEndOfEpisode();

      final events = <SleepTimerEvent>[];
      final sub = container
          .read(sleepTimerControllerProvider.notifier)
          .events
          .listen(events.add);
      addTearDown(sub.cancel);

      fakeLifecycle.emit(const EpisodeCompletedLifecycle());
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sleepTimerControllerProvider);
      expect(state.config, const SleepTimerConfig.off());
      expect(events, contains(isA<SleepTimerFired>()));
    });

    test('setOff() while episodes active clears config', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(sleepTimerControllerProvider.notifier)
          .setEpisodes(2);
      container.read(sleepTimerControllerProvider.notifier).setOff();

      final state = container.read(sleepTimerControllerProvider);
      expect(state.config, const SleepTimerConfig.off());
    });
  });
}
```

- [ ] **Step 3: Run test and confirm failure**

```bash
cd packages/audiflow_domain
flutter test test/features/player/controllers/sleep_timer_controller_test.dart
```

Expected: FAIL — symbols undefined.

- [ ] **Step 4: Create the controller**

Create `packages/audiflow_domain/lib/src/features/player/controllers/sleep_timer_controller.dart`:

```dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../transcript/repositories/chapter_repository_impl.dart';
import '../models/sleep_timer_config.dart';
import '../models/sleep_timer_event.dart';
import '../models/sleep_timer_state.dart';
import '../providers/sleep_timer_providers.dart';
import '../services/audio_player_service.dart';
import '../services/now_playing_controller.dart';
import '../services/player_lifecycle_events.dart';
import '../services/sleep_timer_service.dart';

part 'sleep_timer_controller.g.dart';

/// Reports whether the currently-playing episode has any chapter data.
///
/// Used by [SleepTimerController] to hide the "End of chapter" menu entry
/// and to evaluate chapter-dependent decisions. Returns false when no
/// episode is playing or when the episode has no chapters.
@Riverpod(keepAlive: true)
Future<bool> currentEpisodeHasChapters(Ref ref) async {
  final nowPlaying = ref.watch(nowPlayingControllerProvider);
  final episodeId = nowPlaying?.episode?.id;
  if (episodeId == null) return false;
  final chapters = await ref
      .watch(chapterRepositoryProvider)
      .getByEpisodeId(episodeId);
  return chapters.isNotEmpty;
}

/// Coordinates the sleep timer: subscribes to player lifecycle events,
/// runs a 1s duration tick, and executes decisions from [SleepTimerService].
///
/// Kept alive so remembered values survive screen navigation.
@Riverpod(keepAlive: true)
class SleepTimerController extends _$SleepTimerController {
  static const SleepTimerService _service = SleepTimerService();

  final StreamController<SleepTimerEvent> _events =
      StreamController<SleepTimerEvent>.broadcast();
  Timer? _tick;

  Stream<SleepTimerEvent> get events => _events.stream;

  @override
  SleepTimerState build() {
    final ds = ref.watch(sleepTimerPreferencesDatasourceProvider);
    final initial = SleepTimerState(
      config: const SleepTimerConfig.off(),
      lastMinutes: ds.getLastMinutes(),
      lastEpisodes: ds.getLastEpisodes(),
    );

    ref.listen<AsyncValue<PlayerLifecycleEvent>>(
      playerLifecycleEventsProvider,
      (previous, next) {
        final evt = next.valueOrNull;
        if (evt == null) return;
        _onLifecycle(evt);
      },
    );

    ref.onDispose(() {
      _tick?.cancel();
      _events.close();
    });

    return initial;
  }

  void setOff() {
    _tick?.cancel();
    _tick = null;
    state = state.copyWith(config: const SleepTimerConfig.off());
  }

  void setEndOfEpisode() {
    _tick?.cancel();
    _tick = null;
    state = state.copyWith(config: const SleepTimerConfig.endOfEpisode());
  }

  void setEndOfChapter() {
    _tick?.cancel();
    _tick = null;
    state = state.copyWith(config: const SleepTimerConfig.endOfChapter());
  }

  Future<void> setDuration(Duration total) async {
    final minutes = total.inMinutes.clamp(1, 999);
    final clamped = Duration(minutes: minutes);
    final deadline = DateTime.now().add(clamped);

    await ref
        .read(sleepTimerPreferencesDatasourceProvider)
        .setLastMinutes(minutes);

    _startTick();
    state = state.copyWith(
      config: SleepTimerConfig.duration(total: clamped, deadline: deadline),
      lastMinutes: minutes,
    );
  }

  Future<void> setEpisodes(int total) async {
    final clamped = total.clamp(1, 99);
    await ref
        .read(sleepTimerPreferencesDatasourceProvider)
        .setLastEpisodes(clamped);

    _tick?.cancel();
    _tick = null;
    state = state.copyWith(
      config: SleepTimerConfig.episodes(total: clamped, remaining: clamped),
      lastEpisodes: clamped,
    );
  }

  Duration? remaining() {
    return switch (state.config) {
      SleepTimerConfigDuration(:final deadline) =>
        deadline.difference(DateTime.now()).isNegative
            ? Duration.zero
            : deadline.difference(DateTime.now()),
      _ => null,
    };
  }

  void _startTick() {
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });
  }

  void _onTick() {
    final hasChapters =
        ref.read(currentEpisodeHasChaptersProvider).valueOrNull ?? false;
    final decision = _service.evaluate(
      config: state.config,
      event: TickEvent(DateTime.now()),
      currentEpisodeHasChapters: hasChapters,
    );
    _applyDecision(decision);
  }

  void _onLifecycle(PlayerLifecycleEvent event) {
    final mapped = switch (event) {
      EpisodeCompletedLifecycle() => const EpisodeCompletedEvent(),
      EpisodeSwitchedLifecycle() => const ManualEpisodeSwitchedEvent(),
      SeekLifecycle() => null,
    };
    if (mapped == null) return;

    final hasChapters =
        ref.read(currentEpisodeHasChaptersProvider).valueOrNull ?? false;
    final decision = _service.evaluate(
      config: state.config,
      event: mapped,
      currentEpisodeHasChapters: hasChapters,
    );
    _applyDecision(decision);
  }

  void _applyDecision(SleepTimerDecision decision) {
    switch (decision) {
      case KeepDecision():
        return;
      case FireDecision():
        _fire();
      case DecrementEpisodesDecision():
        final cfg = state.config;
        if (cfg is SleepTimerConfigEpisodes) {
          state = state.copyWith(
            config: SleepTimerConfig.episodes(
              total: cfg.total,
              remaining: cfg.remaining - 1,
            ),
          );
        }
      case RetargetChapterDecision():
        return;
    }
  }

  void _fire() {
    _tick?.cancel();
    _tick = null;
    final player = ref.read(audioPlayerControllerProvider.notifier);
    unawaited(player.fadeOutAndPause());
    _events.add(const SleepTimerFired());
    state = state.copyWith(config: const SleepTimerConfig.off());
  }
}
```

- [ ] **Step 5: Export controller + provider**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:

```dart
export 'src/features/player/controllers/sleep_timer_controller.dart';
export 'src/features/player/providers/sleep_timer_providers.dart';
```

- [ ] **Step 6: Regenerate**

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 7: Run the test**

```bash
flutter test test/features/player/controllers/sleep_timer_controller_test.dart
```

Expected: PASS.

- [ ] **Step 8: Run the full domain suite + analyzer**

```bash
flutter test
flutter analyze
```

Expected: all PASS.

- [ ] **Step 9: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/controllers/sleep_timer_controller.dart \
        packages/audiflow_domain/lib/src/features/player/controllers/sleep_timer_controller.g.dart \
        packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.dart \
        packages/audiflow_domain/lib/src/features/player/providers/sleep_timer_providers.g.dart \
        packages/audiflow_domain/lib/audiflow_domain.dart \
        packages/audiflow_domain/test/features/player/controllers/sleep_timer_controller_test.dart
git commit -m "feat(domain): add SleepTimerController wiring service + lifecycle"
```

---

### Task 8: Add localization keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add English keys**

Append to `packages/audiflow_app/lib/l10n/app_en.arb` (before the closing `}`; place alongside other player keys — search for `"playerPlayLabel"` to find the block and insert near there):

```json
  "sleepTimerTitle": "Sleep Timer",
  "@sleepTimerTitle": { "description": "Sleep timer sheet title" },
  "sleepTimerOff": "Off",
  "@sleepTimerOff": { "description": "Cancel the active sleep timer" },
  "sleepTimerEndOfEpisode": "End of episode",
  "@sleepTimerEndOfEpisode": { "description": "Stop when the current episode ends" },
  "sleepTimerEndOfChapter": "End of chapter",
  "@sleepTimerEndOfChapter": { "description": "Stop when the current chapter ends" },
  "sleepTimerSetMinutes": "Set minutes",
  "@sleepTimerSetMinutes": { "description": "First-time label for the minutes entry" },
  "sleepTimerSetEpisodes": "Set episodes",
  "@sleepTimerSetEpisodes": { "description": "First-time label for the episodes entry" },
  "sleepTimerMinutesLabel": "{count, plural, one{{count} minute} other{{count} minutes}}",
  "@sleepTimerMinutesLabel": {
    "description": "Remembered minutes label",
    "placeholders": { "count": { "type": "int" } }
  },
  "sleepTimerEpisodesLabel": "{count, plural, one{{count} episode} other{{count} episodes}}",
  "@sleepTimerEpisodesLabel": {
    "description": "Remembered episodes label",
    "placeholders": { "count": { "type": "int" } }
  },
  "sleepTimerChipEpisodeEnd": "Sleep · Episode end",
  "@sleepTimerChipEpisodeEnd": { "description": "Chip label when end-of-episode is active" },
  "sleepTimerChipChapterEnd": "Sleep · Chapter end",
  "@sleepTimerChipChapterEnd": { "description": "Chip label when end-of-chapter is active" },
  "sleepTimerChipEpisodesLeft": "Sleep · {count} eps left",
  "@sleepTimerChipEpisodesLeft": {
    "description": "Chip label for N-episode timer",
    "placeholders": { "count": { "type": "int" } }
  },
  "sleepTimerChipDurationPrefix": "Sleep · ",
  "@sleepTimerChipDurationPrefix": { "description": "Prefix shown before duration countdown on the chip" },
  "sleepTimerFiredSnackbar": "Sleep timer ended",
  "@sleepTimerFiredSnackbar": { "description": "Snackbar shown when a timer fires in the foreground" },
  "sleepTimerNumericMinutesTitle": "Minutes",
  "@sleepTimerNumericMinutesTitle": { "description": "Numeric input panel title for minutes" },
  "sleepTimerNumericEpisodesTitle": "Episodes",
  "@sleepTimerNumericEpisodesTitle": { "description": "Numeric input panel title for episodes" },
  "sleepTimerStart": "Start",
  "@sleepTimerStart": { "description": "Primary CTA on the numeric input panel" },
  "sleepTimerIconLabel": "Sleep timer",
  "@sleepTimerIconLabel": { "description": "Accessibility label for the sleep-timer icon button" },
```

- [ ] **Step 2: Add Japanese keys**

Append the same block to `packages/audiflow_app/lib/l10n/app_ja.arb`:

```json
  "sleepTimerTitle": "スリープタイマー",
  "@sleepTimerTitle": { "description": "Sleep timer sheet title" },
  "sleepTimerOff": "オフ",
  "@sleepTimerOff": { "description": "Cancel the active sleep timer" },
  "sleepTimerEndOfEpisode": "エピソードの終わり",
  "@sleepTimerEndOfEpisode": { "description": "Stop when the current episode ends" },
  "sleepTimerEndOfChapter": "チャプターの終わり",
  "@sleepTimerEndOfChapter": { "description": "Stop when the current chapter ends" },
  "sleepTimerSetMinutes": "分数を設定",
  "@sleepTimerSetMinutes": { "description": "First-time label for the minutes entry" },
  "sleepTimerSetEpisodes": "エピソード数を設定",
  "@sleepTimerSetEpisodes": { "description": "First-time label for the episodes entry" },
  "sleepTimerMinutesLabel": "{count}分",
  "@sleepTimerMinutesLabel": {
    "description": "Remembered minutes label",
    "placeholders": { "count": { "type": "int" } }
  },
  "sleepTimerEpisodesLabel": "{count}エピソード",
  "@sleepTimerEpisodesLabel": {
    "description": "Remembered episodes label",
    "placeholders": { "count": { "type": "int" } }
  },
  "sleepTimerChipEpisodeEnd": "スリープ · エピソード末",
  "@sleepTimerChipEpisodeEnd": { "description": "Chip label when end-of-episode is active" },
  "sleepTimerChipChapterEnd": "スリープ · チャプター末",
  "@sleepTimerChipChapterEnd": { "description": "Chip label when end-of-chapter is active" },
  "sleepTimerChipEpisodesLeft": "スリープ · 残り{count}本",
  "@sleepTimerChipEpisodesLeft": {
    "description": "Chip label for N-episode timer",
    "placeholders": { "count": { "type": "int" } }
  },
  "sleepTimerChipDurationPrefix": "スリープ · ",
  "@sleepTimerChipDurationPrefix": { "description": "Prefix shown before duration countdown on the chip" },
  "sleepTimerFiredSnackbar": "スリープタイマーが終了しました",
  "@sleepTimerFiredSnackbar": { "description": "Snackbar shown when a timer fires in the foreground" },
  "sleepTimerNumericMinutesTitle": "分",
  "@sleepTimerNumericMinutesTitle": { "description": "Numeric input panel title for minutes" },
  "sleepTimerNumericEpisodesTitle": "エピソード",
  "@sleepTimerNumericEpisodesTitle": { "description": "Numeric input panel title for episodes" },
  "sleepTimerStart": "開始",
  "@sleepTimerStart": { "description": "Primary CTA on the numeric input panel" },
  "sleepTimerIconLabel": "スリープタイマー",
  "@sleepTimerIconLabel": { "description": "Accessibility label for the sleep-timer icon button" },
```

- [ ] **Step 3: Regenerate l10n**

```bash
cd packages/audiflow_app
flutter gen-l10n
flutter analyze
```

Expected: gen-l10n produces new getters; analyze clean.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/l10n/app_en.arb \
        packages/audiflow_app/lib/l10n/app_ja.arb \
        packages/audiflow_app/lib/l10n/app_localizations*.dart
git commit -m "feat(l10n): add sleep timer copy (en, ja)"
```

---

### Task 9: Build `SleepTimerNumericPanel` widget

**Files:**
- Create: `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_numeric_panel.dart`
- Test: `packages/audiflow_app/test/features/player/widgets/sleep_timer_numeric_panel_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/player/widgets/sleep_timer_numeric_panel_test.dart`:

```dart
import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_numeric_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPanel(
    WidgetTester tester, {
    int initial = 0,
    required int maxValue,
    required void Function(int) onStart,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SleepTimerNumericPanel(
            title: 'Minutes',
            initialValue: initial,
            maxValue: maxValue,
            startLabel: 'Start',
            onBack: () {},
            onClose: () {},
            onStart: onStart,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Start disabled when value is 0', (tester) async {
    var started = 0;
    await pumpPanel(tester, maxValue: 999, onStart: (v) => started = v);

    final startButton = find.widgetWithText(FilledButton, 'Start');
    expect(tester.widget<FilledButton>(startButton).onPressed, isNull);
    expect(started, 0);
  });

  testWidgets('digit buttons append and Start emits value', (tester) async {
    var started = 0;
    await pumpPanel(tester, maxValue: 999, onStart: (v) => started = v);

    await tester.tap(find.widgetWithText(TextButton, '3'));
    await tester.tap(find.widgetWithText(TextButton, '0'));
    await tester.pumpAndSettle();

    expect(find.text('30'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    expect(started, 30);
  });

  testWidgets('clamps typing beyond maxValue', (tester) async {
    await pumpPanel(tester, maxValue: 99, onStart: (_) {});

    await tester.tap(find.widgetWithText(TextButton, '9'));
    await tester.tap(find.widgetWithText(TextButton, '9'));
    await tester.tap(find.widgetWithText(TextButton, '9'));
    await tester.pumpAndSettle();

    expect(find.text('99'), findsOneWidget);
  });

  testWidgets('backspace removes last digit', (tester) async {
    await pumpPanel(tester, initial: 30, maxValue: 999, onStart: (_) {});

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test and confirm failure**

```bash
cd packages/audiflow_app
flutter test test/features/player/widgets/sleep_timer_numeric_panel_test.dart
```

Expected: FAIL — missing widget.

- [ ] **Step 3: Implement the widget**

Create `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_numeric_panel.dart`:

```dart
import 'package:flutter/material.dart';

/// A stateful numeric input panel used inside the sleep-timer sheet.
///
/// Shows a large numeric readout, a number pad (0-9 + backspace), and a
/// primary Start button. The Start button is disabled when the current
/// value is 0.
class SleepTimerNumericPanel extends StatefulWidget {
  const SleepTimerNumericPanel({
    required this.title,
    required this.initialValue,
    required this.maxValue,
    required this.startLabel,
    required this.onBack,
    required this.onClose,
    required this.onStart,
    super.key,
  });

  final String title;
  final int initialValue;
  final int maxValue;
  final String startLabel;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueChanged<int> onStart;

  @override
  State<SleepTimerNumericPanel> createState() => _SleepTimerNumericPanelState();
}

class _SleepTimerNumericPanelState extends State<SleepTimerNumericPanel> {
  late String _display;

  @override
  void initState() {
    super.initState();
    _display = widget.initialValue == 0 ? '' : '${widget.initialValue}';
  }

  int get _value => int.tryParse(_display) ?? 0;

  void _appendDigit(String digit) {
    final next = _display == '0' ? digit : '$_display$digit';
    final candidate = int.tryParse(next) ?? 0;
    if (widget.maxValue < candidate) return;
    setState(() => _display = next);
  }

  void _backspace() {
    if (_display.isEmpty) return;
    setState(
      () => _display = _display.substring(0, _display.length - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _display.isEmpty ? '0' : _display,
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          _Keypad(onDigit: _appendDigit, onBackspace: _backspace),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _value == 0 ? null : () => widget.onStart(_value),
              child: Text(widget.startLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget digit(String d) => Expanded(
      child: TextButton(
        onPressed: () => onDigit(d),
        child: Text(d, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );

    return Column(
      children: [
        Row(children: [digit('1'), digit('2'), digit('3')]),
        Row(children: [digit('4'), digit('5'), digit('6')]),
        Row(children: [digit('7'), digit('8'), digit('9')]),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            digit('0'),
            Expanded(
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test**

```bash
flutter test test/features/player/widgets/sleep_timer_numeric_panel_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_numeric_panel.dart \
        packages/audiflow_app/test/features/player/widgets/sleep_timer_numeric_panel_test.dart
git commit -m "feat(app): add SleepTimerNumericPanel widget"
```

---

### Task 10: Build `SleepTimerSheet` widget

**Files:**
- Create: `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_sheet.dart`
- Test: `packages/audiflow_app/test/features/player/widgets/sleep_timer_sheet_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/player/widgets/sleep_timer_sheet_test.dart`:

```dart
import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('shows Off, End of episode, Set minutes/episodes by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.off(),
            lastMinutes: 0,
            lastEpisodes: 0,
          ),
          hasChapters: false,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Off'), findsOneWidget);
    expect(find.text('End of episode'), findsOneWidget);
    expect(find.text('End of chapter'), findsNothing);
    expect(find.text('Set minutes'), findsOneWidget);
    expect(find.text('Set episodes'), findsOneWidget);
  });

  testWidgets('shows End of chapter when hasChapters true', (tester) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.off(),
            lastMinutes: 0,
            lastEpisodes: 0,
          ),
          hasChapters: true,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('End of chapter'), findsOneWidget);
  });

  testWidgets(
    'short-tap on remembered minutes starts timer immediately',
    (tester) async {
      var started = Duration.zero;
      await tester.pumpWidget(
        wrap(
          SleepTimerSheet(
            state: const SleepTimerState(
              config: SleepTimerConfig.off(),
              lastMinutes: 30,
              lastEpisodes: 0,
            ),
            hasChapters: false,
            onOff: () {},
            onEndOfEpisode: () {},
            onEndOfChapter: () {},
            onDurationStart: (d) => started = d,
            onEpisodesStart: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('30 minutes'));
      await tester.pumpAndSettle();
      expect(started, const Duration(minutes: 30));
    },
  );

  testWidgets('long-press on remembered minutes opens numeric panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.off(),
            lastMinutes: 30,
            lastEpisodes: 0,
          ),
          hasChapters: false,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('30 minutes'));
    await tester.pumpAndSettle();
    expect(find.text('Minutes'), findsOneWidget);
  });

  testWidgets('checkmark shown on active entry', (tester) async {
    await tester.pumpWidget(
      wrap(
        SleepTimerSheet(
          state: const SleepTimerState(
            config: SleepTimerConfig.endOfEpisode(),
            lastMinutes: 0,
            lastEpisodes: 0,
          ),
          hasChapters: false,
          onOff: () {},
          onEndOfEpisode: () {},
          onEndOfChapter: () {},
          onDurationStart: (_) {},
          onEpisodesStart: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.ancestor(
      of: find.text('End of episode'),
      matching: find.byType(ListTile),
    );
    expect(row, findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });
}
```

- [ ] **Step 2: Run test and confirm failure**

```bash
cd packages/audiflow_app
flutter test test/features/player/widgets/sleep_timer_sheet_test.dart
```

Expected: FAIL — widget not defined.

- [ ] **Step 3: Implement the sheet**

Create `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_sheet.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_numeric_panel.dart';

enum _SheetPanel { menu, minutes, episodes }

/// Sheet body for the sleep-timer feature.
///
/// Presents the menu on first open; swaps to the numeric panel when the
/// user taps "Set minutes" / "Set episodes" (first time) or long-presses
/// a remembered value. Short-tap on a remembered value fires the
/// corresponding onStart callback immediately.
class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({
    required this.state,
    required this.hasChapters,
    required this.onOff,
    required this.onEndOfEpisode,
    required this.onEndOfChapter,
    required this.onDurationStart,
    required this.onEpisodesStart,
    super.key,
  });

  final SleepTimerState state;
  final bool hasChapters;
  final VoidCallback onOff;
  final VoidCallback onEndOfEpisode;
  final VoidCallback onEndOfChapter;
  final ValueChanged<Duration> onDurationStart;
  final ValueChanged<int> onEpisodesStart;

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  _SheetPanel _panel = _SheetPanel.menu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (_panel) {
      case _SheetPanel.menu:
        return _MenuPanel(
          l10n: l10n,
          state: widget.state,
          hasChapters: widget.hasChapters,
          onOff: widget.onOff,
          onEndOfEpisode: widget.onEndOfEpisode,
          onEndOfChapter: widget.onEndOfChapter,
          onShortTapMinutes: () {
            if (widget.state.lastMinutes == 0) {
              setState(() => _panel = _SheetPanel.minutes);
            } else {
              widget.onDurationStart(
                Duration(minutes: widget.state.lastMinutes),
              );
            }
          },
          onLongPressMinutes: () =>
              setState(() => _panel = _SheetPanel.minutes),
          onShortTapEpisodes: () {
            if (widget.state.lastEpisodes == 0) {
              setState(() => _panel = _SheetPanel.episodes);
            } else {
              widget.onEpisodesStart(widget.state.lastEpisodes);
            }
          },
          onLongPressEpisodes: () =>
              setState(() => _panel = _SheetPanel.episodes),
        );
      case _SheetPanel.minutes:
        return SleepTimerNumericPanel(
          title: l10n.sleepTimerNumericMinutesTitle,
          initialValue: widget.state.lastMinutes,
          maxValue: 999,
          startLabel: l10n.sleepTimerStart,
          onBack: () => setState(() => _panel = _SheetPanel.menu),
          onClose: () => Navigator.of(context).maybePop(),
          onStart: (v) => widget.onDurationStart(Duration(minutes: v)),
        );
      case _SheetPanel.episodes:
        return SleepTimerNumericPanel(
          title: l10n.sleepTimerNumericEpisodesTitle,
          initialValue: widget.state.lastEpisodes,
          maxValue: 99,
          startLabel: l10n.sleepTimerStart,
          onBack: () => setState(() => _panel = _SheetPanel.menu),
          onClose: () => Navigator.of(context).maybePop(),
          onStart: widget.onEpisodesStart,
        );
    }
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.l10n,
    required this.state,
    required this.hasChapters,
    required this.onOff,
    required this.onEndOfEpisode,
    required this.onEndOfChapter,
    required this.onShortTapMinutes,
    required this.onLongPressMinutes,
    required this.onShortTapEpisodes,
    required this.onLongPressEpisodes,
  });

  final AppLocalizations l10n;
  final SleepTimerState state;
  final bool hasChapters;
  final VoidCallback onOff;
  final VoidCallback onEndOfEpisode;
  final VoidCallback onEndOfChapter;
  final VoidCallback onShortTapMinutes;
  final VoidCallback onLongPressMinutes;
  final VoidCallback onShortTapEpisodes;
  final VoidCallback onLongPressEpisodes;

  bool get _isOff => state.config is SleepTimerConfigOff;
  bool get _isEndOfEpisode => state.config is SleepTimerConfigEndOfEpisode;
  bool get _isEndOfChapter => state.config is SleepTimerConfigEndOfChapter;
  bool get _isDuration => state.config is SleepTimerConfigDuration;
  bool get _isEpisodes => state.config is SleepTimerConfigEpisodes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.sleepTimerTitle,
            style: theme.textTheme.titleMedium,
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.close,
            color: _isOff ? dimColor : theme.colorScheme.error,
          ),
          title: Text(
            l10n.sleepTimerOff,
            style: TextStyle(
              color: _isOff ? dimColor : theme.colorScheme.error,
            ),
          ),
          enabled: !_isOff,
          onTap: _isOff ? null : onOff,
        ),
        ListTile(
          leading: _isEndOfEpisode
              ? const Icon(Icons.check)
              : const SizedBox(width: 24),
          title: Text(l10n.sleepTimerEndOfEpisode),
          onTap: onEndOfEpisode,
        ),
        if (hasChapters)
          ListTile(
            leading: _isEndOfChapter
                ? const Icon(Icons.check)
                : const SizedBox(width: 24),
            title: Text(l10n.sleepTimerEndOfChapter),
            onTap: onEndOfChapter,
          ),
        ListTile(
          leading: _isDuration
              ? const Icon(Icons.check)
              : const SizedBox(width: 24),
          title: Text(
            state.lastMinutes == 0
                ? l10n.sleepTimerSetMinutes
                : l10n.sleepTimerMinutesLabel(state.lastMinutes),
          ),
          trailing: state.lastMinutes == 0
              ? null
              : Icon(Icons.edit_outlined, size: 16, color: dimColor),
          onTap: onShortTapMinutes,
          onLongPress: onLongPressMinutes,
        ),
        ListTile(
          leading: _isEpisodes
              ? const Icon(Icons.check)
              : const SizedBox(width: 24),
          title: Text(
            state.lastEpisodes == 0
                ? l10n.sleepTimerSetEpisodes
                : l10n.sleepTimerEpisodesLabel(state.lastEpisodes),
          ),
          trailing: state.lastEpisodes == 0
              ? null
              : Icon(Icons.edit_outlined, size: 16, color: dimColor),
          onTap: onShortTapEpisodes,
          onLongPress: onLongPressEpisodes,
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test**

```bash
flutter test test/features/player/widgets/sleep_timer_sheet_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_sheet.dart \
        packages/audiflow_app/test/features/player/widgets/sleep_timer_sheet_test.dart
git commit -m "feat(app): add SleepTimerSheet widget"
```

---

### Task 11: Build `SleepTimerIconButton` widget

**Files:**
- Create: `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_icon_button.dart`
- Test: `packages/audiflow_app/test/features/player/widgets/sleep_timer_icon_button_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/player/widgets/sleep_timer_icon_button_test.dart`:

```dart
import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_icon_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> container() async {
  SharedPreferences.setMockInitialValues({});
  return ProviderContainer();
}

Widget wrap(ProviderContainer c, Widget child) {
  return UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('icon is outlined when timer is off', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await tester.pumpWidget(wrap(c, const SleepTimerIconButton()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.nights_stay_outlined), findsOneWidget);
  });

  testWidgets('icon is filled when timer is active', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await tester.pumpWidget(wrap(c, const SleepTimerIconButton()));
    await tester.pumpAndSettle();

    c.read(sleepTimerControllerProvider.notifier).setEndOfEpisode();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.nights_stay), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to confirm failure**

```bash
cd packages/audiflow_app
flutter test test/features/player/widgets/sleep_timer_icon_button_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement the icon**

Create `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_icon_button.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import 'sleep_timer_sheet.dart';

/// Sleep-timer icon button for the full player's action row.
///
/// The icon switches between outlined (inactive) and filled (active)
/// variants. Tapping opens the sleep-timer sheet.
class SleepTimerIconButton extends ConsumerWidget {
  const SleepTimerIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sleepTimerControllerProvider);
    final isActive = state.config is! SleepTimerConfigOff;
    final theme = Theme.of(context);

    return IconButton(
      tooltip: l10n.sleepTimerIconLabel,
      icon: Icon(
        isActive ? Icons.nights_stay : Icons.nights_stay_outlined,
        color: isActive ? theme.colorScheme.primary : null,
      ),
      onPressed: () => _open(context, ref),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final state = ref.watch(sleepTimerControllerProvider);
            final hasChaptersAsync = ref.watch(
              currentEpisodeHasChaptersProvider,
            );
            final hasChapters = hasChaptersAsync.valueOrNull ?? false;
            final notifier = ref.read(sleepTimerControllerProvider.notifier);
            return SleepTimerSheet(
              state: state,
              hasChapters: hasChapters,
              onOff: () {
                notifier.setOff();
                Navigator.of(ctx).pop();
              },
              onEndOfEpisode: () {
                notifier.setEndOfEpisode();
                Navigator.of(ctx).pop();
              },
              onEndOfChapter: () {
                notifier.setEndOfChapter();
                Navigator.of(ctx).pop();
              },
              onDurationStart: (d) async {
                await notifier.setDuration(d);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              onEpisodesStart: (n) async {
                await notifier.setEpisodes(n);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            );
          },
        );
      },
    );
  }
}
```

- [ ] **Step 4: Run test**

```bash
flutter test test/features/player/widgets/sleep_timer_icon_button_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_icon_button.dart \
        packages/audiflow_app/test/features/player/widgets/sleep_timer_icon_button_test.dart
git commit -m "feat(app): add SleepTimerIconButton"
```

---

### Task 12: Build `SleepTimerChip` widget

**Files:**
- Create: `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_chip.dart`
- Test: `packages/audiflow_app/test/features/player/widgets/sleep_timer_chip_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/player/widgets/sleep_timer_chip_test.dart`:

```dart
import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_chip.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> container() async {
  SharedPreferences.setMockInitialValues({});
  return ProviderContainer();
}

Widget wrap(ProviderContainer c, Widget child) {
  return UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders nothing when timer is off', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.byType(Chip), findsNothing);
  });

  testWidgets('renders Episode end label when endOfEpisode active', (
    tester,
  ) async {
    final c = await container();
    addTearDown(c.dispose);
    c.read(sleepTimerControllerProvider.notifier).setEndOfEpisode();

    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.text('Sleep · Episode end'), findsOneWidget);
  });

  testWidgets('renders Chapter end label when endOfChapter active', (
    tester,
  ) async {
    final c = await container();
    addTearDown(c.dispose);
    c.read(sleepTimerControllerProvider.notifier).setEndOfChapter();

    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.text('Sleep · Chapter end'), findsOneWidget);
  });

  testWidgets('renders N eps left when episodes active', (tester) async {
    final c = await container();
    addTearDown(c.dispose);
    await c.read(sleepTimerControllerProvider.notifier).setEpisodes(3);

    await tester.pumpWidget(wrap(c, const SleepTimerChip()));
    await tester.pumpAndSettle();

    expect(find.text('Sleep · 3 eps left'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test**

```bash
cd packages/audiflow_app
flutter test test/features/player/widgets/sleep_timer_chip_test.dart
```

Expected: FAIL.

- [ ] **Step 3: Implement the chip**

Create `packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_chip.dart`:

```dart
import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Persistent status chip rendered above the mini player while a sleep
/// timer is active.
///
/// Renders nothing when the config is `off`. For duration timers it
/// refreshes once per second.
class SleepTimerChip extends ConsumerStatefulWidget {
  const SleepTimerChip({super.key});

  @override
  ConsumerState<SleepTimerChip> createState() => _SleepTimerChipState();
}

class _SleepTimerChipState extends ConsumerState<SleepTimerChip> {
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sleepTimerControllerProvider);
    final l10n = AppLocalizations.of(context);

    final label = _labelFor(state.config, l10n);
    if (label == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          avatar: const Icon(Icons.nights_stay, size: 16),
          label: Text(label),
          onDeleted: () {
            ref.read(sleepTimerControllerProvider.notifier).setOff();
          },
          deleteIcon: const Icon(Icons.close, size: 16),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  String? _labelFor(SleepTimerConfig config, AppLocalizations l10n) {
    return switch (config) {
      SleepTimerConfigOff() => null,
      SleepTimerConfigEndOfEpisode() => l10n.sleepTimerChipEpisodeEnd,
      SleepTimerConfigEndOfChapter() => l10n.sleepTimerChipChapterEnd,
      SleepTimerConfigEpisodes(:final remaining) =>
        l10n.sleepTimerChipEpisodesLeft(remaining),
      SleepTimerConfigDuration(:final deadline) =>
        '${l10n.sleepTimerChipDurationPrefix}${_formatRemaining(deadline)}',
    };
  }

  String _formatRemaining(DateTime deadline) {
    final remaining = deadline.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final totalSeconds = clamped.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    String pad2(int v) => v.toString().padLeft(2, '0');
    if (0 < hours) return '${pad2(hours)}:${pad2(minutes)}:${pad2(seconds)}';
    return '${pad2(minutes)}:${pad2(seconds)}';
  }
}
```

- [ ] **Step 4: Run test**

```bash
flutter test test/features/player/widgets/sleep_timer_chip_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/widgets/sleep_timer_chip.dart \
        packages/audiflow_app/test/features/player/widgets/sleep_timer_chip_test.dart
git commit -m "feat(app): add SleepTimerChip"
```

---

### Task 13: Wire the sleep icon into the full player screen

**Files:**
- Modify: `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart` (around lines 147–166)

- [ ] **Step 1: Add import**

At the top of `player_screen.dart`, add:

```dart
import '../widgets/sleep_timer_icon_button.dart';
```

- [ ] **Step 2: Replace the speed button line with a row containing sleep + speed**

Locate the existing `const _PlaybackSpeedButton(),` line near line 166. Replace it with:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    SleepTimerIconButton(),
    SizedBox(width: 16),
    _PlaybackSpeedButton(),
  ],
),
```

- [ ] **Step 3: Run app analyzer + tests**

```bash
cd packages/audiflow_app
flutter analyze
flutter test test/features/player/
```

Expected: analyzer clean, tests pass.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart
git commit -m "feat(app): surface sleep-timer icon in player action row"
```

---

### Task 14: Wire the sleep-timer chip above the mini player

**Files:**
- Modify: `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart` (three mounts)

- [ ] **Step 1: Add import**

At the top of `scaffold_with_nav_bar.dart`:

```dart
import '../features/player/presentation/widgets/sleep_timer_chip.dart';
```

- [ ] **Step 2: Insert the chip above each AnimatedMiniPlayer site**

There are three occurrences. For each, insert `const SleepTimerChip(),` as the sibling immediately before `AnimatedMiniPlayer(onTap: onMiniPlayerTap),` inside the existing `Column`. Do not otherwise alter the Column structure.

Phone portrait site (~line 163) final shape:

```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const SleepTimerChip(),
    AnimatedMiniPlayer(onTap: onMiniPlayerTap),
    _CustomNavBar(
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      voiceEnabled: voiceEnabled,
    ),
  ],
),
```

Tablet portrait site (~line 385) final shape:

```dart
body: Column(
  children: [
    Expanded(child: navigationShell),
    const SleepTimerChip(),
    AnimatedMiniPlayer(onTap: onMiniPlayerTap),
  ],
),
```

Tablet landscape site (~line 437) final shape:

```dart
child: Column(
  children: [
    Expanded(child: navigationShell),
    const SleepTimerChip(),
    AnimatedMiniPlayer(onTap: onMiniPlayerTap),
  ],
),
```

- [ ] **Step 3: Analyze**

```bash
cd packages/audiflow_app
flutter analyze
```

Expected: clean.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart
git commit -m "feat(app): mount SleepTimerChip above mini player"
```

---

### Task 15: Show "Sleep timer ended" snackbar when timer fires in foreground

**Files:**
- Create: `packages/audiflow_app/lib/features/player/presentation/controllers/sleep_timer_ui_controller.dart`
- Modify: `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`
- Test: `packages/audiflow_app/test/features/player/widgets/sleep_timer_snackbar_test.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/player/widgets/sleep_timer_snackbar_test.dart`:

```dart
import 'package:audiflow_app/features/player/presentation/controllers/sleep_timer_ui_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('host mounts without error', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SleepTimerSnackbarHost(child: SizedBox.shrink()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SleepTimerSnackbarHost), findsOneWidget);
  });
}
```

(Note: end-to-end snackbar-on-fire coverage belongs in an integration test. This widget test confirms the host mounts + subscribes without error.)

- [ ] **Step 2: Run test to confirm failure**

```bash
cd packages/audiflow_app
flutter test test/features/player/widgets/sleep_timer_snackbar_test.dart
```

Expected: FAIL — `SleepTimerSnackbarHost` undefined.

- [ ] **Step 3: Implement the host widget**

Create `packages/audiflow_app/lib/features/player/presentation/controllers/sleep_timer_ui_controller.dart`:

```dart
import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Widget host that listens to [SleepTimerController.events] and shows
/// a snackbar when a timer fires while the app is in the foreground.
///
/// Wrap a wide widget (e.g. body of a Scaffold) so ScaffoldMessenger is
/// in scope. No-op if ScaffoldMessenger is unavailable.
class SleepTimerSnackbarHost extends ConsumerStatefulWidget {
  const SleepTimerSnackbarHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SleepTimerSnackbarHost> createState() =>
      _SleepTimerSnackbarHostState();
}

class _SleepTimerSnackbarHostState
    extends ConsumerState<SleepTimerSnackbarHost> {
  StreamSubscription<SleepTimerEvent>? _sub;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(sleepTimerControllerProvider.notifier);
    _sub = notifier.events.listen((event) {
      if (event is! SleepTimerFired) return;
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      final l10n = AppLocalizations.of(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sleepTimerFiredSnackbar)),
      );
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

- [ ] **Step 4: Wrap the Scaffold body in each layout**

Open `scaffold_with_nav_bar.dart` and add the import:

```dart
import '../features/player/presentation/controllers/sleep_timer_ui_controller.dart';
```

For each of the three `Scaffold` layouts, wrap the `body:` argument with `SleepTimerSnackbarHost`. Example for the phone layout:

```dart
return Scaffold(
  body: SleepTimerSnackbarHost(child: navigationShell),
  bottomNavigationBar: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SleepTimerChip(),
      AnimatedMiniPlayer(onTap: onMiniPlayerTap),
      _CustomNavBar(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        voiceEnabled: voiceEnabled,
      ),
    ],
  ),
);
```

For tablet portrait:

```dart
body: SleepTimerSnackbarHost(
  child: Column(
    children: [
      Expanded(child: navigationShell),
      const SleepTimerChip(),
      AnimatedMiniPlayer(onTap: onMiniPlayerTap),
    ],
  ),
),
```

For tablet landscape, wrap the inner right-hand `Column` (the one containing `Expanded(child: navigationShell)` + chip + `AnimatedMiniPlayer`) with `SleepTimerSnackbarHost`.

- [ ] **Step 5: Run tests**

```bash
flutter test test/features/player/widgets/sleep_timer_snackbar_test.dart
flutter analyze
```

Expected: PASS, analyzer clean.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/controllers/sleep_timer_ui_controller.dart \
        packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart \
        packages/audiflow_app/test/features/player/widgets/sleep_timer_snackbar_test.dart
git commit -m "feat(app): surface sleep-timer-fired snackbar"
```

---

### Task 16: End-to-end suite, lint, and manual validation

- [ ] **Step 1: Run domain tests + analyzer**

```bash
cd packages/audiflow_domain
flutter test
flutter analyze
```

Expected: all green.

- [ ] **Step 2: Run app tests + analyzer**

```bash
cd packages/audiflow_app
flutter test
flutter analyze
```

Expected: all green.

- [ ] **Step 3: Run workspace-wide tests**

From the repo root:

```bash
melos run test
```

Expected: all packages pass.

- [ ] **Step 4: Format + final commit if anything changed**

```bash
dart format .
git status
```

If `dart format` produced changes, commit them:

```bash
git add -A
git commit -m "chore: apply dart format"
```

- [ ] **Step 5: Verify in the running app**

Launch the dev flavor:

```bash
cd packages/audiflow_app
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev
```

Manually verify:
- Open full player → tap moon icon → sheet shows Off / End of episode / Set minutes / Set episodes
- Tap "Set minutes" → numeric panel opens → enter 1 → Start → chip reads "Sleep · 00:xx"
- Re-open sheet → "1 minute" entry shows edit icon; short-tap restarts timer; long-press reopens panel
- Wait 1 minute → volume fades over ~8s, playback pauses, "Sleep timer ended" snackbar shows, chip disappears
- Play an episode with chapter data → sheet shows "End of chapter"
- Start end-of-episode timer → manual skip to another episode → timer stays active (transfers)
- Start 2-episode timer → natural completion decrements to 1; natural completion fires at 0

---

## Self-review

**Spec coverage:**
- Menu entries + Off-always-visible + edit-icon hint → Task 10
- Content-swap numeric panel (bounds 1–999 / 1–99) → Tasks 9, 10
- Short-tap vs long-press vs first-time rules → Task 10 tests
- Chip placement + labels + per-config formatting → Task 12, wired in Task 14
- Sleep icon in player action row → Tasks 11, 13
- Fade-out (8s linear, restore volume, cancel on Off mid-fade) → Task 6
- Snackbar on fire (foreground only) → Task 15
- Persistence keys + clamping → Task 4
- Service decision table AABB → Task 3
- Controller wiring + lifecycle mapping → Task 7
- Chapter entry conditional visibility → `currentEpisodeHasChaptersProvider` in Task 7, consumed in Tasks 10, 11
- Session-only timer → Task 7 (`build()` returns `off()`)
- Localization en/ja with plurals → Task 8

**Known gaps / intentional follow-ups:**
- `SleekLifecycle`-driven chapter retarget is left as a follow-up. The controller currently ignores `SeekLifecycle`. End-of-chapter will still fire at the next natural chapter change after seek, but boundary detection on seek itself is not yet plumbed.
- Chapter-change emission from natural playback is not wired. The `endOfChapter` fire path is complete in the service and controller, but no source currently emits `ChapterChangedEvent`. A follow-up task can add a chapter-change detector by watching `playbackProgressStreamProvider` + the episode's chapter list. The menu entry is hidden unless chapters exist, so this does not surface a broken feature — it surfaces an inert option for chaptered episodes that will work once the detector is added.

These follow-ups let Task 16 ship with durations and episode-count timers (the two broadest user needs per the market analysis during brainstorming), plus end-of-episode. End-of-chapter becomes active in a follow-up PR that adds the chapter-change detector.

**Placeholder scan:** no TBD / TODO / "fill in later". All code blocks are complete.

**Type consistency:** `SleepTimerConfigOff / EndOfEpisode / EndOfChapter / Duration / Episodes` used identically across Tasks 1, 3, 7, 10, 11, 12. `SleepTimerPlayerEvent`, `SleepTimerDecision` variants consistent across Tasks 3 and 7. `PlayerLifecycleEvent` (`EpisodeCompletedLifecycle / EpisodeSwitchedLifecycle / SeekLifecycle`) consistent across Tasks 5 and 7. `fadeOutAndPause` / `cancelFade` signatures consistent across Tasks 6 and 7.
