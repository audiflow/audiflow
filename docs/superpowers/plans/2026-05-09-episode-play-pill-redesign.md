# Episode Play Pill Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the `EpisodeCard` action row so the play pill conveys playback state + duration only, the publish date renders as a sibling text node, and the pill icon shows real progress when an episode is in progress.

**Architecture:** Three-layer change. `audiflow_core` gains a single pure formatter (`Duration.podcastShortLabel`) so the same time string is used everywhere. `audiflow_domain` exposes a `Duration`-typed `remainingDuration` getter on `EpisodeWithProgress` so callers can format with the new helper. `audiflow_ui` widens `EpisodePlayPill` (new `isInProgress`, `progressFraction`) and rewrites `EpisodeCard` to take `pillLabel` + `dateLabel` instead of one combined `subtitle`. `audiflow_app` callers (two list tiles plus l10n) move from a single subtitle builder to dedicated pill-label, date-label, and progress-fraction builders.

**Tech Stack:** Flutter 3.41+, Dart 3.11+, Riverpod 3 (read-only here, no provider changes), Freezed (regenerated for new getter), Material 3 widgets (`CircularProgressIndicator` for the determinate ring).

---

## Pre-flight

- Working branch: `feat/episode-play-pill-redesign` already exists from the spec commit. Stay on it.
- Spec lives at `docs/superpowers/specs/2026-05-08-play-button-content-design.md`.
- Theme work and an in-flight pill scaffold already sit uncommitted on this branch (`audiflow_ui/.../episode_play_pill.dart`, theme files, `episode_card.dart` and its test). The plan rebuilds the pill API rather than relying on the current uncommitted shape; tasks below show the **final** state of each file regardless of intermediate edits.
- After every commit: `flutter analyze` in the repo root must report `No issues found!`. If a step fails analyze, fix and amend before moving on.

---

### Task 1: Add `Duration.podcastShortLabel` formatter

**Files:**
- Modify: `packages/audiflow_core/lib/src/extensions/duration_extensions.dart`
- Test: `packages/audiflow_core/test/extensions/duration_extensions_test.dart`

- [ ] **Step 1: Write the failing tests**

Append the following group to `packages/audiflow_core/test/extensions/duration_extensions_test.dart`, inside the existing `group('DurationExtensions', ...)` body, just before its closing `});`:

```dart
group('podcastShortLabel', () {
  test('renders zero as 0:00', () {
    expect(Duration.zero.podcastShortLabel, '0:00');
  });

  test('renders single-digit seconds zero-padded', () {
    expect(const Duration(seconds: 9).podcastShortLabel, '0:09');
  });

  test('renders 59 seconds as 0:59', () {
    expect(const Duration(seconds: 59).podcastShortLabel, '0:59');
  });

  test('renders exactly 60 seconds as 1m', () {
    expect(const Duration(seconds: 60).podcastShortLabel, '1m');
  });

  test('truncates seconds within minute', () {
    expect(const Duration(seconds: 90).podcastShortLabel, '1m');
  });

  test('renders typical episode minutes', () {
    expect(const Duration(minutes: 33).podcastShortLabel, '33m');
  });

  test('renders very long episodes without ceiling', () {
    expect(const Duration(minutes: 9999).podcastShortLabel, '9999m');
  });

  test('treats negative duration as zero', () {
    expect(const Duration(seconds: -5).podcastShortLabel, '0:00');
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test packages/audiflow_core/test/extensions/duration_extensions_test.dart`
Expected: 8 failures with "The getter 'podcastShortLabel' isn't defined for the type 'Duration'."

- [ ] **Step 3: Implement the getter**

Replace the contents of `packages/audiflow_core/lib/src/extensions/duration_extensions.dart` with:

```dart
/// Extensions for Duration class
extension DurationExtensions on Duration {
  /// Format duration as MM:SS
  String formatMinutesSeconds() {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration as HH:MM:SS
  String formatHoursMinutesSeconds() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Compact label for podcast UIs (pill, list rows).
  ///
  /// - `< 60 s` → `0:ss` zero-padded (e.g. `0:09`, `0:45`).
  /// - `>= 60 s` → `{minutes truncated}m` (e.g. `33m`, `9999m`).
  /// - Negative durations clamp to `0:00`.
  String get podcastShortLabel {
    final secs = inSeconds;
    if (secs <= 0) return '0:00';
    if (secs < 60) {
      return '0:${secs.toString().padLeft(2, '0')}';
    }
    return '${inMinutes}m';
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test packages/audiflow_core/test/extensions/duration_extensions_test.dart`
Expected: all tests pass (existing + 8 new).

