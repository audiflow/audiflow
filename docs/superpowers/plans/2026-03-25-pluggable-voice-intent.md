# Pluggable Voice Intent Resolution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace on-device AI settings resolution with native platform NLU (Siri App Intents on iOS, App Actions on Android) behind a platform channel interface.

**Architecture:** Add `resolveSettingsIntent` platform channel method. iOS uses App Intents framework for NLU. Android uses a Kotlin-side keyword resolver. The Dart orchestrator calls the platform channel instead of on-device AI for settings commands. Simple parser continues to handle playback commands.

**Tech Stack:** Flutter, Swift (App Intents), Kotlin, Platform Channels, Riverpod

**Spec:** `docs/superpowers/specs/2026-03-25-pluggable-voice-intent-design.md`

---

## File Map

### New Files

| File | Package | Purpose |
|------|---------|---------|
| `packages/audiflow_ai/ios/Classes/Intents/SetSettingIntent.swift` | audiflow_ai (iOS) | App Intent for absolute setting changes |
| `packages/audiflow_ai/ios/Classes/Intents/AdjustSettingIntent.swift` | audiflow_ai (iOS) | App Intent for relative setting changes |
| `packages/audiflow_ai/ios/Classes/Intents/SettingsShortcutsProvider.swift` | audiflow_ai (iOS) | AppShortcutsProvider for Siri phrase registration |
| `packages/audiflow_ai/ios/Classes/Intents/SettingsIntentHandler.swift` | audiflow_ai (iOS) | Resolves transcription against settings schema |
| `packages/audiflow_ai/android/src/main/kotlin/com/audiflow/ai/SettingsIntentResolver.kt` | audiflow_ai (Android) | Kotlin-side keyword resolver for settings |

### Modified Files

| File | Change |
|------|--------|
| `packages/audiflow_ai/lib/src/channel/audiflow_ai_channel.dart` | Add `resolveSettingsIntent` method constant |
| `packages/audiflow_ai/lib/src/audiflow_ai.dart` | Add `resolveSettingsIntent` abstract + impl methods |
| `packages/audiflow_ai/ios/Classes/AudiflowAiPlugin.swift` | Add `resolveSettingsIntent` handler, delegate to SettingsIntentHandler |
| `packages/audiflow_ai/android/src/main/kotlin/com/audiflow/ai/AudiflowAiPlugin.kt` | Add `resolveSettingsIntent` handler, delegate to SettingsIntentResolver |
| `packages/audiflow_domain/lib/src/features/voice/services/settings_metadata_registry.dart` | Add `toJson()` method |
| `packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart` | Replace on-device AI with platform channel call |
| `packages/audiflow_ai/lib/src/utils/prompt_templates.dart` | Remove `{settingsSnapshot}` block from voice command prompt |
| `packages/audiflow_ai/lib/src/services/voice_command_service.dart` | Remove `_parseSettingsPayload` and settings response parsing |
| `packages/audiflow_domain/lib/src/features/voice/services/settings_intent_resolver.dart` | Remove `resolveFromTranscription` (replaced by platform NLU) |

---

## Task 1: Add `toJson()` to SettingsMetadataRegistry

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/settings_metadata_registry.dart`
- Create: `packages/audiflow_domain/test/features/voice/services/settings_metadata_registry_json_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/fake_app_settings_repository.dart';

