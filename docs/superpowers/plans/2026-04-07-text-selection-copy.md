# Text Selection & Copy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable users to select and copy text across the app using context-appropriate patterns (native selection for prose/titles, one-tap copy for metadata).

**Architecture:** Three widget patterns — `SelectionArea` for HTML prose, `SelectableText` for standalone titles/segments, and a new `CopyableText` widget for metadata one-tap copy. Changes span `audiflow_ui` (new widget) and `audiflow_app` (four screens).

**Tech Stack:** Flutter built-in (`SelectionArea`, `SelectableText`, `Clipboard`), `flutter_html`, `package:checks` for tests.

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `packages/audiflow_ui/lib/src/widgets/text/copyable_text.dart` | One-tap copy widget with icon + snackbar |
| Create | `packages/audiflow_ui/test/widgets/text/copyable_text_test.dart` | Widget tests for CopyableText |
| Modify | `packages/audiflow_ui/lib/audiflow_ui.dart` | Export new widget |
| Modify | `packages/audiflow_app/lib/l10n/app_en.arb` | Add `commonCopiedToClipboard` key |
| Modify | `packages/audiflow_app/lib/l10n/app_ja.arb` | Add Japanese translation |
| Modify | `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart` | SelectableText for title, Text for podcast name (tappable link), SelectionArea for description, CopyableText for metadata/stats |
| Modify | `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/podcast_detail_header.dart` | SelectionArea + Text for podcast title, artist, genres |
| Modify | `packages/audiflow_app/lib/features/player/presentation/widgets/transcript_timeline_view.dart` | SelectionArea + Text for segment body, chapter title, speaker name |
| Modify | `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart` | SelectionArea + Text for episode/podcast titles |
| Modify | `packages/audiflow_app/test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart` | Add tests for selectable/copyable elements |
| Modify | `packages/audiflow_app/test/features/podcast_detail/presentation/widgets/podcast_detail_header_test.dart` | Add tests for selectable elements |

---

### Task 1: Add localization keys

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb:755-757`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb:405-406`

- [ ] **Step 1: Add English l10n key**

In `app_en.arb`, before the closing `}`, add:

```json
  "commonCopiedToClipboard": "Copied to clipboard",
  "@commonCopiedToClipboard": { "description": "Snackbar shown after copying text to clipboard" }
```

- [ ] **Step 2: Add Japanese l10n key**

In `app_ja.arb`, before the closing `}`, add:

```json
  "commonCopiedToClipboard": "クリップボードにコピーしました"
```

- [ ] **Step 3: Run l10n generation**

Run: `cd packages/audiflow_app && flutter gen-l10n`
Expected: Generated files updated, no errors.

