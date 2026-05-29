# Parental Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add PIN-gated Restricted Mode that hides discovery (Search tab, Developer section) and locks content-entry surfaces (Subscribe/Unsubscribe, OPML import, non-subscribed deep links) so the device owner curates the listening environment for a shared user.

**Architecture:** Domain-layer Isar-backed `ParentalControlRepository` + `ParentalControlGate` notifier (Riverpod, keepAlive). App-layer `GateGuard` (BuildContext-aware) shows a `PinEntrySheet` for unlock and is invoked from the 5 gated call sites (subscribe/unsubscribe, OPML, deep link, router redirect, settings screens). Idle 5-min sliding timer + immediate relock on `AppLifecycleState.paused` via `AppLifecycleObserver`. PBKDF2-HMAC-SHA256 with per-install salt and exponential lockout backoff.

**Tech Stack:** Flutter / Dart, Riverpod 3 + code generation, Isar (`isar_community` 3.x), `crypto` (new dep — PBKDF2 implemented on top of `Hmac` + `sha256`), `go_router` for redirect + nav refresh, `flutter_test` + `checks` + `fake_async` (no mockito, no generated mocks per project rule).

**Spec:** `docs/superpowers/specs/2026-05-28-parental-control-design.md`
**FR:** `docs/fr/18-parental-control.md`

**Scope notes:**
- Biometric unlock (`local_auth`) is deferred per spec open question — schema includes `biometricUnlockEnabled` but UI/integration ship in a follow-up.
- Episode `itunesExplicit` field does not exist today; Task 2.5 adds it.
- The crypto package (`package:crypto`) is added directly because no other domain dep exposes PBKDF2.

---

## Phase 0 — Branch and dependencies

### Task 0.1: Create feature branch and add `crypto` dep

**Files:**
- Modify: `packages/audiflow_domain/pubspec.yaml`

- [ ] **Step 1: Branch off main**

```bash
git switch main
git pull --ff-only
git switch -c feat/parental-control
```

- [ ] **Step 2: Add `crypto` to `audiflow_domain` dependencies**

Open `packages/audiflow_domain/pubspec.yaml`. Add `crypto: ^3.0.6` in alphabetical position under `dependencies:` (between `connectivity_plus` and `dio` works):

```yaml
  connectivity_plus: ^7.0.0
  crypto: ^3.0.6
  dio: ^5.9.0
```

- [ ] **Step 3: Resolve workspace**

```bash
melos bootstrap
```