void main() {
  group('SettingsMetadataRegistry.toJson', () {
    late SettingsMetadataRegistry registry;

    setUp(() {
      registry = SettingsMetadataRegistry();
    });

    test('produces valid JSON with settings array', () {
      final repo = FakeAppSettingsRepository();
      final json = registry.toJson(repo);
      check(json).containsKey('settings');
      check(json['settings']).isA<List>().isNotEmpty();
    });

    test('each entry has required fields', () {
      final repo = FakeAppSettingsRepository();
      final json = registry.toJson(repo);
      final settings = json['settings'] as List;
      final first = settings.first as Map<String, dynamic>;
      check(first).containsKey('key');
      check(first).containsKey('displayName');
      check(first).containsKey('type');
      check(first).containsKey('currentValue');
      check(first).containsKey('constraints');
      check(first).containsKey('synonyms');
    });

    test('range constraint includes min, max, step', () {
      final repo = FakeAppSettingsRepository();
      final json = registry.toJson(repo);
      final settings = json['settings'] as List<dynamic>;
      // Find playback speed (a range type)
      final speed = settings.cast<Map<String, dynamic>>().firstWhere(
        (s) => (s['key'] as String).contains('playback_speed'),
      );
      final constraints = speed['constraints'] as Map<String, dynamic>;
      check(constraints['type']).equals('range');
      check(constraints['min']).isA<num>();
      check(constraints['max']).isA<num>();
      check(constraints['step']).isA<num>();
    });

    test('options constraint includes values list', () {
      final repo = FakeAppSettingsRepository();
      final json = registry.toJson(repo);
      final settings = json['settings'] as List<dynamic>;
      // Find theme mode (an options type)
      final theme = settings.cast<Map<String, dynamic>>().firstWhere(
        (s) => (s['key'] as String).contains('theme_mode'),
      );
      final constraints = theme['constraints'] as Map<String, dynamic>;
      check(constraints['type']).equals('options');
      check(constraints['values']).isA<List>();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/settings_metadata_registry_json_test.dart`
Expected: FAIL - `toJson` not found

- [ ] **Step 3: Write implementation**

Add to `SettingsMetadataRegistry`:

```dart
import '../../settings/repositories/app_settings_repository.dart';
import '../services/settings_snapshot_service.dart';

/// Serializes the registry + current values to JSON for platform channel.
Map<String, dynamic> toJson(AppSettingsRepository settingsRepo) {
  final snapshotService = SettingsSnapshotService(
    registry: this,
    settingsRepository: settingsRepo,
  );

  return {
    'settings': allSettings.map((meta) {
      return {
        'key': meta.key,
        'displayName': meta.displayNameKey,
        'type': meta.type.name,
        'currentValue': snapshotService.getCurrentValue(meta.key),
        'constraints': _constraintsToJson(meta.constraints),
        'synonyms': meta.synonyms,
      };
    }).toList(),
  };
}

Map<String, dynamic> _constraintsToJson(SettingConstraints c) {
  return switch (c) {
    BooleanConstraints() => {'type': 'boolean'},
    RangeConstraints(:final min, :final max, :final step) => {
      'type': 'range',
      'min': min,
      'max': max,
      'step': step,
    },
    OptionsConstraints(:final values) => {
      'type': 'options',
      'values': values,
    },
  };
}
```

- [ ] **Step 4: Run test to verify it passes**

- [ ] **Step 5: Run analyze and commit**

```bash
flutter analyze
PRE_COMMIT_ALLOW_NO_CONFIG=1 git add -A && git commit -m "feat(domain): add toJson() to SettingsMetadataRegistry"
```

---

## Task 2: Add platform channel constants and Dart interface

**Files:**
- Modify: `packages/audiflow_ai/lib/src/channel/audiflow_ai_channel.dart`
- Modify: `packages/audiflow_ai/lib/src/audiflow_ai.dart`

- [ ] **Step 1: Add channel constant**

In `audiflow_ai_channel.dart`, add after line 20:
```dart
static const String resolveSettingsIntent = 'resolveSettingsIntent';
```

- [ ] **Step 2: Add abstract method to AudiflowAi**

In `audiflow_ai.dart`, add to the abstract class after `parseVoiceCommand`:
```dart
/// Resolve a voice transcription into a settings change using
/// platform-native NLU (Siri App Intents / Google App Actions).
///
/// [settingsSchemaJson] is the JSON-serialized settings metadata.
/// Returns a Map with action, key, value, direction, magnitude, confidence.
/// Returns null if the platform cannot resolve the intent.
Future<Map<String, dynamic>?> resolveSettingsIntent({
  required String transcription,
  required String settingsSchemaJson,
});
```

- [ ] **Step 3: Add implementation to AudiflowAiImpl**

```dart
@override
Future<Map<String, dynamic>?> resolveSettingsIntent({
  required String transcription,
  required String settingsSchemaJson,
}) async {
  try {
    final result = await AudiflowAiChannel.channel.invokeMapMethod<String, dynamic>(
      AudiflowAiChannel.resolveSettingsIntent,
      {
        'transcription': transcription,
        'settingsSchema': settingsSchemaJson,
      },
    );
    return result;
  } on PlatformException {
    return null;
  }
}
```

- [ ] **Step 4: Run analyze and commit**

```bash
flutter analyze
PRE_COMMIT_ALLOW_NO_CONFIG=1 git add -A && git commit -m "feat(ai): add resolveSettingsIntent to platform channel interface"
```

---

## Task 3: iOS App Intents - SettingsIntentHandler

**Files:**
- Create: `packages/audiflow_ai/ios/Classes/Intents/SettingsIntentHandler.swift`
- Modify: `packages/audiflow_ai/ios/Classes/AudiflowAiPlugin.swift`

- [ ] **Step 1: Create SettingsIntentHandler**

This Swift class receives a transcription + settings schema JSON, matches the transcription against setting synonyms, detects values/direction, and returns a structured result dictionary.

```swift
import Foundation

/// Resolves voice transcriptions into settings changes using the
/// settings schema and keyword matching + App Intents NLU.
@available(iOS 26.0, *)
class SettingsIntentHandler {

    struct ResolvedIntent {
        let action: String  // "absolute", "relative", "ambiguous", "not_found"
        let key: String?
        let value: String?
        let direction: String?  // "increase", "decrease"
        let magnitude: String?  // "small", "medium", "large"
        let candidates: [[String: Any]]?
        let confidence: Double

        func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [
                "action": action,
                "confidence": confidence,
            ]
            if let key { dict["key"] = key }
            if let value { dict["value"] = value }
            if let direction { dict["direction"] = direction }
            if let magnitude { dict["magnitude"] = magnitude }
            if let candidates { dict["candidates"] = candidates }
            return dict
        }
    }

    func resolve(transcription: String, schemaJson: String) -> ResolvedIntent {
        guard let data = schemaJson.data(using: .utf8),
              let schema = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let settings = schema["settings"] as? [[String: Any]] else {
            return ResolvedIntent(action: "not_found", key: nil, value: nil,
                                  direction: nil, magnitude: nil, candidates: nil,
                                  confidence: 0)
        }

        let text = transcription.lowercased()

        // Find settings whose synonyms match the transcription
        var matches: [(setting: [String: Any], matchLength: Int)] = []
        for setting in settings {
            guard let synonyms = setting["synonyms"] as? [String] else { continue }
            var bestLength = 0
            for synonym in synonyms {
                if text.contains(synonym.lowercased()) && synonym.count > bestLength {
                    bestLength = synonym.count
                }
            }
            if bestLength > 0 {
                matches.append((setting, bestLength))
            }
        }

        guard !matches.isEmpty else {
            return ResolvedIntent(action: "not_found", key: nil, value: nil,
                                  direction: nil, magnitude: nil, candidates: nil,
                                  confidence: 0)
        }

        // Sort by longest match (most specific)
        matches.sort { $0.matchLength > $1.matchLength }

        let bestMatch = matches[0].setting
        let key = bestMatch["key"] as? String

        // Detect target value for enum/options settings
        if let constraints = bestMatch["constraints"] as? [String: Any],
           let type = constraints["type"] as? String,
           type == "options",
           let values = constraints["values"] as? [String] {
            if let targetValue = detectTargetValue(text: text, options: values) {
                return ResolvedIntent(action: "absolute", key: key, value: targetValue,
                                      direction: nil, magnitude: nil, candidates: nil,
                                      confidence: 0.9)
            }
        }

        // Detect boolean intent
        if let constraints = bestMatch["constraints"] as? [String: Any],
           let type = constraints["type"] as? String,
           type == "boolean" {
            if let boolValue = detectBooleanIntent(text: text) {
                return ResolvedIntent(action: "absolute", key: key, value: boolValue,
                                      direction: nil, magnitude: nil, candidates: nil,
                                      confidence: 0.9)
            }
        }

        // Detect numeric value
        if let constraints = bestMatch["constraints"] as? [String: Any],
           let type = constraints["type"] as? String,
           type == "range" {
            if let numValue = detectNumericValue(text: text, constraints: constraints) {
                return ResolvedIntent(action: "absolute", key: key, value: numValue,
                                      direction: nil, magnitude: nil, candidates: nil,
                                      confidence: 0.9)
            }

            // Detect direction for relative change
            if let direction = detectDirection(text: text) {
                let magnitude = detectMagnitude(text: text)
                return ResolvedIntent(action: "relative", key: key, value: nil,
                                      direction: direction, magnitude: magnitude,
                                      candidates: nil, confidence: 0.85)
            }
        }

        // If multiple equally-good matches, disambiguate
        if matches.count > 1 && matches[0].matchLength == matches[1].matchLength {
            let candidateList: [[String: Any]] = matches.prefix(3).map { match in
                return [
                    "key": match.setting["key"] as? String ?? "",
                    "value": match.setting["currentValue"] as? String ?? "",
                    "confidence": 0.6,
                ]
            }
            return ResolvedIntent(action: "ambiguous", key: nil, value: nil,
                                  direction: nil, magnitude: nil, candidates: candidateList,
                                  confidence: 0.6)
        }

        return ResolvedIntent(action: "not_found", key: key, value: nil,
                              direction: nil, magnitude: nil, candidates: nil,
                              confidence: 0.3)
    }

    // MARK: - Value Detection

    private let optionAliases: [String: [String]] = [
        "dark": ["ダーク", "dark", "暗い", "暗く"],
        "light": ["ライト", "light", "明るい", "明るく"],
        "system": ["システム", "system", "自動", "auto"],
        "newestFirst": ["新しい順", "newest", "新着順"],
        "oldestFirst": ["古い順", "oldest"],
        "en": ["英語", "english"],
        "ja": ["日本語", "japanese"],
    ]

    private func detectTargetValue(text: String, options: [String]) -> String? {
        for option in options {
            if text.contains(option.lowercased()) { return option }
            if let aliases = optionAliases[option] {
                for alias in aliases {
                    if text.contains(alias.lowercased()) { return option }
                }
            }
        }
        return nil
    }

    private func detectBooleanIntent(text: String) -> String? {
        let onKeywords = ["オン", "on", "有効", "使う", "つけ", "enable"]
        let offKeywords = ["オフ", "off", "無効", "やめ", "消", "disable"]
        for kw in onKeywords { if text.contains(kw.lowercased()) { return "true" } }
        for kw in offKeywords { if text.contains(kw.lowercased()) { return "false" } }
        return nil
    }

    private func detectNumericValue(text: String, constraints: [String: Any]) -> String? {
        let pattern = try? NSRegularExpression(pattern: "(\\d+\\.?\\d*)")
        guard let match = pattern?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text),
              let value = Double(text[range]) else { return nil }

        let min = constraints["min"] as? Double ?? 0
        let max = constraints["max"] as? Double ?? 100
        let clamped = Swift.min(max, Swift.max(min, value))
        return String(clamped)
    }

    private func detectDirection(text: String) -> String? {
        let increase = ["大きく", "上げ", "速く", "早く", "増や", "高く", "アップ",
                         "increase", "up", "faster", "higher", "bigger", "more"]
        let decrease = ["小さく", "下げ", "遅く", "減ら", "低く", "ダウン",
                         "decrease", "down", "slower", "lower", "smaller", "less"]
        for kw in increase { if text.contains(kw) { return "increase" } }
        for kw in decrease { if text.contains(kw) { return "decrease" } }
        return nil
    }

    private func detectMagnitude(text: String) -> String {
        let large = ["かなり", "すごく", "めっちゃ", "大幅", "a lot", "much", "significantly"]
        let medium = ["少し", "ちょっと", "やや", "a bit", "slightly", "a little"]
        for kw in large { if text.contains(kw) { return "large" } }
        for kw in medium { if text.contains(kw) { return "small" } }
        return "small"  // default
    }
}
```

- [ ] **Step 2: Add handler to AudiflowAiPlugin.swift**

Add constant:
```swift
private static let methodResolveSettingsIntent = "resolveSettingsIntent"
```

Add to switch in `handle(_:result:)`:
```swift
case AudiflowAiPlugin.methodResolveSettingsIntent:
    handleResolveSettingsIntent(call: call, result: result)
```

Add handler method:
```swift
private func handleResolveSettingsIntent(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let transcription = args["transcription"] as? String,
          let schemaJson = args["settingsSchema"] as? String else {
        result(FlutterError(code: AudiflowAiPlugin.errorInvalidArgument,
                            message: "Missing transcription or settingsSchema",
                            details: nil))
        return
    }

    if #available(iOS 26.0, *) {
        let handler = SettingsIntentHandler()
        let resolved = handler.resolve(transcription: transcription, schemaJson: schemaJson)
        result(resolved.toDictionary())
    } else {
        result(nil)
    }
}
```

- [ ] **Step 3: Build and verify**

Run: `cd packages/audiflow_ai && flutter build ios --no-codesign 2>&1 | tail -5`

- [ ] **Step 4: Commit**

```bash
PRE_COMMIT_ALLOW_NO_CONFIG=1 git add -A && git commit -m "feat(ai-ios): add SettingsIntentHandler for platform NLU resolution"
```

---

## Task 4: iOS App Intents for Siri

**Files:**
- Create: `packages/audiflow_ai/ios/Classes/Intents/SetSettingIntent.swift`
- Create: `packages/audiflow_ai/ios/Classes/Intents/AdjustSettingIntent.swift`
- Create: `packages/audiflow_ai/ios/Classes/Intents/SettingsShortcutsProvider.swift`

- [ ] **Step 1: Create SetSettingIntent**

```swift
import AppIntents

@available(iOS 26.0, *)
struct SetSettingIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Setting"
    static var description = IntentDescription("Change an Audiflow setting to a specific value")

    @Parameter(title: "Setting Name")
    var settingName: String

    @Parameter(title: "Value")
    var value: String

    func perform() async throws -> some IntentResult {
        // For out-of-app Siri invocation, apply directly via UserDefaults
        // (SharedPreferences on Flutter side uses UserDefaults)
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: settingName)
        return .result()
    }
}
```

- [ ] **Step 2: Create AdjustSettingIntent**

```swift
import AppIntents