- [ ] **Step 4: Verify the key is accessible**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: Zero issues.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/l10n/app_en.arb packages/audiflow_app/lib/l10n/app_ja.arb packages/audiflow_app/lib/l10n/
git commit -m "feat(l10n): add copied-to-clipboard localization key"
```

---

### Task 2: Create CopyableText widget

**Files:**
- Create: `packages/audiflow_ui/lib/src/widgets/text/copyable_text.dart`
- Create: `packages/audiflow_ui/test/widgets/text/copyable_text_test.dart`
- Modify: `packages/audiflow_ui/lib/audiflow_ui.dart:49`

- [ ] **Step 1: Write failing tests for CopyableText**

Create `packages/audiflow_ui/test/widgets/text/copyable_text_test.dart`:

```dart
import 'package:audiflow_ui/src/widgets/text/copyable_text.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CopyableText', () {
    testWidgets('renders text value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CopyableText(text: '42')),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(text: '42', label: 'Episode'),
          ),
        ),
      );

      expect(find.text('Episode'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('renders copy icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CopyableText(text: '42')),
        ),
      );

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('copies text to clipboard on tap', (tester) async {
      String? clipboardData;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            final args = call.arguments as Map<String, dynamic>;
            clipboardData = args['text'] as String;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CopyableText(text: 'test-value')),
        ),
      );

      await tester.tap(find.byType(CopyableText));
      await tester.pump();

      check(clipboardData).equals('test-value');
    });

    testWidgets('shows snackbar after copy', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async => null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CopyableText(text: 'value')),
        ),
      );

      await tester.tap(find.byType(CopyableText));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('copies only text, not label', (tester) async {
      String? clipboardData;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            final args = call.arguments as Map<String, dynamic>;
            clipboardData = args['text'] as String;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(text: '42', label: 'Episode'),
          ),
        ),
      );

      await tester.tap(find.byType(CopyableText));
      await tester.pump();

      check(clipboardData).equals('42');
    });

    testWidgets('applies custom text style', (tester) async {
      const style = TextStyle(fontSize: 20, color: Colors.red);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CopyableText(text: '42', style: style),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('42'),
      );
      check(textWidget.style?.fontSize).equals(20.0);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd packages/audiflow_ui && flutter test test/widgets/text/copyable_text_test.dart`
Expected: FAIL — `copyable_text.dart` does not exist.

- [ ] **Step 3: Implement CopyableText widget**

Create `packages/audiflow_ui/lib/src/widgets/text/copyable_text.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text widget that copies its value to the clipboard on tap.
///
/// Displays [text] with an optional [label] prefix and a small copy icon.
/// Tapping copies [text] (not the label) to the clipboard and shows a
/// [SnackBar] confirmation.
class CopyableText extends StatelessWidget {
  const CopyableText({
    required this.text,
    required this.snackBarMessage,
    this.label,
    this.style,
    this.labelStyle,
    super.key,
  });

  /// The value to display and copy to clipboard.
  final String text;

  /// Optional leading label (not copied).
  final String? label;

  /// Style for the value text.
  final TextStyle? style;

  /// Style for the label text. Defaults to a dimmed variant of [style].
  final TextStyle? labelStyle;

  /// Localized snackbar message shown after copying.
  final String snackBarMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = style ?? theme.textTheme.bodySmall;
    final effectiveLabelStyle = labelStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => _copyToClipboard(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(label!, style: effectiveLabelStyle),
              const SizedBox(width: 4),
            ],
            Flexible(child: Text(text, style: effectiveStyle)),
            const SizedBox(width: 4),
            Icon(
              Icons.copy_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarMessage),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/audiflow_ui && flutter test test/widgets/text/copyable_text_test.dart`
Expected: All 7 tests PASS.

- [ ] **Step 5: Export the widget**

In `packages/audiflow_ui/lib/audiflow_ui.dart`, add after the Search exports (line 44):

```dart
// Widgets - Text
export 'src/widgets/text/copyable_text.dart';
```

- [ ] **Step 6: Run analyze**

Run: `cd packages/audiflow_ui && flutter analyze`
Expected: Zero issues.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_ui/lib/src/widgets/text/copyable_text.dart packages/audiflow_ui/test/widgets/text/copyable_text_test.dart packages/audiflow_ui/lib/audiflow_ui.dart
git commit -m "feat(ui): add CopyableText widget for one-tap clipboard copy"
```

---

### Task 3: Episode detail screen — selectable title and podcast name

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart:226-244`
- Modify: `packages/audiflow_app/test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart`

- [ ] **Step 1: Write failing test for selectable episode title**

Add to the test file's `EpisodeDetailScreen` group:

```dart
    testWidgets('episode title is selectable', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final selectableTexts = tester.widgetList<SelectableText>(
        find.byType(SelectableText),
      );
      final titleWidget = selectableTexts.where(
        (w) => w.data == 'Test Episode Title',
      );
      check(titleWidget.length).equals(1);
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart --name "episode title is selectable"`
Expected: FAIL — no `SelectableText` found with that data.

- [ ] **Step 3: Replace episode title Text with SelectableText**

In `episode_detail_screen.dart`, replace lines 226-231:

```dart
// Before:
Text(
  widget.episode.title,
  style: theme.textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
  ),
),

// After:
SelectableText(
  widget.episode.title,
  style: theme.textTheme.titleLarge?.copyWith(
    fontWeight: FontWeight.bold,
  ),
),
```

- [ ] **Step 4: Replace podcast name Text with SelectableText**

In `episode_detail_screen.dart`, the podcast name at lines 238-244 is inside an `InkWell`. Replace the `Text` with `SelectableText`:

```dart
// Before:
Text(
  widget.podcastTitle,
  style: theme.textTheme.titleMedium?.copyWith(
    color: colorScheme.primary,
  ),
),

// After:
SelectableText(
  widget.podcastTitle,
  style: theme.textTheme.titleMedium?.copyWith(
    color: colorScheme.primary,
  ),
),
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart --name "episode title is selectable"`
Expected: PASS.

- [ ] **Step 6: Run full episode detail tests**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart`
Expected: All tests PASS.

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart packages/audiflow_app/test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart
git commit -m "feat(episode-detail): make title and podcast name selectable"
```

---

### Task 4: Episode detail screen — SelectionArea for HTML description

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart:800-817` (in `_DescriptionSection`)

- [ ] **Step 1: Wrap Html widget in SelectionArea**

In `_DescriptionSection.build()`, wrap the `Html(...)` return value in a `SelectionArea`:

```dart
// Before:
return Html(
  data: content.plainTextToHtml.linkifyUrls,
  onLinkTap: (url, attributes, element) async {
    ...
  },
);

// After:
return SelectionArea(
  child: Html(
    data: content.plainTextToHtml.linkifyUrls,
    onLinkTap: (url, attributes, element) async {
      ...
    },
  ),
);
```

- [ ] **Step 2: Run analyze**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: Zero issues.

- [ ] **Step 3: Run episode detail tests**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart`
Expected: All tests PASS.

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart
git commit -m "feat(episode-detail): wrap description in SelectionArea for text selection"
```

---

### Task 5: Episode detail screen — CopyableText for metadata and stats

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart:649-704` (`_MetadataRow`) and `822-934` (`_EpisodeStatsSection`)

- [ ] **Step 1: Import CopyableText and Clipboard**

Add to the imports at the top of `episode_detail_screen.dart`:

```dart
import 'package:audiflow_ui/audiflow_ui.dart';
```

If already imported, no action needed. Check that `CopyableText` is accessible via this import.

- [ ] **Step 2: Convert stats table values to CopyableText**

In `_EpisodeStatsSection.build()`, the table rows are built at lines 899-917. Replace the value `Text` widget (line 912) with `CopyableText`:

```dart
// Before (line 910-913):
Padding(
  padding: const EdgeInsets.only(bottom: Spacing.xs),
  child: Text(row.value, style: valueStyle),
),

// After:
Padding(
  padding: const EdgeInsets.only(bottom: Spacing.xs),
  child: CopyableText(
    text: row.value,
    style: valueStyle,
    snackBarMessage: l10n.commonCopiedToClipboard,
  ),
),
```

- [ ] **Step 3: Run analyze**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: Zero issues.

- [ ] **Step 4: Run tests**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/screens/episode_detail_screen_test.dart`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart
git commit -m "feat(episode-detail): add one-tap copy for stats values"
```

---

### Task 6: Podcast detail header — selectable title, artist, genres

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/podcast_detail_header.dart:94-121` (in `_PodcastMetadata`)
- Modify: `packages/audiflow_app/test/features/podcast_detail/presentation/widgets/podcast_detail_header_test.dart`

- [ ] **Step 1: Write failing test for selectable podcast title**

Add to the test file's `PodcastDetailHeader` group:

```dart
    testWidgets('podcast title is selectable', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      final selectableTexts = tester.widgetList<SelectableText>(
        find.byType(SelectableText),
      );
      final titleWidget = selectableTexts.where(
        (w) => w.data == 'Test Podcast',
      );
      check(titleWidget.length).equals(1);
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/widgets/podcast_detail_header_test.dart --name "podcast title is selectable"`
Expected: FAIL.

- [ ] **Step 3: Wrap Column in SelectionArea and keep Text with overflow in _PodcastMetadata**

In `podcast_detail_header.dart`, wrap the `Column` in `_PodcastMetadata` with `SelectionArea`. Keep `Text` widgets with `overflow: TextOverflow.ellipsis` (do NOT use `SelectableText`, which drops ellipsis and causes gesture conflicts).

Note: `SelectionArea` + `Text` preserves both ellipsis truncation and long-press selection. This avoids the gesture arena conflict that `SelectableText` causes inside tappable parents.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/widgets/podcast_detail_header_test.dart --name "podcast title is selectable"`
Expected: PASS.

- [ ] **Step 5: Run full header tests**

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/widgets/podcast_detail_header_test.dart`
Expected: All tests PASS.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/podcast_detail_header.dart packages/audiflow_app/test/features/podcast_detail/presentation/widgets/podcast_detail_header_test.dart
git commit -m "feat(podcast-detail): make header text selectable"
```

---

### Task 7: Transcript timeline — selectable segment body, chapter, speaker

**Files:**
- Modify: `packages/audiflow_app/lib/features/player/presentation/widgets/transcript_timeline_view.dart:265-322`

- [ ] **Step 1: Wrap segment tile content in SelectionArea and keep Text**

In `_SegmentTile`, wrap the `Column` inside the `InkWell`'s `Container` with `SelectionArea`. Keep `Text` widgets (do NOT use `SelectableText` -- it causes gesture arena conflicts with the parent `InkWell.onTap` for tap-to-seek).

- [ ] **Step 2: Wrap chapter title in SelectionArea and keep Text with overflow**

In `_ChapterHeader`, wrap the chapter title `Text` with `SelectionArea`. Keep `overflow: TextOverflow.ellipsis` (which `SelectableText` does not support).

- [ ] **Step 3: Run analyze**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: Zero issues.

- [ ] **Step 4: Run all tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests PASS. Tap-to-seek on `InkWell` (parent of `_SegmentTile`) remains functional -- `SelectionArea` enables long-press selection while leaving single-tap free for the parent gesture.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/widgets/transcript_timeline_view.dart
git commit -m "feat(transcript): make segment text, chapters, and speakers selectable"
```

---

### Task 8: Player screen — selectable titles

**Files:**
- Modify: `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart:435-457` (in `_PlayerInfo`)

- [ ] **Step 1: Wrap _PlayerInfo Column in SelectionArea and keep Text with overflow**

In `_PlayerInfo`, wrap the `Column` with `SelectionArea`. Keep `Text` widgets with `overflow: TextOverflow.ellipsis` inside the `GestureDetector` children (do NOT use `SelectableText` -- it captures taps and prevents `GestureDetector.onTap` from firing).

Note: `SelectionArea` + `Text` preserves both ellipsis truncation and tap-to-navigate while enabling long-press selection.

- [ ] **Step 3: Run analyze**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: Zero issues.

- [ ] **Step 4: Run all tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart
git commit -m "feat(player): make episode and podcast titles selectable"
```

---

### Task 9: Final verification

- [ ] **Step 1: Run full test suite**

Run: `melos run test`
Expected: All packages pass.

- [ ] **Step 2: Run analyze across all packages**

Run: `flutter analyze`
Expected: Zero issues.

- [ ] **Step 3: Review all changes**

Run: `git log --oneline main..HEAD`
Expected: 8 commits covering l10n, CopyableText widget, episode detail, podcast header, transcript, and player screen changes.
