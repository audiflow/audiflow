# Voice Debug Overlay Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a debug panel (bottom-left) that shows voice pipeline internals during voice interactions on dev/stg builds only.

**Architecture:** New `VoiceDebugInfo` freezed model + `VoiceDebugInfoNotifier` Riverpod provider in `audiflow_domain` to track which parser matched and the last command. The orchestrator populates this alongside existing state transitions. A new `VoiceDebugPanel` widget in `audiflow_app` reads both providers and renders a monospace overlay. Guarded by `FlavorConfig.current.flavor != Flavor.prod`.

**Tech Stack:** Dart, Flutter, Riverpod (code generation), Freezed, `package:checks` for tests.

---

## File Structure

| File | Responsibility |
|------|---------------|
| `audiflow_domain/lib/src/features/voice/models/voice_debug_info.dart` | New -- `VoiceDebugInfo` freezed class + `VoiceParserSource` enum |
| `audiflow_domain/lib/src/features/voice/services/voice_debug_info_notifier.dart` | New -- `@Riverpod(keepAlive: true)` notifier |
| `audiflow_domain/lib/audiflow_domain.dart` | Modified -- add exports |
| `audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart` | Modified -- populate debug info at each parser match point |
| `audiflow_app/lib/features/voice/presentation/widgets/voice_debug_panel.dart` | New -- debug overlay widget |
| `audiflow_app/lib/routing/scaffold_with_nav_bar.dart` | Modified -- add `VoiceDebugPanel` to `Stack` |

---