@available(iOS 26.0, *)
struct AdjustSettingIntent: AppIntent {
    static var title: LocalizedStringResource = "Adjust Setting"
    static var description = IntentDescription("Increase or decrease an Audiflow setting")

    @Parameter(title: "Setting Name")
    var settingName: String

    @Parameter(title: "Direction")
    var direction: String  // "increase" or "decrease"

    func perform() async throws -> some IntentResult {
        // Relative changes require current value + step info
        // For out-of-app, read current from UserDefaults and adjust
        return .result()
    }
}
```

- [ ] **Step 3: Create SettingsShortcutsProvider**

```swift
import AppIntents

@available(iOS 26.0, *)
struct SettingsShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SetSettingIntent(),
            phrases: [
                "\(.applicationName)の設定を変更",
                "\(.applicationName) change setting",
            ],
            shortTitle: "Change Setting",
            systemImageName: "gear"
        )
        AppShortcut(
            intent: AdjustSettingIntent(),
            phrases: [
                "\(.applicationName)の設定を調整",
                "\(.applicationName) adjust setting",
            ],
            shortTitle: "Adjust Setting",
            systemImageName: "slider.horizontal.3"
        )
    }
}
```

- [ ] **Step 4: Build and verify**

Run: `cd packages/audiflow_ai && flutter build ios --no-codesign 2>&1 | tail -5`

- [ ] **Step 5: Commit**

```bash
PRE_COMMIT_ALLOW_NO_CONFIG=1 git add -A && git commit -m "feat(ai-ios): add App Intents for Siri settings control"
```

---

## Task 5: Android Settings Intent Resolver

**Files:**
- Create: `packages/audiflow_ai/android/src/main/kotlin/com/audiflow/ai/SettingsIntentResolver.kt`
- Modify: `packages/audiflow_ai/android/src/main/kotlin/com/audiflow/ai/AudiflowAiPlugin.kt`

- [ ] **Step 1: Create SettingsIntentResolver.kt**

Kotlin-side keyword resolver that mirrors the iOS SettingsIntentHandler logic:
- Parse settings schema JSON
- Match transcription against synonyms
- Detect target values (enum options, boolean, numeric)
- Detect direction and magnitude for relative changes
- Return structured Map result

- [ ] **Step 2: Add handler to AudiflowAiPlugin.kt**

Add constant:
```kotlin
private const val METHOD_RESOLVE_SETTINGS_INTENT = "resolveSettingsIntent"
```

Add to `onMethodCall` when block:
```kotlin
METHOD_RESOLVE_SETTINGS_INTENT -> handleResolveSettingsIntent(call, result)
```

Add handler:
```kotlin
private fun handleResolveSettingsIntent(call: MethodCall, result: Result) {
    val transcription = call.argument<String>("transcription")
    val schemaJson = call.argument<String>("settingsSchema")
    if (transcription == null || schemaJson == null) {
        result.error("INVALID_ARGUMENT", "Missing transcription or settingsSchema", null)
        return
    }
    val resolver = SettingsIntentResolver()
    val resolved = resolver.resolve(transcription, schemaJson)
    result.success(resolved)
}
```

- [ ] **Step 3: Build and verify**

Run: `cd packages/audiflow_ai && flutter build apk --debug 2>&1 | tail -5`

- [ ] **Step 4: Commit**

```bash
PRE_COMMIT_ALLOW_NO_CONFIG=1 git add -A && git commit -m "feat(ai-android): add SettingsIntentResolver for platform NLU"
```

---

## Task 6: Wire orchestrator to platform channel

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart`

