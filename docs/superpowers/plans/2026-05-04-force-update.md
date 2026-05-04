# Force Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a remote-controlled force-upgrade feature: hard block / soft nudge / maintenance mode, driven by a static JSON config on GitHub Pages, with i18n, fail-open-then-closed cache semantics, and an in-app gate that runs before the router.

**Architecture:** New feature module under `packages/audiflow_app/lib/features/force_update/` with `data/`, `domain/`, `presentation/` layers. Pure-function evaluator (testable in isolation). Repository coordinates Dio remote + SharedPreferences cache. Riverpod `keepAlive` controller exposes `AsyncValue<UpdateDecision>`. Gate widget wraps `MaterialApp.router` and either mounts the router (with optional banner) or renders a full-screen `ForceUpdateScreen`. Localized via existing intl ARB files (en, ja). Sentry breadcrumbs/events for failure modes and decision transitions.

**Tech Stack:** Flutter / Dart, Riverpod 3 (`@riverpod` codegen), Freezed + json_serializable (`fieldRename: FieldRename.snake`), Dio, shared_preferences, package_info_plus, url_launcher, pub_semver, sentry_flutter, intl/flutter_localizations, `package:checks` for tests.

**Spec:** `docs/superpowers/specs/2026-05-04-force-upgrade-design.md`

---

## File Structure

| File | Responsibility |
|---|---|
| `packages/audiflow_app/lib/features/force_update/constants.dart` | Constants (refresh interval, timeout, cache keys, env var name) |
| `packages/audiflow_app/lib/features/force_update/data/force_update_config.dart` | Freezed model + JSON (snake_case) |
| `packages/audiflow_app/lib/features/force_update/data/force_update_local_data_source.dart` | SharedPreferences read/write |
| `packages/audiflow_app/lib/features/force_update/data/force_update_remote_data_source.dart` | Dio fetch with timeout |
| `packages/audiflow_app/lib/features/force_update/data/force_update_repository.dart` | Coordinates remote + cache |
| `packages/audiflow_app/lib/features/force_update/domain/update_decision.dart` | Sealed `UpdateDecision` types |
| `packages/audiflow_app/lib/features/force_update/domain/force_update_evaluator.dart` | Pure function `evaluate()` |
| `packages/audiflow_app/lib/features/force_update/domain/update_url_resolver.dart` | configUrl ?? platform store fallback |
| `packages/audiflow_app/lib/features/force_update/domain/i18n_message_resolver.dart` | Resolve `messageKey` + `messageOverride` to displayable strings |
| `packages/audiflow_app/lib/features/force_update/presentation/force_update_controller.dart` | Riverpod async controller w/ lifecycle observer |
| `packages/audiflow_app/lib/features/force_update/presentation/force_update_screen.dart` | Full-screen splash (hard / maintenance) |
| `packages/audiflow_app/lib/features/force_update/presentation/force_update_banner.dart` | Soft banner widget |
| `packages/audiflow_app/lib/features/force_update/presentation/force_update_gate.dart` | Wraps MaterialApp content; renders splash or child |
| `packages/audiflow_app/lib/features/force_update/force_update.dart` | Barrel export |
| `packages/audiflow_app/lib/l10n/app_en.arb` | Modify: add `forceUpdate*` keys |
| `packages/audiflow_app/lib/l10n/app_ja.arb` | Modify: add `forceUpdate*` keys |
| `packages/audiflow_app/lib/main.dart` | Modify: wrap router with `ForceUpdateGate`, init controller |
| `packages/audiflow_app/pubspec.yaml` | Modify: add `pub_semver`, `url_launcher` (already present, verify) |
| `.env.dev` / `.env.stg` / `.env.prod` | Modify: add `FORCE_UPDATE_CONFIG_URL=...` |

**Test files:** mirror lib structure under `packages/audiflow_app/test/features/force_update/`.

---

## Task 1: Project setup — dependencies, env vars, scaffolding

**Files:**
- Modify: `packages/audiflow_app/pubspec.yaml`
- Modify: `.env.dev`, `.env.stg`, `.env.prod`
- Create: `packages/audiflow_app/lib/features/force_update/constants.dart`
- Create: `packages/audiflow_app/lib/features/force_update/force_update.dart`

- [ ] **Step 1: Verify `pub_semver` and `url_launcher` are declared explicitly**

Read `packages/audiflow_app/pubspec.yaml`. `url_launcher: ^6.3.1` already declared. Add `pub_semver` to `dependencies`:

```yaml
  # Versioning
  pub_semver: ^2.1.4
```

(If `pub_semver` is already present, skip.)

- [ ] **Step 2: Run pub get**

```
cd packages/audiflow_app && flutter pub get
```

Expected: succeeds.

- [ ] **Step 3: Add env var to all three env files**

Append the following line to each of `.env.dev`, `.env.stg`, `.env.prod`:

```
FORCE_UPDATE_CONFIG_URL=https://audiflow.github.io/audiflow-app-config/v1/app_config.json
```

For `.env.dev` use `app_config.dev.json`, for `.env.stg` use `app_config.stg.json`, for `.env.prod` use `app_config.json`.

(Hosting repo creation is out of scope of this code plan — the URL can resolve to 404 during development; fail-open behavior tolerates it.)

- [ ] **Step 4: Create constants file**

Create `packages/audiflow_app/lib/features/force_update/constants.dart`:

```dart
const forceUpdateRefreshInterval = Duration(hours: 6);
const forceUpdateFetchTimeout = Duration(seconds: 5);
const forceUpdateCacheKey = 'force_update_config_v1';
const forceUpdateLastFetchKey = 'force_update_last_fetch_at';
const forceUpdateConfigUrlEnv = 'FORCE_UPDATE_CONFIG_URL';
const forceUpdateSupportedSchemaVersion = 1;
```

- [ ] **Step 5: Create empty barrel**

Create `packages/audiflow_app/lib/features/force_update/force_update.dart`:

```dart
export 'constants.dart';
```

(Will be extended as files are added.)

- [ ] **Step 6: Analyze**

```
cd packages/audiflow_app && flutter analyze
```

Expected: zero issues.

- [ ] **Step 7: Commit**

```
git add packages/audiflow_app/pubspec.yaml packages/audiflow_app/lib/features/force_update .env.dev .env.stg .env.prod
git commit -m "chore(force-update): scaffold feature module + env vars"
```

---

## Task 2: ForceUpdateConfig model

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/data/force_update_config_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/data/force_update_config.dart`
- Modify: `packages/audiflow_app/lib/features/force_update/force_update.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/force_update/data/force_update_config_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/data/force_update_config.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