Expected: completes without errors. `crypto` shows in `.dart_tool/package_config.json`.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/pubspec.yaml pubspec.lock packages/*/pubspec.lock
git commit -m "chore(domain): add crypto dependency for parental control PBKDF2"
```

---

## Phase 1 — Domain models, datasource, repository

### Task 1.1: `ParentalControlSettings` Isar collection

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/models/parental_control_settings.dart`

- [ ] **Step 1: Write the collection**

```dart
import 'package:isar_community/isar.dart';

part 'parental_control_settings.g.dart';

@collection
class ParentalControlSettings {
  Id id = 0; // singleton

  String? pinHashBase64;
  String? pinSaltBase64;
  int pinIterations = 100000;

  bool restrictedModeEnabled = false;
  int unlockTimeoutSeconds = 300;
  bool biometricUnlockEnabled = false;

  int failedAttempts = 0;
  DateTime? lockoutUntil;
}
```

- [ ] **Step 2: Run codegen**

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

Expected: `parental_control_settings.g.dart` produced; no errors.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/models/parental_control_settings.dart packages/audiflow_domain/lib/src/features/parental_control/models/parental_control_settings.g.dart
git commit -m "feat(domain): add ParentalControlSettings Isar collection"
```

### Task 1.2: `PodcastParentalFlags` Isar collection

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/models/podcast_parental_flags.dart`

- [ ] **Step 1: Write the collection**

```dart
import 'package:isar_community/isar.dart';

part 'podcast_parental_flags.g.dart';

@collection
class PodcastParentalFlags {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int itunesId;

  bool hideExplicitEpisodes = false;
}
```

- [ ] **Step 2: Run codegen**

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/models/podcast_parental_flags.dart packages/audiflow_domain/lib/src/features/parental_control/models/podcast_parental_flags.g.dart
git commit -m "feat(domain): add PodcastParentalFlags Isar collection"
```

### Task 1.3: Register schemas in `database_provider.dart`

**Files:**
- Modify: `packages/audiflow_domain/lib/src/common/providers/database_provider.dart`

- [ ] **Step 1: Add imports and schemas**

After the existing `import '../../features/transcript/...'` lines, add:

```dart
import '../../features/parental_control/models/parental_control_settings.dart';
import '../../features/parental_control/models/podcast_parental_flags.dart';
```

Inside the `isarSchemas` list, append at the end:

```dart
  StationEpisodeSchema,
  ParentalControlSettingsSchema,
  PodcastParentalFlagsSchema,
];
```

- [ ] **Step 2: Verify analyze**

```bash
cd packages/audiflow_domain
flutter analyze
```

Expected: zero issues.

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/common/providers/database_provider.dart
git commit -m "feat(domain): register parental control schemas with Isar"
```

### Task 1.4: `UnlockState` sealed class

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/models/unlock_state.dart`
- Create: `packages/audiflow_domain/test/features/parental_control/models/unlock_state_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:audiflow_domain/src/features/parental_control/models/unlock_state.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnlockState', () {
    test('Locked is const', () {
      check(const Locked()).equals(const Locked());
    });

    test('Unlocked carries expiresAt', () {
      final t = DateTime.utc(2026, 5, 28, 12, 0);
      final s = Unlocked(expiresAt: t);
      check(s.expiresAt).equals(t);
    });

    test('LockedOut carries retryAt and attemptCount', () {
      final t = DateTime.utc(2026, 5, 28, 12, 5);
      final s = LockedOut(retryAt: t, attemptCount: 7);
      check(s.retryAt).equals(t);
      check(s.attemptCount).equals(7);
    });

    test('switch covers all cases (exhaustive)', () {
      const UnlockState s = Locked();
      final result = switch (s) {
        Locked() => 'locked',
        Unlocked() => 'unlocked',
        LockedOut() => 'lockedOut',
      };
      check(result).equals('locked');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd packages/audiflow_domain
flutter test test/features/parental_control/models/unlock_state_test.dart
```

Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the implementation**

```dart
import 'package:meta/meta.dart';

@immutable
sealed class UnlockState {
  const UnlockState();
}

class Locked extends UnlockState {
  const Locked();

  @override
  bool operator ==(Object other) => other is Locked;

  @override
  int get hashCode => 'Locked'.hashCode;
}

class Unlocked extends UnlockState {
  const Unlocked({required this.expiresAt});

  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      other is Unlocked && other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash('Unlocked', expiresAt);
}

class LockedOut extends UnlockState {
  const LockedOut({required this.retryAt, required this.attemptCount});

  final DateTime retryAt;
  final int attemptCount;

  @override
  bool operator ==(Object other) =>
      other is LockedOut &&
      other.retryAt == retryAt &&
      other.attemptCount == attemptCount;

  @override
  int get hashCode => Object.hash('LockedOut', retryAt, attemptCount);
}
```

- [ ] **Step 4: Run test to verify pass**

```bash
flutter test test/features/parental_control/models/unlock_state_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/models/unlock_state.dart packages/audiflow_domain/test/features/parental_control/models/unlock_state_test.dart
git commit -m "feat(domain): add UnlockState sealed class for parental control"
```

### Task 1.5: `PinHasher` (PBKDF2-HMAC-SHA256)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/services/pin_hasher.dart`
- Create: `packages/audiflow_domain/test/features/parental_control/services/pin_hasher_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/services/pin_hasher.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinHasher', () {
    final hasher = PinHasher();

    test('generateSalt returns 16 random bytes; two calls differ', () {
      final a = hasher.generateSalt();
      final b = hasher.generateSalt();
      check(a.length).equals(16);
      check(b.length).equals(16);
      check(base64.encode(a)).not((s) => s.equals(base64.encode(b)));
    });

    test('hash is deterministic with same salt+pin+iterations', () {
      final salt = Uint8List.fromList(List<int>.generate(16, (i) => i));
      final h1 = hasher.hash(pin: '1234', salt: salt, iterations: 1000);
      final h2 = hasher.hash(pin: '1234', salt: salt, iterations: 1000);
      check(base64.encode(h1)).equals(base64.encode(h2));
      check(h1.length).equals(32);
    });

    test('hash differs for different PINs', () {
      final salt = Uint8List.fromList(List<int>.generate(16, (i) => i));
      final h1 = hasher.hash(pin: '1234', salt: salt, iterations: 1000);
      final h2 = hasher.hash(pin: '1235', salt: salt, iterations: 1000);
      check(base64.encode(h1)).not((s) => s.equals(base64.encode(h2)));
    });

    test('verify returns true for correct PIN', () {
      final salt = hasher.generateSalt();
      final settings = ParentalControlSettings()
        ..pinHashBase64 = base64.encode(
            hasher.hash(pin: '4321', salt: salt, iterations: 1000))
        ..pinSaltBase64 = base64.encode(salt)
        ..pinIterations = 1000;
      check(hasher.verify(pin: '4321', settings: settings)).isTrue();
    });

    test('verify returns false for wrong PIN', () {
      final salt = hasher.generateSalt();
      final settings = ParentalControlSettings()
        ..pinHashBase64 = base64.encode(
            hasher.hash(pin: '4321', salt: salt, iterations: 1000))
        ..pinSaltBase64 = base64.encode(salt)
        ..pinIterations = 1000;
      check(hasher.verify(pin: '9999', settings: settings)).isFalse();
    });

    test('verify returns false when hash or salt is null', () {
      final settings = ParentalControlSettings();
      check(hasher.verify(pin: '1234', settings: settings)).isFalse();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/features/parental_control/services/pin_hasher_test.dart
```

Expected: FAIL — `PinHasher` not defined.

- [ ] **Step 3: Write the implementation**

```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../models/parental_control_settings.dart';

class PinHasher {
  PinHasher({Random? secureRandom}) : _random = secureRandom ?? Random.secure();

  final Random _random;

  Uint8List generateSalt({int length = 16}) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// PBKDF2-HMAC-SHA256.
  /// Returns 32-byte derived key.
  Uint8List hash({
    required String pin,
    required Uint8List salt,
    required int iterations,
  }) {
    final pinBytes = utf8.encode(pin);
    final hmac = Hmac(sha256, pinBytes);

    const blockSize = 32; // sha256 output length
    const dkLen = 32;
    final blocks = (dkLen / blockSize).ceil();
    final out = BytesBuilder();

    for (var i = 1; i <= blocks; i++) {
      out.add(_pbkdf2Block(hmac, salt, iterations, i));
    }

    final bytes = out.toBytes();
    return bytes.sublist(0, dkLen);
  }

  Uint8List _pbkdf2Block(Hmac hmac, Uint8List salt, int iterations, int blockIndex) {
    final saltWithIndex = Uint8List(salt.length + 4)
      ..setRange(0, salt.length, salt)
      ..[salt.length] = (blockIndex >> 24) & 0xff
      ..[salt.length + 1] = (blockIndex >> 16) & 0xff
      ..[salt.length + 2] = (blockIndex >> 8) & 0xff
      ..[salt.length + 3] = blockIndex & 0xff;

    var u = Uint8List.fromList(hmac.convert(saltWithIndex).bytes);
    final result = Uint8List.fromList(u);

    for (var i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    return result;
  }

  bool verify({
    required String pin,
    required ParentalControlSettings settings,
  }) {
    final hashB64 = settings.pinHashBase64;
    final saltB64 = settings.pinSaltBase64;
    if (hashB64 == null || saltB64 == null) return false;

    final salt = base64.decode(saltB64);
    final computed = hash(
      pin: pin,
      salt: Uint8List.fromList(salt),
      iterations: settings.pinIterations,
    );
    final stored = base64.decode(hashB64);
    return _constantTimeEquals(computed, stored);
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
```

- [ ] **Step 4: Run test to verify pass**

```bash
flutter test test/features/parental_control/services/pin_hasher_test.dart
```

Expected: PASS (all 6 tests).

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/services/pin_hasher.dart packages/audiflow_domain/test/features/parental_control/services/pin_hasher_test.dart
git commit -m "feat(domain): add PinHasher with PBKDF2-HMAC-SHA256"
```

### Task 1.6: Local datasource

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/datasources/local/parental_control_local_datasource.dart`
- Create: `packages/audiflow_domain/test/features/parental_control/datasources/local/parental_control_local_datasource_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/models/parental_control_settings.dart';
import 'package:audiflow_domain/src/features/parental_control/models/podcast_parental_flags.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../../helpers/fake_path_provider.dart';
import '../../../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProvider();

  late Isar isar;
  late ParentalControlLocalDataSource ds;

  setUp(() async {
    isar = await openTestIsar();
    ds = ParentalControlLocalDataSource(isar: isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('ParentalControlLocalDataSource', () {
    test('getSettings returns default singleton when empty', () async {
      final s = await ds.getSettings();
      check(s.id).equals(0);
      check(s.restrictedModeEnabled).isFalse();
      check(s.pinHashBase64).isNull();
      check(s.pinIterations).equals(100000);
    });

    test('saveSettings persists and getSettings returns it', () async {
      final s = await ds.getSettings();
      s.restrictedModeEnabled = true;
      s.unlockTimeoutSeconds = 600;
      await ds.saveSettings(s);

      final read = await ds.getSettings();
      check(read.restrictedModeEnabled).isTrue();
      check(read.unlockTimeoutSeconds).equals(600);
    });

    test('watchSettings emits on save', () async {
      final emissions = <ParentalControlSettings>[];
      final sub = ds.watchSettings().listen(emissions.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final s = await ds.getSettings();
      s.restrictedModeEnabled = true;
      await ds.saveSettings(s);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      check(emissions.length).isGreaterOrEqual(1);
      check(emissions.last.restrictedModeEnabled).isTrue();
    });

    test('setHideExplicit upserts per-podcast flag', () async {
      await ds.setHideExplicit(itunesId: 42, hide: true);
      final f = await ds.getFlags(42);
      check(f).isNotNull();
      check(f!.hideExplicitEpisodes).isTrue();

      await ds.setHideExplicit(itunesId: 42, hide: false);
      final f2 = await ds.getFlags(42);
      check(f2!.hideExplicitEpisodes).isFalse();
    });

    test('pruneFlagsFor removes the row', () async {
      await ds.setHideExplicit(itunesId: 42, hide: true);
      await ds.pruneFlagsFor(42);
      check(await ds.getFlags(42)).isNull();
    });

    test('watchHideExplicit emits on change', () async {
      final emissions = <bool>[];
      final sub = ds.watchHideExplicit(42).listen(emissions.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await ds.setHideExplicit(itunesId: 42, hide: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      check(emissions.last).isTrue();
    });
  });
}

extension on Subject<int> {
  void isGreaterOrEqual(int v) {
    has((x) => v <= x, 'is >= $v').isTrue();
  }
}
```

> Note: project rule prohibits `>=` / `>` operators. The custom extension uses `v <= x` form. Reuse this `isGreaterOrEqual` pattern wherever needed in later tests.

- [ ] **Step 2: Check helpers exist**

```bash
ls packages/audiflow_domain/test/helpers/ 2>/dev/null
```

If `isar_test_helper.dart` and `fake_path_provider.dart` do not exist, search for the existing pattern other tests use:

```bash
grep -rn "openTestIsar\|Isar.open" packages/audiflow_domain/test --include="*.dart" -l | head -5
```

Mirror that helper (commonly `test/helpers/isar_test_helper.dart` exposing `Future<Isar> openTestIsar()` using a temp directory).

- [ ] **Step 3: Run test to verify it fails**

```bash
flutter test test/features/parental_control/datasources/local/parental_control_local_datasource_test.dart
```

Expected: FAIL — `ParentalControlLocalDataSource` not defined.

- [ ] **Step 4: Write the implementation**

```dart
import 'package:isar_community/isar.dart';

import '../../models/parental_control_settings.dart';
import '../../models/podcast_parental_flags.dart';

class ParentalControlLocalDataSource {
  ParentalControlLocalDataSource({required Isar isar}) : _isar = isar;

  final Isar _isar;

  Future<ParentalControlSettings> getSettings() async {
    final existing = await _isar.parentalControlSettings.get(0);
    if (existing != null) return existing;

    final fresh = ParentalControlSettings();
    await _isar.writeTxn(() async {
      await _isar.parentalControlSettings.put(fresh);
    });
    return fresh;
  }

  Future<void> saveSettings(ParentalControlSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.parentalControlSettings.put(settings);
    });
  }

  Stream<ParentalControlSettings> watchSettings() {
    return _isar.parentalControlSettings
        .watchObject(0, fireImmediately: true)
        .asyncMap((s) async => s ?? await getSettings());
  }

  Future<PodcastParentalFlags?> getFlags(int itunesId) {
    return _isar.podcastParentalFlags
        .filter()
        .itunesIdEqualTo(itunesId)
        .findFirst();
  }

  Future<void> setHideExplicit({
    required int itunesId,
    required bool hide,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.podcastParentalFlags
          .filter()
          .itunesIdEqualTo(itunesId)
          .findFirst();
      final row = existing ?? (PodcastParentalFlags()..itunesId = itunesId);
      row.hideExplicitEpisodes = hide;
      await _isar.podcastParentalFlags.put(row);
    });
  }

  Future<void> pruneFlagsFor(int itunesId) async {
    await _isar.writeTxn(() async {
      await _isar.podcastParentalFlags
          .filter()
          .itunesIdEqualTo(itunesId)
          .deleteAll();
    });
  }

  Stream<bool> watchHideExplicit(int itunesId) {
    return _isar.podcastParentalFlags
        .filter()
        .itunesIdEqualTo(itunesId)
        .watch(fireImmediately: true)
        .map((rows) => rows.isNotEmpty && rows.first.hideExplicitEpisodes);
  }
}
```

- [ ] **Step 5: Run test to verify pass**

```bash
flutter test test/features/parental_control/datasources/local/parental_control_local_datasource_test.dart
```

Expected: all 6 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/datasources/ packages/audiflow_domain/test/features/parental_control/datasources/
git commit -m "feat(domain): add ParentalControlLocalDataSource"
```

### Task 1.7: Repository interface

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/repositories/parental_control_repository.dart`

- [ ] **Step 1: Write the interface**

```dart
import '../models/parental_control_settings.dart';

abstract class ParentalControlRepository {
  Stream<ParentalControlSettings> watchSettings();
  Future<ParentalControlSettings> getSettings();

  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();

  Future<void> setRestrictedMode(bool enabled);
  Future<void> setUnlockTimeout(Duration timeout);
  Future<void> setBiometricUnlockEnabled(bool enabled);

  /// Increments the failed-attempts counter. Returns the new lockout
  /// window (null if no lockout triggered yet).
  Future<Duration?> registerFailedAttempt();
  Future<void> clearFailedAttempts();

  Stream<bool> watchHideExplicit(int itunesId);
  Future<bool> getHideExplicit(int itunesId);
  Future<void> setHideExplicit(int itunesId, bool hide);
  Future<void> pruneFlagsFor(int itunesId);
}
```

- [ ] **Step 2: Verify analyze**

```bash
flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/repositories/parental_control_repository.dart
git commit -m "feat(domain): add ParentalControlRepository interface"
```

### Task 1.8: Repository implementation + tests

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/repositories/parental_control_repository_impl.dart`
- Create: `packages/audiflow_domain/test/features/parental_control/repositories/parental_control_repository_impl_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/repositories/parental_control_repository_impl.dart';
import 'package:audiflow_domain/src/features/parental_control/services/pin_hasher.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../helpers/fake_path_provider.dart';
import '../../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProvider();

  late Isar isar;
  late ParentalControlRepositoryImpl repo;

  setUp(() async {
    isar = await openTestIsar();
    final ds = ParentalControlLocalDataSource(isar: isar);
    repo = ParentalControlRepositoryImpl(
      datasource: ds,
      hasher: PinHasher(),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('ParentalControlRepositoryImpl', () {
    test('setPin / verifyPin round-trip succeeds', () async {
      await repo.setPin('1234');
      check(await repo.verifyPin('1234')).isTrue();
      check(await repo.verifyPin('0000')).isFalse();
    });

    test('setPin clears failedAttempts and lockoutUntil', () async {
      await repo.registerFailedAttempt();
      await repo.registerFailedAttempt();
      await repo.setPin('1234');
      final s = await repo.getSettings();
      check(s.failedAttempts).equals(0);
      check(s.lockoutUntil).isNull();
    });

    test('setPin rotates salt', () async {
      await repo.setPin('1234');
      final salt1 = (await repo.getSettings()).pinSaltBase64;
      await repo.setPin('5678');
      final salt2 = (await repo.getSettings()).pinSaltBase64;
      check(salt2).not((s) => s.equals(salt1));
    });

    test('clearPin removes hash, salt, and failedAttempts', () async {
      await repo.setPin('1234');
      await repo.clearPin();
      final s = await repo.getSettings();
      check(s.pinHashBase64).isNull();
      check(s.pinSaltBase64).isNull();
      check(s.failedAttempts).equals(0);
    });

    test('registerFailedAttempt increments counter; returns lockout at 5th',
        () async {
      check(await repo.registerFailedAttempt()).isNull();
      check(await repo.registerFailedAttempt()).isNull();
      check(await repo.registerFailedAttempt()).isNull();
      check(await repo.registerFailedAttempt()).isNull();
      final fifth = await repo.registerFailedAttempt();
      check(fifth).isNotNull();
      check(fifth!.inSeconds).equals(30);
    });

    test('registerFailedAttempt backoff sequence: 30s, 60s, 120s, 240s, 300s cap',
        () async {
      for (var i = 0; i < 4; i++) {
        await repo.registerFailedAttempt();
      }
      check((await repo.registerFailedAttempt())!.inSeconds).equals(30);
      check((await repo.registerFailedAttempt())!.inSeconds).equals(60);
      check((await repo.registerFailedAttempt())!.inSeconds).equals(120);
      check((await repo.registerFailedAttempt())!.inSeconds).equals(240);
      check((await repo.registerFailedAttempt())!.inSeconds).equals(300);
      check((await repo.registerFailedAttempt())!.inSeconds).equals(300);
    });

    test('clearFailedAttempts resets counter and lockoutUntil', () async {
      for (var i = 0; i < 6; i++) {
        await repo.registerFailedAttempt();
      }
      await repo.clearFailedAttempts();
      final s = await repo.getSettings();
      check(s.failedAttempts).equals(0);
      check(s.lockoutUntil).isNull();
    });

    test('setRestrictedMode and setUnlockTimeout persist', () async {
      await repo.setRestrictedMode(true);
      await repo.setUnlockTimeout(const Duration(minutes: 10));
      final s = await repo.getSettings();
      check(s.restrictedModeEnabled).isTrue();
      check(s.unlockTimeoutSeconds).equals(600);
    });

    test('setHideExplicit and getHideExplicit round-trip', () async {
      check(await repo.getHideExplicit(99)).isFalse();
      await repo.setHideExplicit(99, true);
      check(await repo.getHideExplicit(99)).isTrue();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Expected: FAIL — impl missing.

- [ ] **Step 3: Write the implementation**

```dart
import '../datasources/local/parental_control_local_datasource.dart';
import '../models/parental_control_settings.dart';
import '../services/pin_hasher.dart';
import 'parental_control_repository.dart';

class ParentalControlRepositoryImpl implements ParentalControlRepository {
  ParentalControlRepositoryImpl({
    required ParentalControlLocalDataSource datasource,
    required PinHasher hasher,
    DateTime Function()? clock,
  })  : _ds = datasource,
        _hasher = hasher,
        _now = clock ?? DateTime.now;

  final ParentalControlLocalDataSource _ds;
  final PinHasher _hasher;
  final DateTime Function() _now;

  static const List<int> _backoffSeconds = [30, 60, 120, 240, 300];

  @override
  Stream<ParentalControlSettings> watchSettings() => _ds.watchSettings();

  @override
  Future<ParentalControlSettings> getSettings() => _ds.getSettings();

  @override
  Future<void> setPin(String pin) async {
    final salt = _hasher.generateSalt();
    final s = await _ds.getSettings();
    s.pinSaltBase64 = base64Encode(salt);
    s.pinHashBase64 = base64Encode(
      _hasher.hash(pin: pin, salt: salt, iterations: s.pinIterations),
    );
    s.failedAttempts = 0;
    s.lockoutUntil = null;
    await _ds.saveSettings(s);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final s = await _ds.getSettings();
    return _hasher.verify(pin: pin, settings: s);
  }

  @override
  Future<void> clearPin() async {
    final s = await _ds.getSettings();
    s.pinHashBase64 = null;
    s.pinSaltBase64 = null;
    s.failedAttempts = 0;
    s.lockoutUntil = null;
    await _ds.saveSettings(s);
  }

  @override
  Future<void> setRestrictedMode(bool enabled) async {
    final s = await _ds.getSettings();
    s.restrictedModeEnabled = enabled;
    await _ds.saveSettings(s);
  }

  @override
  Future<void> setUnlockTimeout(Duration timeout) async {
    final s = await _ds.getSettings();
    s.unlockTimeoutSeconds = timeout.inSeconds;
    await _ds.saveSettings(s);
  }

  @override
  Future<void> setBiometricUnlockEnabled(bool enabled) async {
    final s = await _ds.getSettings();
    s.biometricUnlockEnabled = enabled;
    await _ds.saveSettings(s);
  }

  @override
  Future<Duration?> registerFailedAttempt() async {
    final s = await _ds.getSettings();
    s.failedAttempts = s.failedAttempts + 1;
    Duration? lockout;
    // Lockout triggers at the 5th attempt (index 4); cap at index 4 of _backoffSeconds.
    if (5 <= s.failedAttempts) {
      final idx = s.failedAttempts - 5;
      final cappedIdx = idx < _backoffSeconds.length ? idx : _backoffSeconds.length - 1;
      lockout = Duration(seconds: _backoffSeconds[cappedIdx]);
      s.lockoutUntil = _now().add(lockout);
    }
    await _ds.saveSettings(s);
    return lockout;
  }

  @override
  Future<void> clearFailedAttempts() async {
    final s = await _ds.getSettings();
    s.failedAttempts = 0;
    s.lockoutUntil = null;
    await _ds.saveSettings(s);
  }

  @override
  Stream<bool> watchHideExplicit(int itunesId) =>
      _ds.watchHideExplicit(itunesId);

  @override
  Future<bool> getHideExplicit(int itunesId) async {
    final f = await _ds.getFlags(itunesId);
    return f?.hideExplicitEpisodes ?? false;
  }

  @override
  Future<void> setHideExplicit(int itunesId, bool hide) =>
      _ds.setHideExplicit(itunesId: itunesId, hide: hide);

  @override
  Future<void> pruneFlagsFor(int itunesId) => _ds.pruneFlagsFor(itunesId);
}

```

> Note: the file requires `import 'dart:convert' show base64Encode;` at the top alongside the other imports.

- [ ] **Step 4: Run test to verify pass**

```bash
flutter test test/features/parental_control/repositories/parental_control_repository_impl_test.dart
```

Expected: PASS (9 tests).

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/repositories/ packages/audiflow_domain/test/features/parental_control/repositories/
git commit -m "feat(domain): add ParentalControlRepositoryImpl with lockout backoff"
```

### Task 1.9: Riverpod providers — repository + settings stream

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/providers/parental_control_providers.dart`

- [ ] **Step 1: Write the providers**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../datasources/local/parental_control_local_datasource.dart';
import '../models/parental_control_settings.dart';
import '../repositories/parental_control_repository.dart';
import '../repositories/parental_control_repository_impl.dart';
import '../services/pin_hasher.dart';

part 'parental_control_providers.g.dart';

@Riverpod(keepAlive: true)
PinHasher pinHasher(Ref ref) => PinHasher();

@Riverpod(keepAlive: true)
ParentalControlLocalDataSource parentalControlLocalDataSource(Ref ref) {
  final isar = ref.watch(isarProvider);
  return ParentalControlLocalDataSource(isar: isar);
}

@Riverpod(keepAlive: true)
ParentalControlRepository parentalControlRepository(Ref ref) {
  return ParentalControlRepositoryImpl(
    datasource: ref.watch(parentalControlLocalDataSourceProvider),
    hasher: ref.watch(pinHasherProvider),
  );
}

@Riverpod(keepAlive: true)
Stream<ParentalControlSettings> parentalControlSettingsStream(Ref ref) {
  return ref.watch(parentalControlRepositoryProvider).watchSettings();
}

@riverpod
bool isRestrictedModeOn(Ref ref) {
  final s = ref.watch(parentalControlSettingsStreamProvider);
  return s.maybeWhen(data: (v) => v.restrictedModeEnabled, orElse: () => false);
}

@riverpod
Stream<bool> hideExplicitForPodcast(Ref ref, int itunesId) {
  return ref.watch(parentalControlRepositoryProvider).watchHideExplicit(itunesId);
}
```

- [ ] **Step 2: Run codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `parental_control_providers.g.dart` produced.

- [ ] **Step 3: Verify analyze**

```bash
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/providers/
git commit -m "feat(domain): add parental control Riverpod providers"
```

### Task 1.10: Export from `audiflow_domain` barrel

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Add exports**

Append to barrel:

```dart
export 'src/features/parental_control/models/parental_control_settings.dart';
export 'src/features/parental_control/models/podcast_parental_flags.dart';
export 'src/features/parental_control/models/unlock_state.dart';
export 'src/features/parental_control/repositories/parental_control_repository.dart';
export 'src/features/parental_control/services/pin_hasher.dart';
export 'src/features/parental_control/providers/parental_control_providers.dart';
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): export parental control public API"
```

---

## Phase 2 — Domain gate (notifier with timer + lockout state machine)

### Task 2.1: `ParentalControlGate` skeleton + basic tests

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/parental_control/services/parental_control_gate.dart`
- Create: `packages/audiflow_domain/test/features/parental_control/services/parental_control_gate_test.dart`

- [ ] **Step 1: Write failing tests for basic state**

```dart
import 'package:audiflow_domain/src/features/parental_control/datasources/local/parental_control_local_datasource.dart';
import 'package:audiflow_domain/src/features/parental_control/models/unlock_state.dart';
import 'package:audiflow_domain/src/features/parental_control/providers/parental_control_providers.dart';
import 'package:audiflow_domain/src/features/parental_control/repositories/parental_control_repository_impl.dart';
import 'package:audiflow_domain/src/features/parental_control/services/parental_control_gate.dart';
import 'package:audiflow_domain/src/features/parental_control/services/pin_hasher.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../../helpers/fake_path_provider.dart';
import '../../../helpers/isar_test_helper.dart';

ProviderContainer makeContainer(Isar isar) {
  return ProviderContainer(overrides: [
    isarProvider.overrideWithValue(isar),
  ]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProvider();

  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await openTestIsar();
    container = makeContainer(isar);
    await container.read(parentalControlRepositoryProvider).setPin('1234');
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
  });

  group('ParentalControlGate basic', () {
    test('initial state is Locked', () {
      final state = container.read(parentalControlGateProvider);
      check(state).equals(const Locked());
    });

    test('tryUnlock with correct PIN returns true and transitions to Unlocked',
        () async {
      final ok = await container
          .read(parentalControlGateProvider.notifier)
          .tryUnlock('1234');
      check(ok).isTrue();
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();
    });

    test('tryUnlock with wrong PIN returns false, state stays Locked', () async {
      final ok = await container
          .read(parentalControlGateProvider.notifier)
          .tryUnlock('0000');
      check(ok).isFalse();
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });

    test('lock() returns state to Locked from Unlocked', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      await notifier.tryUnlock('1234');
      notifier.lock();
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });
  });
}
```

- [ ] **Step 2: Run test — FAIL (gate not defined).**

- [ ] **Step 3: Write the skeleton implementation (timer/lockout in next tasks)**

```dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/unlock_state.dart';
import '../providers/parental_control_providers.dart';
import '../repositories/parental_control_repository.dart';

part 'parental_control_gate.g.dart';

@Riverpod(keepAlive: true)
class ParentalControlGate extends _$ParentalControlGate {
  Timer? _idleTimer;
  DateTime Function() _now = DateTime.now;

  @override
  UnlockState build() {
    ref.onDispose(() => _idleTimer?.cancel());
    return const Locked();
  }

  ParentalControlRepository get _repo =>
      ref.read(parentalControlRepositoryProvider);

  Future<bool> tryUnlock(String pin) async {
    final settings = await _repo.getSettings();

    // Respect lockout window.
    final lockoutUntil = settings.lockoutUntil;
    if (lockoutUntil != null && _now().isBefore(lockoutUntil)) {
      state = LockedOut(
        retryAt: lockoutUntil,
        attemptCount: settings.failedAttempts,
      );
      return false;
    }

    final ok = await _repo.verifyPin(pin);
    if (!ok) {
      final lockout = await _repo.registerFailedAttempt();
      if (lockout != null) {
        state = LockedOut(
          retryAt: _now().add(lockout),
          attemptCount: (await _repo.getSettings()).failedAttempts,
        );
      } else {
        state = const Locked();
      }
      return false;
    }

    await _repo.clearFailedAttempts();
    final timeout = Duration(seconds: settings.unlockTimeoutSeconds);
    state = Unlocked(expiresAt: _now().add(timeout));
    _startIdleTimer(timeout);
    return true;
  }

  void extendIdle() {
    final current = state;
    if (current is! Unlocked) return;
    // Re-read timeout to honor mid-session changes.
    _repo.getSettings().then((s) {
      final timeout = Duration(seconds: s.unlockTimeoutSeconds);
      state = Unlocked(expiresAt: _now().add(timeout));
      _startIdleTimer(timeout);
    });
  }

  void lock() {
    _idleTimer?.cancel();
    state = const Locked();
  }

  void _startIdleTimer(Duration timeout) {
    _idleTimer?.cancel();
    _idleTimer = Timer(timeout, lock);
  }

  /// Test-only seam for injecting fake_async clock.
  void debugSetClock(DateTime Function() clock) {
    _now = clock;
  }
}
```

- [ ] **Step 4: Codegen and run tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/parental_control/services/parental_control_gate_test.dart
```

Expected: 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/services/parental_control_gate.dart packages/audiflow_domain/lib/src/features/parental_control/services/parental_control_gate.g.dart packages/audiflow_domain/test/features/parental_control/services/parental_control_gate_test.dart
git commit -m "feat(domain): add ParentalControlGate notifier with basic unlock/lock"
```

### Task 2.2: Idle timer + `extendIdle` tests (with `fake_async`)

**Files:**
- Modify: `packages/audiflow_domain/test/features/parental_control/services/parental_control_gate_test.dart`

- [ ] **Step 1: Add tests inside the existing test file**

Append a new `group` after the existing `group('ParentalControlGate basic', ...)`:

```dart
  group('ParentalControlGate idle timer', () {
    test('auto-relocks after timeout', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      await container
          .read(parentalControlRepositoryProvider)
          .setUnlockTimeout(const Duration(seconds: 60));

      await notifier.tryUnlock('1234');
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();

      // The Timer fires in real time; use a short timeout for the test.
      await container
          .read(parentalControlRepositoryProvider)
          .setUnlockTimeout(const Duration(milliseconds: 100));
      await notifier.tryUnlock('1234');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });

    test('extendIdle no-ops when locked', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      notifier.extendIdle();
      check(container.read(parentalControlGateProvider)).equals(const Locked());
    });

    test('extendIdle reschedules the relock timer', () async {
      await container
          .read(parentalControlRepositoryProvider)
          .setUnlockTimeout(const Duration(milliseconds: 200));
      final notifier = container.read(parentalControlGateProvider.notifier);
      await notifier.tryUnlock('1234');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      notifier.extendIdle();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      // Original timer would have fired by now; extended timer keeps it Unlocked.
      check(container.read(parentalControlGateProvider)).isA<Unlocked>();
    });
  });
```

- [ ] **Step 2: Run tests**

```bash
flutter test test/features/parental_control/services/parental_control_gate_test.dart
```

Expected: PASS (basic 4 + idle 3 = 7).

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/test/features/parental_control/services/parental_control_gate_test.dart
git commit -m "test(domain): cover parental control idle timer behavior"
```

### Task 2.3: Lockout transitions + tests

**Files:**
- Modify: `packages/audiflow_domain/test/features/parental_control/services/parental_control_gate_test.dart`

- [ ] **Step 1: Add lockout tests**

Append:

```dart
  group('ParentalControlGate lockout', () {
    test('5 wrong PINs transitions to LockedOut with 30s window', () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      for (var i = 0; i < 4; i++) {
        check(await notifier.tryUnlock('0000')).isFalse();
        check(container.read(parentalControlGateProvider))
            .equals(const Locked());
      }
      check(await notifier.tryUnlock('0000')).isFalse();
      final s = container.read(parentalControlGateProvider);
      check(s).isA<LockedOut>();
      final lo = s as LockedOut;
      check(lo.attemptCount).equals(5);
    });

    test('tryUnlock during LockedOut window short-circuits without hashing',
        () async {
      final notifier = container.read(parentalControlGateProvider.notifier);
      for (var i = 0; i < 5; i++) {
        await notifier.tryUnlock('0000');
      }
      // Correct PIN, but still in lockout window
      check(await notifier.tryUnlock('1234')).isFalse();
      check(container.read(parentalControlGateProvider)).isA<LockedOut>();
    });
  });
```

- [ ] **Step 2: Run tests**

Expected: PASS (10 total).

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/test/features/parental_control/services/parental_control_gate_test.dart
git commit -m "test(domain): cover parental control lockout transitions"
```

### Task 2.4: Convenience `isUnlocked` provider

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/parental_control/providers/parental_control_providers.dart`

- [ ] **Step 1: Add provider**

```dart
@riverpod
bool isUnlocked(Ref ref) {
  final s = ref.watch(parentalControlGateProvider);
  return s is Unlocked;
}
```

Add the required import at top of file:

```dart
import '../models/unlock_state.dart';
import '../services/parental_control_gate.dart';
```

- [ ] **Step 2: Codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/providers/parental_control_providers.dart packages/audiflow_domain/lib/src/features/parental_control/providers/parental_control_providers.g.dart
git commit -m "feat(domain): add isUnlocked convenience provider"
```

### Task 2.5: Add `itunesExplicit` to `Episode` collection

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/models/episode.dart`
- Modify: `packages/audiflow_podcast/lib/...` (RSS parser — set the field from `<itunes:explicit>`)

- [ ] **Step 1: Add field to Episode**

After `bool autoDownloadEnqueued = false;` add:

```dart
  /// True when the feed item carries <itunes:explicit>true</itunes:explicit>.
  bool itunesExplicit = false;
```

- [ ] **Step 2: Codegen**

```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Find and update RSS parser**

```bash
grep -rn "itunes:explicit\|itunesExplicit\|<itunes:" packages/audiflow_podcast/lib --include="*.dart"
```

In the file producing `Episode` entities (typically a builder under `audiflow_podcast/lib/src/builders/` or `audiflow_domain/lib/src/features/feed/services/feed_parser_service.dart`), set:

```dart
episode.itunesExplicit = itunesExplicitValue?.toLowerCase() == 'true' ||
    itunesExplicitValue?.toLowerCase() == 'yes';
```

(Adjust to match the parser's element-extraction pattern. `<itunes:explicit>` accepts `true|false|yes|no|clean` per Apple spec — treat anything other than `true`/`yes` as not explicit.)

- [ ] **Step 4: Add a parser test**

In the parser package's existing tests, add:

```dart
test('parses <itunes:explicit>true</itunes:explicit>', () {
  final xml = '''<rss><channel><item>
    <guid>g1</guid><title>t</title><enclosure url="https://example/a.mp3"/>
    <itunes:explicit>true</itunes:explicit>
  </item></channel></rss>''';
  final ep = parseEpisode(xml); // adapt to actual parser API
  check(ep.itunesExplicit).isTrue();
});
```

- [ ] **Step 5: Run tests**

```bash
cd packages/audiflow_domain && flutter test
cd packages/audiflow_podcast && flutter test
```

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/episode.dart packages/audiflow_domain/lib/src/features/feed/models/episode.g.dart packages/audiflow_podcast/
git commit -m "feat(domain): add itunesExplicit field to Episode collection"
```

---

## Phase 3 — App layer: GateGuard, PIN sheet, l10n

### Task 3.1: `GateGuard` interface + `GateReason` enum

**Files:**
- Create: `packages/audiflow_app/lib/features/parental_control/domain/gate_guard.dart`

- [ ] **Step 1: Write the interface**

```dart
import 'package:flutter/widgets.dart';

enum GateReason {
  subscribe,
  unsubscribe,
  opmlImport,
  deepLink,
  parentalSettings,
  developerSettings,
}

abstract class GateGuard {
  /// Returns true if the action may proceed.
  ///
  /// - Restricted Mode off -> true immediately.
  /// - Restricted Mode on + already unlocked -> extends idle, returns true.
  /// - Otherwise shows the PIN entry sheet and awaits the result.
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  });
}
```

- [ ] **Step 2: Analyze**

```bash
cd packages/audiflow_app
flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/features/parental_control/domain/gate_guard.dart
git commit -m "feat(app): add GateGuard interface and GateReason enum"
```

### Task 3.2: l10n strings

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add keys**

In `app_en.arb`:

```json
"parentalControlTitle": "Parental Control",
"parentalControlEnable": "Restricted Mode",
"parentalControlEnableSubtitle": "Hide discovery and lock subscription changes",
"parentalControlPinSetupTitle": "Set a PIN",
"parentalControlPinSetupSubtitle": "Enter a 4-8 digit PIN",
"parentalControlPinConfirm": "Confirm PIN",
"parentalControlPinChange": "Change PIN",
"parentalControlPinCurrent": "Current PIN",
"parentalControlPinNew": "New PIN",
"parentalControlPinEntryReasonSubscribe": "Subscribe to this podcast",
"parentalControlPinEntryReasonUnsubscribe": "Unsubscribe from this podcast",
"parentalControlPinEntryReasonOpmlImport": "Import OPML",
"parentalControlPinEntryReasonDeepLink": "Open this link",
"parentalControlPinEntryReasonParentalSettings": "Change Parental Control",
"parentalControlPinEntryReasonDeveloperSettings": "Open Developer settings",
"parentalControlPinIncorrect": "Incorrect PIN. {remaining} attempts remaining.",
"@parentalControlPinIncorrect": { "placeholders": { "remaining": { "type": "int" } } },
"parentalControlLockoutCountdown": "Too many attempts. Try again in {seconds}s.",
"@parentalControlLockoutCountdown": { "placeholders": { "seconds": { "type": "int" } } },
"parentalControlForgotPinBanner": "Forgot PIN? Reset all app data from Storage settings.",
"parentalControlHideExplicitToggle": "Hide explicit episodes",
"parentalControlBiometricToggle": "Allow biometric unlock",
"parentalControlUnlockTimeoutLabel": "Auto re-lock after",
"parentalControlSubmit": "Submit",
"parentalControlCancel": "Cancel",
"parentalControlSettingsUnavailable": "Settings unavailable — restart the app.",
"parentalControlRestrictedRedirect": "Restricted Mode is on. Open the gate from Settings."
```

In `app_ja.arb`, mirror with Japanese translations (keep placeholder keys identical):

```json
"parentalControlTitle": "ペアレンタル コントロール",
"parentalControlEnable": "制限モード",
"parentalControlEnableSubtitle": "検索を隠し、購読変更をロックします",
"parentalControlPinSetupTitle": "PINを設定",
"parentalControlPinSetupSubtitle": "4〜8桁のPINを入力",
"parentalControlPinConfirm": "PIN確認",
"parentalControlPinChange": "PINを変更",
"parentalControlPinCurrent": "現在のPIN",
"parentalControlPinNew": "新しいPIN",
"parentalControlPinEntryReasonSubscribe": "このポッドキャストを購読",
"parentalControlPinEntryReasonUnsubscribe": "このポッドキャストの購読を解除",
"parentalControlPinEntryReasonOpmlImport": "OPMLをインポート",
"parentalControlPinEntryReasonDeepLink": "このリンクを開く",
"parentalControlPinEntryReasonParentalSettings": "ペアレンタル コントロールを変更",
"parentalControlPinEntryReasonDeveloperSettings": "デベロッパー設定を開く",
"parentalControlPinIncorrect": "PINが正しくありません。残り{remaining}回。",
"@parentalControlPinIncorrect": { "placeholders": { "remaining": { "type": "int" } } },
"parentalControlLockoutCountdown": "試行回数が上限に達しました。{seconds}秒後に再試行できます。",
"@parentalControlLockoutCountdown": { "placeholders": { "seconds": { "type": "int" } } },
"parentalControlForgotPinBanner": "PINを忘れた場合は、ストレージ設定からすべてのデータをリセットしてください。",
"parentalControlHideExplicitToggle": "アダルト指定エピソードを非表示",
"parentalControlBiometricToggle": "生体認証によるロック解除を許可",
"parentalControlUnlockTimeoutLabel": "自動再ロックまでの時間",
"parentalControlSubmit": "送信",
"parentalControlCancel": "キャンセル",
"parentalControlSettingsUnavailable": "設定を利用できません。アプリを再起動してください。",
"parentalControlRestrictedRedirect": "制限モードが有効です。設定からゲートを開いてください。"
```

- [ ] **Step 2: Regenerate l10n**

```bash
cd packages/audiflow_app
flutter gen-l10n
```

- [ ] **Step 3: Analyze**

```bash
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/l10n/
git commit -m "feat(app): add parental control l10n strings (en, ja)"
```

### Task 3.3: `PinEntrySheet` widget + tests

**Files:**
- Create: `packages/audiflow_app/lib/features/parental_control/presentation/widgets/pin_entry_sheet.dart`
- Create: `packages/audiflow_app/test/features/parental_control/widgets/pin_entry_sheet_test.dart`

- [ ] **Step 1: Write failing widget test**

```dart
import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/presentation/widgets/pin_entry_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('Submit button disabled until 4 digits entered', (tester) async {
    await tester.pumpWidget(_wrap(
      PinEntrySheet(reason: GateReason.subscribe),
    ));
    final submit = find.text('Submit');
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNull();

    final field = find.byType(TextField).first;
    await tester.enterText(field, '12');
    await tester.pump();
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNull();

    await tester.enterText(field, '1234');
    await tester.pump();
    check(tester.widget<ElevatedButton>(submit.first).onPressed).isNotNull();
  });
}
```

- [ ] **Step 2: Run test — FAIL.**

- [ ] **Step 3: Write the widget**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/gate_guard.dart';

class PinEntrySheet extends ConsumerStatefulWidget {
  const PinEntrySheet({required this.reason, super.key});

  final GateReason reason;

  @override
  ConsumerState<PinEntrySheet> createState() => _PinEntrySheetState();
}

class _PinEntrySheetState extends ConsumerState<PinEntrySheet> {
  final _controller = TextEditingController();
  String? _errorMessage;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _reasonHeadline(AppLocalizations l10n) {
    return switch (widget.reason) {
      GateReason.subscribe => l10n.parentalControlPinEntryReasonSubscribe,
      GateReason.unsubscribe => l10n.parentalControlPinEntryReasonUnsubscribe,
      GateReason.opmlImport => l10n.parentalControlPinEntryReasonOpmlImport,
      GateReason.deepLink => l10n.parentalControlPinEntryReasonDeepLink,
      GateReason.parentalSettings =>
          l10n.parentalControlPinEntryReasonParentalSettings,
      GateReason.developerSettings =>
          l10n.parentalControlPinEntryReasonDeveloperSettings,
    };
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final pin = _controller.text;
    final notifier = ref.read(parentalControlGateProvider.notifier);
    final ok = await notifier.tryUnlock(pin);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }
    final state = ref.read(parentalControlGateProvider);
    final l10n = AppLocalizations.of(context);
    setState(() {
      _submitting = false;
      _controller.clear();
      if (state is LockedOut) {
        final seconds = state.retryAt.difference(DateTime.now()).inSeconds;
        // Guard against negative seconds at boundary
        final safe = seconds < 1 ? 1 : seconds;
        _errorMessage = l10n.parentalControlLockoutCountdown(safe);
      } else {
        // Show generic incorrect message; remaining attempts computed from state.
        const limit = 5;
        // Read failedAttempts directly via repo if needed; using a simple "—" placeholder for remaining.
        // Accurate count comes from a follow-up provider; for now, show plain message.
        _errorMessage = l10n.parentalControlPinIncorrect(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_reasonHeadline(l10n),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(l10n.parentalControlCancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (_controller.text.length < 4 || _submitting)
                    ? null
                    : _submit,
                child: Text(l10n.parentalControlSubmit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests**

```bash
cd packages/audiflow_app
flutter test test/features/parental_control/widgets/pin_entry_sheet_test.dart
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/parental_control/presentation/widgets/pin_entry_sheet.dart packages/audiflow_app/test/features/parental_control/widgets/pin_entry_sheet_test.dart
git commit -m "feat(app): add PinEntrySheet for parental control unlock"
```

### Task 3.4: `GateGuardImpl` + provider

**Files:**
- Create: `packages/audiflow_app/lib/features/parental_control/data/gate_guard_impl.dart`
- Create: `packages/audiflow_app/lib/features/parental_control/providers/gate_guard_provider.dart`
- Create: `packages/audiflow_app/test/features/parental_control/data/gate_guard_impl_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:audiflow_app/features/parental_control/data/gate_guard_impl.dart';
import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/test_isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await openTestIsar();
    container = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
  });

  testWidgets('returns true immediately when Restricted Mode is off',
      (tester) async {
    final guard = GateGuardImpl(ref: container);
    late BuildContext capturedCtx;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (ctx) {
          capturedCtx = ctx;
          return const Scaffold();
        }),
      ),
    ));
    final ok =
        await guard.requireUnlock(capturedCtx, reason: GateReason.subscribe);
    check(ok).isTrue();
  });
}
```

- [ ] **Step 2: Run — FAIL.**

- [ ] **Step 3: Write impl**

```dart
// gate_guard_impl.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/gate_guard.dart';
import '../presentation/widgets/pin_entry_sheet.dart';

class GateGuardImpl implements GateGuard {
  GateGuardImpl({required this.ref});

  final Ref ref;

  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async {
    final restricted = ref.read(isRestrictedModeOnProvider);
    if (!restricted) return true;

    final state = ref.read(parentalControlGateProvider);
    if (state is Unlocked) {
      ref.read(parentalControlGateProvider.notifier).extendIdle();
      return true;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (_) => PinEntrySheet(reason: reason),
    );
    return result ?? false;
  }
}
```

```dart
// gate_guard_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/gate_guard_impl.dart';
import '../domain/gate_guard.dart';

part 'gate_guard_provider.g.dart';

@Riverpod(keepAlive: true)
GateGuard gateGuard(Ref ref) => GateGuardImpl(ref: ref);
```

- [ ] **Step 4: Codegen + tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/parental_control/data/gate_guard_impl_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/parental_control/
git add packages/audiflow_app/test/features/parental_control/data/
git commit -m "feat(app): add GateGuardImpl and provider"
```

---

## Phase 4 — Settings screens

### Task 4.1: `PinSetupScreen` + controller + tests

**Files:**
- Create: `packages/audiflow_app/lib/features/parental_control/presentation/screens/pin_setup_screen.dart`
- Create: `packages/audiflow_app/lib/features/parental_control/presentation/controllers/parental_control_controller.dart`
- Create: `packages/audiflow_app/test/features/parental_control/screens/pin_setup_screen_test.dart`

- [ ] **Step 1: Write controller** (it's small; combined here)

```dart
// parental_control_controller.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parental_control_controller.g.dart';

@riverpod
class ParentalControlController extends _$ParentalControlController {
  @override
  Future<ParentalControlSettings> build() async {
    return ref.watch(parentalControlRepositoryProvider).getSettings();
  }

  Future<void> setPin(String pin) async {
    await ref.read(parentalControlRepositoryProvider).setPin(pin);
    ref.invalidateSelf();
  }

  Future<void> setRestrictedMode(bool enabled) async {
    await ref.read(parentalControlRepositoryProvider).setRestrictedMode(enabled);
    ref.invalidateSelf();
  }

  Future<void> setUnlockTimeout(Duration timeout) async {
    await ref.read(parentalControlRepositoryProvider).setUnlockTimeout(timeout);
    ref.invalidateSelf();
  }
}
```

- [ ] **Step 2: Write PinSetupScreen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/parental_control_controller.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  String? _err;

  bool get _valid {
    final n = _pin1.text.length;
    return 4 <= n && n <= 8 && _pin1.text == _pin2.text;
  }

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_pin1.text != _pin2.text) {
      final l10n = AppLocalizations.of(context);
      setState(() => _err = l10n.parentalControlPinIncorrect(0));
      return;
    }
    await ref
        .read(parentalControlControllerProvider.notifier)
        .setPin(_pin1.text);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentalControlPinSetupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.parentalControlPinSetupSubtitle),
            const SizedBox(height: 16),
            TextField(
              controller: _pin1,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (_) => setState(() => _err = null),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pin2,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.parentalControlPinConfirm,
                errorText: _err,
              ),
              onChanged: (_) => setState(() => _err = null),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _valid ? _save : null,
              child: Text(l10n.parentalControlSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Write a smoke widget test**

```dart
testWidgets('Save disabled until two matching 4-8 digit PINs entered',
    (tester) async {
  await tester.pumpWidget(/* ProviderScope + MaterialApp wrap with PinSetupScreen */);
  // Enter "123" in both -> still disabled (too short)
  // Enter "1234" + "1235" -> still disabled (mismatch)
  // Enter "1234" + "1234" -> enabled
});
```

(Mirror the pattern from `PinEntrySheet` test; assert button `onPressed` null vs non-null at each step.)

- [ ] **Step 4: Codegen + run tests**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/features/parental_control/screens/pin_setup_screen_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/parental_control/presentation/ packages/audiflow_app/test/features/parental_control/screens/
git commit -m "feat(app): add PinSetupScreen and ParentalControlController"
```