- [ ] **Step 1: Replace on-device AI call with platform channel**

In `_processTranscription`, after the simple parser miss block, replace the AI call with:

```dart
// Use platform-native NLU for settings resolution
final settingsRepo = ref.read(appSettingsRepositoryProvider);
final schemaJson = jsonEncode(
  _settingsResolver.registry.toJson(settingsRepo),
);

final result = await AudiflowAi.instance.resolveSettingsIntent(
  transcription: transcription,
  settingsSchemaJson: schemaJson,
);

if (result == null) {
  state = VoiceRecognitionState.error(
    message: 'Voice settings unavailable',
  );
  return;
}

final action = result['action'] as String? ?? 'not_found';
if (action == 'not_found') {
  // Try on-device AI for non-settings commands (e.g., play podcast by name)
  try {
    if (!AudiflowAi.instance.isInitialized) {
      await AudiflowAi.instance.initialize();
    }
    final command = await AudiflowAi.instance
        .parseVoiceCommand(transcription: transcription)
        .timeout(const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('AI call timed out'));
    await _executeCommand(command);
  } on AudiflowAiException {
    state = VoiceRecognitionState.error(
      message: 'Could not understand: "$transcription"',
    );
  }
  return;
}

// Build payload from platform result
final payload = _buildPayloadFromPlatformResult(result);
if (payload == null) {
  state = VoiceRecognitionState.error(
    message: 'Could not parse settings result',
  );
  return;
}

// Use existing SettingsIntentResolver for validation
final command = VoiceCommand(
  intent: VoiceIntent.changeSettings,
  parameters: const {},
  confidence: (result['confidence'] as num?)?.toDouble() ?? 0.8,
  rawTranscription: transcription,
  settingsPayload: payload,
);
await _executeCommand(command);
```