void main() {
  group('ForceUpdateConfig.fromJson', () {
    test('parses minimal valid payload', () {
      final json = {
        'schema_version': 1,
        'min_version': '2.0.0',
        'recommended_version': '2.1.0',
        'maintenance_mode': false,
        'message_key': 'default',
      };

      final cfg = ForceUpdateConfig.fromJson(json);

      check(cfg.schemaVersion).equals(1);
      check(cfg.minVersion).equals('2.0.0');
      check(cfg.recommendedVersion).equals('2.1.0');
      check(cfg.maintenanceMode).isFalse();
      check(cfg.messageKey).equals('default');
      check(cfg.messageOverride).isNull();
      check(cfg.updateUrl).isNull();
    });

    test('parses full payload with override and url', () {
      final json = {
        'schema_version': 1,
        'min_version': '2.0.0',
        'recommended_version': '2.1.0',
        'maintenance_mode': true,
        'message_key': 'security_critical',
        'message_override': {'en': 'Update', 'ja': 'アップデート'},
        'update_url': 'https://example.com/update',
      };

      final cfg = ForceUpdateConfig.fromJson(json);

      check(cfg.maintenanceMode).isTrue();
      check(cfg.messageOverride!['en']).equals('Update');
      check(cfg.messageOverride!['ja']).equals('アップデート');
      check(cfg.updateUrl).equals('https://example.com/update');
    });

    test('round-trips via toJson', () {
      final original = ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: false,
        messageKey: 'default',
      );

      final restored = ForceUpdateConfig.fromJson(original.toJson());

      check(restored).equals(original);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_config_test.dart
```

Expected: FAIL — "ForceUpdateConfig" is undefined.

- [ ] **Step 3: Implement model**

Create `packages/audiflow_app/lib/features/force_update/data/force_update_config.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'force_update_config.freezed.dart';
part 'force_update_config.g.dart';

@Freezed(toJson: true, fromJson: true)
abstract class ForceUpdateConfig with _$ForceUpdateConfig {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ForceUpdateConfig({
    required int schemaVersion,
    required String minVersion,
    required String recommendedVersion,
    required bool maintenanceMode,
    required String messageKey,
    Map<String, String>? messageOverride,
    String? updateUrl,
  }) = _ForceUpdateConfig;

  factory ForceUpdateConfig.fromJson(Map<String, dynamic> json) =>
      _$ForceUpdateConfigFromJson(json);
}
```

- [ ] **Step 4: Run code generation**

```
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

Expected: generates `force_update_config.freezed.dart` and `force_update_config.g.dart`.

- [ ] **Step 5: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_config_test.dart
```

Expected: 3/3 pass.

- [ ] **Step 6: Update barrel**

Edit `packages/audiflow_app/lib/features/force_update/force_update.dart`:

```dart
export 'constants.dart';
export 'data/force_update_config.dart';
```

- [ ] **Step 7: Analyze**

```
cd packages/audiflow_app && flutter analyze
```

Expected: zero issues.

- [ ] **Step 8: Commit**

```
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add ForceUpdateConfig model"
```

---

## Task 3: UpdateDecision sealed types

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/domain/update_decision_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/domain/update_decision.dart`

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/force_update/domain/update_decision_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/domain/update_decision.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateDecision', () {
    test('NoUpdate has no payload', () {
      const decision = NoUpdate();
      check(decision).isA<UpdateDecision>();
    });

    test('SoftUpdate carries messageKey, override, url', () {
      const decision = SoftUpdate(
        messageKey: 'security_critical',
        messageOverride: {'en': 'Hi'},
        updateUrl: 'https://x',
      );
      check(decision.messageKey).equals('security_critical');
      check(decision.messageOverride!['en']).equals('Hi');
      check(decision.updateUrl).equals('https://x');
    });

    test('HardUpdate has same payload shape as SoftUpdate', () {
      const decision = HardUpdate(messageKey: 'breaking_change');
      check(decision.messageKey).equals('breaking_change');
      check(decision.messageOverride).isNull();
      check(decision.updateUrl).isNull();
    });

    test('Maintenance has same payload shape', () {
      const decision = Maintenance(messageKey: 'maintenance');
      check(decision.messageKey).equals('maintenance');
    });

    test('decisions support equality', () {
      const a = NoUpdate();
      const b = NoUpdate();
      check(a).equals(b);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/update_decision_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 3: Implement sealed types**

Create `packages/audiflow_app/lib/features/force_update/domain/update_decision.dart`:

```dart
import 'package:meta/meta.dart';

@immutable
sealed class UpdateDecision {
  const UpdateDecision();
}

class NoUpdate extends UpdateDecision {
  const NoUpdate();

  @override
  bool operator ==(Object other) => other is NoUpdate;

  @override
  int get hashCode => 0;
}

abstract class _DecisionWithMessage extends UpdateDecision {
  final String messageKey;
  final Map<String, String>? messageOverride;
  final String? updateUrl;

  const _DecisionWithMessage({
    required this.messageKey,
    this.messageOverride,
    this.updateUrl,
  });
}

class SoftUpdate extends _DecisionWithMessage {
  const SoftUpdate({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is SoftUpdate &&
      other.messageKey == messageKey &&
      _mapEq(other.messageOverride, messageOverride) &&
      other.updateUrl == updateUrl;

  @override
  int get hashCode => Object.hash(messageKey, messageOverride, updateUrl);
}

class HardUpdate extends _DecisionWithMessage {
  const HardUpdate({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is HardUpdate &&
      other.messageKey == messageKey &&
      _mapEq(other.messageOverride, messageOverride) &&
      other.updateUrl == updateUrl;

  @override
  int get hashCode => Object.hash(messageKey, messageOverride, updateUrl);
}

class Maintenance extends _DecisionWithMessage {
  const Maintenance({
    required super.messageKey,
    super.messageOverride,
    super.updateUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is Maintenance &&
      other.messageKey == messageKey &&
      _mapEq(other.messageOverride, messageOverride) &&
      other.updateUrl == updateUrl;

  @override
  int get hashCode => Object.hash(messageKey, messageOverride, updateUrl);
}

bool _mapEq(Map<String, String>? a, Map<String, String>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/update_decision_test.dart
```

Expected: 5/5 pass.

- [ ] **Step 5: Update barrel**

Add to `force_update.dart`:

```dart
export 'domain/update_decision.dart';
```

- [ ] **Step 6: Analyze**

```
cd packages/audiflow_app && flutter analyze
```

Expected: zero issues.

- [ ] **Step 7: Commit**

```
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add UpdateDecision sealed types"
```

---

## Task 4: ForceUpdateEvaluator (pure function)

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/domain/force_update_evaluator_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/domain/force_update_evaluator.dart`

- [ ] **Step 1: Write failing tests covering all branches**

Create `packages/audiflow_app/test/features/force_update/domain/force_update_evaluator_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/data/force_update_config.dart';
import 'package:audiflow_app/features/force_update/domain/force_update_evaluator.dart';
import 'package:audiflow_app/features/force_update/domain/update_decision.dart';
import 'package:checks/checks.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

ForceUpdateConfig _cfg({
  int schemaVersion = 1,
  String minVersion = '2.0.0',
  String recommendedVersion = '2.1.0',
  bool maintenanceMode = false,
  String messageKey = 'default',
  Map<String, String>? messageOverride,
  String? updateUrl,
}) =>
    ForceUpdateConfig(
      schemaVersion: schemaVersion,
      minVersion: minVersion,
      recommendedVersion: recommendedVersion,
      maintenanceMode: maintenanceMode,
      messageKey: messageKey,
      messageOverride: messageOverride,
      updateUrl: updateUrl,
    );

void main() {
  group('evaluate', () {
    test('returns Maintenance regardless of version when flag set', () {
      final result = evaluate(
        config: _cfg(maintenanceMode: true, messageKey: 'maintenance'),
        currentVersion: Version.parse('999.0.0'),
      );
      check(result).isA<Maintenance>();
      check((result as Maintenance).messageKey).equals('maintenance');
    });

    test('returns HardUpdate when current < minVersion', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('1.9.9'),
      );
      check(result).isA<HardUpdate>();
    });

    test('returns SoftUpdate when minVersion <= current < recommendedVersion', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('2.0.5'),
      );
      check(result).isA<SoftUpdate>();
    });

    test('returns NoUpdate when current == recommendedVersion', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('2.1.0'),
      );
      check(result).isA<NoUpdate>();
    });

    test('returns NoUpdate when recommendedVersion < current', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('3.0.0'),
      );
      check(result).isA<NoUpdate>();
    });

    test('boundary: current == minVersion is SoftUpdate (not hard)', () {
      final result = evaluate(
        config: _cfg(),
        currentVersion: Version.parse('2.0.0'),
      );
      check(result).isA<SoftUpdate>();
    });

    test('Hard/Soft/Maintenance carry messageKey and override and updateUrl', () {
      final result = evaluate(
        config: _cfg(
          messageKey: 'security_critical',
          messageOverride: {'en': 'x'},
          updateUrl: 'https://y',
        ),
        currentVersion: Version.parse('1.0.0'),
      );
      check(result).isA<HardUpdate>();
      final hard = result as HardUpdate;
      check(hard.messageKey).equals('security_critical');
      check(hard.messageOverride!['en']).equals('x');
      check(hard.updateUrl).equals('https://y');
    });
  });

  group('configIsValid', () {
    test('rejects unsupported schema version', () {
      check(configIsValid(_cfg(schemaVersion: 999))).isFalse();
    });

    test('rejects when recommendedVersion < minVersion', () {
      check(configIsValid(_cfg(minVersion: '3.0.0', recommendedVersion: '2.0.0')))
          .isFalse();
    });

    test('rejects when min/recommended are not valid semver', () {
      check(configIsValid(_cfg(minVersion: 'not-semver'))).isFalse();
    });

    test('accepts minVersion == recommendedVersion', () {
      check(configIsValid(_cfg(minVersion: '2.0.0', recommendedVersion: '2.0.0')))
          .isTrue();
    });

    test('accepts minVersion < recommendedVersion at v1', () {
      check(configIsValid(_cfg())).isTrue();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/force_update_evaluator_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 3: Implement evaluator**

Create `packages/audiflow_app/lib/features/force_update/domain/force_update_evaluator.dart`:

```dart
import 'package:pub_semver/pub_semver.dart';

import '../constants.dart';
import '../data/force_update_config.dart';
import 'update_decision.dart';

/// Returns true if [config] is structurally valid and supported by this client.
/// Invalid configs are dropped (fail-open) by callers.
bool configIsValid(ForceUpdateConfig config) {
  if (forceUpdateSupportedSchemaVersion < config.schemaVersion) return false;
  final min = Version.tryParse(config.minVersion);
  final rec = Version.tryParse(config.recommendedVersion);
  if (min == null || rec == null) return false;
  if (rec < min) return false;
  return true;
}

/// Pure decision function. Caller is responsible for validating the config
/// via [configIsValid] first; passing an invalid config produces undefined
/// behaviour.
UpdateDecision evaluate({
  required ForceUpdateConfig config,
  required Version currentVersion,
}) {
  if (config.maintenanceMode) {
    return Maintenance(
      messageKey: config.messageKey,
      messageOverride: config.messageOverride,
      updateUrl: config.updateUrl,
    );
  }

  final min = Version.parse(config.minVersion);
  final rec = Version.parse(config.recommendedVersion);

  if (currentVersion < min) {
    return HardUpdate(
      messageKey: config.messageKey,
      messageOverride: config.messageOverride,
      updateUrl: config.updateUrl,
    );
  }
  if (currentVersion < rec) {
    return SoftUpdate(
      messageKey: config.messageKey,
      messageOverride: config.messageOverride,
      updateUrl: config.updateUrl,
    );
  }
  return const NoUpdate();
}
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/force_update_evaluator_test.dart
```

Expected: 12/12 pass.

- [ ] **Step 5: Update barrel**

Append to `force_update.dart`:

```dart
export 'domain/force_update_evaluator.dart';
```

- [ ] **Step 6: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add evaluator + config validator"
```

Expected: zero analyzer issues.

---

## Task 5: ForceUpdateLocalDataSource (SharedPreferences)

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/data/force_update_local_data_source_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/data/force_update_local_data_source.dart`

- [ ] **Step 1: Write failing tests**

Create `packages/audiflow_app/test/features/force_update/data/force_update_local_data_source_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/data/force_update_config.dart';
import 'package:audiflow_app/features/force_update/data/force_update_local_data_source.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ForceUpdateLocalDataSource ds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    ds = ForceUpdateLocalDataSource(prefs);
  });

  test('returns null when no cached value', () async {
    check(await ds.read()).isNull();
    check(ds.lastFetchAt()).isNull();
  });

  test('round-trips a stored config', () async {
    final cfg = const ForceUpdateConfig(
      schemaVersion: 1,
      minVersion: '2.0.0',
      recommendedVersion: '2.1.0',
      maintenanceMode: false,
      messageKey: 'default',
    );

    await ds.write(cfg, fetchedAt: DateTime.utc(2026, 5, 4, 12));

    final read = await ds.read();
    check(read).equals(cfg);
    check(ds.lastFetchAt()).equals(DateTime.utc(2026, 5, 4, 12));
  });

  test('discards corrupt cache and returns null', () async {
    await prefs.setString('force_update_config_v1', 'not json');
    check(await ds.read()).isNull();
  });

  test('clears cached state', () async {
    final cfg = const ForceUpdateConfig(
      schemaVersion: 1,
      minVersion: '2.0.0',
      recommendedVersion: '2.1.0',
      maintenanceMode: false,
      messageKey: 'default',
    );
    await ds.write(cfg, fetchedAt: DateTime.utc(2026, 5, 4));

    await ds.clear();

    check(await ds.read()).isNull();
    check(ds.lastFetchAt()).isNull();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_local_data_source_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 3: Implement local data source**

Create `packages/audiflow_app/lib/features/force_update/data/force_update_local_data_source.dart`:

```dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'force_update_config.dart';

class ForceUpdateLocalDataSource {
  ForceUpdateLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  Future<ForceUpdateConfig?> read() async {
    final raw = _prefs.getString(forceUpdateCacheKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return ForceUpdateConfig.fromJson(json);
    } catch (_) {
      // Corrupt cache; discard.
      await _prefs.remove(forceUpdateCacheKey);
      await _prefs.remove(forceUpdateLastFetchKey);
      return null;
    }
  }

  Future<void> write(ForceUpdateConfig config, {required DateTime fetchedAt}) async {
    await _prefs.setString(forceUpdateCacheKey, jsonEncode(config.toJson()));
    await _prefs.setString(
      forceUpdateLastFetchKey,
      fetchedAt.toUtc().toIso8601String(),
    );
  }

  DateTime? lastFetchAt() {
    final raw = _prefs.getString(forceUpdateLastFetchKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await _prefs.remove(forceUpdateCacheKey);
    await _prefs.remove(forceUpdateLastFetchKey);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_local_data_source_test.dart
```

Expected: 4/4 pass.

- [ ] **Step 5: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add local data source (SharedPreferences)"
```

Expected: zero issues.

---

## Task 6: ForceUpdateRemoteDataSource (Dio)

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/data/force_update_remote_data_source_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/data/force_update_remote_data_source.dart`

- [ ] **Step 1: Write failing tests using `http_mock_adapter`**

Create `packages/audiflow_app/test/features/force_update/data/force_update_remote_data_source_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/data/force_update_remote_data_source.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ForceUpdateRemoteDataSource ds;
  const url = 'https://example.com/app_config.json';

  setUp(() {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    ds = ForceUpdateRemoteDataSource(dio: dio, configUrl: url);
  });

  test('returns parsed config on 200', () async {
    adapter.onGet(url, (server) {
      server.reply(200, {
        'schema_version': 1,
        'min_version': '2.0.0',
        'recommended_version': '2.1.0',
        'maintenance_mode': false,
        'message_key': 'default',
      });
    });

    final cfg = await ds.fetch();

    check(cfg.minVersion).equals('2.0.0');
  });

  test('throws on non-200', () async {
    adapter.onGet(url, (server) => server.reply(500, ''));

    await check(ds.fetch()).throws<DioException>();
  });

  test('throws on malformed JSON', () async {
    adapter.onGet(url, (server) => server.reply(200, 'not json'));

    await check(ds.fetch()).throws<Exception>();
  });

  test('throws when configUrl is empty', () async {
    final empty = ForceUpdateRemoteDataSource(dio: dio, configUrl: '');
    await check(empty.fetch()).throws<StateError>();
  });
}
```

- [ ] **Step 2: Verify `http_mock_adapter` is available**

`http_mock_adapter` is listed in tech rules as a project test dep. Check `packages/audiflow_app/pubspec.yaml` `dev_dependencies`. If missing, add `http_mock_adapter: ^0.6.1`. Run `flutter pub get`.

- [ ] **Step 3: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_remote_data_source_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 4: Implement remote data source**

Create `packages/audiflow_app/lib/features/force_update/data/force_update_remote_data_source.dart`:

```dart
import 'package:dio/dio.dart';

import '../constants.dart';
import 'force_update_config.dart';

class ForceUpdateRemoteDataSource {
  ForceUpdateRemoteDataSource({required Dio dio, required String configUrl})
    : _dio = dio,
      _url = configUrl;

  final Dio _dio;
  final String _url;

  Future<ForceUpdateConfig> fetch() async {
    if (_url.isEmpty) {
      throw StateError('FORCE_UPDATE_CONFIG_URL is not configured');
    }

    final response = await _dio.get<Object?>(
      _url,
      options: Options(
        responseType: ResponseType.json,
        sendTimeout: forceUpdateFetchTimeout,
        receiveTimeout: forceUpdateFetchTimeout,
      ),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw FormatException(
        'Expected JSON object from force-update config; got ${data.runtimeType}',
      );
    }
    return ForceUpdateConfig.fromJson(data);
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_remote_data_source_test.dart
```

Expected: 4/4 pass.

- [ ] **Step 6: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update packages/audiflow_app/pubspec.yaml
git commit -m "feat(force-update): add remote data source (Dio)"
```

Expected: zero issues.

---

## Task 7: ForceUpdateRepository

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/data/force_update_repository_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/data/force_update_repository.dart`

- [ ] **Step 1: Write failing test using fakes (no codegen mocks)**

Create `packages/audiflow_app/test/features/force_update/data/force_update_repository_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/data/force_update_config.dart';
import 'package:audiflow_app/features/force_update/data/force_update_local_data_source.dart';
import 'package:audiflow_app/features/force_update/data/force_update_remote_data_source.dart';
import 'package:audiflow_app/features/force_update/data/force_update_repository.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRemote implements ForceUpdateRemoteDataSource {
  _FakeRemote({this.response, this.error});
  final ForceUpdateConfig? response;
  final Object? error;
  int callCount = 0;

  @override
  Future<ForceUpdateConfig> fetch() async {
    callCount++;
    if (error != null) throw error!;
    return response!;
  }
}

ForceUpdateConfig _validCfg() => const ForceUpdateConfig(
      schemaVersion: 1,
      minVersion: '2.0.0',
      recommendedVersion: '2.1.0',
      maintenanceMode: false,
      messageKey: 'default',
    );

ForceUpdateConfig _invalidCfg() => const ForceUpdateConfig(
      schemaVersion: 1,
      minVersion: '3.0.0',
      recommendedVersion: '2.0.0',
      maintenanceMode: false,
      messageKey: 'default',
    );

void main() {
  late SharedPreferences prefs;
  late ForceUpdateLocalDataSource local;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    local = ForceUpdateLocalDataSource(prefs);
  });

  test('successful fetch caches and returns config', () async {
    final cfg = _validCfg();
    final remote = _FakeRemote(response: cfg);
    final repo = ForceUpdateRepository(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).equals(cfg);
    check(await local.read()).equals(cfg);
    check(local.lastFetchAt()).isNotNull();
  });

  test('fetch fails, no cache: returns null (fail-open)', () async {
    final remote = _FakeRemote(error: Exception('boom'));
    final repo = ForceUpdateRepository(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).isNull();
  });

  test('fetch fails, cache exists: returns cached', () async {
    final cached = _validCfg();
    await local.write(cached, fetchedAt: DateTime.utc(2026, 1, 1));
    final remote = _FakeRemote(error: Exception('boom'));
    final repo = ForceUpdateRepository(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).equals(cached);
  });

  test('invalid config from remote is dropped: returns null when no cache', () async {
    final remote = _FakeRemote(response: _invalidCfg());
    final repo = ForceUpdateRepository(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).isNull();
    check(await local.read()).isNull();
  });

  test('invalid config from remote falls back to cached valid config', () async {
    final cached = _validCfg();
    await local.write(cached, fetchedAt: DateTime.utc(2026, 1, 1));
    final remote = _FakeRemote(response: _invalidCfg());
    final repo = ForceUpdateRepository(remote: remote, local: local);

    final result = await repo.refresh();

    check(result).equals(cached);
  });

  test('readCachedOnly returns cached without calling remote', () async {
    final cached = _validCfg();
    await local.write(cached, fetchedAt: DateTime.utc(2026, 1, 1));
    final remote = _FakeRemote(error: Exception('should not be called'));
    final repo = ForceUpdateRepository(remote: remote, local: local);

    final result = await repo.readCachedOnly();

    check(result).equals(cached);
    check(remote.callCount).equals(0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_repository_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 3: Implement repository**

Create `packages/audiflow_app/lib/features/force_update/data/force_update_repository.dart`:

```dart
import '../domain/force_update_evaluator.dart';
import 'force_update_config.dart';
import 'force_update_local_data_source.dart';
import 'force_update_remote_data_source.dart';

typedef ForceUpdateLogger = void Function(String message, Object? error);

class ForceUpdateRepository {
  ForceUpdateRepository({
    required ForceUpdateRemoteDataSource remote,
    required ForceUpdateLocalDataSource local,
    ForceUpdateLogger? onWarning,
  }) : _remote = remote,
       _local = local,
       _onWarning = onWarning;

  final ForceUpdateRemoteDataSource _remote;
  final ForceUpdateLocalDataSource _local;
  final ForceUpdateLogger? _onWarning;

  /// Fetches a fresh config; falls back to cache on failure or invalid payload.
  /// Returns null if neither remote nor cache yields a valid config.
  Future<ForceUpdateConfig?> refresh() async {
    try {
      final fresh = await _remote.fetch();
      if (configIsValid(fresh)) {
        await _local.write(fresh, fetchedAt: DateTime.now().toUtc());
        return fresh;
      }
      _onWarning?.call('Received invalid force-update config; ignoring', null);
    } catch (e, _) {
      _onWarning?.call('Force-update fetch failed', e);
    }
    return readCachedOnly();
  }

  /// Returns cached config without touching the network. Honors offline blocks.
  Future<ForceUpdateConfig?> readCachedOnly() async {
    final cached = await _local.read();
    if (cached == null) return null;
    if (!configIsValid(cached)) return null;
    return cached;
  }

  DateTime? lastFetchAt() => _local.lastFetchAt();
}
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/data/force_update_repository_test.dart
```

Expected: 6/6 pass.

- [ ] **Step 5: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add repository (remote+cache coordination)"
```

Expected: zero issues.

---

## Task 8: Localization keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

ARB keys must be flat identifiers, so the spec's logical `forceUpdate.<key>.<field>` becomes `forceUpdate<Key><Field>` camelCase keys in ARB.

- [ ] **Step 1: Add English keys to `app_en.arb`**

Add the following entries (insert near other top-level keys; ARB is a JSON map):

```json
"forceUpdateDefaultTitle": "Update Required",
"@forceUpdateDefaultTitle": { "description": "Default force-update title" },
"forceUpdateDefaultBody": "A newer version of Audiflow is required to continue.",
"@forceUpdateDefaultBody": { "description": "Default hard-update body" },
"forceUpdateDefaultSoftBody": "A newer version of Audiflow is available.",
"@forceUpdateDefaultSoftBody": { "description": "Default soft-update body" },

"forceUpdateSecurityCriticalTitle": "Security Update Required",
"@forceUpdateSecurityCriticalTitle": { "description": "Security-critical title" },
"forceUpdateSecurityCriticalBody": "Please update Audiflow to address an important security issue.",
"@forceUpdateSecurityCriticalBody": { "description": "Security-critical body" },
"forceUpdateSecurityCriticalSoftBody": "An important security update is available.",
"@forceUpdateSecurityCriticalSoftBody": { "description": "Security-critical soft body" },

"forceUpdateBreakingChangeTitle": "Update Required",
"@forceUpdateBreakingChangeTitle": { "description": "Breaking change title" },
"forceUpdateBreakingChangeBody": "Audiflow has changes that require an updated app to continue.",
"@forceUpdateBreakingChangeBody": { "description": "Breaking change body" },
"forceUpdateBreakingChangeSoftBody": "An update with required changes is available.",
"@forceUpdateBreakingChangeSoftBody": { "description": "Breaking change soft body" },

"forceUpdateOsDriftTitle": "Update Required",
"@forceUpdateOsDriftTitle": { "description": "OS drift title" },
"forceUpdateOsDriftBody": "Please update Audiflow to keep up with the latest platform requirements.",
"@forceUpdateOsDriftBody": { "description": "OS drift body" },
"forceUpdateOsDriftSoftBody": "A newer version is available with platform improvements.",
"@forceUpdateOsDriftSoftBody": { "description": "OS drift soft body" },

"forceUpdateMaintenanceTitle": "Under Maintenance",
"@forceUpdateMaintenanceTitle": { "description": "Maintenance title" },
"forceUpdateMaintenanceBody": "Audiflow is temporarily unavailable. Please try again later.",
"@forceUpdateMaintenanceBody": { "description": "Maintenance body" },

"forceUpdateActionUpdateNow": "Update now",
"@forceUpdateActionUpdateNow": { "description": "Update now button" },
"forceUpdateActionLater": "Later",
"@forceUpdateActionLater": { "description": "Later (dismiss soft banner)" },
"forceUpdateActionRetry": "Retry",
"@forceUpdateActionRetry": { "description": "Retry maintenance check" },
"forceUpdateActionQuit": "Quit",
"@forceUpdateActionQuit": { "description": "Quit app (Android only)" }
```

- [ ] **Step 2: Add Japanese keys to `app_ja.arb`**

Mirror exactly the same key names with Japanese values:

```json
"forceUpdateDefaultTitle": "アップデートが必要です",
"forceUpdateDefaultBody": "Audiflow を続けて使うには新しいバージョンが必要です。",
"forceUpdateDefaultSoftBody": "Audiflow の新しいバージョンが利用できます。",

"forceUpdateSecurityCriticalTitle": "セキュリティアップデート",
"forceUpdateSecurityCriticalBody": "重要なセキュリティ修正を含むアップデートを適用してください。",
"forceUpdateSecurityCriticalSoftBody": "重要なセキュリティアップデートが利用できます。",

"forceUpdateBreakingChangeTitle": "アップデートが必要です",
"forceUpdateBreakingChangeBody": "互換性のため Audiflow をアップデートしてください。",
"forceUpdateBreakingChangeSoftBody": "互換性のためのアップデートが利用できます。",

"forceUpdateOsDriftTitle": "アップデートが必要です",
"forceUpdateOsDriftBody": "プラットフォーム要件に合わせてアップデートしてください。",
"forceUpdateOsDriftSoftBody": "プラットフォーム改善を含む新しいバージョンが利用できます。",

"forceUpdateMaintenanceTitle": "メンテナンス中",
"forceUpdateMaintenanceBody": "Audiflow は一時的に利用できません。後ほどお試しください。",

"forceUpdateActionUpdateNow": "今すぐアップデート",
"forceUpdateActionLater": "あとで",
"forceUpdateActionRetry": "再試行",
"forceUpdateActionQuit": "終了"
```

(`@`-prefixed metadata only required in template `app_en.arb`; `app_ja.arb` may omit them.)

- [ ] **Step 3: Generate localizations**

```
cd packages/audiflow_app && flutter gen-l10n
```

Expected: regenerates `lib/l10n/app_localizations.dart`. No errors.

- [ ] **Step 4: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/l10n
git commit -m "i18n(force-update): add force-update strings (en, ja)"
```

Expected: zero issues.

---

## Task 9: i18nMessageResolver — key lookup with override + fallback

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/domain/i18n_message_resolver_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/domain/i18n_message_resolver.dart`

This module turns `(messageKey, override, AppLocalizations, Locale, kind)` into the actual displayable strings, with fallback to `default` when an unknown key arrives from the server.

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/force_update/domain/i18n_message_resolver_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/domain/i18n_message_resolver.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> _en() async =>
    AppLocalizations.delegate.load(const Locale('en'));
Future<AppLocalizations> _ja() async =>
    AppLocalizations.delegate.load(const Locale('ja'));

void main() {
  testWidgets('resolves known key (security_critical) for hard kind', (tester) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'security_critical',
      messageOverride: null,
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.title).equals(l10n.forceUpdateSecurityCriticalTitle);
    check(msg.body).equals(l10n.forceUpdateSecurityCriticalBody);
  });

  testWidgets('falls back to default for unknown key', (tester) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'totally_unknown_key',
      messageOverride: null,
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.title).equals(l10n.forceUpdateDefaultTitle);
    check(msg.body).equals(l10n.forceUpdateDefaultBody);
  });

  testWidgets('soft kind uses *SoftBody fields', (tester) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'breaking_change',
      messageOverride: null,
      kind: ForceUpdateMessageKind.soft,
    );

    check(msg.body).equals(l10n.forceUpdateBreakingChangeSoftBody);
  });

  testWidgets('maintenance kind uses maintenance keys regardless of messageKey', (tester) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'security_critical',
      messageOverride: null,
      kind: ForceUpdateMessageKind.maintenance,
    );

    check(msg.title).equals(l10n.forceUpdateMaintenanceTitle);
    check(msg.body).equals(l10n.forceUpdateMaintenanceBody);
  });

  testWidgets('messageOverride takes precedence over keys, picks language', (tester) async {
    final l10n = await _ja();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('ja'),
      messageKey: 'default',
      messageOverride: {'en': 'Update', 'ja': 'アップデートしてね'},
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.body).equals('アップデートしてね');
  });

  testWidgets('override falls back to en when locale missing', (tester) async {
    final l10n = await _ja();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('ja'),
      messageKey: 'default',
      messageOverride: {'en': 'English only'},
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.body).equals('English only');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/i18n_message_resolver_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 3: Implement resolver**

Create `packages/audiflow_app/lib/features/force_update/domain/i18n_message_resolver.dart`:

```dart
import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

enum ForceUpdateMessageKind { hard, soft, maintenance }

class ForceUpdateMessage {
  const ForceUpdateMessage({required this.title, required this.body});

  final String title;
  final String body;

  static ForceUpdateMessage resolve({
    required AppLocalizations l10n,
    required Locale locale,
    required String messageKey,
    required Map<String, String>? messageOverride,
    required ForceUpdateMessageKind kind,
  }) {
    if (kind == ForceUpdateMessageKind.maintenance) {
      return ForceUpdateMessage(
        title: l10n.forceUpdateMaintenanceTitle,
        body: messageOverride != null
            ? _pickOverride(messageOverride, locale)
            : l10n.forceUpdateMaintenanceBody,
      );
    }

    final entry = _entries[messageKey] ?? _entries['default']!;
    final title = entry.title(l10n);
    final body = messageOverride != null
        ? _pickOverride(messageOverride, locale)
        : (kind == ForceUpdateMessageKind.soft
            ? entry.softBody(l10n)
            : entry.body(l10n));

    return ForceUpdateMessage(title: title, body: body);
  }

  static String _pickOverride(Map<String, String> override, Locale locale) {
    return override[locale.languageCode] ?? override['en'] ?? override.values.first;
  }
}

typedef _L = String Function(AppLocalizations);

class _Entry {
  const _Entry({required this.title, required this.body, required this.softBody});
  final _L title;
  final _L body;
  final _L softBody;
}

final Map<String, _Entry> _entries = {
  'default': _Entry(
    title: (l) => l.forceUpdateDefaultTitle,
    body: (l) => l.forceUpdateDefaultBody,
    softBody: (l) => l.forceUpdateDefaultSoftBody,
  ),
  'security_critical': _Entry(
    title: (l) => l.forceUpdateSecurityCriticalTitle,
    body: (l) => l.forceUpdateSecurityCriticalBody,
    softBody: (l) => l.forceUpdateSecurityCriticalSoftBody,
  ),
  'breaking_change': _Entry(
    title: (l) => l.forceUpdateBreakingChangeTitle,
    body: (l) => l.forceUpdateBreakingChangeBody,
    softBody: (l) => l.forceUpdateBreakingChangeSoftBody,
  ),
  'os_drift': _Entry(
    title: (l) => l.forceUpdateOsDriftTitle,
    body: (l) => l.forceUpdateOsDriftBody,
    softBody: (l) => l.forceUpdateOsDriftSoftBody,
  ),
};
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/i18n_message_resolver_test.dart
```

Expected: 6/6 pass.

- [ ] **Step 5: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add i18n message resolver with override + fallback"
```

Expected: zero issues.

---

## Task 10: UpdateUrlResolver

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/domain/update_url_resolver_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/domain/update_url_resolver.dart`

The platform fallback URLs must come from a constant. Determine the actual App Store ID and Android package name from the existing build config (e.g., `packages/audiflow_app/ios/Runner.xcodeproj` `PRODUCT_BUNDLE_IDENTIFIER` and Android `applicationId`). Substitute below.

- [ ] **Step 1: Look up bundle identifiers**

```
grep -rn "PRODUCT_BUNDLE_IDENTIFIER\s*=" packages/audiflow_app/ios/Runner.xcodeproj/project.pbxproj | head -3
grep -rn "applicationId" packages/audiflow_app/android/app/build.gradle*
```

Record values (something like `com.audiflow.app` for Android, plus the App Store numeric ID once the app is in the store; if not yet listed, use the bundle ID URL `https://apps.apple.com/app/<bundle>` as a temporary placeholder and add a TODO comment).

- [ ] **Step 2: Write failing test**

Create `packages/audiflow_app/test/features/force_update/domain/update_url_resolver_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/domain/update_url_resolver.dart';
import 'package:checks/checks.dart';
import 'package:test/test.dart';

void main() {
  group('resolveUpdateUrl', () {
    test('configUrl is preferred when present', () {
      final uri = resolveUpdateUrl(
        configUrl: 'https://example.com/x',
        platform: TargetUpdatePlatform.ios,
      );
      check(uri.toString()).equals('https://example.com/x');
    });

    test('falls back to App Store on iOS when configUrl is null', () {
      final uri = resolveUpdateUrl(
        configUrl: null,
        platform: TargetUpdatePlatform.ios,
      );
      check(uri.toString()).startsWith('https://apps.apple.com/');
    });

    test('falls back to Play Store on Android when configUrl is null', () {
      final uri = resolveUpdateUrl(
        configUrl: null,
        platform: TargetUpdatePlatform.android,
      );
      check(uri.toString()).startsWith('market://details');
    });

    test('falls back to App Store when configUrl is empty string', () {
      final uri = resolveUpdateUrl(
        configUrl: '',
        platform: TargetUpdatePlatform.ios,
      );
      check(uri.toString()).startsWith('https://apps.apple.com/');
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/update_url_resolver_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 4: Implement resolver**

Create `packages/audiflow_app/lib/features/force_update/domain/update_url_resolver.dart`. Replace `<APP_STORE_URL>` and `<ANDROID_PACKAGE>` with the values discovered in Step 1:

```dart
enum TargetUpdatePlatform { ios, android, other }

const _appStoreUrl = '<APP_STORE_URL>';        // e.g. 'https://apps.apple.com/app/id1234567890'
const _androidPackage = '<ANDROID_PACKAGE>';   // e.g. 'com.audiflow.app'

Uri resolveUpdateUrl({
  required String? configUrl,
  required TargetUpdatePlatform platform,
}) {
  if (configUrl != null && configUrl.isNotEmpty) {
    return Uri.parse(configUrl);
  }
  switch (platform) {
    case TargetUpdatePlatform.ios:
      return Uri.parse(_appStoreUrl);
    case TargetUpdatePlatform.android:
      return Uri.parse('market://details?id=$_androidPackage');
    case TargetUpdatePlatform.other:
      return Uri.parse(_appStoreUrl);
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/update_url_resolver_test.dart
```

Expected: 4/4 pass.

- [ ] **Step 6: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add update URL resolver with store fallback"
```

Expected: zero issues.

---

## Task 11: ForceUpdateController (Riverpod)

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/presentation/force_update_controller_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/presentation/force_update_controller.dart`

Controller exposes `AsyncValue<UpdateDecision>`. Initial build performs a refresh; `refreshIfStale()` is called from a lifecycle observer in the gate widget. The provider depends on:
- `forceUpdateRepositoryProvider` (created in this task)
- `currentAppVersionProvider` (created in this task using `package_info_plus`)

- [ ] **Step 1: Write failing test**

Create `packages/audiflow_app/test/features/force_update/presentation/force_update_controller_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/data/force_update_config.dart';
import 'package:audiflow_app/features/force_update/data/force_update_local_data_source.dart';
import 'package:audiflow_app/features/force_update/data/force_update_remote_data_source.dart';
import 'package:audiflow_app/features/force_update/data/force_update_repository.dart';
import 'package:audiflow_app/features/force_update/domain/update_decision.dart';
import 'package:audiflow_app/features/force_update/presentation/force_update_controller.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRemote implements ForceUpdateRemoteDataSource {
  _FakeRemote(this.cfg);
  ForceUpdateConfig cfg;

  @override
  Future<ForceUpdateConfig> fetch() async => cfg;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<ProviderContainer> _container({
    required ForceUpdateConfig remoteCfg,
    required Version currentVersion,
  }) async {
    final remote = _FakeRemote(remoteCfg);
    final local = ForceUpdateLocalDataSource(prefs);
    final repo = ForceUpdateRepository(remote: remote, local: local);
    return ProviderContainer(
      overrides: [
        forceUpdateRepositoryProvider.overrideWithValue(repo),
        currentAppVersionProvider.overrideWithValue(currentVersion),
      ],
    );
  }

  test('initial state is HardUpdate when current < min', () async {
    final container = await _container(
      remoteCfg: const ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: false,
        messageKey: 'default',
      ),
      currentVersion: Version.parse('1.0.0'),
    );

    final result = await container.read(forceUpdateControllerProvider.future);

    check(result).isA<HardUpdate>();
  });

  test('initial state is NoUpdate when at recommendedVersion', () async {
    final container = await _container(
      remoteCfg: const ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: false,
        messageKey: 'default',
      ),
      currentVersion: Version.parse('2.1.0'),
    );

    final result = await container.read(forceUpdateControllerProvider.future);

    check(result).isA<NoUpdate>();
  });

  test('Maintenance flag yields Maintenance regardless of version', () async {
    final container = await _container(
      remoteCfg: const ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: true,
        messageKey: 'maintenance',
      ),
      currentVersion: Version.parse('999.0.0'),
    );

    final result = await container.read(forceUpdateControllerProvider.future);

    check(result).isA<Maintenance>();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_controller_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 3: Implement controller, repository provider, and version provider**

Create `packages/audiflow_app/lib/features/force_update/presentation/force_update_controller.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../data/force_update_local_data_source.dart';
import '../data/force_update_remote_data_source.dart';
import '../data/force_update_repository.dart';
import '../domain/force_update_evaluator.dart';
import '../domain/update_decision.dart';

part 'force_update_controller.g.dart';

/// Sentinel: replaced via override in tests.
@Riverpod(keepAlive: true)
Version currentAppVersion(Ref ref) {
  throw UnimplementedError(
    'currentAppVersionProvider must be overridden at app bootstrap',
  );
}

@Riverpod(keepAlive: true)
String forceUpdateConfigUrl(Ref ref) {
  return const String.fromEnvironment(forceUpdateConfigUrlEnv, defaultValue: '');
}

@Riverpod(keepAlive: true)
ForceUpdateRepository forceUpdateRepository(Ref ref) {
  final dio = Dio();
  final url = ref.watch(forceUpdateConfigUrlProvider);
  final logger = ref.watch(namedLoggerProvider('ForceUpdate'));
  final remote = ForceUpdateRemoteDataSource(dio: dio, configUrl: url);
  final prefs = ref.watch(sharedPreferencesProvider);
  final local = ForceUpdateLocalDataSource(prefs);
  return ForceUpdateRepository(
    remote: remote,
    local: local,
    onWarning: (msg, err) => logger.w(msg, error: err),
  );
}

@Riverpod(keepAlive: true)
class ForceUpdateController extends _$ForceUpdateController {
  @override
  Future<UpdateDecision> build() async {
    final repo = ref.watch(forceUpdateRepositoryProvider);
    final version = ref.watch(currentAppVersionProvider);

    final config = await repo.refresh();
    if (config == null) return const NoUpdate();

    return evaluate(config: config, currentVersion: version);
  }

  /// Re-fetches if the cache is older than [forceUpdateRefreshInterval].
  Future<void> refreshIfStale() async {
    final repo = ref.read(forceUpdateRepositoryProvider);
    final last = repo.lastFetchAt();
    if (last != null) {
      final age = DateTime.now().toUtc().difference(last);
      if (age < forceUpdateRefreshInterval) return;
    }
    ref.invalidateSelf();
  }

  /// Forces an immediate re-fetch (used by maintenance "Retry" button).
  Future<void> refreshNow() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Existing helper provider — used by `forceUpdateRepositoryProvider`.
/// If `sharedPreferencesProvider` already exists in the app, import it from
/// its current location instead of redeclaring it here. Below is a scaffold;
/// remove this provider if the app already exposes one.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden at app bootstrap '
    '(or imported from existing location)',
  );
}
```

- [ ] **Step 4: Wire to existing `sharedPreferencesProvider` if one exists**

Search for an existing prefs provider:

```
grep -rn "sharedPreferencesProvider\|SharedPreferences\\.getInstance" packages/audiflow_app/lib --include="*.dart" | head -10
grep -rn "sharedPreferencesProvider\|SharedPreferences" packages/audiflow_domain/lib --include="*.dart" | head -10
```

If one is found, delete the local `sharedPreferencesProvider` definition above and import the existing one. If none exists, keep the local one and override it from `main.dart` in Task 13.

- [ ] **Step 5: Generate Riverpod code**

```
cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs
```

Expected: produces `force_update_controller.g.dart`.

- [ ] **Step 6: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_controller_test.dart
```

Expected: 3/3 pass.

- [ ] **Step 7: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add Riverpod controller + providers"
```

Expected: zero issues.

---

## Task 12: ForceUpdateScreen (full-screen splash)

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/presentation/force_update_screen_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/presentation/force_update_screen.dart`

- [ ] **Step 1: Write failing widget tests**

Create `packages/audiflow_app/test/features/force_update/presentation/force_update_screen_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/domain/update_decision.dart';
import 'package:audiflow_app/features/force_update/presentation/force_update_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    );

void main() {
  testWidgets('hard update renders title, body, update button', (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateScreen(
        decision: HardUpdate(messageKey: 'default'),
      ),
    ));
    await tester.pumpAndSettle();

    check(find.text('Update Required').evaluate().isNotEmpty).isTrue();
    check(find.text('Update now').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('hard update falls back to default when key unknown', (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateScreen(
        decision: HardUpdate(messageKey: 'unknown_key_xyz'),
      ),
    ));
    await tester.pumpAndSettle();

    check(find.text('Update Required').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('messageOverride trumps localized key', (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateScreen(
        decision: HardUpdate(
          messageKey: 'default',
          messageOverride: {'en': 'CUSTOM-MESSAGE-XYZ'},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    check(find.text('CUSTOM-MESSAGE-XYZ').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('maintenance shows Retry instead of Update now', (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateScreen(
        decision: Maintenance(messageKey: 'maintenance'),
      ),
    ));
    await tester.pumpAndSettle();

    check(find.text('Retry').evaluate().isNotEmpty).isTrue();
    check(find.text('Update now').evaluate().isEmpty).isTrue();
  });

  testWidgets('back gesture cannot dismiss screen (PopScope blocks pop)',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateScreen(
        decision: HardUpdate(messageKey: 'default'),
      ),
    ));
    await tester.pumpAndSettle();

    final state = tester
        .widgetList<PopScope>(find.byType(PopScope))
        .firstOrNull;
    check(state).isNotNull();
    check(state!.canPop).isFalse();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_screen_test.dart
```

Expected: FAIL — `ForceUpdateScreen` undefined.

- [ ] **Step 3: Implement screen**

Create `packages/audiflow_app/lib/features/force_update/presentation/force_update_screen.dart`:

```dart
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/i18n_message_resolver.dart';
import '../domain/update_decision.dart';
import '../domain/update_url_resolver.dart';
import 'force_update_controller.dart';

class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({required this.decision, super.key});

  final UpdateDecision decision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final kind = switch (decision) {
      Maintenance() => ForceUpdateMessageKind.maintenance,
      HardUpdate() => ForceUpdateMessageKind.hard,
      // SoftUpdate / NoUpdate not expected here.
      _ => ForceUpdateMessageKind.hard,
    };

    final (key, override, url) = switch (decision) {
      HardUpdate(:final messageKey, :final messageOverride, :final updateUrl) =>
        (messageKey, messageOverride, updateUrl),
      Maintenance(:final messageKey, :final messageOverride, :final updateUrl) =>
        (messageKey, messageOverride, updateUrl),
      _ => ('default', null as Map<String, String>?, null as String?),
    };

    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: locale,
      messageKey: key,
      messageOverride: override,
      kind: kind,
    );

    final isMaintenance = decision is Maintenance;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMaintenance ? Icons.build : Icons.system_update,
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    msg.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    msg.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (isMaintenance)
                    FilledButton(
                      onPressed: () =>
                          ref.read(forceUpdateControllerProvider.notifier).refreshNow(),
                      child: Text(l10n.forceUpdateActionRetry),
                    )
                  else
                    FilledButton(
                      onPressed: () => _openUpdateUrl(url),
                      child: Text(l10n.forceUpdateActionUpdateNow),
                    ),
                  if (!isMaintenance && Platform.isAndroid) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: Text(l10n.forceUpdateActionQuit),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUpdateUrl(String? configUrl) async {
    final platform = Platform.isIOS
        ? TargetUpdatePlatform.ios
        : Platform.isAndroid
            ? TargetUpdatePlatform.android
            : TargetUpdatePlatform.other;
    final uri = resolveUpdateUrl(configUrl: configUrl, platform: platform);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_screen_test.dart
```

Expected: 5/5 pass. (Tests do not actually tap buttons that launch URLs; they only verify rendered text and `PopScope.canPop`.)

- [ ] **Step 5: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add full-screen splash (hard + maintenance)"
```

Expected: zero issues.

---

## Task 13: ForceUpdateBanner (soft nudge)

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/presentation/force_update_banner_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/presentation/force_update_banner.dart`

- [ ] **Step 1: Write failing widget test**

Create `packages/audiflow_app/test/features/force_update/presentation/force_update_banner_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/domain/update_decision.dart';
import 'package:audiflow_app/features/force_update/presentation/force_update_banner.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('renders body and Update / Later actions for SoftUpdate', (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateBanner(
        decision: SoftUpdate(messageKey: 'default'),
      ),
    ));
    await tester.pumpAndSettle();

    check(find.text('Update now').evaluate().isNotEmpty).isTrue();
    check(find.text('Later').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('Later button hides the banner for the rest of the session',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateBanner(
        decision: SoftUpdate(messageKey: 'default'),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    check(find.text('Update now').evaluate().isEmpty).isTrue();
  });

  testWidgets('non-soft decision renders nothing', (tester) async {
    await tester.pumpWidget(_wrap(
      const ForceUpdateBanner(
        decision: NoUpdate(),
      ),
    ));
    await tester.pumpAndSettle();

    check(find.byType(MaterialBanner).evaluate().isEmpty).isTrue();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_banner_test.dart
```

Expected: FAIL — undefined.

- [ ] **Step 3: Implement banner**

Create `packages/audiflow_app/lib/features/force_update/presentation/force_update_banner.dart`:

```dart
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/i18n_message_resolver.dart';
import '../domain/update_decision.dart';
import '../domain/update_url_resolver.dart';

class ForceUpdateBanner extends StatefulWidget {
  const ForceUpdateBanner({required this.decision, super.key});

  final UpdateDecision decision;

  @override
  State<ForceUpdateBanner> createState() => _ForceUpdateBannerState();
}

class _ForceUpdateBannerState extends State<ForceUpdateBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final decision = widget.decision;
    if (decision is! SoftUpdate || _dismissed) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: locale,
      messageKey: decision.messageKey,
      messageOverride: decision.messageOverride,
      kind: ForceUpdateMessageKind.soft,
    );

    return MaterialBanner(
      content: Text(msg.body),
      actions: [
        TextButton(
          onPressed: () => _openUpdateUrl(decision.updateUrl),
          child: Text(l10n.forceUpdateActionUpdateNow),
        ),
        TextButton(
          onPressed: () => setState(() => _dismissed = true),
          child: Text(l10n.forceUpdateActionLater),
        ),
      ],
    );
  }

  Future<void> _openUpdateUrl(String? configUrl) async {
    final platform = Platform.isIOS
        ? TargetUpdatePlatform.ios
        : Platform.isAndroid
            ? TargetUpdatePlatform.android
            : TargetUpdatePlatform.other;
    final uri = resolveUpdateUrl(configUrl: configUrl, platform: platform);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_banner_test.dart
```

Expected: 3/3 pass.

- [ ] **Step 5: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add soft banner widget"
```

Expected: zero issues.

---

## Task 14: ForceUpdateGate + lifecycle observer

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/presentation/force_update_gate_test.dart`
- Create: `packages/audiflow_app/lib/features/force_update/presentation/force_update_gate.dart`

The gate watches `forceUpdateControllerProvider` and:
- `loading` → renders a small loading splash (so cold start doesn't flash router)
- `error` → renders the child (fail-open)
- `data: NoUpdate` → renders child (router) directly
- `data: SoftUpdate` → renders child + banner overlay
- `data: HardUpdate` / `Maintenance` → renders `ForceUpdateScreen`

It also installs a `WidgetsBindingObserver` to call `refreshIfStale()` on resume.

- [ ] **Step 1: Write failing widget test**

Create `packages/audiflow_app/test/features/force_update/presentation/force_update_gate_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/domain/update_decision.dart';
import 'package:audiflow_app/features/force_update/presentation/force_update_controller.dart';
import 'package:audiflow_app/features/force_update/presentation/force_update_gate.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      ),
    );

void main() {
  testWidgets('NoUpdate renders child', (tester) async {
    final container = ProviderContainer(overrides: [
      forceUpdateControllerProvider.overrideWith(() => _StubController(const NoUpdate())),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(
      const ForceUpdateGate(child: Text('CHILD')),
      container,
    ));
    await tester.pumpAndSettle();

    check(find.text('CHILD').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('HardUpdate renders splash, not child', (tester) async {
    final container = ProviderContainer(overrides: [
      forceUpdateControllerProvider.overrideWith(
        () => _StubController(const HardUpdate(messageKey: 'default')),
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(
      const ForceUpdateGate(child: Text('CHILD-SHOULD-NOT-RENDER')),
      container,
    ));
    await tester.pumpAndSettle();

    check(find.text('CHILD-SHOULD-NOT-RENDER').evaluate().isEmpty).isTrue();
    check(find.text('Update Required').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('Maintenance renders splash with Retry', (tester) async {
    final container = ProviderContainer(overrides: [
      forceUpdateControllerProvider.overrideWith(
        () => _StubController(const Maintenance(messageKey: 'maintenance')),
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(
      const ForceUpdateGate(child: Text('CHILD')),
      container,
    ));
    await tester.pumpAndSettle();

    check(find.text('Retry').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('SoftUpdate renders child plus banner', (tester) async {
    final container = ProviderContainer(overrides: [
      forceUpdateControllerProvider.overrideWith(
        () => _StubController(const SoftUpdate(messageKey: 'default')),
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(
      const ForceUpdateGate(child: Text('CHILD')),
      container,
    ));
    await tester.pumpAndSettle();

    check(find.text('CHILD').evaluate().isNotEmpty).isTrue();
    check(find.text('Update now').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('error in controller falls back to child (fail-open)', (tester) async {
    final container = ProviderContainer(overrides: [
      forceUpdateControllerProvider.overrideWith(
        () => _StubController(null, error: Exception('boom')),
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(
      const ForceUpdateGate(child: Text('CHILD')),
      container,
    ));
    await tester.pumpAndSettle();

    check(find.text('CHILD').evaluate().isNotEmpty).isTrue();
  });
}

class _StubController extends ForceUpdateController {
  _StubController(this._decision, {this.error});

  final UpdateDecision? _decision;
  final Object? error;

  @override
  Future<UpdateDecision> build() async {
    if (error != null) throw error!;
    return _decision!;
  }
}
```

- [ ] **Step 2: Run test to verify it fails**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_gate_test.dart
```

Expected: FAIL — `ForceUpdateGate` undefined.

- [ ] **Step 3: Implement gate**

Create `packages/audiflow_app/lib/features/force_update/presentation/force_update_gate.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/update_decision.dart';
import 'force_update_banner.dart';
import 'force_update_controller.dart';
import 'force_update_screen.dart';

class ForceUpdateGate extends ConsumerStatefulWidget {
  const ForceUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends ConsumerState<ForceUpdateGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(forceUpdateControllerProvider.notifier).refreshIfStale();
    }
  }

  @override
  Widget build(BuildContext context) {
    final decisionAsync = ref.watch(forceUpdateControllerProvider);

    return decisionAsync.when(
      loading: () => const _Loading(),
      error: (_, __) => widget.child,
      data: (decision) => switch (decision) {
        NoUpdate() => widget.child,
        SoftUpdate() => _SoftLayer(decision: decision, child: widget.child),
        HardUpdate() || Maintenance() => ForceUpdateScreen(decision: decision),
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _SoftLayer extends StatelessWidget {
  const _SoftLayer({required this.decision, required this.child});

  final UpdateDecision decision;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: ForceUpdateBanner(decision: decision),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```
cd packages/audiflow_app && flutter test test/features/force_update/presentation/force_update_gate_test.dart
```

Expected: 5/5 pass.

- [ ] **Step 5: Update barrel**

Add to `force_update.dart`:

```dart
export 'presentation/force_update_controller.dart';
export 'presentation/force_update_gate.dart';
```

- [ ] **Step 6: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add gate widget with lifecycle observer"
```

Expected: zero issues.

---

## Task 15: Wire ForceUpdateGate into main.dart

**Files:**
- Modify: `packages/audiflow_app/lib/main.dart`

The gate must wrap the `MaterialApp.router` builder result so it sits above all routes. The `currentAppVersionProvider` must be overridden at bootstrap with the real `package_info_plus` version.

- [ ] **Step 1: Read current main.dart structure (orientation)**

```
sed -n '1,60p' packages/audiflow_app/lib/main.dart
sed -n '120,170p' packages/audiflow_app/lib/main.dart
sed -n '215,235p' packages/audiflow_app/lib/main.dart
sed -n '395,440p' packages/audiflow_app/lib/main.dart
```

Locate:
- The `PackageInfo.fromPlatform()` call (already exists around line 130).
- The `UncontrolledProviderScope` instantiation (line 218).
- `MaterialApp.router` invocation (line 401) and its `builder:` parameter (line 427: `builder: (context, child) => OpmlFileReceiver(child: child!)`).

- [ ] **Step 2: Add provider overrides at bootstrap**

In `main.dart`, locate the `ProviderContainer` / `UncontrolledProviderScope` overrides list. Add:

```dart
import 'package:pub_semver/pub_semver.dart';
import 'features/force_update/force_update.dart';
import 'features/force_update/presentation/force_update_controller.dart';
```

Inside the existing overrides list:

```dart
overrides: [
  // ...existing overrides...
  currentAppVersionProvider.overrideWithValue(
    Version.parse(packageInfo.version),
  ),
  // If sharedPreferencesProvider is the local one defined in
  // force_update_controller.dart, also override it here:
  sharedPreferencesProvider.overrideWithValue(sharedPreferences),
],
```

(`packageInfo` and `sharedPreferences` are already obtained earlier in the existing bootstrap.)

- [ ] **Step 3: Wrap MaterialApp content with ForceUpdateGate**

Change the existing builder from:

```dart
builder: (context, child) => OpmlFileReceiver(child: child!),
```

to:

```dart
builder: (context, child) => ForceUpdateGate(
  child: OpmlFileReceiver(child: child!),
),
```

- [ ] **Step 4: Add `package_info_plus` version parse safety**

If `Version.parse(packageInfo.version)` could throw on a malformed `pubspec.yaml` version (it won't for normal builds), wrap in try/catch and fall back to `Version(0, 0, 0)`. Default behaviour is fine — `2.0.0+1` parses cleanly because `pub_semver` accepts the build suffix.

- [ ] **Step 5: Analyze**

```
cd packages/audiflow_app && flutter analyze
```

Expected: zero issues.

- [ ] **Step 6: Manual smoke test (dev flavor)**

Either run the app, or note that this step is manual and will be exercised in Task 17.

- [ ] **Step 7: Commit**

```
git add packages/audiflow_app/lib/main.dart
git commit -m "feat(force-update): wire ForceUpdateGate into app bootstrap"
```

---

## Task 16: Sentry instrumentation

**Files:**
- Modify: `packages/audiflow_app/lib/features/force_update/data/force_update_repository.dart`
- Modify: `packages/audiflow_app/lib/features/force_update/presentation/force_update_controller.dart`

Goal: emit Sentry breadcrumbs for fetch failures, parse failures, schema mismatches, invariant violations, and decision transitions.

- [ ] **Step 1a: Add failing tests for `configValidationFailure`**

Append to `packages/audiflow_app/test/features/force_update/domain/force_update_evaluator_test.dart` inside a new group:

```dart
  group('configValidationFailure', () {
    test('returns null when config is valid', () {
      check(configValidationFailure(_cfg())).isNull();
    });

    test('returns unsupportedSchemaVersion when schemaVersion is too high', () {
      check(configValidationFailure(_cfg(schemaVersion: 999)))
          .equals(ForceUpdateConfigInvalidReason.unsupportedSchemaVersion);
    });

    test('returns unparseableMinVersion when min is garbage', () {
      check(configValidationFailure(_cfg(minVersion: 'not-semver')))
          .equals(ForceUpdateConfigInvalidReason.unparseableMinVersion);
    });

    test('returns unparseableRecommendedVersion when recommended is garbage', () {
      check(configValidationFailure(_cfg(recommendedVersion: 'xx')))
          .equals(ForceUpdateConfigInvalidReason.unparseableRecommendedVersion);
    });

    test('returns recommendedBelowMin when rec < min', () {
      check(configValidationFailure(
        _cfg(minVersion: '3.0.0', recommendedVersion: '2.0.0'),
      )).equals(ForceUpdateConfigInvalidReason.recommendedBelowMin);
    });
  });
```

Run:

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/force_update_evaluator_test.dart
```

Expected: FAIL — `configValidationFailure` and `ForceUpdateConfigInvalidReason` undefined.

- [ ] **Step 1b: Refactor evaluator to expose `configValidationFailure`**

Replace `configIsValid` in `force_update_evaluator.dart` with the more granular form. `configIsValid` becomes a thin wrapper so existing call sites keep working:

```dart
enum ForceUpdateConfigInvalidReason {
  unsupportedSchemaVersion,
  unparseableMinVersion,
  unparseableRecommendedVersion,
  recommendedBelowMin,
}

ForceUpdateConfigInvalidReason? configValidationFailure(ForceUpdateConfig config) {
  if (forceUpdateSupportedSchemaVersion < config.schemaVersion) {
    return ForceUpdateConfigInvalidReason.unsupportedSchemaVersion;
  }
  final min = Version.tryParse(config.minVersion);
  if (min == null) {
    return ForceUpdateConfigInvalidReason.unparseableMinVersion;
  }
  final rec = Version.tryParse(config.recommendedVersion);
  if (rec == null) {
    return ForceUpdateConfigInvalidReason.unparseableRecommendedVersion;
  }
  if (rec < min) {
    return ForceUpdateConfigInvalidReason.recommendedBelowMin;
  }
  return null;
}

bool configIsValid(ForceUpdateConfig config) =>
    configValidationFailure(config) == null;
```

Run all evaluator tests:

```
cd packages/audiflow_app && flutter test test/features/force_update/domain/force_update_evaluator_test.dart
```

Expected: previous 12 tests still pass + 5 new tests pass = 17/17.

- [ ] **Step 2: Add Sentry breadcrumb emission to repository**

Modify `force_update_repository.dart` constructor signature to accept an optional Sentry breadcrumb hook:

```dart
typedef ForceUpdateBreadcrumb = void Function(String category, Map<String, Object?> data);

ForceUpdateRepository({
  required ForceUpdateRemoteDataSource remote,
  required ForceUpdateLocalDataSource local,
  ForceUpdateLogger? onWarning,
  ForceUpdateBreadcrumb? onBreadcrumb,
})
```

Apply these emissions in `refresh()`:

```dart
Future<ForceUpdateConfig?> refresh() async {
  try {
    final fresh = await _remote.fetch();
    final invalid = configValidationFailure(fresh);
    if (invalid == null) {
      await _local.write(fresh, fetchedAt: DateTime.now().toUtc());
      _onBreadcrumb?.call('force_update.fetch', {'status': 'ok'});
      return fresh;
    }
    _onBreadcrumb?.call('force_update.invalid', {'reason': invalid.name});
    _onWarning?.call('Received invalid force-update config: ${invalid.name}', null);
  } catch (e, _) {
    _onBreadcrumb?.call('force_update.fetch', {'status': 'error', 'error': '$e'});
    _onWarning?.call('Force-update fetch failed', e);
  }
  return readCachedOnly();
}
```

The new `_onBreadcrumb` is a private field initialised from the constructor's optional parameter; existing repository tests already pass `null` (default) and need no changes.

- [ ] **Step 3: Wire up Sentry breadcrumb in provider**

In `force_update_controller.dart`, build the repository with:

```dart
return ForceUpdateRepository(
  remote: remote,
  local: local,
  onWarning: (msg, err) => logger.w(msg, error: err),
  onBreadcrumb: (category, data) {
    Sentry.addBreadcrumb(Breadcrumb(
      category: category,
      level: SentryLevel.info,
      data: data,
    ));
  },
);
```

(Add `import 'package:sentry_flutter/sentry_flutter.dart';`)

- [ ] **Step 4: Decision-transition breadcrumb**

In `ForceUpdateController.build()`, after computing the decision, emit:

```dart
Sentry.addBreadcrumb(Breadcrumb(
  category: 'force_update.decision',
  level: SentryLevel.info,
  data: {'kind': decision.runtimeType.toString()},
));
```

- [ ] **Step 5: Run all force_update tests**

```
cd packages/audiflow_app && flutter test test/features/force_update
```

Expected: all pass. (Sentry calls in tests are no-ops because Sentry is not initialised; that's fine.)

- [ ] **Step 6: Analyze + commit**

```
cd packages/audiflow_app && flutter analyze
git add packages/audiflow_app/lib/features/force_update packages/audiflow_app/test/features/force_update
git commit -m "feat(force-update): add Sentry breadcrumbs for fetch + decisions"
```

Expected: zero issues.

---

## Task 17: End-to-end integration test

**Files:**
- Test: `packages/audiflow_app/test/features/force_update/integration/force_update_flow_test.dart`

Verifies: a fake repository emitting `HardUpdate` blocks the router, and a different fake emitting `NoUpdate` mounts it.

- [ ] **Step 1: Write integration test**

Create `packages/audiflow_app/test/features/force_update/integration/force_update_flow_test.dart`:

```dart
import 'package:audiflow_app/features/force_update/data/force_update_config.dart';
import 'package:audiflow_app/features/force_update/data/force_update_local_data_source.dart';
import 'package:audiflow_app/features/force_update/data/force_update_remote_data_source.dart';
import 'package:audiflow_app/features/force_update/data/force_update_repository.dart';
import 'package:audiflow_app/features/force_update/presentation/force_update_controller.dart';
import 'package:audiflow_app/features/force_update/presentation/force_update_gate.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StaticRemote implements ForceUpdateRemoteDataSource {
  _StaticRemote(this.cfg);
  final ForceUpdateConfig cfg;

  @override
  Future<ForceUpdateConfig> fetch() async => cfg;
}

Future<ProviderContainer> _container({
  required ForceUpdateConfig cfg,
  required Version version,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final local = ForceUpdateLocalDataSource(prefs);
  final repo = ForceUpdateRepository(
    remote: _StaticRemote(cfg),
    local: local,
  );
  return ProviderContainer(overrides: [
    forceUpdateRepositoryProvider.overrideWithValue(repo),
    currentAppVersionProvider.overrideWithValue(version),
  ]);
}

Widget _wrap(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ForceUpdateGate(child: child),
      ),
    );

void main() {
  testWidgets('hard config below min blocks the inner content', (tester) async {
    final container = await _container(
      cfg: const ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: false,
        messageKey: 'default',
      ),
      version: Version.parse('1.0.0'),
    );

    await tester.pumpWidget(_wrap(container, const Text('INNER-XYZ')));
    await tester.pumpAndSettle();

    check(find.text('INNER-XYZ').evaluate().isEmpty).isTrue();
    check(find.text('Update Required').evaluate().isNotEmpty).isTrue();
  });

  testWidgets('config equal to recommended renders inner content', (tester) async {
    final container = await _container(
      cfg: const ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: false,
        messageKey: 'default',
      ),
      version: Version.parse('2.1.0'),
    );

    await tester.pumpWidget(_wrap(container, const Text('INNER-XYZ')));
    await tester.pumpAndSettle();

    check(find.text('INNER-XYZ').evaluate().isNotEmpty).isTrue();
    check(find.text('Update Required').evaluate().isEmpty).isTrue();
  });

  testWidgets('maintenance mode shows splash regardless of version', (tester) async {
    final container = await _container(
      cfg: const ForceUpdateConfig(
        schemaVersion: 1,
        minVersion: '2.0.0',
        recommendedVersion: '2.1.0',
        maintenanceMode: true,
        messageKey: 'maintenance',
      ),
      version: Version.parse('999.0.0'),
    );

    await tester.pumpWidget(_wrap(container, const Text('INNER')));
    await tester.pumpAndSettle();

    check(find.text('Under Maintenance').evaluate().isNotEmpty).isTrue();
    check(find.text('Retry').evaluate().isNotEmpty).isTrue();
  });
}
```

- [ ] **Step 2: Run integration tests**

```
cd packages/audiflow_app && flutter test test/features/force_update/integration/force_update_flow_test.dart
```

Expected: 3/3 pass.

- [ ] **Step 3: Run full test suite**

```
cd packages/audiflow_app && flutter test
```

Expected: zero failures (existing + new).

- [ ] **Step 4: Commit**

```
git add packages/audiflow_app/test/features/force_update/integration
git commit -m "test(force-update): add end-to-end gate flow tests"
```

---

## Task 18: Final validation

- [ ] **Step 1: Workspace-wide analyze**

```
melos run analyze
```

Expected: zero issues across all packages.

- [ ] **Step 2: Workspace-wide tests**

```
melos run test
```

Expected: all pass.

- [ ] **Step 3: Coverage check (force_update only)**

```
cd packages/audiflow_app && flutter test --coverage test/features/force_update
```

Inspect `coverage/lcov.info` for `force_update` lines. Target: ≥ 80%. If under, add tests for uncovered branches.

- [ ] **Step 4: Manual smoke test on simulator/emulator**

Run dev flavor:

```
flutter run --flavor dev -t packages/audiflow_app/lib/main_dev.dart \
  --dart-define-from-file=.env.dev
```

(or via Makefile if a target exists)

Verify:
- App launches with `FORCE_UPDATE_CONFIG_URL` pointing to a non-existent endpoint → app runs normally (fail-open).
- Replace URL with a local stub returning `{minVersion: 99.0.0, ...}` → splash appears.
- Replace with `{maintenanceMode: true, ...}` → maintenance splash with Retry.
- Replace with `{minVersion: 0.0.1, recommendedVersion: 99.0.0}` → soft banner.

Note: this is a manual step. Document any flakiness.

- [ ] **Step 5: Final commit (if any housekeeping)**

If validation surfaces small fixes, commit them as a single chore commit.

---

## Open items (not blocking implementation, surface in PR description)

1. **Hosting repo:** create `audiflow/audiflow-app-config` (or new path under existing infra) and seed prod/stg/dev JSON files before promoting `FORCE_UPDATE_CONFIG_URL` to a real endpoint. Until then, fail-open keeps the app working.
2. **App Store ID:** if Audiflow is not yet listed in the App Store, the iOS fallback URL in `update_url_resolver.dart` is a placeholder. Replace before shipping force-upgrade in production.
3. **Coverage of error paths:** integration test does not cover Dio timeout / 5xx specifically (covered at unit level). If desired, add a `DioAdapter`-backed integration test that drives a real `ForceUpdateRepository` with simulated failures.
