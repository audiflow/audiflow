# Voice Settings Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable users to change any app preference setting via voice commands with fuzzy natural language interpretation.

**Architecture:** Extend the existing `VoiceCommandService` prompt to classify + resolve settings in a single AI call. A `SettingsIntentResolver` in `audiflow_domain` validates AI output against a `SettingsMetadataRegistry`. Three new `VoiceRecognitionState` variants drive confirmation/disambiguation/auto-apply UI in the existing overlay.

**Tech Stack:** Flutter/Dart, Riverpod, freezed, on-device AI (audiflow_ai), SharedPreferences

**Spec:** `docs/superpowers/specs/2026-03-24-voice-settings-design.md`

---

## File Map

### New Files

| File | Package | Purpose |
|------|---------|---------|
| `packages/audiflow_ai/lib/src/models/settings_change_payload.dart` | audiflow_ai | Sealed class for settings change data (absolute, relative, ambiguous) |
| `packages/audiflow_domain/lib/src/features/voice/models/settings_metadata.dart` | audiflow_domain | `SettingMetadata` model + `SettingType` enum + `SettingConstraints` |
| `packages/audiflow_domain/lib/src/features/voice/services/settings_metadata_registry.dart` | audiflow_domain | Registry of all voice-controllable settings |
| `packages/audiflow_domain/lib/src/features/voice/services/settings_snapshot_service.dart` | audiflow_domain | Builds prompt-ready text from registry + current values |
| `packages/audiflow_domain/lib/src/features/voice/services/settings_intent_resolver.dart` | audiflow_domain | Validates AI output, computes relative values, determines resolution path |
| `packages/audiflow_ai/test/models/settings_change_payload_test.dart` | audiflow_ai | Tests for payload model |
| `packages/audiflow_domain/test/features/voice/models/settings_metadata_test.dart` | audiflow_domain | Tests for metadata model |
| `packages/audiflow_domain/test/features/voice/services/settings_metadata_registry_test.dart` | audiflow_domain | Registry parity tests |
| `packages/audiflow_domain/test/features/voice/services/settings_snapshot_service_test.dart` | audiflow_domain | Snapshot format tests |
| `packages/audiflow_domain/test/features/voice/services/settings_intent_resolver_test.dart` | audiflow_domain | Resolver logic tests |

### Modified Files

| File | Lines | Change |
|------|-------|--------|
| `packages/audiflow_ai/lib/src/models/voice_command.dart` | 7-31, 34-71 | Add `changeSettings` intent; add `settingsPayload` field |
| `packages/audiflow_ai/lib/src/utils/prompt_templates.dart` | 80-112 | Extend voice command prompt with settings snapshot placeholder |
| `packages/audiflow_ai/lib/src/services/voice_command_service.dart` | 72-135 | Parse `changeSettings` response into `SettingsChangePayload` |
| `packages/audiflow_domain/lib/src/features/voice/models/voice_recognition_state.dart` | 10-43 | Add `settingsAutoApplied`, `settingsDisambiguation`, `settingsLowConfidence` states |
| `packages/audiflow_domain/lib/src/features/voice/services/voice_command_executor.dart` | 1-58 | Add `AppSettingsRepository` + `AudioPlayerController` coordination for settings |
| `packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart` | 206-276 | Add `changeSettings` case to `_executeCommand` switch |
| `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_listening_overlay.dart` | 51-176 | Add rendering for three new states |
| `packages/audiflow_app/lib/features/voice/presentation/controllers/voice_command_controller.dart` | 35-97 | Add settings-specific methods (confirm, undo, selectCandidate) |
| `packages/audiflow_domain/test/features/voice/models/voice_recognition_state_test.dart` | 153-190 | Add new states to exhaustive switch test |
| `packages/audiflow_ai/lib/audiflow_ai.dart` | barrel | Export new models |
| `packages/audiflow_domain/lib/audiflow_domain.dart` | barrel | Export new services/models |

---

## Task 1: SettingsChangePayload model (`audiflow_ai`)

**Files:**
- Create: `packages/audiflow_ai/lib/src/models/settings_change_payload.dart`
- Create: `packages/audiflow_ai/test/models/settings_change_payload_test.dart`
- Modify: `packages/audiflow_ai/lib/audiflow_ai.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_ai/test/models/settings_change_payload_test.dart
import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsChangePayload', () {
    group('absolute', () {
      test('creates with key and value', () {
        const payload = SettingsChangePayload.absolute(
          key: 'playbackSpeed',
          value: '1.5',
          confidence: 0.95,
        );
        expect(payload, isA<SettingsChangeAbsolute>());
        expect((payload as SettingsChangeAbsolute).key, 'playbackSpeed');
        expect(payload.value, '1.5');
        expect(payload.confidence, 0.95);
      });
    });

    group('relative', () {
      test('creates with key, direction, and magnitude', () {
        const payload = SettingsChangePayload.relative(
          key: 'playbackSpeed',
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.9,
        );
        expect(payload, isA<SettingsChangeRelative>());
        final rel = payload as SettingsChangeRelative;
        expect(rel.direction, ChangeDirection.increase);
        expect(rel.magnitude, ChangeMagnitude.small);
      });
    });

    group('ambiguous', () {
      test('creates with multiple candidates', () {
        const payload = SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(key: 'themeMode', value: 'dark', confidence: 0.6),
            SettingsCandidate(
              key: 'textScale',
              value: '0.8',
              confidence: 0.5,
            ),
          ],
        );
        expect(payload, isA<SettingsChangeAmbiguous>());
        expect(
          (payload as SettingsChangeAmbiguous).candidates.length,
          2,
        );
      });
    });

    group('ChangeDirection', () {
      test('has increase and decrease values', () {
        expect(ChangeDirection.values.length, 2);
        expect(ChangeDirection.values, contains(ChangeDirection.increase));
        expect(ChangeDirection.values, contains(ChangeDirection.decrease));
      });
    });

    group('ChangeMagnitude', () {
      test('has small, medium, and large values', () {
        expect(ChangeMagnitude.values.length, 3);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_ai && flutter test test/models/settings_change_payload_test.dart`
Expected: FAIL - imports cannot be resolved

- [ ] **Step 3: Write minimal implementation**

```dart
// packages/audiflow_ai/lib/src/models/settings_change_payload.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_change_payload.freezed.dart';

/// Direction for relative setting changes.
enum ChangeDirection { increase, decrease }

/// Magnitude for relative setting changes.
enum ChangeMagnitude { small, medium, large }

/// Payload describing a settings change resolved by the AI.
@freezed
sealed class SettingsChangePayload with _$SettingsChangePayload {
  /// An absolute value change (e.g. "set speed to 1.5x").
  const factory SettingsChangePayload.absolute({
    required String key,
    required String value,
    required double confidence,
  }) = SettingsChangeAbsolute;

  /// A relative value change (e.g. "a bit faster").
  const factory SettingsChangePayload.relative({
    required String key,
    required ChangeDirection direction,
    required ChangeMagnitude magnitude,
    required double confidence,
  }) = SettingsChangeRelative;

  /// Multiple possible settings matched (e.g. "make it darker").
  const factory SettingsChangePayload.ambiguous({
    required List<SettingsCandidate> candidates,
  }) = SettingsChangeAmbiguous;
}

/// A single candidate in an ambiguous settings resolution.
@freezed
class SettingsCandidate with _$SettingsCandidate {
  const factory SettingsCandidate({
    required String key,
    required String value,
    required double confidence,
  }) = _SettingsCandidate;
}
```

- [ ] **Step 4: Run codegen**

Run: `cd packages/audiflow_ai && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Export from barrel**

Add to `packages/audiflow_ai/lib/audiflow_ai.dart`:
```dart
export 'src/models/settings_change_payload.dart';
```

- [ ] **Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_ai && flutter test test/models/settings_change_payload_test.dart`
Expected: PASS

- [ ] **Step 7: Run analyze**

Run: `cd packages/audiflow_ai && flutter analyze`
Expected: No issues

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_ai/lib/src/models/settings_change_payload.dart \
  packages/audiflow_ai/lib/src/models/settings_change_payload.freezed.dart \
  packages/audiflow_ai/lib/audiflow_ai.dart \
  packages/audiflow_ai/test/models/settings_change_payload_test.dart