### Task 4.2: `ParentalControlSettingsScreen` + route

**Files:**
- Create: `packages/audiflow_app/lib/features/parental_control/presentation/screens/parental_control_settings_screen.dart`
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart`

- [ ] **Step 1: Write the screen**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../domain/gate_guard.dart';
import '../../providers/gate_guard_provider.dart';
import '../controllers/parental_control_controller.dart';

class ParentalControlSettingsScreen extends ConsumerWidget {
  const ParentalControlSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncSettings = ref.watch(parentalControlControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentalControlTitle)),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.parentalControlSettingsUnavailable)),
        data: (s) => ListView(
          children: [
            if (s.pinHashBase64 == null)
              ListTile(
                title: Text(l10n.parentalControlPinSetupTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.parentalControlPinSetup),
              )
            else ...[
              SwitchListTile(
                title: Text(l10n.parentalControlEnable),
                subtitle: Text(l10n.parentalControlEnableSubtitle),
                value: s.restrictedModeEnabled,
                onChanged: (v) async {
                  final guard = ref.read(gateGuardProvider);
                  final ok = await guard.requireUnlock(
                    context,
                    reason: GateReason.parentalSettings,
                  );
                  if (!ok) return;
                  await ref
                      .read(parentalControlControllerProvider.notifier)
                      .setRestrictedMode(v);
                },
              ),
              ListTile(
                title: Text(l10n.parentalControlUnlockTimeoutLabel),
                trailing: DropdownButton<int>(
                  value: s.unlockTimeoutSeconds,
                  items: const [
                    DropdownMenuItem(value: 60, child: Text('1 min')),
                    DropdownMenuItem(value: 300, child: Text('5 min')),
                    DropdownMenuItem(value: 900, child: Text('15 min')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    final guard = ref.read(gateGuardProvider);
                    final ok = await guard.requireUnlock(
                      context,
                      reason: GateReason.parentalSettings,
                    );
                    if (!ok) return;
                    await ref
                        .read(parentalControlControllerProvider.notifier)
                        .setUnlockTimeout(Duration(seconds: v));
                  },
                ),
              ),
              ListTile(
                title: Text(l10n.parentalControlPinChange),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final guard = ref.read(gateGuardProvider);
                  final ok = await guard.requireUnlock(
                    context,
                    reason: GateReason.parentalSettings,
                  );
                  if (!ok) return;
                  if (!context.mounted) return;
                  context.push(AppRoutes.parentalControlPinChange);
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.parentalControlForgotPinBanner,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Register routes**

In `app_router.dart`, add to `AppRoutes`:

```dart
  static const String settingsParentalControl = '/settings/parental-control';
  static const String parentalControlPinSetup = '/settings/parental-control/pin-setup';
  static const String parentalControlPinChange = '/settings/parental-control/pin-change';