- [ ] **Step 2: Add `_buildPayloadFromPlatformResult` helper**

```dart
SettingsChangePayload? _buildPayloadFromPlatformResult(
  Map<String, dynamic> result,
) {
  final action = result['action'] as String?;
  final key = result['key'] as String?;

  return switch (action) {
    'absolute' => SettingsChangePayload.absolute(
      key: key ?? '',
      value: (result['value'] as String?) ?? '',
      confidence: (result['confidence'] as num?)?.toDouble() ?? 0.8,
    ),
    'relative' => SettingsChangePayload.relative(
      key: key ?? '',
      direction: (result['direction'] as String?) == 'decrease'
          ? ChangeDirection.decrease
          : ChangeDirection.increase,
      magnitude: switch (result['magnitude'] as String?) {
        'medium' => ChangeMagnitude.medium,
        'large' => ChangeMagnitude.large,
        _ => ChangeMagnitude.small,
      },
      confidence: (result['confidence'] as num?)?.toDouble() ?? 0.8,
    ),
    'ambiguous' => SettingsChangePayload.ambiguous(
      candidates: ((result['candidates'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(
            (c) => SettingsCandidate(
              key: c['key'] as String? ?? '',
              value: c['value'] as String? ?? '',
              confidence: (c['confidence'] as num?)?.toDouble() ?? 0.5,
            ),
          )
          .toList(),
    ),
    _ => null,
  };
}
```