### Task 1: Create `VoiceDebugInfo` model and `VoiceParserSource` enum

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/voice/models/voice_debug_info.dart`
- Test: `packages/audiflow_domain/test/features/voice/models/voice_debug_info_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_domain/test/features/voice/models/voice_debug_info_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceDebugInfo', () {
    test('default values', () {
      const info = VoiceDebugInfo();
      check(info.parserSource).equals(VoiceParserSource.none);
      check(info.lastCommand).isNull();
    });

    test('copyWith parserSource', () {
      const info = VoiceDebugInfo();
      final updated = info.copyWith(parserSource: VoiceParserSource.simplePattern);
      check(updated.parserSource).equals(VoiceParserSource.simplePattern);
      check(info.parserSource).equals(VoiceParserSource.none);
    });

    test('copyWith lastCommand', () {
      const info = VoiceDebugInfo();
      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {'podcastName': 'news'},
        confidence: 0.9,
        rawTranscription: 'play the news',
      );
      final updated = info.copyWith(lastCommand: command);
      check(updated.lastCommand).isNotNull();
      check(updated.lastCommand!.intent).equals(VoiceIntent.play);
      check(updated.lastCommand!.confidence).equals(0.9);
    });

    test('equality', () {
      const a = VoiceDebugInfo();
      const b = VoiceDebugInfo();
      check(a).equals(b);
    });
  });

  group('VoiceParserSource', () {
    test('has expected values', () {
      check(VoiceParserSource.values.length).equals(4);
      check(VoiceParserSource.values).contains(VoiceParserSource.none);
      check(VoiceParserSource.values).contains(VoiceParserSource.simplePattern);
      check(VoiceParserSource.values).contains(VoiceParserSource.platformNlu);
      check(VoiceParserSource.values).contains(VoiceParserSource.onDeviceAi);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/models/voice_debug_info_test.dart`
Expected: FAIL -- `VoiceDebugInfo` not found.

- [ ] **Step 3: Write the model**

Create `packages/audiflow_domain/lib/src/features/voice/models/voice_debug_info.dart`:

```dart
import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_debug_info.freezed.dart';

/// Which parser resolved the voice transcription.
enum VoiceParserSource {
  /// No parser has matched yet.
  none,

  /// Deterministic keyword/regex matching.
  simplePattern,

  /// Platform-native NLU (Apple/Google).
  platformNlu,

  /// On-device AI model.
  onDeviceAi,
}

/// Debug metadata for the voice command pipeline.
///
/// Populated by [VoiceCommandOrchestrator] alongside the main
/// [VoiceRecognitionState]. Consumed only by the debug overlay
/// on non-production builds.
@freezed
sealed class VoiceDebugInfo with _$VoiceDebugInfo {
  const factory VoiceDebugInfo({
    @Default(VoiceParserSource.none) VoiceParserSource parserSource,
    VoiceCommand? lastCommand,
  }) = _VoiceDebugInfo;
}
```

- [ ] **Step 4: Add export to barrel file**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart` after the existing voice exports (after line `export 'src/features/voice/services/voice_command_orchestrator.dart';`):

```dart
export 'src/features/voice/models/voice_debug_info.dart';
```

- [ ] **Step 5: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/models/voice_debug_info_test.dart`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/models/voice_debug_info.dart \
       packages/audiflow_domain/lib/src/features/voice/models/voice_debug_info.freezed.dart \
       packages/audiflow_domain/lib/audiflow_domain.dart \
       packages/audiflow_domain/test/features/voice/models/voice_debug_info_test.dart
git commit -m "feat(voice): add VoiceDebugInfo model and VoiceParserSource enum"
```

---

### Task 2: Create `VoiceDebugInfoNotifier` provider

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/voice/services/voice_debug_info_notifier.dart`
- Test: `packages/audiflow_domain/test/features/voice/services/voice_debug_info_notifier_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_domain/test/features/voice/services/voice_debug_info_notifier_test.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceDebugInfoNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is default VoiceDebugInfo', () {
      final state = container.read(voiceDebugInfoNotifierProvider);
      check(state.parserSource).equals(VoiceParserSource.none);
      check(state.lastCommand).isNull();
    });

    test('setParserSource updates parserSource', () {
      container
          .read(voiceDebugInfoNotifierProvider.notifier)
          .setParserSource(VoiceParserSource.simplePattern);

      final state = container.read(voiceDebugInfoNotifierProvider);
      check(state.parserSource).equals(VoiceParserSource.simplePattern);
    });

    test('setLastCommand updates lastCommand', () {
      final command = VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: const {},
        confidence: 0.95,
        rawTranscription: 'pause',
      );
      container
          .read(voiceDebugInfoNotifierProvider.notifier)
          .setLastCommand(command);

      final state = container.read(voiceDebugInfoNotifierProvider);
      check(state.lastCommand).isNotNull();
      check(state.lastCommand!.intent).equals(VoiceIntent.pause);
    });

    test('reset restores default state', () {
      container
          .read(voiceDebugInfoNotifierProvider.notifier)
          .setParserSource(VoiceParserSource.onDeviceAi);

      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: 'play',
      );
      container
          .read(voiceDebugInfoNotifierProvider.notifier)
          .setLastCommand(command);

      container.read(voiceDebugInfoNotifierProvider.notifier).reset();

      final state = container.read(voiceDebugInfoNotifierProvider);
      check(state.parserSource).equals(VoiceParserSource.none);
      check(state.lastCommand).isNull();
    });

    test('setParserSource preserves lastCommand', () {
      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {},
        confidence: 0.9,
        rawTranscription: 'play',
      );
      final notifier = container.read(
        voiceDebugInfoNotifierProvider.notifier,
      );
      notifier.setLastCommand(command);
      notifier.setParserSource(VoiceParserSource.platformNlu);

      final state = container.read(voiceDebugInfoNotifierProvider);
      check(state.parserSource).equals(VoiceParserSource.platformNlu);
      check(state.lastCommand).isNotNull();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/voice_debug_info_notifier_test.dart`
Expected: FAIL -- `voiceDebugInfoNotifierProvider` not found.

- [ ] **Step 3: Write the notifier**

Create `packages/audiflow_domain/lib/src/features/voice/services/voice_debug_info_notifier.dart`:

```dart
import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/voice_debug_info.dart';

part 'voice_debug_info_notifier.g.dart';

/// Notifier that holds debug metadata for the voice command pipeline.
///
/// Populated by [VoiceCommandOrchestrator] at each parser match point.
/// Read only by the debug overlay widget on non-production builds.
@Riverpod(keepAlive: true)
class VoiceDebugInfoNotifier extends _$VoiceDebugInfoNotifier {
  @override
  VoiceDebugInfo build() => const VoiceDebugInfo();

  /// Records which parser resolved the current transcription.
  void setParserSource(VoiceParserSource source) {
    state = state.copyWith(parserSource: source);
  }

  /// Stores the last parsed command so debug info survives across
  /// state transitions (e.g., executing -> success).
  void setLastCommand(VoiceCommand command) {
    state = state.copyWith(lastCommand: command);
  }

  /// Resets to default state. Called when voice flow returns to idle.
  void reset() {
    state = const VoiceDebugInfo();
  }
}
```

- [ ] **Step 4: Add export to barrel file**

Add to `packages/audiflow_domain/lib/audiflow_domain.dart` after the `voice_debug_info.dart` export:

```dart
export 'src/features/voice/services/voice_debug_info_notifier.dart';
```

- [ ] **Step 5: Run code generation**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 6: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/services/voice_debug_info_notifier_test.dart`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/voice_debug_info_notifier.dart \
       packages/audiflow_domain/lib/src/features/voice/services/voice_debug_info_notifier.g.dart \
       packages/audiflow_domain/lib/audiflow_domain.dart \
       packages/audiflow_domain/test/features/voice/services/voice_debug_info_notifier_test.dart
git commit -m "feat(voice): add VoiceDebugInfoNotifier provider"
```

---

### Task 3: Wire orchestrator to populate debug info

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart`

The orchestrator already has `ref` access. We add calls to the debug info notifier at each parser decision point.

- [ ] **Step 1: Add import**

At the top of `voice_command_orchestrator.dart`, add:

```dart
import '../models/voice_debug_info.dart';
import 'voice_debug_info_notifier.dart';
```

- [ ] **Step 2: Add `setLastCommand` in `_executeCommand`**

In `_executeCommand`, add immediately after the opening `{`:

```dart
    ref.read(voiceDebugInfoNotifierProvider.notifier).setLastCommand(command);
```

- [ ] **Step 3: Add `setParserSource` at each match point in `_processTranscription`**

In `_processTranscription`, after the line `_logger?.i('Simple parser matched: ${simpleCommand.intent}');` (around line 252), add before `await _executeCommand(simpleCommand);`:

```dart
      ref
          .read(voiceDebugInfoNotifierProvider.notifier)
          .setParserSource(VoiceParserSource.simplePattern);
```

After the line `_logger?.i('Platform NLU resolved: $action');` (around line 268), add before `final payload = ...`:

```dart
        ref
            .read(voiceDebugInfoNotifierProvider.notifier)
            .setParserSource(VoiceParserSource.platformNlu);
```

After the line `_logger?.i('AI parsed command: ${command.intent}');` (around line 295), add before `await _executeCommand(command);`:

```dart
      ref
          .read(voiceDebugInfoNotifierProvider.notifier)
          .setParserSource(VoiceParserSource.onDeviceAi);
```

- [ ] **Step 4: Add `reset` in `cancelVoiceCommand` and `resetToIdle`**

In `cancelVoiceCommand`, add after `state = const VoiceRecognitionState.idle();`:

```dart
    ref.read(voiceDebugInfoNotifierProvider.notifier).reset();
```

In `resetToIdle`, add after `state = const VoiceRecognitionState.idle();`:

```dart
    ref.read(voiceDebugInfoNotifierProvider.notifier).reset();
```

- [ ] **Step 5: Run analyze**

Run: `cd packages/audiflow_domain && flutter analyze`
Expected: No issues.

- [ ] **Step 6: Run all domain voice tests**

Run: `cd packages/audiflow_domain && flutter test test/features/voice/`
Expected: ALL PASS (existing tests should remain green; the debug notifier is a side channel that doesn't affect orchestrator behavior).

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/voice/services/voice_command_orchestrator.dart
git commit -m "feat(voice): wire orchestrator to populate VoiceDebugInfo"
```

---

### Task 4: Create `VoiceDebugPanel` widget

**Files:**
- Create: `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_debug_panel.dart`
- Test: `packages/audiflow_app/test/features/voice/presentation/widgets/voice_debug_panel_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_app/test/features/voice/presentation/widgets/voice_debug_panel_test.dart`:

```dart
import 'package:audiflow_app/features/voice/presentation/widgets/voice_debug_panel.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeOrchestrator extends VoiceCommandOrchestrator {
  _FakeOrchestrator(this._state);

  final VoiceRecognitionState _state;

  @override
  VoiceRecognitionState build() => _state;
}

class _FakeDebugInfoNotifier extends VoiceDebugInfoNotifier {
  _FakeDebugInfoNotifier(this._info);

  final VoiceDebugInfo _info;

  @override
  VoiceDebugInfo build() => _info;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestApp({
  required VoiceRecognitionState voiceState,
  VoiceDebugInfo debugInfo = const VoiceDebugInfo(),
}) {
  final container = ProviderContainer(
    overrides: [
      voiceCommandOrchestratorProvider.overrideWith(
        () => _FakeOrchestrator(voiceState),
      ),
      voiceDebugInfoNotifierProvider.overrideWith(
        () => _FakeDebugInfoNotifier(debugInfo),
      ),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Stack(children: [VoiceDebugPanel()])),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VoiceDebugPanel', () {
    testWidgets('renders nothing when idle', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(voiceState: const VoiceRecognitionState.idle()),
      );
      await tester.pump();

      final finder = find.text('VOICE DEBUG');
      check(finder.evaluate().isEmpty).isTrue();
    });

    testWidgets('shows header and state when listening', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          voiceState: const VoiceRecognitionState.listening(
            partialTranscript: 'play the',
          ),
        ),
      );
      await tester.pump();

      check(find.text('VOICE DEBUG').evaluate().isNotEmpty).isTrue();
      check(find.textContaining('LISTENING').evaluate().isNotEmpty).isTrue();
      check(find.textContaining('play the').evaluate().isNotEmpty).isTrue();
    });

    testWidgets('shows parser source and intent when executing', (
      tester,
    ) async {
      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {'podcastName': 'news'},
        confidence: 0.9,
        rawTranscription: 'play the news',
      );

      await tester.pumpWidget(
        _buildTestApp(
          voiceState: VoiceRecognitionState.executing(command: command),
          debugInfo: VoiceDebugInfo(
            parserSource: VoiceParserSource.simplePattern,
            lastCommand: command,
          ),
        ),
      );
      await tester.pump();

      check(find.textContaining('EXECUTING').evaluate().isNotEmpty).isTrue();
      check(
        find.textContaining('simple (pattern)').evaluate().isNotEmpty,
      ).isTrue();
      check(find.textContaining('play').evaluate().isNotEmpty).isTrue();
      check(find.textContaining('0.90').evaluate().isNotEmpty).isTrue();
    });

    testWidgets('shows AI status as ready when initialized', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          voiceState: const VoiceRecognitionState.listening(),
        ),
      );
      await tester.pump();

      // AI status should show (either "ready" or "not init")
      // In test environment AudiflowAi is not initialized
      check(find.textContaining('AI:').evaluate().isNotEmpty).isTrue();
    });

    testWidgets('shows params when command has parameters', (tester) async {
      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {'podcastName': 'news'},
        confidence: 0.9,
        rawTranscription: 'play the news',
      );

      await tester.pumpWidget(
        _buildTestApp(
          voiceState: const VoiceRecognitionState.success(
            message: 'Playing',
          ),
          debugInfo: VoiceDebugInfo(
            parserSource: VoiceParserSource.simplePattern,
            lastCommand: command,
          ),
        ),
      );
      await tester.pump();

      check(find.textContaining('podcastName').evaluate().isNotEmpty).isTrue();
    });

    testWidgets('shows confidence from debug info', (tester) async {
      final command = VoiceCommand(
        intent: VoiceIntent.pause,
        parameters: const {},
        confidence: 0.95,
        rawTranscription: 'pause',
      );

      await tester.pumpWidget(
        _buildTestApp(
          voiceState: const VoiceRecognitionState.success(message: 'Paused'),
          debugInfo: VoiceDebugInfo(
            parserSource: VoiceParserSource.platformNlu,
            lastCommand: command,
          ),
        ),
      );
      await tester.pump();

      check(find.textContaining('0.95').evaluate().isNotEmpty).isTrue();
      check(
        find.textContaining('platform NLU').evaluate().isNotEmpty,
      ).isTrue();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/voice_debug_panel_test.dart`
Expected: FAIL -- `VoiceDebugPanel` not found.

- [ ] **Step 3: Write the widget**

Create `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_debug_panel.dart`:

```dart
import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug overlay that shows voice pipeline internals.
///
/// Shown only on non-production builds. Appears when the voice state
/// leaves idle and disappears when it returns to idle.
class VoiceDebugPanel extends ConsumerStatefulWidget {
  const VoiceDebugPanel({super.key});

  @override
  ConsumerState<VoiceDebugPanel> createState() => _VoiceDebugPanelState();
}

class _VoiceDebugPanelState extends ConsumerState<VoiceDebugPanel>
    with SingleTickerProviderStateMixin {
  static const Duration _fadeInDuration = Duration(milliseconds: 200);
  static const Duration _fadeOutDuration = Duration(milliseconds: 150);

  late final AnimationController _visibilityController;
  late final Animation<double> _fadeAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: _fadeInDuration,
      reverseDuration: _fadeOutDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _visibilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final debugInfo = ref.watch(voiceDebugInfoNotifierProvider);
    final shouldShow = voiceState is! VoiceIdle;

    if (shouldShow && !_isVisible) {
      _isVisible = true;
      _visibilityController.forward();
    } else if (!shouldShow && _isVisible) {
      _isVisible = false;
      _visibilityController.reverse();
    }

    if (!shouldShow && !_visibilityController.isAnimating) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: 220,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromRGBO(124, 58, 237, 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(debugInfo: debugInfo),
                const Divider(
                  height: 12,
                  thickness: 0.5,
                  color: Color.fromRGBO(255, 255, 255, 0.1),
                ),
                _Body(voiceState: voiceState, debugInfo: debugInfo),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.debugInfo});

  final VoiceDebugInfo debugInfo;

  @override
  Widget build(BuildContext context) {
    bool aiReady;
    try {
      aiReady = AudiflowAi.instance.isInitialized;
    } catch (_) {
      aiReady = false;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'VOICE DEBUG',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(124, 58, 237, 1),
          ),
        ),
        Text(
          'AI: ${aiReady ? "ready" : "not init"}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 9,
            color: aiReady
                ? const Color.fromRGBO(74, 222, 128, 1)
                : const Color.fromRGBO(148, 163, 184, 1),
          ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.voiceState, required this.debugInfo});

  final VoiceRecognitionState voiceState;
  final VoiceDebugInfo debugInfo;

  @override
  Widget build(BuildContext context) {
    final command = debugInfo.lastCommand;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DebugRow(
          label: 'State',
          value: _stateName(voiceState),
          valueColor: _stateColor(voiceState),
        ),
        _DebugRow(label: 'Transcript', value: _transcript(voiceState)),
        _DebugRow(
          label: 'Parser',
          value: _parserLabel(debugInfo.parserSource),
          valueColor: const Color.fromRGBO(56, 189, 248, 1),
        ),
        _DebugRow(label: 'Intent', value: command?.intent.name ?? '--'),
        _DebugRow(
          label: 'Confidence',
          value: command != null
              ? command.confidence.toStringAsFixed(2)
              : '--',
        ),
        _DebugRow(
          label: 'Params',
          value: _formatParams(command?.parameters),
          valueColor: const Color.fromRGBO(192, 132, 252, 1),
        ),
      ],
    );
  }

  static String _stateName(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => 'IDLE',
      VoiceListening() => 'LISTENING',
      VoiceProcessing() => 'PROCESSING',
      VoiceExecuting() => 'EXECUTING',
      VoiceSuccess() => 'SUCCESS',
      VoiceError() => 'ERROR',
      VoiceSettingsAutoApplied() => 'SETTINGS_APPLIED',
      VoiceSettingsDisambiguation() => 'DISAMBIGUATION',
      VoiceSettingsLowConfidence() => 'LOW_CONFIDENCE',
    };
  }

  static Color _stateColor(VoiceRecognitionState state) {
    return switch (state) {
      VoiceIdle() => const Color.fromRGBO(148, 163, 184, 1),
      VoiceListening() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceProcessing() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceExecuting() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceSuccess() => const Color.fromRGBO(74, 222, 128, 1),
      VoiceError() => const Color.fromRGBO(248, 113, 113, 1),
      VoiceSettingsAutoApplied() => const Color.fromRGBO(74, 222, 128, 1),
      VoiceSettingsDisambiguation() => const Color.fromRGBO(250, 204, 21, 1),
      VoiceSettingsLowConfidence() => const Color.fromRGBO(250, 204, 21, 1),
    };
  }

  static String _transcript(VoiceRecognitionState state) {
    return switch (state) {
      VoiceListening(:final partialTranscript) =>
        partialTranscript ?? '--',
      VoiceProcessing(:final transcription) => transcription,
      VoiceExecuting(:final command) => command.rawTranscription,
      _ => '--',
    };
  }

  static String _parserLabel(VoiceParserSource source) {
    return switch (source) {
      VoiceParserSource.none => '--',
      VoiceParserSource.simplePattern => 'simple (pattern)',
      VoiceParserSource.platformNlu => 'platform NLU',
      VoiceParserSource.onDeviceAi => 'on-device AI',
    };
  }

  static String _formatParams(Map<String, String>? params) {
    if (params == null || params.isEmpty) return '--';
    return params.entries.map((e) => '${e.key}: "${e.value}"').join(', ');
  }
}