```

Add corresponding `GoRoute` entries inside the settings branch shell:

```dart
GoRoute(
  path: AppRoutes.settingsParentalControl,
  parentNavigatorKey: rootNavigatorKey,
  builder: (_, __) => const ParentalControlSettingsScreen(),
),
GoRoute(
  path: AppRoutes.parentalControlPinSetup,
  parentNavigatorKey: rootNavigatorKey,
  builder: (_, __) => const PinSetupScreen(),
),
GoRoute(
  path: AppRoutes.parentalControlPinChange,
  parentNavigatorKey: rootNavigatorKey,
  builder: (_, __) => const PinChangeScreen(),
),
```

Add the matching `import` statements at the top of `app_router.dart`:

```dart
import '../features/parental_control/presentation/screens/parental_control_settings_screen.dart';
import '../features/parental_control/presentation/screens/pin_change_screen.dart';
import '../features/parental_control/presentation/screens/pin_setup_screen.dart';
```

- [ ] **Step 3: Add a Settings grid card**

In `settings_screen.dart`, add a new category card "Parental Control" → `context.push(AppRoutes.settingsParentalControl)`.

- [ ] **Step 4: Run analyze**

```bash
cd packages/audiflow_app
flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/parental_control/presentation/screens/parental_control_settings_screen.dart packages/audiflow_app/lib/routing/app_router.dart packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart
git commit -m "feat(app): add Parental Control settings screen and route"
```

### Task 4.3: `PinChangeScreen` (re-enter current PIN, then new+confirm)

**Files:**
- Create: `packages/audiflow_app/lib/features/parental_control/presentation/screens/pin_change_screen.dart`
- Create: `packages/audiflow_app/test/features/parental_control/screens/pin_change_screen_test.dart`

- [ ] **Step 1: Write the screen**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/parental_control_controller.dart';

class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  final _current = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();

  bool _currentVerified = false;
  String? _err;

  @override
  void dispose() {
    _current.dispose();
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  bool get _newValid {
    final n = _new1.text.length;
    return 4 <= n && n <= 8 && _new1.text == _new2.text;
  }

  Future<void> _verifyCurrent() async {
    final ok = await ref
        .read(parentalControlRepositoryProvider)
        .verifyPin(_current.text);
    if (!mounted) return;
    setState(() {
      _currentVerified = ok;
      _err = ok ? null : AppLocalizations.of(context).parentalControlPinIncorrect(0);
    });
  }

  Future<void> _save() async {
    await ref
        .read(parentalControlControllerProvider.notifier)
        .setPin(_new1.text);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentalControlPinChange)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _current,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              enabled: !_currentVerified,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.parentalControlPinCurrent,
                errorText: _err,
              ),
              onSubmitted: (_) => _verifyCurrent(),
            ),
            if (!_currentVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  onPressed: 4 <= _current.text.length ? _verifyCurrent : null,
                  child: Text(l10n.parentalControlSubmit),
                ),
              )
            else ...[
              const SizedBox(height: 16),
              TextField(
                controller: _new1,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.parentalControlPinNew,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _new2,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 8,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.parentalControlPinConfirm,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _newValid ? _save : null,
                child: Text(l10n.parentalControlSubmit),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write widget tests**

```dart
testWidgets('Cannot edit new-PIN fields until current PIN verified',
    (tester) async {
  // Pre-seed repo with PIN '1234' via container override.
  // Pump PinChangeScreen.
  // Initially: new-PIN fields not in tree.
  // Enter wrong current PIN -> tap Submit -> error shown, fields still absent.
  // Enter '1234' -> tap Submit -> new-PIN fields appear.
  // Enter matching new PINs -> Save enabled.
});
```

- [ ] **Step 3: Run analyze + tests**

```bash
flutter analyze
flutter test test/features/parental_control/screens/pin_change_screen_test.dart
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/parental_control/presentation/screens/pin_change_screen.dart packages/audiflow_app/test/features/parental_control/screens/pin_change_screen_test.dart
git commit -m "feat(app): add PinChangeScreen"
```

---

## Phase 5 — Integrations

### Task 5.1: `AppLifecycleObserver` — relock on background

**Files:**
- Modify: `packages/audiflow_app/lib/app/app_lifecycle_observer.dart`

- [ ] **Step 1: Add relock on `_onHide`**

Inside `_onHide`, before the existing background-download scheduling, add:

```dart
ref.read(parentalControlGateProvider.notifier).lock();
```

(Import `package:audiflow_domain/audiflow_domain.dart` if not already present.)

- [ ] **Step 2: Add a widget test that toggles `WidgetsBindingObserver.didChangeAppLifecycleState` to `paused` and asserts gate goes to Locked**

(Existing tests for `AppLifecycleObserver` should show the pattern.)

- [ ] **Step 3: Run tests**

```bash
flutter test
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/app/app_lifecycle_observer.dart packages/audiflow_app/test/app/app_lifecycle_observer_test.dart
git commit -m "feat(app): relock parental control gate on app hide"
```

### Task 5.2: Router redirect for restricted paths

**Files:**
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`