- [ ] **Step 3: Add `dart:convert` import**

- [ ] **Step 4: Run analyze and tests**

```bash
flutter analyze
flutter test packages/audiflow_domain/test/
```

- [ ] **Step 5: Commit**

```bash
PRE_COMMIT_ALLOW_NO_CONFIG=1 git add -A && git commit -m "feat(voice): wire orchestrator to platform channel for settings NLU"
```

---

## Task 7: Clean up old on-device AI settings code

**Files:**
- Modify: `packages/audiflow_ai/lib/src/utils/prompt_templates.dart`
- Modify: `packages/audiflow_ai/lib/src/services/voice_command_service.dart`
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/settings_intent_resolver.dart`
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart`

- [ ] **Step 1: Remove `{settingsSnapshot}` block from prompt template**

In `prompt_templates.dart`, remove the settings response format block that was added after the voice command examples. Keep the base voice command prompt for non-settings parsing (play, pause, search etc.).

- [ ] **Step 2: Remove `_parseSettingsPayload` from VoiceCommandService**

Remove the `_parseSettingsPayload` and `_parseAmbiguousCandidates` methods.
Remove the `changeSettings` branch in `_parseResponse` that calls `_parseSettingsPayload`.

- [ ] **Step 3: Remove `resolveFromTranscription` from SettingsIntentResolver**

Remove `resolveFromTranscription`, `_detectTargetValue`, `_detectNumericValue`, `_detectBooleanIntent`, `_detectDirection` methods. These are now handled by the platform-native code.

- [ ] **Step 4: Remove `_payloadFromParameters` from orchestrator**

Remove the `_payloadFromParameters` helper method.

- [ ] **Step 5: Run all tests, fix any broken ones**

```bash
flutter test packages/audiflow_ai/test/
flutter test packages/audiflow_domain/test/
```

Update tests that referenced removed methods.

- [ ] **Step 6: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 7: Commit**

```bash
PRE_COMMIT_ALLOW_NO_CONFIG=1 git add -A && git commit -m "refactor(voice): remove on-device AI settings resolution code"
```

---

## Task 8: Final validation

- [ ] **Step 1: Run full test suite**

```bash
flutter test packages/audiflow_ai/test/
flutter test packages/audiflow_domain/test/
flutter test packages/audiflow_core/test/
```

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze
```

- [ ] **Step 3: Verify iOS builds**

```bash
cd packages/audiflow_ai && flutter build ios --no-codesign
```

- [ ] **Step 4: Commit any remaining fixes**