git commit -m "feat(ai): add SettingsChangePayload model for voice settings"
```

---

## Task 2: Add `changeSettings` intent to VoiceCommand (`audiflow_ai`)

**Files:**
- Modify: `packages/audiflow_ai/lib/src/models/voice_command.dart`
- Modify: `packages/audiflow_ai/test/services/voice_command_service_test.dart`

- [ ] **Step 1: Write the failing test**

Add to `packages/audiflow_ai/test/services/voice_command_service_test.dart`:
```dart
group('changeSettings intent', () {
  test('VoiceIntent includes changeSettings', () {
    expect(VoiceIntent.values, contains(VoiceIntent.changeSettings));
  });

  test('VoiceCommand holds settingsPayload', () {
    const payload = SettingsChangePayload.absolute(
      key: 'playbackSpeed',
      value: '1.5',
      confidence: 0.95,
    );
    final command = VoiceCommand(
      intent: VoiceIntent.changeSettings,
      parameters: const {},
      confidence: 0.95,
      rawTranscription: 'set speed to 1.5',
      settingsPayload: payload,
    );
    expect(command.settingsPayload, isA<SettingsChangeAbsolute>());
  });

  test('VoiceCommand settingsPayload is null for non-settings intents', () {
    const command = VoiceCommand(
      intent: VoiceIntent.play,
      parameters: {},
      confidence: 0.9,
      rawTranscription: 'play',
    );
    expect(command.settingsPayload, isNull);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_ai && flutter test test/services/voice_command_service_test.dart`
Expected: FAIL - `changeSettings` not in enum, `settingsPayload` not a field

- [ ] **Step 3: Add `changeSettings` to VoiceIntent and `settingsPayload` to VoiceCommand**

In `packages/audiflow_ai/lib/src/models/voice_command.dart`:

Add `changeSettings` before `unknown` in the `VoiceIntent` enum (line 29):
```dart
  // Settings intents
  changeSettings,
```

Add `settingsPayload` field to `VoiceCommand` (after `rawTranscription`):
```dart
  /// Optional structured payload for settings changes.
  final SettingsChangePayload? settingsPayload;
```

Update constructor to accept optional `settingsPayload`:
```dart
  const VoiceCommand({
    required this.intent,
    required this.parameters,
    required this.confidence,
    required this.rawTranscription,
    this.settingsPayload,
  });
```

Update `operator ==` and `hashCode` to include `settingsPayload`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_ai && flutter test test/services/voice_command_service_test.dart`
Expected: PASS

- [ ] **Step 5: Run analyze**

Run: `cd packages/audiflow_ai && flutter analyze`
Expected: No issues

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_ai/lib/src/models/voice_command.dart \
  packages/audiflow_ai/test/services/voice_command_service_test.dart
git commit -m "feat(ai): add changeSettings intent and settingsPayload to VoiceCommand"
```

---

## Task 3: SettingsMetadata model (`audiflow_domain`)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/voice/models/settings_metadata.dart`
- Create: `packages/audiflow_domain/test/features/voice/models/settings_metadata_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/voice/models/settings_metadata_test.dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingMetadata', () {
    test('creates boolean setting', () {
      const meta = SettingMetadata(
        key: 'skipSilence',
        displayNameKey: 'settingsSkipSilence',
        type: SettingType.boolean,
        constraints: SettingConstraints.boolean(),
        synonyms: ['skip silence', 'silence', '無音スキップ'],
      );
      expect(meta.key, 'skipSilence');
      expect(meta.type, SettingType.boolean);
      expect(meta.synonyms.length, 3);
    });

    test('creates numeric setting with range', () {
      const meta = SettingMetadata(
        key: 'playbackSpeed',
        displayNameKey: 'settingsPlaybackSpeed',
        type: SettingType.doubleValue,
        constraints: SettingConstraints.range(
          min: 0.5,
          max: 3.0,
          step: 0.1,
        ),
        synonyms: ['speed', '速度', 'スピード'],
      );
      final range = meta.constraints as RangeConstraints;
      expect(range.min, 0.5);
      expect(range.max, 3.0);
      expect(range.step, 0.1);
    });

    test('creates enum setting with options', () {
      const meta = SettingMetadata(
        key: 'themeMode',
        displayNameKey: 'settingsThemeMode',
        type: SettingType.enumValue,
        constraints: SettingConstraints.options(
          values: ['light', 'dark', 'system'],
        ),
        synonyms: ['theme', 'テーマ', '外観'],
      );
      final opts = meta.constraints as OptionsConstraints;
      expect(opts.values, ['light', 'dark', 'system']);
    });
  });

  group('SettingType', () {
    test('has all expected types', () {
      expect(SettingType.values, containsAll([
        SettingType.boolean,
        SettingType.intValue,
        SettingType.doubleValue,
        SettingType.enumValue,
      ]));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/models/settings_metadata_test.dart`
Expected: FAIL - types not found

- [ ] **Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/voice/models/settings_metadata.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_metadata.freezed.dart';

/// Types of settings values.
enum SettingType { boolean, intValue, doubleValue, enumValue }

/// Describes a single voice-controllable setting.
@freezed
class SettingMetadata with _$SettingMetadata {
  const factory SettingMetadata({
    required String key,
    required String displayNameKey,
    required SettingType type,
    required SettingConstraints constraints,
    required List<String> synonyms,
  }) = _SettingMetadata;
}

/// Constraints for a setting value.
@freezed
sealed class SettingConstraints with _$SettingConstraints {
  const factory SettingConstraints.boolean() = BooleanConstraints;

  const factory SettingConstraints.range({
    required double min,
    required double max,
    required double step,
  }) = RangeConstraints;

  const factory SettingConstraints.options({
    required List<String> values,
  }) = OptionsConstraints;
}
```

- [ ] **Step 4: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/voice/models/settings_metadata.dart';
```

- [ ] **Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/models/settings_metadata_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/models/settings_metadata.dart \
  packages/audiflow_domain/lib/src/features/voice/models/settings_metadata.freezed.dart \
  packages/audiflow_domain/lib/audiflow_domain.dart \
  packages/audiflow_domain/test/features/voice/models/settings_metadata_test.dart
git commit -m "feat(domain): add SettingMetadata model for voice settings registry"
```

---

## Task 4: SettingsMetadataRegistry (`audiflow_domain`)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/voice/services/settings_metadata_registry.dart`
- Create: `packages/audiflow_domain/test/features/voice/services/settings_metadata_registry_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/voice/services/settings_metadata_registry_test.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsMetadataRegistry', () {
    test('has entry for every settings key', () {
      // All keys from SettingsKeys that represent user-facing settings
      // (exclude lastTabIndex which is navigation state, not a preference)
      final settingsKeyValues = [
        SettingsKeys.themeMode,
        SettingsKeys.locale,
        SettingsKeys.textScale,
        SettingsKeys.playbackSpeed,
        SettingsKeys.skipForwardSeconds,
        SettingsKeys.skipBackwardSeconds,
        SettingsKeys.autoCompleteThreshold,
        SettingsKeys.continuousPlayback,
        SettingsKeys.autoPlayOrder,
        SettingsKeys.wifiOnlyDownload,
        SettingsKeys.autoDeletePlayed,
        SettingsKeys.maxConcurrentDownloads,
        SettingsKeys.autoSync,
        SettingsKeys.syncIntervalMinutes,
        SettingsKeys.wifiOnlySync,
        SettingsKeys.notifyNewEpisodes,
        SettingsKeys.searchCountry,
      ];

      final registry = SettingsMetadataRegistry();
      for (final key in settingsKeyValues) {
        expect(
          registry.findByKey(key),
          isNotNull,
          reason: 'Missing registry entry for key: $key',
        );
      }
    });

    test('every entry has non-empty synonyms', () {
      final registry = SettingsMetadataRegistry();
      for (final meta in registry.allSettings) {
        expect(
          meta.synonyms,
          isNotEmpty,
          reason: 'Setting ${meta.key} has no synonyms',
        );
      }
    });

    test('findByKey returns null for unknown key', () {
      final registry = SettingsMetadataRegistry();
      expect(registry.findByKey('nonexistent'), isNull);
    });

    test('playbackSpeed has correct range constraints', () {
      final registry = SettingsMetadataRegistry();
      final meta = registry.findByKey(SettingsKeys.playbackSpeed);
      expect(meta, isNotNull);
      expect(meta!.type, SettingType.doubleValue);
      final range = meta.constraints as RangeConstraints;
      expect(range.min, 0.5);
      expect(range.max, 3.0);
      expect(range.step, 0.1);
    });

    test('themeMode has correct options constraints', () {
      final registry = SettingsMetadataRegistry();
      final meta = registry.findByKey(SettingsKeys.themeMode);
      expect(meta, isNotNull);
      expect(meta!.type, SettingType.enumValue);
      final opts = meta.constraints as OptionsConstraints;
      expect(opts.values, containsAll(['light', 'dark', 'system']));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_metadata_registry_test.dart`
Expected: FAIL - `SettingsMetadataRegistry` not found

- [ ] **Step 3: Write the registry**

```dart
// packages/audiflow_domain/lib/src/features/voice/services/settings_metadata_registry.dart
import 'package:audiflow_core/audiflow_core.dart';

import '../models/settings_metadata.dart';

/// Registry of all voice-controllable settings with metadata.
///
/// Each setting has a key matching [SettingsKeys], type info, constraints,
/// and synonym hints for AI fuzzy matching.
class SettingsMetadataRegistry {
  SettingsMetadataRegistry();

  /// All registered settings.
  List<SettingMetadata> get allSettings => List.unmodifiable(_settings);

  /// Finds metadata by settings key. Returns null if not registered.
  SettingMetadata? findByKey(String key) {
    for (final meta in _settings) {
      if (meta.key == key) return meta;
    }
    return null;
  }

  static const _settings = <SettingMetadata>[
    // -- Appearance --
    SettingMetadata(
      key: SettingsKeys.themeMode,
      displayNameKey: 'settingsThemeMode',
      type: SettingType.enumValue,
      constraints: SettingConstraints.options(
        values: ['light', 'dark', 'system'],
      ),
      synonyms: [
        'theme', 'dark mode', 'light mode', 'appearance',
        'テーマ', 'ダークモード', 'ライトモード', '外観', '暗い', '明るい',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.textScale,
      displayNameKey: 'settingsTextScale',
      type: SettingType.doubleValue,
      constraints: SettingConstraints.range(min: 0.8, max: 1.4, step: 0.1),
      synonyms: [
        'text size', 'font size', 'text scale',
        '文字サイズ', 'フォントサイズ', '文字の大きさ',
      ],
    ),
    // -- Playback --
    SettingMetadata(
      key: SettingsKeys.playbackSpeed,
      displayNameKey: 'settingsPlaybackSpeed',
      type: SettingType.doubleValue,
      constraints: SettingConstraints.range(min: 0.5, max: 3.0, step: 0.1),
      synonyms: [
        'speed', 'playback speed', 'pace', 'rate',
        '速度', 'スピード', '再生速度', '速さ', '速く', '遅く',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.skipForwardSeconds,
      displayNameKey: 'settingsSkipForward',
      type: SettingType.intValue,
      constraints: SettingConstraints.range(min: 5, max: 60, step: 5),
      synonyms: [
        'skip forward', 'forward skip', 'jump ahead',
        'スキップ', '早送り', '先送り',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.skipBackwardSeconds,
      displayNameKey: 'settingsSkipBackward',
      type: SettingType.intValue,
      constraints: SettingConstraints.range(min: 5, max: 60, step: 5),
      synonyms: [
        'skip backward', 'backward skip', 'jump back', 'rewind',
        '巻き戻し', '戻し',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.autoCompleteThreshold,
      displayNameKey: 'settingsAutoComplete',
      type: SettingType.doubleValue,
      constraints: SettingConstraints.range(min: 0.8, max: 1.0, step: 0.01),
      synonyms: [
        'auto complete', 'completion threshold', 'mark as played',
        '自動完了', '再生完了',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.continuousPlayback,
      displayNameKey: 'settingsContinuousPlayback',
      type: SettingType.boolean,
      constraints: SettingConstraints.boolean(),
      synonyms: [
        'continuous playback', 'auto play next', 'continuous',
        '連続再生', '自動再生',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.autoPlayOrder,
      displayNameKey: 'settingsAutoPlayOrder',
      type: SettingType.enumValue,
      constraints: SettingConstraints.options(
        values: ['newestFirst', 'oldestFirst'],
      ),
      synonyms: [
        'play order', 'auto play order', 'episode order',
        '再生順', 'エピソード順', '新しい順', '古い順',
      ],
    ),
    // -- Downloads --
    SettingMetadata(
      key: SettingsKeys.wifiOnlyDownload,
      displayNameKey: 'settingsWifiOnlyDownload',
      type: SettingType.boolean,
      constraints: SettingConstraints.boolean(),
      synonyms: [
        'wifi only download', 'download wifi', 'wifi download',
        'Wi-Fiのみ', 'ダウンロード',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.autoDeletePlayed,
      displayNameKey: 'settingsAutoDelete',
      type: SettingType.boolean,
      constraints: SettingConstraints.boolean(),
      synonyms: [
        'auto delete', 'delete played', 'auto remove',
        '自動削除', '再生済み削除',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.maxConcurrentDownloads,
      displayNameKey: 'settingsMaxDownloads',
      type: SettingType.intValue,
      constraints: SettingConstraints.range(min: 1, max: 5, step: 1),
      synonyms: [
        'concurrent downloads', 'max downloads', 'parallel downloads',
        '同時ダウンロード', '並列ダウンロード',
      ],
    ),
    // -- Feed Sync --
    SettingMetadata(
      key: SettingsKeys.autoSync,
      displayNameKey: 'settingsAutoSync',
      type: SettingType.boolean,
      constraints: SettingConstraints.boolean(),
      synonyms: [
        'auto sync', 'automatic sync', 'background refresh',
        '自動同期', 'バックグラウンド更新',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.syncIntervalMinutes,
      displayNameKey: 'settingsSyncInterval',
      type: SettingType.intValue,
      constraints: SettingConstraints.range(min: 15, max: 1440, step: 15),
      synonyms: [
        'sync interval', 'refresh interval', 'update frequency',
        '同期間隔', '更新頻度',
      ],
    ),
    SettingMetadata(
      key: SettingsKeys.wifiOnlySync,
      displayNameKey: 'settingsWifiOnlySync',
      type: SettingType.boolean,
      constraints: SettingConstraints.boolean(),
      synonyms: [
        'wifi only sync', 'sync wifi',
        'Wi-Fiのみ同期',
      ],
    ),
    // -- Notifications --
    SettingMetadata(
      key: SettingsKeys.notifyNewEpisodes,
      displayNameKey: 'settingsNotifications',
      type: SettingType.boolean,
      constraints: SettingConstraints.boolean(),
      synonyms: [
        'notifications', 'new episode alerts', 'notify',
        '通知', '新着通知', 'アラート',
      ],
    ),
    // -- Search --
    SettingMetadata(
      key: SettingsKeys.searchCountry,
      displayNameKey: 'settingsSearchCountry',
      type: SettingType.enumValue,
      constraints: SettingConstraints.options(
        values: ['us', 'jp', 'gb', 'de', 'fr', 'au', 'ca'],
      ),
      synonyms: [
        'search country', 'search region', 'country',
        '検索地域', '国', 'リージョン',
      ],
    ),
    // -- Locale (nullable string, treated as enum of common locales) --
    SettingMetadata(
      key: SettingsKeys.locale,
      displayNameKey: 'settingsLocale',
      type: SettingType.enumValue,
      constraints: SettingConstraints.options(
        values: ['en', 'ja', 'system'],
      ),
      synonyms: [
        'language', 'locale', 'app language',
        '言語', 'アプリ言語',
      ],
    ),
  ];
}
```

- [ ] **Step 4: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/voice/services/settings_metadata_registry.dart';
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_metadata_registry_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/settings_metadata_registry.dart \
  packages/audiflow_domain/lib/audiflow_domain.dart \
  packages/audiflow_domain/test/features/voice/services/settings_metadata_registry_test.dart
git commit -m "feat(domain): add SettingsMetadataRegistry with all voice-controllable settings"
```

---

## Task 5: SettingsSnapshotService (`audiflow_domain`)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/voice/services/settings_snapshot_service.dart`
- Create: `packages/audiflow_domain/test/features/voice/services/settings_snapshot_service_test.dart`

**Important:** `AppSettingsRepository` uses Flutter enum types: `getThemeMode()` returns `ThemeMode`, `getAutoPlayOrder()` returns `AutoPlayOrder`. The snapshot service must convert these to strings via `.name`.

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/voice/services/settings_snapshot_service_test.dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Fake AppSettingsRepository that returns known defaults
// Uses correct return types: ThemeMode enum, AutoPlayOrder enum
class FakeAppSettingsRepository implements AppSettingsRepository {
  @override
  double getPlaybackSpeed() => 1.0;
  @override
  ThemeMode getThemeMode() => ThemeMode.system;
  @override
  bool getContinuousPlayback() => true;
  @override
  int getSkipForwardSeconds() => 30;
  @override
  int getSkipBackwardSeconds() => 10;
  @override
  double getAutoCompleteThreshold() => 0.95;
  @override
  AutoPlayOrder getAutoPlayOrder() => AutoPlayOrder.newestFirst;
  @override
  bool getWifiOnlyDownload() => false;
  @override
  bool getAutoDeletePlayed() => false;
  @override
  int getMaxConcurrentDownloads() => 3;
  @override
  bool getAutoSync() => true;
  @override
  int getSyncIntervalMinutes() => 60;
  @override
  bool getWifiOnlySync() => false;
  @override
  bool getNotifyNewEpisodes() => true;
  @override
  String? getSearchCountry() => 'us';
  @override
  String? getLocale() => null;
  @override
  double getTextScale() => 1.0;
  @override
  int getLastTabIndex() => 0;

  // Setters (not needed for snapshot tests)
  @override
  Future<void> setPlaybackSpeed(double v) async {}
  @override
  Future<void> setThemeMode(ThemeMode v) async {}
  @override
  Future<void> setContinuousPlayback(bool v) async {}
  @override
  Future<void> setSkipForwardSeconds(int v) async {}
  @override
  Future<void> setSkipBackwardSeconds(int v) async {}
  @override
  Future<void> setAutoCompleteThreshold(double v) async {}
  @override
  Future<void> setAutoPlayOrder(AutoPlayOrder v) async {}
  @override
  Future<void> setWifiOnlyDownload(bool v) async {}
  @override
  Future<void> setAutoDeletePlayed(bool v) async {}
  @override
  Future<void> setMaxConcurrentDownloads(int v) async {}
  @override
  Future<void> setAutoSync(bool v) async {}
  @override
  Future<void> setSyncIntervalMinutes(int v) async {}
  @override
  Future<void> setWifiOnlySync(bool v) async {}
  @override
  Future<void> setNotifyNewEpisodes(bool v) async {}
  @override
  Future<void> setSearchCountry(String? v) async {}
  @override
  Future<void> setLocale(String? v) async {}
  @override
  Future<void> setTextScale(double v) async {}
  @override
  Future<void> setLastTabIndex(int v) async {}
  @override
  Future<void> clearAll() async {}
}

void main() {
  group('SettingsSnapshotService', () {
    late SettingsSnapshotService service;

    setUp(() {
      service = SettingsSnapshotService(
        registry: SettingsMetadataRegistry(),
        settingsRepository: FakeAppSettingsRepository(),
      );
    });

    test('generates non-empty prompt text', () {
      final snapshot = service.buildPromptSnapshot();
      expect(snapshot, isNotEmpty);
    });

    test('includes playbackSpeed with current value', () {
      final snapshot = service.buildPromptSnapshot();
      expect(snapshot, contains('playbackSpeed'));
      expect(snapshot, contains('1.0'));
    });

    test('includes range constraints for numeric settings', () {
      final snapshot = service.buildPromptSnapshot();
      expect(snapshot, contains('range: 0.5-3.0'));
      expect(snapshot, contains('step: 0.1'));
    });

    test('includes options for enum settings', () {
      final snapshot = service.buildPromptSnapshot();
      expect(snapshot, contains('options: light, dark, system'));
    });

    test('includes boolean type indicator', () {
      final snapshot = service.buildPromptSnapshot();
      expect(snapshot, contains('(boolean)'));
    });

    test('includes synonyms', () {
      final snapshot = service.buildPromptSnapshot();
      expect(snapshot, contains('speed'));
      expect(snapshot, contains('速度'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_snapshot_service_test.dart`
Expected: FAIL - `SettingsSnapshotService` not found

- [ ] **Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/voice/services/settings_snapshot_service.dart
import '../../settings/repositories/app_settings_repository.dart';
import '../models/settings_metadata.dart';
import 'settings_metadata_registry.dart';

/// Builds a prompt-ready text snapshot of all settings with current values.
class SettingsSnapshotService {
  SettingsSnapshotService({
    required SettingsMetadataRegistry registry,
    required AppSettingsRepository settingsRepository,
  }) : _registry = registry,
       _settingsRepository = settingsRepository;

  final SettingsMetadataRegistry _registry;
  final AppSettingsRepository _settingsRepository;

  /// Builds a text snapshot of all settings for AI prompt injection.
  String buildPromptSnapshot() {
    final buffer = StringBuffer('Available settings:\n');

    for (final meta in _registry.allSettings) {
      final currentValue = _getCurrentValue(meta.key);
      final constraintDesc = _describeConstraints(meta);
      final synonymDesc = meta.synonyms.join(', ');

      buffer.writeln(
        '- ${meta.key}: $currentValue $constraintDesc '
        '[synonyms: $synonymDesc]',
      );
    }

    return buffer.toString();
  }

  /// Returns the current value of a setting as a string.
  ///
  /// Public so the orchestrator can build current-value maps for resolution.
  String getCurrentValue(String key) {
    return switch (key) {
      'settings_theme_mode' => _settingsRepository.getThemeMode().name,
      'settings_locale' => _settingsRepository.getLocale() ?? 'system',
      'settings_text_scale' => '${_settingsRepository.getTextScale()}',
      'settings_playback_speed' => '${_settingsRepository.getPlaybackSpeed()}',
      'settings_skip_forward_seconds' =>
        '${_settingsRepository.getSkipForwardSeconds()}',
      'settings_skip_backward_seconds' =>
        '${_settingsRepository.getSkipBackwardSeconds()}',
      'settings_auto_complete_threshold' =>
        '${_settingsRepository.getAutoCompleteThreshold()}',
      'settings_continuous_playback' =>
        '${_settingsRepository.getContinuousPlayback()}',
      'settings_auto_play_order' =>
        _settingsRepository.getAutoPlayOrder().name,
      'settings_wifi_only_download' =>
        '${_settingsRepository.getWifiOnlyDownload()}',
      'settings_auto_delete_played' =>
        '${_settingsRepository.getAutoDeletePlayed()}',
      'settings_max_concurrent_downloads' =>
        '${_settingsRepository.getMaxConcurrentDownloads()}',
      'settings_auto_sync' => '${_settingsRepository.getAutoSync()}',
      'settings_sync_interval_minutes' =>
        '${_settingsRepository.getSyncIntervalMinutes()}',
      'settings_wifi_only_sync' =>
        '${_settingsRepository.getWifiOnlySync()}',
      'settings_notify_new_episodes' =>
        '${_settingsRepository.getNotifyNewEpisodes()}',
      'settings_search_country' =>
        _settingsRepository.getSearchCountry() ?? 'us',
      _ => 'unknown',
    };
  }

  String _describeConstraints(SettingMetadata meta) {
    return switch (meta.constraints) {
      BooleanConstraints() => '(boolean)',
      RangeConstraints(:final min, :final max, :final step) =>
        '(range: $min-$max, step: $step)',
      OptionsConstraints(:final values) =>
        '(options: ${values.join(', ')})',
    };
  }
}
```

Note: The `_getCurrentValue` switch uses the actual `SettingsKeys` constant string values. Verify these match by checking `settings_keys.dart`.

- [ ] **Step 4: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/voice/services/settings_snapshot_service.dart';
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_snapshot_service_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/settings_snapshot_service.dart \
  packages/audiflow_domain/lib/audiflow_domain.dart \
  packages/audiflow_domain/test/features/voice/services/settings_snapshot_service_test.dart
git commit -m "feat(domain): add SettingsSnapshotService for AI prompt generation"
```

---

## Task 6: SettingsIntentResolver (`audiflow_domain`)

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/voice/services/settings_intent_resolver.dart`
- Create: `packages/audiflow_domain/test/features/voice/services/settings_intent_resolver_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// packages/audiflow_domain/test/features/voice/services/settings_intent_resolver_test.dart
import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsIntentResolver resolver;
  late SettingsMetadataRegistry registry;

  setUp(() {
    registry = SettingsMetadataRegistry();
    resolver = SettingsIntentResolver(registry: registry);
  });

  group('resolve absolute', () {
    test('high confidence absolute returns autoApply', () {
      const payload = SettingsChangePayload.absolute(
        key: 'settings_playback_speed',
        value: '1.5',
        confidence: 0.95,
      );

      final result = resolver.resolve(payload, currentValues: {
        'settings_playback_speed': '1.0',
      });

      expect(result, isA<SettingsResolutionAutoApply>());
      final autoApply = result as SettingsResolutionAutoApply;
      expect(autoApply.key, 'settings_playback_speed');
      expect(autoApply.newValue, '1.5');
      expect(autoApply.oldValue, '1.0');
    });

    test('low confidence absolute returns confirm', () {
      const payload = SettingsChangePayload.absolute(
        key: 'settings_playback_speed',
        value: '1.5',
        confidence: 0.6,
      );

      final result = resolver.resolve(payload, currentValues: {
        'settings_playback_speed': '1.0',
      });

      expect(result, isA<SettingsResolutionConfirm>());
    });

    test('unknown key returns notFound', () {
      const payload = SettingsChangePayload.absolute(
        key: 'nonexistent_key',
        value: '1.5',
        confidence: 0.95,
      );

      final result = resolver.resolve(payload, currentValues: {});

      expect(result, isA<SettingsResolutionNotFound>());
    });
  });

  group('resolve relative', () {
    test('small increase on playbackSpeed adds one step', () {
      const payload = SettingsChangePayload.relative(
        key: 'settings_playback_speed',
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.small,
        confidence: 0.9,
      );

      final result = resolver.resolve(payload, currentValues: {
        'settings_playback_speed': '1.0',
      });

      expect(result, isA<SettingsResolutionAutoApply>());
      final autoApply = result as SettingsResolutionAutoApply;
      expect(autoApply.newValue, '1.1');
    });

    test('large decrease on playbackSpeed subtracts three steps', () {
      const payload = SettingsChangePayload.relative(
        key: 'settings_playback_speed',
        direction: ChangeDirection.decrease,
        magnitude: ChangeMagnitude.large,
        confidence: 0.85,
      );

      final result = resolver.resolve(payload, currentValues: {
        'settings_playback_speed': '2.0',
      });

      expect(result, isA<SettingsResolutionAutoApply>());
      final autoApply = result as SettingsResolutionAutoApply;
      expect(autoApply.newValue, '1.7');
    });

    test('clamps to max when increase would exceed range', () {
      const payload = SettingsChangePayload.relative(
        key: 'settings_playback_speed',
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.large,
        confidence: 0.9,
      );

      final result = resolver.resolve(payload, currentValues: {
        'settings_playback_speed': '2.9',
      });

      expect(result, isA<SettingsResolutionAutoApply>());
      final autoApply = result as SettingsResolutionAutoApply;
      expect(autoApply.newValue, '3.0');
    });
  });

  group('resolve ambiguous', () {
    test('returns disambiguate with candidates', () {
      const payload = SettingsChangePayload.ambiguous(
        candidates: [
          SettingsCandidate(
            key: 'settings_theme_mode',
            value: 'dark',
            confidence: 0.6,
          ),
          SettingsCandidate(
            key: 'settings_text_scale',
            value: '0.8',
            confidence: 0.5,
          ),
        ],
      );

      final result = resolver.resolve(payload, currentValues: {
        'settings_theme_mode': 'system',
        'settings_text_scale': '1.0',
      });

      expect(result, isA<SettingsResolutionDisambiguate>());
      final disamb = result as SettingsResolutionDisambiguate;
      expect(disamb.candidates.length, 2);
    });

    test('filters candidates below 0.4 confidence', () {
      const payload = SettingsChangePayload.ambiguous(
        candidates: [
          SettingsCandidate(
            key: 'settings_theme_mode',
            value: 'dark',
            confidence: 0.7,
          ),
          SettingsCandidate(
            key: 'settings_text_scale',
            value: '0.8',
            confidence: 0.3,
          ),
        ],
      );

      final result = resolver.resolve(payload, currentValues: {
        'settings_theme_mode': 'system',
        'settings_text_scale': '1.0',
      });

      // Only one candidate remains after filtering -> single match path
      expect(result, isA<SettingsResolutionConfirm>());
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_intent_resolver_test.dart`
Expected: FAIL - `SettingsIntentResolver` not found

- [ ] **Step 3: Write minimal implementation**

```dart
// packages/audiflow_domain/lib/src/features/voice/services/settings_intent_resolver.dart
import 'dart:math' as math;

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/settings_metadata.dart';
import 'settings_metadata_registry.dart';

part 'settings_intent_resolver.freezed.dart';

/// Result of resolving a settings change intent.
@freezed
sealed class SettingsResolution with _$SettingsResolution {
  /// High confidence, single match -- auto-apply with undo.
  const factory SettingsResolution.autoApply({
    required String key,
    required String oldValue,
    required String newValue,
  }) = SettingsResolutionAutoApply;

  /// Low confidence, single match -- show confirmation.
  const factory SettingsResolution.confirm({
    required String key,
    required String oldValue,
    required String newValue,
    required double confidence,
  }) = SettingsResolutionConfirm;

  /// Multiple candidates -- show disambiguation UI.
  const factory SettingsResolution.disambiguate({
    required List<SettingsResolutionCandidate> candidates,
  }) = SettingsResolutionDisambiguate;

  /// No matching setting found.
  const factory SettingsResolution.notFound() = SettingsResolutionNotFound;
}

/// A candidate in a disambiguation result.
@freezed
class SettingsResolutionCandidate with _$SettingsResolutionCandidate {
  const factory SettingsResolutionCandidate({
    required String key,
    required String oldValue,
    required String newValue,
    required double confidence,
  }) = _SettingsResolutionCandidate;
}

/// Validates AI output against the registry and computes concrete values.
class SettingsIntentResolver {
  SettingsIntentResolver({required SettingsMetadataRegistry registry})
    : _registry = registry;

  final SettingsMetadataRegistry _registry;

  /// The registry used for validation.
  SettingsMetadataRegistry get registry => _registry;

  static const _autoApplyThreshold = 0.8;
  static const _discardThreshold = 0.4;

  /// Resolves a [SettingsChangePayload] into a [SettingsResolution].
  SettingsResolution resolve(
    SettingsChangePayload payload, {
    required Map<String, String> currentValues,
  }) {
    return switch (payload) {
      SettingsChangeAbsolute(:final key, :final value, :final confidence) =>
        _resolveAbsolute(key, value, confidence, currentValues),
      SettingsChangeRelative(
        :final key,
        :final direction,
        :final magnitude,
        :final confidence,
      ) =>
        _resolveRelative(key, direction, magnitude, confidence, currentValues),
      SettingsChangeAmbiguous(:final candidates) =>
        _resolveAmbiguous(candidates, currentValues),
    };
  }

  SettingsResolution _resolveAbsolute(
    String key,
    String value,
    double confidence,
    Map<String, String> currentValues,
  ) {
    final meta = _registry.findByKey(key);
    if (meta == null) return const SettingsResolution.notFound();

    final oldValue = currentValues[key] ?? 'unknown';

    if (_autoApplyThreshold <= confidence) {
      return SettingsResolution.autoApply(
        key: key,
        oldValue: oldValue,
        newValue: value,
      );
    }

    return SettingsResolution.confirm(
      key: key,
      oldValue: oldValue,
      newValue: value,
      confidence: confidence,
    );
  }

  SettingsResolution _resolveRelative(
    String key,
    ChangeDirection direction,
    ChangeMagnitude magnitude,
    double confidence,
    Map<String, String> currentValues,
  ) {
    final meta = _registry.findByKey(key);
    if (meta == null) return const SettingsResolution.notFound();

    final constraints = meta.constraints;
    if (constraints is! RangeConstraints) {
      return const SettingsResolution.notFound();
    }

    final currentStr = currentValues[key] ?? '0';
    final current = double.tryParse(currentStr) ?? 0;

    final multiplier = switch (magnitude) {
      ChangeMagnitude.small => 1.0,
      ChangeMagnitude.medium => 2.0,
      ChangeMagnitude.large => 3.0,
    };

    final delta = switch (direction) {
      ChangeDirection.increase => constraints.step * multiplier,
      ChangeDirection.decrease => -constraints.step * multiplier,
    };

    final raw = current + delta;
    final clamped = math.min(constraints.max, math.max(constraints.min, raw));

    // Round to avoid floating point drift
    final decimalPlaces = _decimalPlaces(constraints.step);
    final factor = math.pow(10, decimalPlaces);
    final rounded = (clamped * factor).round() / factor;

    final newValue = meta.type == SettingType.intValue
        ? '${rounded.toInt()}'
        : '$rounded';

    final oldValue = currentValues[key] ?? 'unknown';

    if (_autoApplyThreshold <= confidence) {
      return SettingsResolution.autoApply(
        key: key,
        oldValue: oldValue,
        newValue: newValue,
      );
    }

    return SettingsResolution.confirm(
      key: key,
      oldValue: oldValue,
      newValue: newValue,
      confidence: confidence,
    );
  }

  SettingsResolution _resolveAmbiguous(
    List<SettingsCandidate> candidates,
    Map<String, String> currentValues,
  ) {
    final filtered = candidates
        .where((c) => _discardThreshold <= c.confidence)
        .where((c) => _registry.findByKey(c.key) != null)
        .toList();

    if (filtered.isEmpty) return const SettingsResolution.notFound();

    if (filtered.length == 1) {
      final c = filtered.first;
      final oldValue = currentValues[c.key] ?? 'unknown';

      if (_autoApplyThreshold <= c.confidence) {
        return SettingsResolution.autoApply(
          key: c.key,
          oldValue: oldValue,
          newValue: c.value,
        );
      }

      return SettingsResolution.confirm(
        key: c.key,
        oldValue: oldValue,
        newValue: c.value,
        confidence: c.confidence,
      );
    }

    return SettingsResolution.disambiguate(
      candidates: filtered
          .map(
            (c) => SettingsResolutionCandidate(
              key: c.key,
              oldValue: currentValues[c.key] ?? 'unknown',
              newValue: c.value,
              confidence: c.confidence,
            ),
          )
          .toList(),
    );
  }

  int _decimalPlaces(double value) {
    final str = value.toString();
    final dotIndex = str.indexOf('.');
    if (0 <= dotIndex) return str.length - dotIndex - 1;
    return 0;
  }
}
```

- [ ] **Step 4: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Export from barrel**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart`:
```dart
export 'src/features/voice/services/settings_intent_resolver.dart';
```

- [ ] **Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_intent_resolver_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/settings_intent_resolver.dart \
  packages/audiflow_domain/lib/src/features/voice/services/settings_intent_resolver.freezed.dart \
  packages/audiflow_domain/lib/audiflow_domain.dart \
  packages/audiflow_domain/test/features/voice/services/settings_intent_resolver_test.dart
git commit -m "feat(domain): add SettingsIntentResolver with confidence-based resolution"
```

---

## Task 7: Extend VoiceCommandService prompt (`audiflow_ai`)

**Files:**
- Modify: `packages/audiflow_ai/lib/src/utils/prompt_templates.dart`
- Modify: `packages/audiflow_ai/lib/src/services/voice_command_service.dart`
- Modify: `packages/audiflow_ai/test/services/voice_command_service_test.dart`

- [ ] **Step 1: Write the failing test**

Add to `packages/audiflow_ai/test/services/voice_command_service_test.dart`:
```dart
group('settings command parsing', () {
  test('parses absolute settings response', () {
    // Test the response parser with a settings format response
    // The prompt template should support a {settingsSnapshot} variable
    final template = PromptTemplates.voiceCommand;
    expect(template, contains('{settingsSnapshot}'));
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_ai && flutter test test/services/voice_command_service_test.dart`
Expected: FAIL - template does not contain `{settingsSnapshot}`

- [ ] **Step 3: Extend the voice command prompt template**

In `packages/audiflow_ai/lib/src/utils/prompt_templates.dart`, modify `_defaultVoiceCommand` (line 80) to add settings intent and snapshot placeholder:

After the queue intents section (line 91), add:
```
- Settings: changeSettings (change a preference setting)
```

After the Japanese examples (line 112), add:
```

For "changeSettings" commands, also determine the specific setting to change.
Use the available settings list below to match the user's intent.

{settingsSnapshot}

For absolute changes, respond:
intent: changeSettings
settingsAction: absolute
settingsKey: <key_from_list>
settingsValue: <target_value>
confidence: <0.0-1.0>

For relative changes (e.g. "a bit faster", "もうちょっと速く"), respond:
intent: changeSettings
settingsAction: relative
settingsKey: <key_from_list>
settingsDirection: increase|decrease
settingsMagnitude: small|medium|large
confidence: <0.0-1.0>

If multiple settings could match (e.g. "暗くして" could mean dark theme or smaller text), respond:
intent: changeSettings
settingsAction: ambiguous
candidates: key1=value1:confidence1, key2=value2:confidence2
```

- [ ] **Step 4: Extend `_parseResponse` in VoiceCommandService to handle settings**

In `packages/audiflow_ai/lib/src/services/voice_command_service.dart`, modify `_parseResponse` to detect `changeSettings` intent and parse the settings-specific fields into a `SettingsChangePayload`:

```dart
if (intent == VoiceIntent.changeSettings) {
  final settingsPayload = _parseSettingsPayload(lines);
  return VoiceCommand(
    intent: intent,
    parameters: parameters,
    confidence: confidence,
    rawTranscription: transcription,
    settingsPayload: settingsPayload,
  );
}
```

Add `_parseSettingsPayload(List<String> lines)` method:

```dart
SettingsChangePayload? _parseSettingsPayload(List<String> lines) {
  final values = <String, String>{};
  for (final line in lines) {
    final colonIndex = line.indexOf(':');
    if (0 < colonIndex) {
      final key = line.substring(0, colonIndex).trim();
      final value = line.substring(colonIndex + 1).trim();
      values[key] = value;
    }
  }

  final action = values['settingsAction'] ?? '';
  final key = values['settingsKey'] ?? '';

  return switch (action) {
    'absolute' => SettingsChangePayload.absolute(
      key: key,
      value: values['settingsValue'] ?? '',
      confidence: _parseConfidence(values['confidence'] ?? '0'),
    ),
    'relative' => SettingsChangePayload.relative(
      key: key,
      direction: switch (values['settingsDirection']) {
        'decrease' => ChangeDirection.decrease,
        _ => ChangeDirection.increase,
      },
      magnitude: switch (values['settingsMagnitude']) {
        'medium' => ChangeMagnitude.medium,
        'large' => ChangeMagnitude.large,
        _ => ChangeMagnitude.small,
      },
      confidence: _parseConfidence(values['confidence'] ?? '0'),
    ),
    'ambiguous' => _parseAmbiguousCandidates(values['candidates'] ?? ''),
    _ => null,
  };
}

SettingsChangePayload _parseAmbiguousCandidates(String raw) {
  // Format: "key1=value1:confidence1, key2=value2:confidence2"
  final candidates = raw.split(',').map((entry) {
    final parts = entry.trim().split(':');
    final keyValue = (parts.firstOrNull ?? '').split('=');
    return SettingsCandidate(
      key: keyValue.firstOrNull?.trim() ?? '',
      value: keyValue.length < 2 ? '' : keyValue[1].trim(),
      confidence: double.tryParse(parts.length < 2 ? '0' : parts[1].trim()) ?? 0,
    );
  }).toList();
  return SettingsChangePayload.ambiguous(candidates: candidates);
}
```

- [ ] **Step 5: Add intent mapping**

In `_parseIntent`, add:
```dart
'changesettings' => VoiceIntent.changeSettings,
```

- [ ] **Step 6: Run tests**

Run: `cd packages/audiflow_ai && flutter test`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_ai/lib/src/utils/prompt_templates.dart \
  packages/audiflow_ai/lib/src/services/voice_command_service.dart \
  packages/audiflow_ai/test/services/voice_command_service_test.dart
git commit -m "feat(ai): extend voice command prompt and parser for settings changes"
```

---

## Task 8: Add new VoiceRecognitionState variants (`audiflow_domain`)

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/voice/models/voice_recognition_state.dart`
- Modify: `packages/audiflow_domain/test/features/voice/models/voice_recognition_state_test.dart`

- [ ] **Step 1: Write the failing test**

Add to the existing test file's `pattern matching` group:
```dart
test('exhaustive switch covers new settings states', () {
  const autoApplied = VoiceRecognitionState.settingsAutoApplied(
    key: 'playbackSpeed',
    displayNameKey: 'settingsPlaybackSpeed',
    oldValue: '1.0',
    newValue: '1.5',
  );
  const disamb = VoiceRecognitionState.settingsDisambiguation(
    candidates: [],
  );
  const lowConf = VoiceRecognitionState.settingsLowConfidence(
    key: 'playbackSpeed',
    displayNameKey: 'settingsPlaybackSpeed',
    oldValue: '1.0',
    newValue: '1.5',
    confidence: 0.6,
  );

  final states = <VoiceRecognitionState>[autoApplied, disamb, lowConf];

  final results = states.map((state) {
    return switch (state) {
      VoiceIdle() => 'idle',
      VoiceListening() => 'listening',
      VoiceProcessing() => 'processing',
      VoiceExecuting() => 'executing',
      VoiceSuccess() => 'success',
      VoiceError() => 'error',
      VoiceSettingsAutoApplied() => 'settingsAutoApplied',
      VoiceSettingsDisambiguation() => 'settingsDisambiguation',
      VoiceSettingsLowConfidence() => 'settingsLowConfidence',
    };
  }).toList();

  expect(results, [
    'settingsAutoApplied',
    'settingsDisambiguation',
    'settingsLowConfidence',
  ]);
});
```

Also update the existing `exhaustive switch covers all variants` test to include the new states.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/models/voice_recognition_state_test.dart`
Expected: FAIL - new state constructors not found

- [ ] **Step 3: Add new states to the sealed class**

In `packages/audiflow_domain/lib/src/features/voice/models/voice_recognition_state.dart`, add after `VoiceError` (line 40-43):

```dart
  /// Setting was auto-applied (high confidence). Shows undo option.
  const factory VoiceRecognitionState.settingsAutoApplied({
    required String key,
    required String displayNameKey,
    required String oldValue,
    required String newValue,
  }) = VoiceSettingsAutoApplied;

  /// Multiple settings candidates. Shows disambiguation UI.
  const factory VoiceRecognitionState.settingsDisambiguation({
    required List<SettingsResolutionCandidate> candidates,
  }) = VoiceSettingsDisambiguation;

  /// Low confidence settings match. Shows confirmation UI.
  const factory VoiceRecognitionState.settingsLowConfidence({
    required String key,
    required String displayNameKey,
    required String oldValue,
    required String newValue,
    required double confidence,
  }) = VoiceSettingsLowConfidence;
```

Import `SettingsResolutionCandidate` from the resolver.

- [ ] **Step 4: Run codegen**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Fix all exhaustive switches**

The compiler will flag every switch on `VoiceRecognitionState` that is now non-exhaustive. Add the new cases:

In `voice_command_orchestrator.dart` -- treat as no-op (these states are set by the settings handler, not transitioned by the orchestrator).

In `voice_listening_overlay.dart` -- will be handled in Task 11.

- [ ] **Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/models/voice_recognition_state_test.dart`
Expected: PASS

- [ ] **Step 7: Run full package tests**

Run: `cd packages/audiflow_domain && flutter test`
Expected: PASS (all existing tests updated for new states)

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/models/voice_recognition_state.dart \
  packages/audiflow_domain/lib/src/features/voice/models/voice_recognition_state.freezed.dart \
  packages/audiflow_domain/test/features/voice/models/voice_recognition_state_test.dart
git commit -m "feat(domain): add settings-specific VoiceRecognitionState variants"
```

---

## Task 9: Extend VoiceCommandExecutor for settings (`audiflow_domain`)

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/voice_command_executor.dart`

- [ ] **Step 1: Write the failing test**

Create: `packages/audiflow_domain/test/features/voice/services/voice_command_executor_test.dart`
```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

// Fakes for AudioPlayerController and QueueService
class FakeAudioPlayerController implements AudioPlayerController {
  double? lastSetSpeed;
  // ... stub all methods, track calls
  @override
  Future<void> setPlaybackSpeed(double speed) async {
    lastSetSpeed = speed;
  }
  // ... other stubs
}

class FakeQueueService implements QueueService {
  // ... stub all methods
}

class FakeAppSettingsRepository implements AppSettingsRepository {
  final Map<String, dynamic> _store = {};
  String? lastSetKey;
  dynamic lastSetValue;

  @override
  Future<void> setPlaybackSpeed(double v) async {
    lastSetKey = 'playbackSpeed';
    lastSetValue = v;
  }
  // ... other stubs returning defaults
}

void main() {
  group('VoiceCommandExecutor.applySetting', () {
    late VoiceCommandExecutor executor;
    late FakeAppSettingsRepository settingsRepo;
    late FakeAudioPlayerController audioController;

    setUp(() {
      settingsRepo = FakeAppSettingsRepository();
      audioController = FakeAudioPlayerController();
      executor = VoiceCommandExecutor(
        audioController: audioController,
        queueService: FakeQueueService(),
        settingsRepository: settingsRepo,
      );
    });

    test('applies playback speed to both repository and audio controller', () async {
      final result = await executor.applySetting(
        key: 'settings_playback_speed',
        value: '1.5',
      );
      expect(result.isSuccess, isTrue);
      expect(settingsRepo.lastSetKey, 'playbackSpeed');
      expect(audioController.lastSetSpeed, 1.5);
    });

    test('returns previous value for undo', () async {
      final result = await executor.applySetting(
        key: 'settings_playback_speed',
        value: '1.5',
      );
      expect(result.previousValue, isNotNull);
    });

    test('applies boolean setting', () async {
      final result = await executor.applySetting(
        key: 'settings_continuous_playback',
        value: 'false',
      );
      expect(result.isSuccess, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/voice_command_executor_test.dart`
Expected: FAIL - `applySetting` method not found

- [ ] **Step 3: Add `AppSettingsRepository` dependency and `applySetting` method**

In `packages/audiflow_domain/lib/src/features/voice/services/voice_command_executor.dart`:

Add `AppSettingsRepository` to constructor:
```dart
VoiceCommandExecutor({
  required AudioPlayerController audioController,
  required QueueService queueService,
  required AppSettingsRepository settingsRepository,
}) : _audioController = audioController,
     _queueService = queueService,
     _settingsRepository = settingsRepository;

final AppSettingsRepository _settingsRepository;
```

Update provider:
```dart
@riverpod
VoiceCommandExecutor voiceCommandExecutor(Ref ref) {
  return VoiceCommandExecutor(
    audioController: ref.watch(audioPlayerControllerProvider.notifier),
    queueService: ref.watch(queueServiceProvider),
    settingsRepository: ref.watch(appSettingsRepositoryProvider),
  );
}
```

Add result class and method:
```dart
class SettingApplyResult {
  const SettingApplyResult({
    required this.isSuccess,
    this.previousValue,
    this.errorMessage,
  });
  final bool isSuccess;
  final String? previousValue;
  final String? errorMessage;
}

/// Applies a setting change, coordinating repository persistence
/// with runtime effects (e.g. playback speed).
Future<SettingApplyResult> applySetting({
  required String key,
  required String value,
}) async {
  // ... implementation with switch on key
  // For playback-affecting settings, also call AudioPlayerController
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/voice_command_executor_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/voice_command_executor.dart \
  packages/audiflow_domain/lib/src/features/voice/services/voice_command_executor.g.dart \
  packages/audiflow_domain/test/features/voice/services/voice_command_executor_test.dart
git commit -m "feat(domain): extend VoiceCommandExecutor with settings apply and undo"
```

---

## Task 10: Wire `changeSettings` into VoiceCommandOrchestrator (`audiflow_domain`)

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart`

- [ ] **Step 1: Add dependencies**

Add `SettingsIntentResolver`, `SettingsSnapshotService`, and `SettingsMetadataRegistry` to the orchestrator's `build()` method:

```dart
late SettingsIntentResolver _settingsResolver;
late SettingsSnapshotService _settingsSnapshotService;
```

Initialize in `build()`:
```dart
final registry = SettingsMetadataRegistry();
_settingsResolver = SettingsIntentResolver(registry: registry);
_settingsSnapshotService = SettingsSnapshotService(
  registry: registry,
  settingsRepository: ref.watch(appSettingsRepositoryProvider),
);
```

- [ ] **Step 2: Inject settings snapshot into prompt**

In `startVoiceCommand()`, before calling `parseVoiceCommand()`, generate the settings snapshot and pass it to the prompt via `PromptTemplates.substituteVariables`:

```dart
final settingsSnapshot = _settingsSnapshotService.buildPromptSnapshot();
```

Pass this to `AudiflowAi.parseVoiceCommand()` (may require adding a `settingsSnapshot` parameter).

- [ ] **Step 3: Add `changeSettings` case to `_executeCommand`**

In `_executeCommand` switch (line 210), add before `VoiceIntent.unknown`:

```dart
case VoiceIntent.changeSettings:
  await _handleChangeSettings(command);
```

Add method:
```dart
Future<void> _handleChangeSettings(VoiceCommand command) async {
  final payload = command.settingsPayload;
  if (payload == null) {
    state = const VoiceRecognitionState.error(
      message: 'Could not parse settings change',
    );
    return;
  }

  final currentValues = <String, String>{};
  for (final meta in _settingsResolver.registry.allSettings) {
    currentValues[meta.key] = _settingsSnapshotService.getCurrentValue(meta.key);
  }

  final resolution = _settingsResolver.resolve(
    payload,
    currentValues: currentValues,
  );

  switch (resolution) {
    case SettingsResolutionAutoApply(:final key, :final oldValue, :final newValue):
      final result = await _executor.applySetting(key: key, value: newValue);
      if (result.isSuccess) {
        final meta = _settingsResolver.registry.findByKey(key);
        state = VoiceRecognitionState.settingsAutoApplied(
          key: key,
          displayNameKey: meta?.displayNameKey ?? key,
          oldValue: oldValue,
          newValue: newValue,
        );
        unawaited(_resetToIdleAfterDelay());
      } else {
        state = VoiceRecognitionState.error(
          message: result.errorMessage ?? 'Failed to apply setting',
        );
      }
    case SettingsResolutionConfirm(:final key, :final oldValue, :final newValue, :final confidence):
      final meta = _settingsResolver.registry.findByKey(key);
      state = VoiceRecognitionState.settingsLowConfidence(
        key: key,
        displayNameKey: meta?.displayNameKey ?? key,
        oldValue: oldValue,
        newValue: newValue,
        confidence: confidence,
      );
    case SettingsResolutionDisambiguate(:final candidates):
      state = VoiceRecognitionState.settingsDisambiguation(
        candidates: candidates,
      );
    case SettingsResolutionNotFound():
      state = const VoiceRecognitionState.error(
        message: 'Could not find matching setting',
      );
  }
}
```

- [ ] **Step 4: Add confirm/undo/selectCandidate methods**

```dart
/// Confirms a low-confidence settings change.
Future<void> confirmSettingsChange(String key, String value) async {
  final result = await _executor.applySetting(key: key, value: value);
  if (result.isSuccess) {
    final meta = _settingsResolver.registry.findByKey(key);
    state = VoiceRecognitionState.settingsAutoApplied(
      key: key,
      displayNameKey: meta?.displayNameKey ?? key,
      oldValue: result.previousValue ?? 'unknown',
      newValue: value,
    );
    _resetToIdleAfterDelay();
  }
}

/// Undoes the last auto-applied settings change.
Future<void> undoSettingsChange(String key, String previousValue) async {
  await _executor.applySetting(key: key, value: previousValue);
  state = const VoiceRecognitionState.idle();
}

/// Selects a candidate from disambiguation.
Future<void> selectSettingsCandidate(
  SettingsResolutionCandidate candidate,
) async {
  final result = await _executor.applySetting(
    key: candidate.key,
    value: candidate.newValue,
  );
  if (result.isSuccess) {
    final meta = _settingsResolver.registry.findByKey(candidate.key);
    state = VoiceRecognitionState.settingsAutoApplied(
      key: candidate.key,
      displayNameKey: meta?.displayNameKey ?? candidate.key,
      oldValue: candidate.oldValue,
      newValue: candidate.newValue,
    );
    _resetToIdleAfterDelay();
  }
}
```

- [ ] **Step 5: Run tests**

Run: `cd packages/audiflow_domain && flutter test`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart \
  packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.g.dart
git commit -m "feat(domain): wire changeSettings intent into voice orchestrator"
```

---

## Task 11: Update VoiceListeningOverlay for settings states (`audiflow_app`)

**Files:**
- Modify: `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_listening_overlay.dart`
- Modify: `packages/audiflow_app/lib/features/voice/presentation/controllers/voice_command_controller.dart`

- [ ] **Step 1: Add settings methods to VoiceCommandController**

```dart
/// Confirms a low-confidence settings change.
Future<void> confirmSettingsChange(String key, String value) async {
  final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
  await orchestrator.confirmSettingsChange(key, value);
}

/// Undoes the last auto-applied settings change.
Future<void> undoSettingsChange(String key, String previousValue) async {
  final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
  await orchestrator.undoSettingsChange(key, previousValue);
}

/// Selects a candidate from disambiguation.
Future<void> selectSettingsCandidate(
  SettingsResolutionCandidate candidate,
) async {
  final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);
  await orchestrator.selectSettingsCandidate(candidate);
}
```

- [ ] **Step 2: Add settings state rendering to overlay**

In `_buildStateIndicator` switch, add:
```dart
VoiceSettingsAutoApplied() => // Check icon with undo button
VoiceSettingsDisambiguation() => // List of candidate cards
VoiceSettingsLowConfidence() => // Question mark icon with confirm/cancel
```

In `_buildStatusText` switch, add localized messages for each state.

- [ ] **Step 3: Implement auto-applied state UI**

```dart
Widget _buildSettingsAutoApplied(
  VoiceSettingsAutoApplied state,
  VoiceCommandController controller,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Symbols.check_circle, color: colorScheme.tertiary, size: 48),
      const SizedBox(height: 16),
      Text(
        '${_resolveDisplayName(state.displayNameKey)}: '
        '${state.oldValue} -> ${state.newValue}',
        style: textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => controller.undoSettingsChange(
          state.key,
          state.oldValue,
        ),
        child: Text(l10n.undo),
      ),
    ],
  );
}
```

- [ ] **Step 4: Implement disambiguation state UI**

```dart
Widget _buildSettingsDisambiguation(
  VoiceSettingsDisambiguation state,
  VoiceCommandController controller,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        l10n.voiceSettingsWhichSetting,
        style: textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      const SizedBox(height: 16),
      ...state.candidates.map((candidate) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: FilledButton.tonal(
            onPressed: () => controller.selectSettingsCandidate(candidate),
            child: Text(
              '${_resolveDisplayName(candidate.key)}: ${candidate.newValue}',
            ),
          ),
        );
      }),
      const SizedBox(height: 8),
      TextButton(
        onPressed: controller.cancel,
        child: Text(l10n.cancel),
      ),
    ],
  );
}
```

- [ ] **Step 5: Implement low-confidence state UI**

```dart
Widget _buildSettingsLowConfidence(
  VoiceSettingsLowConfidence state,
  VoiceCommandController controller,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Symbols.help, color: colorScheme.tertiary, size: 48),
      const SizedBox(height: 16),
      Text(
        '${_resolveDisplayName(state.displayNameKey)}: '
        '${state.oldValue} -> ${state.newValue}?',
        style: textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: controller.cancel,
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: () => controller.confirmSettingsChange(
              state.key,
              state.newValue,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    ],
  );
}
```

- [ ] **Step 6: Add l10n strings**

In `packages/audiflow_app/lib/l10n/app_en.arb`:
```json
"voiceSettingsWhichSetting": "Which setting do you mean?",
"voiceSettingsChanged": "Setting changed"
```

In `packages/audiflow_app/lib/l10n/app_ja.arb`:
```json
"voiceSettingsWhichSetting": "どの設定を変更しますか？",
"voiceSettingsChanged": "設定を変更しました"
```

- [ ] **Step 7: Run analyze**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_app/lib/features/voice/presentation/widgets/voice_listening_overlay.dart \
  packages/audiflow_app/lib/features/voice/presentation/controllers/voice_command_controller.dart \
  packages/audiflow_app/lib/l10n/app_en.arb \
  packages/audiflow_app/lib/l10n/app_ja.arb
git commit -m "feat(app): add settings confirmation UI to voice overlay"
```

---

## Task 12: AI prompt quality tests

**Files:**
- Create: `packages/audiflow_domain/test/features/voice/services/settings_voice_commands_test.dart`

- [ ] **Step 1: Write fixture-based tests**

These tests verify the full pipeline from parsed AI output through resolution. They serve as regression tests when the prompt is tuned.

```dart
// packages/audiflow_domain/test/features/voice/services/settings_voice_commands_test.dart
import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsIntentResolver resolver;

  final defaultValues = {
    'settings_playback_speed': '1.0',
    'settings_theme_mode': 'system',
    'settings_continuous_playback': 'true',
    'settings_skip_forward_seconds': '30',
    'settings_text_scale': '1.0',
  };

  setUp(() {
    resolver = SettingsIntentResolver(
      registry: SettingsMetadataRegistry(),
    );
  });

  group('absolute commands', () {
    test('"1.5倍にして" -> playbackSpeed = 1.5', () {
      const payload = SettingsChangePayload.absolute(
        key: 'settings_playback_speed',
        value: '1.5',
        confidence: 0.95,
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionAutoApply>());
      expect((result as SettingsResolutionAutoApply).newValue, '1.5');
    });

    test('"ダークモードにして" -> themeMode = dark', () {
      const payload = SettingsChangePayload.absolute(
        key: 'settings_theme_mode',
        value: 'dark',
        confidence: 0.9,
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionAutoApply>());
      expect((result as SettingsResolutionAutoApply).newValue, 'dark');
    });

    test('"連続再生をオフにして" -> continuousPlayback = false', () {
      const payload = SettingsChangePayload.absolute(
        key: 'settings_continuous_playback',
        value: 'false',
        confidence: 0.85,
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionAutoApply>());
    });
  });

  group('relative commands', () {
    test('"もうちょっと速くして" -> playbackSpeed += 0.1', () {
      const payload = SettingsChangePayload.relative(
        key: 'settings_playback_speed',
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.small,
        confidence: 0.9,
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionAutoApply>());
      expect((result as SettingsResolutionAutoApply).newValue, '1.1');
    });

    test('"かなり遅くして" -> playbackSpeed -= 0.3', () {
      const payload = SettingsChangePayload.relative(
        key: 'settings_playback_speed',
        direction: ChangeDirection.decrease,
        magnitude: ChangeMagnitude.large,
        confidence: 0.85,
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionAutoApply>());
      expect((result as SettingsResolutionAutoApply).newValue, '0.7');
    });

    test('"文字を大きくして" -> textScale += 0.1', () {
      const payload = SettingsChangePayload.relative(
        key: 'settings_text_scale',
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.small,
        confidence: 0.85,
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionAutoApply>());
      expect((result as SettingsResolutionAutoApply).newValue, '1.1');
    });
  });

  group('ambiguous commands', () {
    test('"暗くして" -> theme dark vs text smaller', () {
      const payload = SettingsChangePayload.ambiguous(
        candidates: [
          SettingsCandidate(
            key: 'settings_theme_mode',
            value: 'dark',
            confidence: 0.6,
          ),
          SettingsCandidate(
            key: 'settings_text_scale',
            value: '0.8',
            confidence: 0.5,
          ),
        ],
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionDisambiguate>());
    });
  });

  group('edge cases', () {
    test('speed at max cannot increase further', () {
      const payload = SettingsChangePayload.relative(
        key: 'settings_playback_speed',
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.small,
        confidence: 0.9,
      );
      final result = resolver.resolve(payload, currentValues: {
        'settings_playback_speed': '3.0',
      });
      expect(result, isA<SettingsResolutionAutoApply>());
      expect((result as SettingsResolutionAutoApply).newValue, '3.0');
    });

    test('unknown key returns notFound', () {
      const payload = SettingsChangePayload.absolute(
        key: 'nonexistent',
        value: 'foo',
        confidence: 0.95,
      );
      final result = resolver.resolve(payload, currentValues: defaultValues);
      expect(result, isA<SettingsResolutionNotFound>());
    });
  });
}
```

- [ ] **Step 2: Run tests**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_voice_commands_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/test/features/voice/services/settings_voice_commands_test.dart
git commit -m "test(domain): add AI prompt quality regression tests for voice settings"
```

---

## Task 13: Widget tests for overlay states (`audiflow_app`)

**Files:**
- Create: `packages/audiflow_app/test/features/voice/presentation/widgets/voice_listening_overlay_settings_test.dart`

- [ ] **Step 1: Write widget tests**

```dart
// Test that each new overlay state renders correctly:
// - settingsAutoApplied: shows check icon, old->new value text, undo button
// - settingsDisambiguation: shows candidate cards, cancel button
// - settingsLowConfidence: shows help icon, confirm/cancel buttons
// Use ProviderScope overrides with fake orchestrator state.
```

- [ ] **Step 2: Run tests**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/voice_listening_overlay_settings_test.dart`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/test/features/voice/presentation/widgets/voice_listening_overlay_settings_test.dart
git commit -m "test(app): add widget tests for voice settings overlay states"
```

---

## Task 14: Timeout handling for settings AI call

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart`

- [ ] **Step 1: Add timeout to the AI call in `startVoiceCommand`**

In the orchestrator's processing phase where `AudiflowAi.parseVoiceCommand()` is called, wrap with a timeout:

```dart
final command = await AudiflowAi.instance
    .parseVoiceCommand(transcription, settingsSnapshot: settingsSnapshot)
    .timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('AI call timed out'),
    );
```

The existing error handling (`catch (e)`) will catch `TimeoutException` and transition to the error state.

- [ ] **Step 2: Run tests**

Run: `cd packages/audiflow_domain && flutter test`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart
git commit -m "feat(domain): add 5s timeout to voice command AI call"
```

---

## Task 15: Final validation and cleanup

- [ ] **Step 1: Run full test suite**

Run: `melos run test`
Expected: All tests pass

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`
Expected: Zero issues

- [ ] **Step 3: Run codegen (ensure nothing stale)**

Run: `melos run codegen`
Expected: No changes

- [ ] **Step 4: Commit any remaining generated files**

```bash
git status
# Add any remaining .g.dart or .freezed.dart files
git add -A '*.g.dart' '*.freezed.dart'
git commit -m "chore: regenerate build_runner outputs"
```