- [ ] **Step 1: Add a router-level redirect**

Inside `GoRouter` configuration, add a top-level `redirect`:

```dart
redirect: (context, state) {
  final container = ProviderScope.containerOf(context, listen: false);
  final restricted = container.read(isRestrictedModeOnProvider);
  if (!restricted) return null;

  final unlockState = container.read(parentalControlGateProvider);
  if (unlockState is Unlocked) return null;

  final loc = state.matchedLocation;
  const blocked = <String>[
    '/search',
    '/settings/developer',
  ];
  for (final prefix in blocked) {
    if (loc == prefix || loc.startsWith('$prefix/')) {
      return AppRoutes.library;
    }
  }
  return null;
},
```

Wire `refreshListenable` to a `ValueNotifier` that toggles whenever `parentalControlSettingsStreamProvider` emits, or use `ProviderScope` listener -> notifier pattern matching the existing onboarding redirect pattern.

- [ ] **Step 2: Add router test**

Test: build `MaterialApp.router` with `restrictedMode=true && locked`, navigate to `/search` → assert current location ends up at `/library`.

- [ ] **Step 3: Run tests**

```bash
flutter test
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/routing/app_router.dart packages/audiflow_app/test/routing/parental_control_redirect_test.dart
git commit -m "feat(app): redirect Search and Developer routes when restricted"
```