- [ ] **Step 5: Run repo analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_core/lib/src/extensions/duration_extensions.dart \
        packages/audiflow_core/test/extensions/duration_extensions_test.dart
git commit -m "feat(core): add Duration.podcastShortLabel formatter"
```

---

### Task 2: Add `remainingDuration` getter on `EpisodeWithProgress`

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/models/episode_with_progress.dart`
- Test: `packages/audiflow_domain/test/features/player/models/episode_with_progress_test.dart`

- [ ] **Step 1: Write the failing test**

Append this group inside the top-level `group('EpisodeWithProgress', ...)` block in `packages/audiflow_domain/test/features/player/models/episode_with_progress_test.dart` (place just before the group's closing `});`):

```dart
group('remainingDuration', () {
  test('null when history is null', () {
    final ep = EpisodeWithProgress(
      episode: Episode()
        ..podcastId = 1
        ..guid = 'g'
        ..title = 't'
        ..audioUrl = 'a',
      history: null,
    );
    expect(ep.remainingDuration, isNull);
  });

  test('null when durationMs is null', () {
    final ep = EpisodeWithProgress(
      episode: Episode()
        ..podcastId = 1
        ..guid = 'g'
        ..title = 't'
        ..audioUrl = 'a',
      history: PlaybackHistory()
        ..episodeId = 1
        ..positionMs = 1000
        ..durationMs = null,
    );
    expect(ep.remainingDuration, isNull);
  });

  test('returns Duration of remaining ms', () {
    final ep = EpisodeWithProgress(
      episode: Episode()
        ..podcastId = 1
        ..guid = 'g'
        ..title = 't'
        ..audioUrl = 'a',
      history: PlaybackHistory()
        ..episodeId = 1
        ..positionMs = 30000
        ..durationMs = 90000,
    );
    expect(ep.remainingDuration, const Duration(milliseconds: 60000));
  });
});
```

If the existing test file does not already import `PlaybackHistory` and `Episode`, add the imports next to the existing imports:

```dart
import 'package:audiflow_domain/src/features/feed/models/episode.dart';
import 'package:audiflow_domain/src/features/player/models/playback_history.dart';
```

(Use the import paths already used in other test files in the same directory if they differ — check `episode_with_progress_test.dart` first.)

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_domain/test/features/player/models/episode_with_progress_test.dart`
Expected: 3 failures with "The getter 'remainingDuration' isn't defined for the type 'EpisodeWithProgress'."

- [ ] **Step 3: Add the getter**

In `packages/audiflow_domain/lib/src/features/player/models/episode_with_progress.dart`, immediately after the existing `remainingMs` getter (around line 43), add:

```dart
/// Returns the remaining duration as a [Duration].
///
/// Null when there is no history or no recorded total duration.
Duration? get remainingDuration {
  final ms = remainingMs;
  if (ms == null) return null;
  return Duration(milliseconds: ms);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test packages/audiflow_domain/test/features/player/models/episode_with_progress_test.dart`
Expected: all tests pass.

- [ ] **Step 5: Run repo analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/player/models/episode_with_progress.dart \
        packages/audiflow_domain/test/features/player/models/episode_with_progress_test.dart
git commit -m "feat(domain): add EpisodeWithProgress.remainingDuration getter"
```

---

### Task 3: Rewrite `EpisodePlayPill` with progress ring + completed icon

**Files:**
- Modify: `packages/audiflow_ui/lib/src/widgets/buttons/episode_play_pill.dart`
- Test (new): `packages/audiflow_ui/test/widgets/buttons/episode_play_pill_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_ui/test/widgets/buttons/episode_play_pill_test.dart`:

```dart
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  group('EpisodePlayPill', () {
    testWidgets('not played: filled play icon, no ring', (tester) async {
      await tester.pumpWidget(host(const EpisodePlayPill(
        label: '33m',
        isPlaying: false,
        isLoading: false,
        isCompleted: false,
        isInProgress: false,
      )));
      check(find.byIcon(Icons.play_circle_filled).evaluate().length).equals(1);
      check(find.byType(CircularProgressIndicator).evaluate().length).equals(0);
      check(find.byIcon(Icons.check_circle_outline).evaluate().length).equals(0);
      check(find.text('33m').evaluate().length).equals(1);
    });

    testWidgets('completed: check_circle_outline, no ring', (tester) async {
      await tester.pumpWidget(host(const EpisodePlayPill(
        label: 'Completed',
        isPlaying: false,
        isLoading: false,
        isCompleted: true,
        isInProgress: false,
      )));
      check(find.byIcon(Icons.check_circle_outline).evaluate().length).equals(1);
      check(find.byType(CircularProgressIndicator).evaluate().length).equals(0);
      check(find.byIcon(Icons.play_circle_filled).evaluate().length).equals(0);
      check(find.text('Completed').evaluate().length).equals(1);
    });

    testWidgets('in-progress paused: ring + play icon', (tester) async {
      await tester.pumpWidget(host(const EpisodePlayPill(
        label: '12m left',
        isPlaying: false,
        isLoading: false,
        isCompleted: false,
        isInProgress: true,
        progressFraction: 0.5,
      )));
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(0.5);
      check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
      check(find.byIcon(Icons.pause).evaluate().length).equals(0);
    });

    testWidgets('playing: ring + pause icon', (tester) async {
      await tester.pumpWidget(host(const EpisodePlayPill(
        label: '12m left',
        isPlaying: true,
        isLoading: false,
        isCompleted: false,
        isInProgress: true,
        progressFraction: 0.7,
      )));
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(0.7);
      check(find.byIcon(Icons.pause).evaluate().length).equals(1);
      check(find.byIcon(Icons.play_arrow).evaluate().length).equals(0);
    });

    testWidgets('loading: indeterminate spinner', (tester) async {
      await tester.pumpWidget(host(const EpisodePlayPill(
        label: '33m',
        isPlaying: false,
        isLoading: true,
        isCompleted: false,
        isInProgress: false,
      )));
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(spinner.value).isNull();
    });

    testWidgets('progress fraction clamps above 1.0', (tester) async {
      await tester.pumpWidget(host(const EpisodePlayPill(
        label: '0m left',
        isPlaying: false,
        isLoading: false,
        isCompleted: false,
        isInProgress: true,
        progressFraction: 1.5,
      )));
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(1.0);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(host(EpisodePlayPill(
        label: '33m',
        isPlaying: false,
        isLoading: false,
        isCompleted: false,
        isInProgress: false,
        onPressed: () => tapped++,
      )));
      await tester.tap(find.byType(EpisodePlayPill));
      check(tapped).equals(1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test packages/audiflow_ui/test/widgets/buttons/episode_play_pill_test.dart`
Expected: failures referencing missing `isInProgress` and `progressFraction` parameters (current pill API).

- [ ] **Step 3: Rewrite the pill**

Replace the contents of `packages/audiflow_ui/lib/src/widgets/buttons/episode_play_pill.dart` with:

```dart
import 'package:flutter/material.dart';

/// Outlined pill containing a leading state visual and a label.
///
/// State precedence (top wins):
/// 1. `isLoading` → indeterminate spinner.
/// 2. `isCompleted` → `check_circle_outline`, muted.
/// 3. `isPlaying` → progress ring with pause icon.
/// 4. `isInProgress` → progress ring with play icon.
/// 5. otherwise → filled play circle.
///
/// `progressFraction` is consumed only by the ring states. It is silently
/// clamped to `[0.0, 1.0]`. When null the ring renders the value as 0.
class EpisodePlayPill extends StatelessWidget {
  const EpisodePlayPill({
    super.key,
    required this.label,
    required this.isPlaying,
    required this.isLoading,
    required this.isCompleted,
    required this.isInProgress,
    this.progressFraction,
    this.onPressed,
  });

  final String label;
  final bool isPlaying;
  final bool isLoading;
  final bool isCompleted;
  final bool isInProgress;
  final double? progressFraction;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final foreground = isCompleted
        ? colorScheme.onSurfaceVariant
        : colorScheme.primary;
    final borderColor = isCompleted
        ? colorScheme.outlineVariant
        : colorScheme.outline;

    return Material(
      color: Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: borderColor)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: _buildLeading(foreground),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(Color color) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    if (isCompleted) {
      return Icon(Icons.check_circle_outline, size: 20, color: color);
    }
    if (isPlaying || isInProgress) {
      final raw = progressFraction ?? 0.0;
      final clamped = raw.isNaN ? 0.0 : raw.clamp(0.0, 1.0).toDouble();
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: 2,
              color: color,
              backgroundColor: color.withValues(alpha: 0.18),
            ),
          ),
          Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            size: 12,
            color: color,
          ),
        ],
      );
    }
    return Icon(Icons.play_circle_filled, size: 20, color: color);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test packages/audiflow_ui/test/widgets/buttons/episode_play_pill_test.dart`
Expected: all 7 tests pass.

- [ ] **Step 5: Run repo analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_ui/lib/src/widgets/buttons/episode_play_pill.dart \
        packages/audiflow_ui/test/widgets/buttons/episode_play_pill_test.dart
git commit -m "feat(ui): add progress ring + completed icon to EpisodePlayPill"
```

---

### Task 4: Split `EpisodeCard` API (`pillLabel` + `dateLabel` + new flags)

**Files:**
- Modify: `packages/audiflow_ui/lib/src/widgets/cards/episode_card.dart`
- Modify: `packages/audiflow_ui/test/widgets/cards/episode_card_test.dart`

- [ ] **Step 1: Update the existing test file to drive the new API**

Replace the contents of `packages/audiflow_ui/test/widgets/cards/episode_card_test.dart` with:

```dart
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:audiflow_ui/src/widgets/cards/episode_card.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    String title = 'Test Episode',
    String pillLabel = '33m',
    String? dateLabel = 'Apr 29',
    String? description,
    bool isPlaying = false,
    bool isLoading = false,
    bool isInProgress = false,
    bool isNew = false,
    bool isCompleted = false,
    bool isCurrentEpisode = false,
    double? progressFraction,
    VoidCallback? onPlayPause,
    VoidCallback? onTap,
    List<Widget> actionButtons = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: episodeCardExtent,
          child: EpisodeCard(
            title: title,
            pillLabel: pillLabel,
            dateLabel: dateLabel,
            description: description,
            isPlaying: isPlaying,
            isLoading: isLoading,
            isInProgress: isInProgress,
            isNew: isNew,
            isCompleted: isCompleted,
            isCurrentEpisode: isCurrentEpisode,
            progressFraction: progressFraction,
            onPlayPause: onPlayPause,
            onTap: onTap,
            actionButtons: actionButtons,
          ),
        ),
      ),
    );
  }

  group('EpisodeCard', () {
    testWidgets('renders title, pill, and date separately', (tester) async {
      await tester.pumpWidget(buildSubject(
        title: 'My Episode',
        pillLabel: '45m',
        dateLabel: 'Mar 22',
      ));
      check(find.text('My Episode').evaluate().length).equals(1);
      check(find.text('45m').evaluate().length).equals(1);
      check(find.text('Mar 22').evaluate().length).equals(1);
    });

    testWidgets('omits date text when dateLabel is null', (tester) async {
      await tester.pumpWidget(buildSubject(dateLabel: null));
      check(find.text('Apr 29').evaluate().length).equals(0);
    });

    testWidgets('not played pill: filled play icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      check(find.byIcon(Icons.play_circle_filled).evaluate().length).equals(1);
    });

    testWidgets('completed pill: check icon', (tester) async {
      await tester.pumpWidget(buildSubject(
        pillLabel: 'Completed',
        isCompleted: true,
      ));
      check(find.byIcon(Icons.check_circle_outline).evaluate().length).equals(1);
      check(find.text('Completed').evaluate().length).equals(1);
    });

    testWidgets('playing pill: ring with pause and progress value', (tester) async {
      await tester.pumpWidget(buildSubject(
        pillLabel: '12m left',
        isPlaying: true,
        isInProgress: true,
        progressFraction: 0.4,
      ));
      check(find.byIcon(Icons.pause).evaluate().length).equals(1);
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(0.4);
    });

    testWidgets('in-progress paused pill: ring with play', (tester) async {
      await tester.pumpWidget(buildSubject(
        pillLabel: '12m left',
        isInProgress: true,
        progressFraction: 0.4,
      ));
      check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
    });

    testWidgets('loading pill: indeterminate spinner', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(spinner.value).isNull();
    });

    testWidgets('shows new badge when isNew is true', (tester) async {
      await tester.pumpWidget(buildSubject(isNew: true));
      check(find.text('new').evaluate().length).equals(1);
    });

    testWidgets('does not show new badge when isNew is false', (tester) async {
      await tester.pumpWidget(buildSubject());
      check(find.text('new').evaluate().length).equals(0);
    });

    testWidgets('fires onPlayPause when pill tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onPlayPause: () => tapped = true));
      await tester.tap(find.byType(EpisodePlayPill));
      check(tapped).isTrue();
    });

    testWidgets('fires onTap when card body tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onTap: () => tapped = true));
      await tester.tap(find.text('Test Episode'));
      check(tapped).isTrue();
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(buildSubject(description: 'This is a test description'));
      check(find.text('This is a test description').evaluate().length).equals(1);
    });

    testWidgets('episodeCardExtent matches actual rendered height', (tester) async {
      await tester.pumpWidget(buildSubject());
      final cardSize = tester.getSize(find.byType(EpisodeCard));
      check(cardSize.height).equals(episodeCardExtent);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test packages/audiflow_ui/test/widgets/cards/episode_card_test.dart`
Expected: failures complaining about removed `subtitle` parameter and missing `pillLabel` / `dateLabel` / `isInProgress` / `progressFraction`.

- [ ] **Step 3: Update `EpisodeCard` to the new API**

Open `packages/audiflow_ui/lib/src/widgets/cards/episode_card.dart` and apply these changes:

a) Replace the constructor field declaration block (the `subtitle` field plus the documentation comment immediately above it) with:

```dart
  /// Pre-formatted state label rendered inside the play pill.
  final String pillLabel;

  /// Pre-formatted publish date rendered next to the pill. Null hides it.
  final String? dateLabel;
```

b) Update the `const EpisodeCard({...})` constructor parameter list:

- Remove `required this.subtitle,`
- Add `required this.pillLabel,` (place near the top with `required this.title,`)
- Add `this.dateLabel,` (place next to other optional named params)
- Add `this.isInProgress = false,` (place near `this.isCompleted = false,`)
- Add `this.progressFraction,` (place near `this.isCurrentEpisode = false,`)

c) Add the new field declarations next to existing flags:

```dart
  final bool isInProgress;

  /// Progress through the episode in `[0.0, 1.0]`. Drives the pill ring
  /// when [isPlaying] or [isInProgress] is true. Null is treated as 0.
  final double? progressFraction;
```

d) Replace the `_buildActionRow` method with:

```dart
  Widget _buildActionRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: EpisodePlayPill(
            label: pillLabel,
            isPlaying: isPlaying,
            isLoading: isLoading,
            isCompleted: isCompleted,
            isInProgress: isInProgress,
            progressFraction: progressFraction,
            onPressed: onPlayPause,
          ),
        ),
        if (dateLabel != null) ...[
          const SizedBox(width: Spacing.sm),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              dateLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        if (hasTranscript) ...[
          const SizedBox(width: Spacing.xs),
          _TranscriptBadge(
            color: colorScheme.onSurfaceVariant,
            label: transcriptLabel,
          ),
        ],
        if (isNew) ...[
          const SizedBox(width: Spacing.xs),
          _NewBadge(color: colorScheme.primary),
        ],
        const Spacer(),
        ...actionButtons,
      ],
    );
  }
