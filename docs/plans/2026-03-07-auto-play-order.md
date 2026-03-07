# Auto-Play Order Preference Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add an "Auto-Play Order" preference under Playback settings that controls whether auto-queued episodes from a podcast list play in chronological order (oldest first) or follow the current screen display order.

**Architecture:** New `AutoPlayOrder` enum in `audiflow_core`, persisted via SharedPreferences through the existing `AppSettingsRepository` pattern. UI uses a `ListTile` + `DropdownButton` in `PlaybackSettingsScreen`, consistent with the playback speed tile.

**Tech Stack:** Dart enum, SharedPreferences, Riverpod, Flutter l10n (ARB)

---

### Task 1: Add `AutoPlayOrder` enum to `audiflow_core`

**Files:**
- Create: `packages/audiflow_core/lib/src/models/auto_play_order.dart`
- Modify: `packages/audiflow_core/lib/audiflow_core.dart`

**Step 1: Write the failing test**

Create `packages/audiflow_core/test/models/auto_play_order_test.dart`:

```dart
import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutoPlayOrder', () {
    test('has exactly two values', () {
      expect(AutoPlayOrder.values.length, equals(2));
    });

    test('oldestFirst is the first value', () {
      expect(AutoPlayOrder.values.first, AutoPlayOrder.oldestFirst);
    });

    test('asDisplayed is the second value', () {
      expect(AutoPlayOrder.values.last, AutoPlayOrder.asDisplayed);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_core/test/models/auto_play_order_test.dart`
Expected: FAIL - `AutoPlayOrder` not found

**Step 3: Write minimal implementation**

Create `packages/audiflow_core/lib/src/models/auto_play_order.dart`:

```dart
/// Controls the order in which episodes are auto-queued
/// when playing from a podcast's episode list.
enum AutoPlayOrder {
  /// Chronological order, oldest episode first.
  oldestFirst,

  /// Follow the current display order on screen.
  asDisplayed,
}
```

Add export to `packages/audiflow_core/lib/audiflow_core.dart`:

```dart
export 'src/models/auto_play_order.dart';
```

**Step 4: Run test to verify it passes**

Run: `flutter test packages/audiflow_core/test/models/auto_play_order_test.dart`
Expected: PASS

**Step 5: Commit**

```
feat(core): add AutoPlayOrder enum
```

---

### Task 2: Add `SettingsKeys` and `SettingsDefaults` entries

**Files:**
- Modify: `packages/audiflow_core/lib/src/constants/settings_keys.dart`
- Modify: `packages/audiflow_core/test/constants/settings_keys_test.dart`

**Step 1: Write the failing tests**

Add to the `Playback keys` group in `settings_keys_test.dart`:

```dart
test('autoPlayOrder has correct value', () {
  expect(
    SettingsKeys.autoPlayOrder,
    equals('settings_auto_play_order'),
  );
});
```

Update the uniqueness test: change `expect(keys.length, equals(14))` to `expect(keys.length, equals(15))` and add `SettingsKeys.autoPlayOrder` to the set.

Add to the `SettingsDefaults` group:

```dart
test('autoPlayOrder defaults to oldestFirst', () {
  expect(
    SettingsDefaults.autoPlayOrder,
    AutoPlayOrder.oldestFirst,
  );
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_core/test/constants/settings_keys_test.dart`
Expected: FAIL - `autoPlayOrder` not found

**Step 3: Write minimal implementation**

In `packages/audiflow_core/lib/src/constants/settings_keys.dart`:

Add after `continuousPlayback` in `SettingsKeys`:

```dart
/// Auto-play order when queuing from a podcast's episode list.
static const String autoPlayOrder = 'settings_auto_play_order';
```

Add after `continuousPlayback` in `SettingsDefaults`:

```dart
/// Default auto-play order (chronological, oldest first).
static const AutoPlayOrder autoPlayOrder = AutoPlayOrder.oldestFirst;
```

Add import at top of file:

```dart
import '../models/auto_play_order.dart';
```

**Step 4: Run test to verify it passes**

Run: `flutter test packages/audiflow_core/test/constants/settings_keys_test.dart`
Expected: PASS

**Step 5: Commit**

```
feat(core): add autoPlayOrder settings key and default
```

---

### Task 3: Add getter/setter to `AppSettingsRepository` and implementation

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart`
- Modify: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart`
- Modify: `packages/audiflow_domain/test/features/settings/repositories/app_settings_repository_impl_test.dart`

**Step 1: Write the failing tests**

Add to `app_settings_repository_impl_test.dart`, after the `ContinuousPlayback` group:

```dart
group('AutoPlayOrder', () {
  test('returns default when no value stored', () {
    expect(
      repository.getAutoPlayOrder(),
      SettingsDefaults.autoPlayOrder,
    );
  });

  test('persists and reads oldestFirst', () async {
    await repository.setAutoPlayOrder(AutoPlayOrder.oldestFirst);
    expect(repository.getAutoPlayOrder(), AutoPlayOrder.oldestFirst);
  });

  test('persists and reads asDisplayed', () async {
    await repository.setAutoPlayOrder(AutoPlayOrder.asDisplayed);
    expect(repository.getAutoPlayOrder(), AutoPlayOrder.asDisplayed);
  });

  test('returns default for unknown stored value', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SettingsKeys.autoPlayOrder, 'unknown');
    expect(repository.getAutoPlayOrder(), SettingsDefaults.autoPlayOrder);
  });
});
```

Add import at top:

```dart
import 'package:audiflow_core/src/models/auto_play_order.dart';
```

**Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_domain/test/features/settings/repositories/app_settings_repository_impl_test.dart`
Expected: FAIL - `getAutoPlayOrder` not found

**Step 3: Write minimal implementation**

In `app_settings_repository.dart`, add after `setContinuousPlayback`:

```dart
// -- Playback (continued) --

/// Auto-play order when queuing from a podcast's episode list.
AutoPlayOrder getAutoPlayOrder();

/// Persists the auto-play order preference.
Future<void> setAutoPlayOrder(AutoPlayOrder order);
```

Add import: `import 'package:audiflow_core/audiflow_core.dart';` (if not already present - check the file; it already imports `audiflow_core` so `AutoPlayOrder` will be available).

In `app_settings_repository_impl.dart`, add after `setContinuousPlayback`:

```dart
@override
AutoPlayOrder getAutoPlayOrder() {
  final name = _ds.getString(SettingsKeys.autoPlayOrder);
  return _parseAutoPlayOrder(name);
}

@override
Future<void> setAutoPlayOrder(AutoPlayOrder order) async {
  await _ds.setString(SettingsKeys.autoPlayOrder, order.name);
}
```

Add helper method in the `-- Helpers --` section:

```dart
AutoPlayOrder _parseAutoPlayOrder(String? name) {
  return switch (name) {
    'oldestFirst' => AutoPlayOrder.oldestFirst,
    'asDisplayed' => AutoPlayOrder.asDisplayed,
    _ => SettingsDefaults.autoPlayOrder,
  };
}
```

Add `SettingsKeys.autoPlayOrder` to the `clearAll()` method's `Future.wait` list.

**Step 4: Run test to verify it passes**

Run: `flutter test packages/audiflow_domain/test/features/settings/repositories/app_settings_repository_impl_test.dart`
Expected: PASS

**Step 5: Commit**

```
feat(domain): add autoPlayOrder to AppSettingsRepository
```

---

### Task 4: Add l10n strings

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

**Step 1: Add English strings**

In `app_en.arb`, add after `playbackContinuousSubtitle` entry:

```json
"playbackAutoPlayOrderTitle": "Auto-Play Order",
"@playbackAutoPlayOrderTitle": { "description": "Auto-play order setting title" },
"playbackAutoPlayOrderSubtitle": "Episode order when auto-queuing from a podcast list",
"@playbackAutoPlayOrderSubtitle": { "description": "Auto-play order setting subtitle" },
"playbackAutoPlayOrderOldestFirst": "Oldest First",
"@playbackAutoPlayOrderOldestFirst": { "description": "Auto-play order: chronological" },
"playbackAutoPlayOrderAsDisplayed": "As Displayed",
"@playbackAutoPlayOrderAsDisplayed": { "description": "Auto-play order: screen order" },
```

**Step 2: Add Japanese strings**

In `app_ja.arb`, add after `playbackContinuousSubtitle` entry:

```json
"playbackAutoPlayOrderTitle": "自動再生の順序",
"playbackAutoPlayOrderSubtitle": "エピソードリストからの自動キュー追加時の順序",
"playbackAutoPlayOrderOldestFirst": "配信順",
"playbackAutoPlayOrderAsDisplayed": "表示順",
```

**Step 3: Generate l10n**

Run: `flutter gen-l10n` (from `packages/audiflow_app/`)

**Step 4: Verify generation succeeded**

Run: `flutter analyze packages/audiflow_app/lib/l10n/`
Expected: No errors

**Step 5: Commit**

```
feat(l10n): add auto-play order labels (en, ja)
```

---

### Task 5: Add UI tile to `PlaybackSettingsScreen`

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/playback_settings_screen.dart`

**Step 1: Add the tile**

In `PlaybackSettingsScreen.build()`, add after the `SwitchListTile` for continuous playback (line 49), inside the `children` list:

```dart
_AutoPlayOrderTile(
  order: repo.getAutoPlayOrder(),
  onChanged: (v) =>
      _update(ref, () => repo.setAutoPlayOrder(v)),
),
```

**Step 2: Create the private widget class**

Add at the end of the file, before the closing:

```dart
class _AutoPlayOrderTile extends StatelessWidget {
  const _AutoPlayOrderTile({
    required this.order,
    required this.onChanged,
  });

  final AutoPlayOrder order;
  final ValueChanged<AutoPlayOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(l10n.playbackAutoPlayOrderTitle),
      subtitle: Text(l10n.playbackAutoPlayOrderSubtitle),
      trailing: DropdownButton<AutoPlayOrder>(
        value: order,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        items: [
          DropdownMenuItem(
            value: AutoPlayOrder.oldestFirst,
            child: Text(l10n.playbackAutoPlayOrderOldestFirst),
          ),
          DropdownMenuItem(
            value: AutoPlayOrder.asDisplayed,
            child: Text(l10n.playbackAutoPlayOrderAsDisplayed),
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Verify build**

Run: `flutter analyze packages/audiflow_app/`
Expected: No errors

**Step 4: Commit**

```
feat(app): add auto-play order tile to playback settings
```

---

### Task 6: Run full test suite and format

**Step 1: Format**

Run: `dart format .`

**Step 2: Analyze**

Run: `flutter analyze`
Expected: No errors

**Step 3: Run tests**

Run: `flutter test packages/audiflow_core && flutter test packages/audiflow_domain`
Expected: All pass

**Step 4: Final commit (if formatting changed anything)**

```
chore: format
```