### Task 5.3: Nav-bar Search tab hiding

**Files:**
- Modify: `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`

- [ ] **Step 1: Filter destinations based on `isRestrictedModeOn` + `!isUnlocked`**

Read both providers at top of `build`, conditionally drop the Search `NavigationDestination` from the list. Index mapping in `currentIndex` must be adjusted when Search is dropped.

- [ ] **Step 2: Widget test**

Test: in restricted+locked state, the Search destination is not in the rendered `NavigationBar` widget tree.

- [ ] **Step 3: Run tests + commit**

```bash
flutter test test/routing/
git add packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart packages/audiflow_app/test/routing/scaffold_with_nav_bar_test.dart
git commit -m "feat(app): hide Search nav tab when restricted and locked"
```

### Task 5.4: Subscribe / Unsubscribe gating

**Files:**
- Modify: `packages/audiflow_app/lib/features/subscription/presentation/controllers/subscription_controller.dart`
- Modify: call sites of `toggleSubscription` (likely `podcast_detail_screen.dart`)

- [ ] **Step 1: Update `toggleSubscription` signature**

Add a `BuildContext context` parameter:

```dart
Future<void> toggleSubscription(
  BuildContext context,
  Podcast podcast, {
  SubscribeSource source = SubscribeSource.discovery,
}) async {
  final isCurrentlySubscribed = state.value ?? false;
  final guard = ref.read(gateGuardProvider);
  final ok = await guard.requireUnlock(
    context,
    reason: isCurrentlySubscribed
        ? GateReason.unsubscribe
        : GateReason.subscribe,
  );
  if (!ok) return;
  // ...existing body...
}
```