```

e) Search the rest of the file for any remaining reference to `subtitle` (there should be none after step (a)). Remove if any are found.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test packages/audiflow_ui/test/widgets/cards/episode_card_test.dart`
Expected: all tests pass.

- [ ] **Step 5: Run analyze (will fail at the two callers)**

Run: `flutter analyze`
Expected: errors at `episode_list_tile.dart` and `smart_playlist_episode_list_tile.dart` referencing the removed `subtitle` parameter. This is the seam picked up by Task 5. **Do not commit yet** — analyze must be clean before committing.

Skip Task 4 commit; the EpisodeCard change ships alongside the caller updates in Task 5 to keep the tree green.

---

### Task 5: Add l10n keys + update `EpisodeListTile`

**Files:**
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`

- [ ] **Step 1: Add the English l10n keys**

Open `packages/audiflow_app/lib/l10n/app_en.arb` and add the following two key/metadata pairs. Place them next to other `episode*` keys (search for `episodeTranscriptAvailable` and put them adjacent — keep both keys in the file's JSON object):

```json
"episodePillCompleted": "Completed",
"@episodePillCompleted": { "description": "Pill label shown on a fully-played episode" },
"episodePillRemaining": "{time} left",
"@episodePillRemaining": {
  "description": "Pill label for an episode with playback progress, showing remaining time",
  "placeholders": {
    "time": { "type": "String", "example": "12m" }
  }
}
```

- [ ] **Step 2: Add the Japanese l10n keys**

Open `packages/audiflow_app/lib/l10n/app_ja.arb` and add:

```json
"episodePillCompleted": "再生済み",
"episodePillRemaining": "残り {time}"
```

(No `@`-metadata block in `app_ja.arb` per existing convention — only the en file holds descriptions.)

- [ ] **Step 3: Regenerate l10n**

Run: `flutter gen-l10n`
Expected: silent success; `packages/audiflow_app/lib/l10n/app_localizations.dart` updates to include `episodePillCompleted` and `episodePillRemaining(String time)`.

- [ ] **Step 4: Update `EpisodeListTile`**

In `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`:

a) Confirm `audiflow_core` is already imported (line 1). It is — it provides `DurationExtensions`.

b) Replace the existing `_buildSubtitleText` method (lines 166–190 currently) with three helpers:

```dart
  String _buildPillLabel(
    EpisodeWithProgress? p,
    bool isCompleted,
    AppLocalizations l10n,
  ) {
    if (isCompleted) return l10n.episodePillCompleted;

    if (p != null && p.isInProgress) {
      final remaining = p.remainingDuration;
      if (remaining != null) {
        return l10n.episodePillRemaining(remaining.podcastShortLabel);
      }
    }

    final total = episode.duration;
    if (total != null) return total.podcastShortLabel;
    return '';
  }

  String? _buildDateLabel(AppLocalizations l10n) {
    final date = episode.publishDate;
    if (date == null) return null;
    return date.formatEpisodeDate(
      todayLabel: l10n.dateToday,
      yesterdayLabel: l10n.dateYesterday,
    );
  }

  double? _buildProgressFraction(EpisodeWithProgress? p) {
    if (p == null) return null;
    return p.progressPercent;
  }