class _DebugRow extends StatelessWidget {
  const _DebugRow({
    required this.label,
    required this.value,
    this.valueColor = const Color.fromRGBO(148, 163, 184, 1),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: Color.fromRGBO(250, 204, 21, 1),
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: valueColor,
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/voice_debug_panel_test.dart`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/voice/presentation/widgets/voice_debug_panel.dart \
       packages/audiflow_app/test/features/voice/presentation/widgets/voice_debug_panel_test.dart
git commit -m "feat(voice): add VoiceDebugPanel widget"
```

---

### Task 5: Integrate `VoiceDebugPanel` into `ScaffoldWithNavBar`

**Files:**
- Modify: `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`
- Modify: `packages/audiflow_app/test/routing/scaffold_with_nav_bar_test.dart`

- [ ] **Step 1: Write the failing tests**

Add to `packages/audiflow_app/test/routing/scaffold_with_nav_bar_test.dart`, inside the existing `main()` `group('ScaffoldWithNavBar', ...)`:

At the top of the file, add imports:

```dart
import 'package:audiflow_app/features/voice/presentation/widgets/voice_debug_panel.dart';
import 'package:audiflow_core/audiflow_core.dart';
```

Add a new fake orchestrator that returns a non-idle state:

```dart
class _ActiveVoiceOrchestrator extends VoiceCommandOrchestrator {
  @override
  VoiceRecognitionState build() =>
      const VoiceRecognitionState.listening(partialTranscript: 'test');
}

class _FakeDebugInfoNotifier extends VoiceDebugInfoNotifier {
  @override
  VoiceDebugInfo build() => const VoiceDebugInfo();
}
```

Update the `buildTestWidget` to accept optional parameters and add an `overrideWith` for the debug notifier:

Add new test group after the existing tests:

```dart
    group('voice debug panel', () {
      Widget buildActiveVoiceWidget() {
        return ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            voiceCommandOrchestratorProvider.overrideWith(
              () => _ActiveVoiceOrchestrator(),
            ),
            voiceDebugInfoNotifierProvider.overrideWith(
              () => _FakeDebugInfoNotifier(),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        );
      }

      testWidgets('shows debug panel on dev build with active voice', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        FlavorConfig.initialize(FlavorConfig.dev);

        await tester.pumpWidget(buildActiveVoiceWidget());
        await tester.pumpAndSettle();

        expect(find.byType(VoiceDebugPanel), findsOneWidget);
        expect(find.text('VOICE DEBUG'), findsOneWidget);
      });

      testWidgets('hides debug panel on prod build', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        FlavorConfig.initialize(FlavorConfig.prod);

        await tester.pumpWidget(buildActiveVoiceWidget());
        await tester.pumpAndSettle();

        expect(find.byType(VoiceDebugPanel), findsNothing);
      });
    });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/routing/scaffold_with_nav_bar_test.dart`
Expected: The new tests fail because `VoiceDebugPanel` is not in `ScaffoldWithNavBar` yet.

- [ ] **Step 3: Add debug panel to ScaffoldWithNavBar**

In `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`:

Add import at the top:

```dart
import '../features/voice/presentation/widgets/voice_debug_panel.dart';
```

In the `build` method of `ScaffoldWithNavBar`, find the `Stack` children list (around line 117-124). After the existing `VoiceCommandPanel` `Positioned`, add:

```dart
        if (voiceEnabled && FlavorConfig.current.flavor != Flavor.prod)
          Positioned(
            bottom: _debugPanelBottom(context, isTablet, isLandscape),
            left: 8,
            child: const VoiceDebugPanel(),
          ),
```

Add a static helper method to `ScaffoldWithNavBar`:

```dart
  static double _debugPanelBottom(
    BuildContext context,
    bool isTablet,
    bool isLandscape,
  ) {
    if (isTablet) return 8;
    // Phone: above the nav bar (80pt) + safe area bottom
    return 80 + MediaQuery.viewPaddingOf(context).bottom + 8;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/routing/scaffold_with_nav_bar_test.dart`
Expected: ALL PASS

- [ ] **Step 5: Run analyze on the whole app package**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues.

- [ ] **Step 6: Run all app tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart \
       packages/audiflow_app/test/routing/scaffold_with_nav_bar_test.dart
git commit -m "feat(voice): integrate VoiceDebugPanel into ScaffoldWithNavBar"
```

---

### Task 6: Final verification

- [ ] **Step 1: Run full test suite**

Run: `cd /Users/tohru/Documents/src/ghq/github.com/audiflow/audiflow.fix-voice && melos run test`
Expected: ALL PASS

- [ ] **Step 2: Run analyze across all packages**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 3: Verify no regressions in existing voice tests**

Run: `cd packages/audiflow_app && flutter test test/features/voice/`
Expected: ALL PASS

- [ ] **Step 4: Commit any formatting or codegen fixes if needed**

Only if previous steps required minor fixups.