- [ ] **Step 2: Update all call sites**

```bash
grep -rn "toggleSubscription(" packages/audiflow_app/lib --include="*.dart"
```

Update each call to pass `context`.

- [ ] **Step 3: Widget test**

Test: tap Subscribe button while restricted+locked → PIN sheet appears; on cancel, no subscribe; on success, subscribe completes.

- [ ] **Step 4: Run analyze + tests + commit**

```bash
flutter analyze
flutter test
git add packages/audiflow_app/lib/features/subscription/ packages/audiflow_app/lib/features/podcast_detail/ packages/audiflow_app/test/features/subscription/
git commit -m "feat(app): gate subscribe/unsubscribe behind parental control"
```

### Task 5.5: OPML import gating

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_import_controller.dart`
- Modify: `packages/audiflow_app/lib/features/settings/presentation/controllers/opml_file_receiver_controller.dart`
- Modify: callers (preview screen, file receiver UI)

- [ ] **Step 1: Locate the entry method (`import(file)` or `startImport(...)`)**

```bash
grep -n "void\|Future" packages/audiflow_app/lib/features/settings/presentation/controllers/opml_import_controller.dart | head -30
```

- [ ] **Step 2: Add `BuildContext context` param + gate call** at the top of the entry method, returning early if the gate denies.

- [ ] **Step 3: Update callers + the file receiver path** (which can be triggered by an iOS share-sheet share — gate before showing the preview screen).

- [ ] **Step 4: Widget test** mirroring Task 5.4.

- [ ] **Step 5: Run tests + commit**

```bash
flutter test
git add packages/audiflow_app/lib/features/settings/ packages/audiflow_app/test/features/settings/
git commit -m "feat(app): gate OPML import behind parental control"
```

### Task 5.6: Deep link gating

**Files:**
- Modify: `packages/audiflow_app/lib/features/share/presentation/screens/deep_link_screen.dart`

- [ ] **Step 1: After resolve, check subscription**

Replace the body inside the `PodcastDeepLinkTarget` case:

```dart
case PodcastDeepLinkTarget(
  :final itunesId,
  :final feedUrl,
  :final title,
  :final artworkUrl,
):
  final subscribed = await ref
      .read(subscriptionRepositoryProvider)
      .isSubscribed(itunesId);
  if (!subscribed) {
    if (!mounted) return;
    final ok = await ref.read(gateGuardProvider).requireUnlock(
          context,
          reason: GateReason.deepLink,
        );
    if (!ok) {
      if (mounted) context.go(AppRoutes.library);
      return;
    }
  }
  final podcast = Podcast(
    id: itunesId,
    name: title,
    artistName: '',
    feedUrl: feedUrl,
    artworkUrl: artworkUrl,
  );
  context.go(
    '${AppRoutes.search}/podcast/$itunesId',
    extra: <String, dynamic>{
      'podcast': podcast,
      'subscribeSource': SubscribeSource.deeplink,
    },
  );
  return;