```

c) Replace the `EpisodeCard(...)` invocation (the call returned from `build`) so it uses the new params. Locate this block (around line 100):

```dart
return EpisodeCard(
  title: episode.title,
  subtitle: _buildSubtitleText(l10n),
  description: episode.description,
  ...
```

Change it to:

```dart
return EpisodeCard(
  title: episode.title,
  pillLabel: _buildPillLabel(progress, isCompleted, l10n),
  dateLabel: _buildDateLabel(l10n),
  isInProgress: progress?.isInProgress ?? false,
  progressFraction: _buildProgressFraction(progress),
  description: episode.description,
  ...
```

Leave every other named argument in the call unchanged.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: `smart_playlist_episode_list_tile.dart` still flags the removed `subtitle` parameter; everything else is clean. Continue to Task 6.

---

### Task 6: Update `SmartPlaylistEpisodeListTile`

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart`

- [ ] **Step 1: Inspect the current file**

Run: `grep -n "subtitle\|EpisodeCard(\|_buildSubtitleText\|publishDate\|formattedDuration" packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart`
Note the lines that build subtitle text and the `EpisodeCard(` call site.

- [ ] **Step 2: Apply the same three-helper split as Task 5**

In the same file, locate the existing `_buildSubtitleText` method (it follows the pattern from `episode_list_tile.dart`). Replace it with the same three helpers:

```dart
  String _buildPillLabel(
    EpisodeWithProgress? p,
    bool isCompleted,
    AppLocalizations l10n,
  ) {
    if (isCompleted) return l10n.episodePillCompleted;

    if (p != null && p.isInProgress) {
      final remaining = p.remainingDuration;
      if (remaining != null) {
        return l10n.episodePillRemaining(remaining.podcastShortLabel);
      }
    }

    final total = episode.duration;
    if (total != null) return total.podcastShortLabel;
    return '';
  }

  String? _buildDateLabel(AppLocalizations l10n) {
    final date = episode.publishDate;
    if (date == null) return null;
    return date.formatEpisodeDate(
      todayLabel: l10n.dateToday,
      yesterdayLabel: l10n.dateYesterday,
    );
  }

  double? _buildProgressFraction(EpisodeWithProgress? p) {
    if (p == null) return null;
    return p.progressPercent;
  }
```

If the smart playlist tile uses a different field name for the underlying episode (e.g. `episode` is reached differently), adapt the body — but keep helper signatures identical so the call site below works unchanged.

- [ ] **Step 3: Update the `EpisodeCard(...)` call site**

Change `subtitle: _buildSubtitleText(l10n),` to:

```dart
pillLabel: _buildPillLabel(progress, isCompleted, l10n),
dateLabel: _buildDateLabel(l10n),
isInProgress: progress?.isInProgress ?? false,
progressFraction: _buildProgressFraction(progress),
```

Keep every other named argument unchanged.

- [ ] **Step 4: Run repo analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Run all tests**

Run: `melos run test --no-select`
Expected: every package's test suite passes (the audiflow_core / audiflow_domain / audiflow_ui tests added in earlier tasks plus the existing audiflow_app tests).

- [ ] **Step 6: Commit (Tasks 4 + 5 + 6 ship together)**

```bash
git add packages/audiflow_ui/lib/src/widgets/cards/episode_card.dart \
        packages/audiflow_ui/test/widgets/cards/episode_card_test.dart \
        packages/audiflow_app/lib/l10n/app_en.arb \
        packages/audiflow_app/lib/l10n/app_ja.arb \
        packages/audiflow_app/lib/l10n/app_localizations.dart \
        packages/audiflow_app/lib/l10n/app_localizations_en.dart \
        packages/audiflow_app/lib/l10n/app_localizations_ja.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart \
        packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart
git commit -m "feat(ui): split EpisodeCard subtitle into pill label + date label"
```

(If `flutter gen-l10n` produced different generated file names, list whatever it actually changed under `packages/audiflow_app/lib/l10n/`.)

---

### Task 7: Manual smoke test + theme snapshot

**Files:**
- None modified — verification only.

- [ ] **Step 1: Run the dev flavor**

Run: `flutter run --flavor dev -t packages/audiflow_app/lib/main_dev.dart --dart-define-from-file=packages/audiflow_app/.env.dev`
Expected: app boots without exceptions.

- [ ] **Step 2: Walk the four pill states**

In a podcast detail screen:
- Find an unplayed episode → pill shows filled play icon + duration (e.g. `33m`).
- Tap play, then pause → pill shows progress ring + pause icon while playing, then progress ring + play icon when paused; label = `Xm left` (en) or `残り Xm` (ja).
- Find a completed episode → pill shows check_circle_outline + `Completed` / `再生済み`, muted color.
- Trigger a fresh load (tap an unloaded episode) → spinner appears briefly before the playing state takes over.

- [ ] **Step 3: Toggle locale**

Switch device locale to Japanese. Confirm the in-progress pill renders `残り 12m` (or similar), and the completed pill renders `再生済み`.

- [ ] **Step 4: Confirm date placement**

Verify the publish date renders to the right of the pill in the action row, never inside it. Confirm the date is omitted on episodes with no `publishDate`.

- [ ] **Step 5: No commit**

This task is verification-only. If a defect surfaces, file a follow-up commit with a focused fix instead of amending earlier commits.

---

## Self-Review

- [x] **Spec coverage:** Every spec section maps to a task — formatter (Task 1), `remainingDuration` (Task 2), pill API + visuals (Task 3), card layout + new params (Task 4), l10n + first caller (Task 5), second caller (Task 6), manual smoke (Task 7).
- [x] **Placeholder scan:** No TBDs. Code blocks complete in every implementation step.
- [x] **Type consistency:** `pillLabel`, `dateLabel`, `isInProgress`, `progressFraction` are spelled identically across `EpisodePlayPill`, `EpisodeCard`, and the two callers. `podcastShortLabel` is referenced exactly the same way in callers as it is defined in Task 1.
- [x] **Cross-task ordering:** Task 4 intentionally defers commit until Task 6 because removing `subtitle` from `EpisodeCard` immediately breaks the two callers — bundling the three together keeps `flutter analyze` green at every committed state.