```

Apply the same `subscribed && !restricted` guard to `EpisodeDeepLinkTarget` (use the parent podcast's `itunesId`).

- [ ] **Step 2: Widget test**

Test: deep link → not subscribed + restricted → PIN sheet → cancel → on `/library`.

- [ ] **Step 3: Run tests + commit**

```bash
flutter test
git add packages/audiflow_app/lib/features/share/ packages/audiflow_app/test/features/share/
git commit -m "feat(app): gate non-subscribed deep links behind parental control"
```

### Task 5.7: Developer settings card hiding

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart`

- [ ] **Step 1: Watch `isRestrictedModeOn` + `isUnlocked`**

When restricted-and-locked, drop the Developer category card from the grid (router redirect already blocks direct navigation; this just removes the visible entry).

- [ ] **Step 2: Widget test + commit**

```bash
flutter test
git add packages/audiflow_app/lib/features/settings/
git commit -m "feat(app): hide Developer settings card when restricted and locked"
```

### Task 5.8: Per-podcast `hideExplicitEpisodes` toggle on podcast detail

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`
- Modify: episode list builder in same file or its widget

- [ ] **Step 1: Show toggle only while unlocked**

In the podcast detail screen menu (overflow), add a `SwitchListTile`-style entry that watches `hideExplicitForPodcastProvider(itunesId)` and calls `repo.setHideExplicit(itunesId, v)`. Render the entry only when `ref.watch(isUnlockedProvider) == true`.

- [ ] **Step 2: Apply filter in episode list builder**

```dart
final hideExplicit = ref.watch(hideExplicitForPodcastProvider(itunesId)).valueOrNull ?? false;
final visible = hideExplicit
    ? episodes.where((e) => !e.itunesExplicit).toList()
    : episodes;
```

- [ ] **Step 3: Widget test**

Test: toggle on → explicit episodes removed from list; toggle off → reappear.

- [ ] **Step 4: Run tests + commit**

```bash
flutter test
git add packages/audiflow_app/lib/features/podcast_detail/
git commit -m "feat(app): per-podcast hide explicit episodes toggle"
```

### Task 5.9: `pruneFlagsFor` hook on unsubscribe

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart`

- [ ] **Step 1: Inject `ParentalControlRepository`**

Add it as a constructor dep; in the Riverpod provider, wire `ref.watch(parentalControlRepositoryProvider)`.

- [ ] **Step 2: Call `pruneFlagsFor(itunesId)` after a successful `unsubscribe(itunesId)`**

- [ ] **Step 3: Test**

```dart
test('unsubscribe removes parental flags for the podcast', () async {
  await parentalRepo.setHideExplicit(42, true);
  await subscriptionRepo.unsubscribe(42);
  check(await parentalRepo.getHideExplicit(42)).isFalse();
});
```

- [ ] **Step 4: Commit**

```bash
flutter test
git add packages/audiflow_domain/lib/src/features/subscription/
git commit -m "feat(domain): prune parental flags on unsubscribe"
```

---

## Phase 6 — Polish

### Task 6.1: Analytics events

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/parental_control/services/parental_control_gate.dart`
- Modify: `packages/audiflow_domain/lib/src/features/parental_control/repositories/parental_control_repository_impl.dart`

- [ ] **Step 1: Locate the existing analytics service**

```bash
grep -rn "class AnalyticsService\|analyticsServiceProvider" packages/audiflow_domain/lib --include="*.dart" | head -5
```

Read the file to confirm the emit method signature (commonly `void emit(String name, [Map<String, Object?> properties])`).

- [ ] **Step 2: Inject + emit in repo impl**

In `ParentalControlRepositoryImpl.setRestrictedMode`:

```dart
@override
Future<void> setRestrictedMode(bool enabled) async {
  final s = await _ds.getSettings();
  s.restrictedModeEnabled = enabled;
  await _ds.saveSettings(s);
  _analytics.emit(
    enabled ? 'parental_control.enabled' : 'parental_control.disabled',
  );
}
```

In `registerFailedAttempt`, after `await _ds.saveSettings(s);`:

```dart
_analytics.emit('parental_control.unlock_failed', {'attempts': s.failedAttempts});
if (lockout != null) {
  _analytics.emit(
    'parental_control.lockout',
    {'duration_seconds': lockout.inSeconds},
  );
}
```

- [ ] **Step 3: Emit in gate notifier**

In `ParentalControlGate.tryUnlock`, on the successful branch (just before `state = Unlocked(...)`):

```dart
ref.read(analyticsServiceProvider).emit(
  'parental_control.unlock_success',
  {'reason': _lastRequestedReason ?? 'unknown'},
);
```

(Plumb `_lastRequestedReason` via an optional parameter on `tryUnlock(String pin, {GateReason? reason})` so callers can pass it; default to `null`.)

- [ ] **Step 4: Tests with `FakeAnalyticsService`**

```dart
class FakeAnalyticsService implements AnalyticsService {
  final List<({String name, Map<String, Object?>? props})> emitted = [];

  @override
  void emit(String name, [Map<String, Object?>? props]) {
    emitted.add((name: name, props: props));
  }
}

test('setRestrictedMode emits enabled event', () async {
  final analytics = FakeAnalyticsService();
  // build repo with analytics override
  await repo.setRestrictedMode(true);
  check(analytics.emitted.map((e) => e.name))
      .contains('parental_control.enabled');
});
```

- [ ] **Step 4: Commit**

```bash
flutter test
git add packages/audiflow_domain/lib/src/features/parental_control/
git commit -m "feat(domain): emit parental control analytics events"
```

### Task 6.2: Sentry capture for storage failures

**Files:**
- Modify: `parental_control_repository_impl.dart`

- [ ] **Step 1: Wrap datasource calls in `try/catch`**

Replace bare `await _ds.getSettings()` and `await _ds.saveSettings(s)` callsites in `ParentalControlRepositoryImpl` with helper methods:

```dart
Future<ParentalControlSettings> _safeGet() async {
  try {
    return await _ds.getSettings();
  } catch (e, stack) {
    _logger.e('Failed to read parental control settings',
        error: e, stackTrace: stack);
    await Sentry.captureException(e, stackTrace: stack);
    rethrow;
  }
}

Future<void> _safeSave(ParentalControlSettings s) async {
  try {
    await _ds.saveSettings(s);
  } catch (e, stack) {
    _logger.e('Failed to write parental control settings',
        error: e, stackTrace: stack);
    await Sentry.captureException(e, stackTrace: stack);
    rethrow;
  }
}
```

Inject `Logger` via constructor (use `namedLoggerProvider('ParentalControl')` from the provider).

- [ ] **Step 2: Test storage failure**

Add a `ThrowingLocalDataSource` test double that throws on `getSettings`; assert the gate transitions to `Locked` and `tryUnlock` returns false with an error logged.

- [ ] **Step 2: Tests pass; commit**

```bash
git add packages/audiflow_domain/lib/src/features/parental_control/
git commit -m "feat(domain): report parental control storage failures to Sentry"
```

### Task 6.3: Integration test

**Files:**
- Create: `packages/audiflow_app/integration_test/parental_control_test.dart`

- [ ] **Step 1: Cover the end-to-end flow**:

```
launch -> open Parental Control -> set PIN -> enable Restricted Mode
-> background app -> reopen -> assert Search tab absent
-> navigate to /search -> assert redirected to /library
-> open subscribed podcast detail -> tap Subscribe-toggle -> PIN sheet
-> enter PIN -> unsubscribe completes
-> background app -> reopen -> assert PIN required again
```

- [ ] **Step 2: Commit**

```bash
flutter test integration_test/parental_control_test.dart
git add packages/audiflow_app/integration_test/parental_control_test.dart
git commit -m "test(app): end-to-end parental control integration test"
```

### Task 6.4: Final lint / format / analyze + push

- [ ] **Step 1: Format**

```bash
dart format packages/audiflow_app packages/audiflow_domain packages/audiflow_podcast
```

- [ ] **Step 2: Analyze (zero issues)**

```bash
melos run analyze
```

- [ ] **Step 3: Full test suite**

```bash
melos run test
```

- [ ] **Step 4: Push branch + open PR**

```bash
git push -u origin feat/parental-control
gh pr create \
  --title "feat: parental control (PIN-gated Restricted Mode)" \
  --body "$(cat <<'EOF'
## Summary
- PIN-gated Restricted Mode hides Search tab + Developer settings
- Gates Subscribe / Unsubscribe / OPML import / non-subscribed deep links
- Per-podcast Hide-Explicit-Episodes opt-in toggle
- PBKDF2-HMAC-SHA256 PIN hashing with per-install salt
- Idle 5-min auto-relock; immediate relock on app background
- Exponential lockout backoff after 5 failures, persisted across restart
- Implements FR 18; spec at docs/superpowers/specs/2026-05-28-parental-control-design.md

## Test plan
- [ ] Unit tests pass: melos run test
- [ ] Analyze clean: melos run analyze
- [ ] Integration test: parental_control_test.dart passes
- [ ] Manual: set PIN, enable Restricted Mode, verify Search tab gone
- [ ] Manual: subscribe gated, PIN sheet appears, success completes flow
- [ ] Manual: app background -> reopen -> re-locked
- [ ] Manual: 5 wrong PINs -> 30s lockout countdown
- [ ] Manual: Reset all data clears the PIN
EOF
)"
```

---

## Deferred follow-ups (separate PR)

- **Biometric unlock**: add `local_auth` dep, biometric toggle in Parental Control screen, biometric button in `PinEntrySheet` shown when `biometricUnlockEnabled` and platform supports it.
- **Remaining-attempts counter on PIN sheet**: surface `failedAttempts` via a provider so the sheet can render the accurate remaining count instead of the placeholder `0`.
- **Voice command gate**: when FR 10 lands, route voice intents that would subscribe / open non-subscribed content through the gate.
- **Settings & Data reset confirmation copy**: mention that PIN is cleared by Reset-all-data — copy edit only, no behavior change.
