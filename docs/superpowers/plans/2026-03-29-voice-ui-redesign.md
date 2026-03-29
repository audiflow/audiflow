# Voice UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the full-screen voice overlay + center-docked nav button with a compact floating panel anchored to an app bar mic trigger, using CustomPainter waveform visualization.

**Architecture:** Three new widgets (WaveformPainter, VoiceTriggerButton, VoiceCommandPanel) replace two existing ones (VoiceListeningOverlay, _VoiceNavButton). Domain layer unchanged. Integration via scaffold_with_nav_bar.dart and 4 tab screen app bars.

**Tech Stack:** Flutter CustomPainter, AnimationController, BackdropFilter, Riverpod, Material Symbols Icons

**Spec:** `docs/superpowers/specs/2026-03-29-voice-ui-redesign.md`

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `packages/audiflow_app/lib/features/voice/presentation/widgets/waveform_painter.dart` | Create | CustomPainter for animated frequency bars |
| `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_trigger_button.dart` | Create | App bar mic icon with state-aware styling |
| `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_command_panel.dart` | Create | Compact floating panel with all voice states |
| `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart` | Modify | Remove _VoiceNavButton, remove center slot, replace overlay with panel |
| `packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart` | Modify | Add VoiceTriggerButton to AppBar.actions |
| `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart` | Modify | Add VoiceTriggerButton to AppBar.actions |
| `packages/audiflow_app/lib/features/queue/presentation/screens/queue_screen.dart` | Modify | Add VoiceTriggerButton to AppBar.actions |
| `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart` | Modify | Add VoiceTriggerButton to AppBar.actions |
| `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_command_fab.dart` | Delete | Unused, replaced |
| `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_listening_overlay.dart` | Delete | Replaced by voice_command_panel.dart |
| `packages/audiflow_app/test/features/voice/presentation/widgets/waveform_painter_test.dart` | Create | Unit tests for painter |
| `packages/audiflow_app/test/features/voice/presentation/widgets/voice_trigger_button_test.dart` | Create | Widget tests for trigger button |
| `packages/audiflow_app/test/features/voice/presentation/widgets/voice_command_panel_test.dart` | Create | Widget tests for panel |

---

### Task 1: WaveformPainter

**Files:**
- Create: `packages/audiflow_app/lib/features/voice/presentation/widgets/waveform_painter.dart`
- Test: `packages/audiflow_app/test/features/voice/presentation/widgets/waveform_painter_test.dart`

- [ ] **Step 1: Write the failing test for WaveformPainter**

Create the test file. These tests verify the painter paints correctly and that the animation mode enum works.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_app/features/voice/presentation/widgets/waveform_painter.dart';

void main() {
  group('WaveformAnimationMode', () {
    test('listening has 800ms duration', () {
      check(WaveformAnimationMode.listening.duration)
          .equals(const Duration(milliseconds: 800));
    });

    test('processing has 2000ms duration', () {
      check(WaveformAnimationMode.processing.duration)
          .equals(const Duration(milliseconds: 2000));
    });
  });

  group('WaveformPainter', () {
    test('shouldRepaint returns true for different animation values', () {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 800),
      );

      final painter1 = WaveformPainter(
        animation: controller,
        mode: WaveformAnimationMode.listening,
      );
      final painter2 = WaveformPainter(
        animation: controller,
        mode: WaveformAnimationMode.processing,
      );

      check(painter1.shouldRepaint(painter2)).isTrue();

      controller.dispose();
    });

    test('shouldRepaint returns false for same mode', () {
      final controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 800),
      );

      final painter = WaveformPainter(
        animation: controller,
        mode: WaveformAnimationMode.listening,
      );

      check(painter.shouldRepaint(painter)).isFalse();

      controller.dispose();
    });
  });

  group('WaveformWidget', () {
    testWidgets('renders CustomPaint with correct size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 48,
                child: WaveformWidget(mode: WaveformAnimationMode.listening),
              ),
            ),
          ),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      check(customPaint.painter).isNotNull();
    });

    testWidgets('disposes animation controller on unmount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveformWidget(mode: WaveformAnimationMode.listening),
          ),
        ),
      );

      // Replace with empty widget — should not throw
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/waveform_painter_test.dart`
Expected: FAIL — `waveform_painter.dart` does not exist.

- [ ] **Step 3: Implement WaveformPainter**

Create `packages/audiflow_app/lib/features/voice/presentation/widgets/waveform_painter.dart`:

```dart
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Animation mode controlling speed, amplitude, and color of waveform bars.
enum WaveformAnimationMode {
  listening(
    duration: Duration(milliseconds: 800),
    minHeight: 4.0,
    maxHeight: 40.0,
    topColor: Color(0xFFFFC107),
    bottomColor: Color(0xFF0D47A1),
  ),
  processing(
    duration: Duration(milliseconds: 2000),
    minHeight: 4.0,
    maxHeight: 16.0,
    topColor: Color(0xFF1976D2),
    bottomColor: Color(0xFF0D47A1),
  ),
  idle(
    duration: Duration(milliseconds: 800),
    minHeight: 4.0,
    maxHeight: 4.0,
    topColor: Color(0xFF1976D2),
    bottomColor: Color(0xFF0D47A1),
  );

  const WaveformAnimationMode({
    required this.duration,
    required this.minHeight,
    required this.maxHeight,
    required this.topColor,
    required this.bottomColor,
  });

  final Duration duration;
  final double minHeight;
  final double maxHeight;
  final Color topColor;
  final Color bottomColor;
}

/// CustomPainter that renders animated audio frequency bars.
///
/// Uses sinusoidal height animation with per-bar phase offset for organic
/// wave motion. Each bar has a vertical gradient from [bottomColor] to
/// [topColor] defined by the current [WaveformAnimationMode].
class WaveformPainter extends CustomPainter {
  WaveformPainter({
    required this.animation,
    required this.mode,
  }) : super(repaint: animation);

  static const _barCount = 12;
  static const _barWidth = 3.0;
  static const _barSpacing = 3.0;
  static const _phaseOffset = 0.5;

  final Animation<double> animation;
  final WaveformAnimationMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    final totalWidth =
        _barCount * _barWidth + (_barCount - 1) * _barSpacing;
    final startX = (size.width - totalWidth) / 2;
    final centerY = size.height / 2;
    final amplitude = mode.maxHeight - mode.minHeight;

    for (var i = 0; i < _barCount; i++) {
      final phase = i * _phaseOffset;
      final sineValue = math.sin(animation.value * 2 * math.pi + phase);
      final barHeight = mode.minHeight + amplitude * ((sineValue + 1) / 2);

      final x = startX + i * (_barWidth + _barSpacing);
      final top = centerY - barHeight / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, _barWidth, barHeight),
        const Radius.circular(1.5),
      );

      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, top + barHeight),
          Offset(x, top),
          [mode.bottomColor, mode.topColor],
        );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      mode != oldDelegate.mode;
}

/// Stateful widget that manages the AnimationController for WaveformPainter.
class WaveformWidget extends StatefulWidget {
  const WaveformWidget({required this.mode, super.key});

  final WaveformAnimationMode mode;

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.mode.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _controller.duration = widget.mode.duration;
      if (widget.mode == WaveformAnimationMode.idle) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaveformPainter(
        animation: _controller,
        mode: widget.mode,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/waveform_painter_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/voice/presentation/widgets/waveform_painter.dart packages/audiflow_app/test/features/voice/presentation/widgets/waveform_painter_test.dart
git commit -m "feat(voice): add CustomPainter waveform visualization"
```

---

### Task 2: VoiceTriggerButton

**Files:**
- Create: `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_trigger_button.dart`
- Test: `packages/audiflow_app/test/features/voice/presentation/widgets/voice_trigger_button_test.dart`

- [ ] **Step 1: Write the failing test for VoiceTriggerButton**

Create the test file. Tests verify icon, color, and tap behavior per voice state. Uses a `ProviderScope` with overridden `voiceCommandOrchestratorProvider`.

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:audiflow_app/features/voice/presentation/widgets/voice_trigger_button.dart';

/// Fake orchestrator that exposes a settable state and records method calls.
class FakeVoiceCommandOrchestrator extends VoiceCommandOrchestrator {
  VoiceRecognitionState _state = const VoiceIdle();
  bool startCalled = false;
  bool cancelCalled = false;
  bool resetCalled = false;

  @override
  VoiceRecognitionState build() => _state;

  void setState(VoiceRecognitionState newState) {
    _state = newState;
    ref.notifySelf();
  }

  @override
  Future<void> startVoiceCommand() async {
    startCalled = true;
  }

  @override
  Future<void> cancelVoiceCommand() async {
    cancelCalled = true;
  }

  @override
  void resetToIdle() {
    resetCalled = true;
  }
}

Widget _buildTestWidget({
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(
        appBar: AppBar(actions: [VoiceTriggerButton()]),
        body: SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  group('VoiceTriggerButton', () {
    testWidgets('shows mic outline icon in idle state', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(
              () => FakeVoiceCommandOrchestrator(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.icon).equals(Symbols.mic);
      check(icon.fill).equals(0.0);
    });

    testWidgets('tap in idle starts voice command', (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(VoiceTriggerButton));
      await tester.pump();

      check(fake.startCalled).isTrue();
    });

    testWidgets('tap while listening cancels', (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      fake.setState(const VoiceListening());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(VoiceTriggerButton));
      await tester.pump();

      check(fake.cancelCalled).isTrue();
    });

    testWidgets('disabled during processing', (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      fake.setState(const VoiceProcessing(transcription: 'test'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(VoiceTriggerButton));
      await tester.pump();

      check(fake.startCalled).isFalse();
      check(fake.cancelCalled).isFalse();
    });
  });
}
```

> **Note:** The `FakeVoiceCommandOrchestrator` above is a simplified sketch. The implementer must check the actual `VoiceCommandOrchestrator` base class signature (it is a `@Riverpod(keepAlive: true)` notifier in `audiflow_domain`) and adjust the fake accordingly — override `build()` to return the state, and provide stubs for methods used by the trigger button (`startVoiceCommand`, `cancelVoiceCommand`, `resetToIdle`). If the notifier's constructor requires injected dependencies, override the provider with `.overrideWith(...)` using the appropriate signature.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/voice_trigger_button_test.dart`
Expected: FAIL — `voice_trigger_button.dart` does not exist.

- [ ] **Step 3: Implement VoiceTriggerButton**

Create `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_trigger_button.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Inline app bar button for initiating voice commands.
///
/// Replaces the center-docked nav button. Shows a mic icon with state-aware
/// background tint, color, and glow. Placed in [AppBar.actions].
class VoiceTriggerButton extends ConsumerStatefulWidget {
  const VoiceTriggerButton({super.key});

  @override
  ConsumerState<VoiceTriggerButton> createState() => _VoiceTriggerButtonState();
}

class _VoiceTriggerButtonState extends ConsumerState<VoiceTriggerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final isListening = voiceState is VoiceListening;
    final isProcessing =
        voiceState is VoiceProcessing || voiceState is VoiceExecuting;
    final isSettingsBusy = voiceState is VoiceSettingsDisambiguation ||
        voiceState is VoiceSettingsLowConfidence ||
        voiceState is VoiceSettingsAutoApplied;
    final isBusy = isProcessing || isSettingsBusy;

    // Control pulse for processing state
    if (isProcessing) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    final mapping = _stateMapping(colorScheme, voiceState);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          final opacity = isProcessing ? _opacityAnimation.value : 1.0;

          return Opacity(
            opacity: opacity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: mapping.background,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isListening
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: isBusy ? null : () => _handleTap(voiceState),
                  child: Center(
                    child: Icon(
                      Symbols.mic,
                      fill: mapping.iconFill,
                      size: 20,
                      color: mapping.iconColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(VoiceRecognitionState state) {
    final orchestrator = ref.read(voiceCommandOrchestratorProvider.notifier);

    switch (state) {
      case VoiceIdle():
        orchestrator.startVoiceCommand();
      case VoiceListening():
        orchestrator.cancelVoiceCommand();
      case VoiceSuccess():
      case VoiceError():
        orchestrator.resetToIdle();
      default:
        break;
    }
  }

  _StateMapping _stateMapping(
    ColorScheme colorScheme,
    VoiceRecognitionState state,
  ) {
    const accentColor = Color(0xFFFFC107);

    return switch (state) {
      VoiceIdle() => _StateMapping(
          background: colorScheme.primary.withValues(alpha: 0.1),
          iconColor: colorScheme.primary,
          iconFill: 0,
        ),
      VoiceListening() => _StateMapping(
          background: colorScheme.primary.withValues(alpha: 0.25),
          iconColor: accentColor,
          iconFill: 1,
        ),
      VoiceProcessing() => _StateMapping(
          background: colorScheme.primary.withValues(alpha: 0.15),
          iconColor: colorScheme.primary,
          iconFill: 0,
        ),
      VoiceExecuting() => _StateMapping(
          background: colorScheme.primary.withValues(alpha: 0.15),
          iconColor: colorScheme.primary,
          iconFill: 0,
        ),
      VoiceSuccess() => _StateMapping(
          background: colorScheme.tertiary.withValues(alpha: 0.15),
          iconColor: colorScheme.tertiary,
          iconFill: 0,
        ),
      VoiceError() => _StateMapping(
          background: colorScheme.error.withValues(alpha: 0.15),
          iconColor: colorScheme.error,
          iconFill: 0,
        ),
      VoiceSettingsAutoApplied() => _StateMapping(
          background: colorScheme.secondary.withValues(alpha: 0.15),
          iconColor: colorScheme.secondary,
          iconFill: 0,
        ),
      VoiceSettingsDisambiguation() => _StateMapping(
          background: colorScheme.secondary.withValues(alpha: 0.15),
          iconColor: colorScheme.secondary,
          iconFill: 0,
        ),
      VoiceSettingsLowConfidence() => _StateMapping(
          background: colorScheme.secondary.withValues(alpha: 0.15),
          iconColor: colorScheme.secondary,
          iconFill: 0,
        ),
    };
  }
}

class _StateMapping {
  const _StateMapping({
    required this.background,
    required this.iconColor,
    required this.iconFill,
  });

  final Color background;
  final Color iconColor;
  final double iconFill;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/voice_trigger_button_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/voice/presentation/widgets/voice_trigger_button.dart packages/audiflow_app/test/features/voice/presentation/widgets/voice_trigger_button_test.dart
git commit -m "feat(voice): add inline app bar voice trigger button"
```

---

### Task 3: VoiceCommandPanel

**Files:**
- Create: `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_command_panel.dart`
- Test: `packages/audiflow_app/test/features/voice/presentation/widgets/voice_command_panel_test.dart`

- [ ] **Step 1: Write the failing test for VoiceCommandPanel**

Create the test file. Tests verify: hidden when idle, fixed 240pt width, content per state, dismiss on tap.

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';

import 'package:audiflow_app/features/voice/presentation/widgets/voice_command_panel.dart';

// Reuse or adapt the FakeVoiceCommandOrchestrator from Task 2 tests.

Widget _buildTestWidget({
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      // Provide localizations delegate for AppLocalizations
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Stack(
          children: [
            SizedBox.expand(),
            Positioned(top: 56, right: 8, child: VoiceCommandPanel()),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('VoiceCommandPanel', () {
    testWidgets('hidden when idle', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(
              () => FakeVoiceCommandOrchestrator(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Panel should render SizedBox.shrink — nothing visible
      check(find.byType(VoiceCommandPanel)).findsOneWidget();
      // No backdrop filter when hidden
      check(find.byType(BackdropFilter)).findsNothing();
    });

    testWidgets('shows waveform and status text when listening',
        (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      fake.setState(const VoiceListening(partialTranscript: 'play the'));
      await tester.pumpAndSettle();

      check(find.text('play the')).findsOneWidget();
    });

    testWidgets('has fixed 240pt width', (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      fake.setState(const VoiceListening());
      await tester.pumpAndSettle();

      final panelFinder = find.byType(VoiceCommandPanel);
      final panelBox =
          tester.renderObject<RenderBox>(panelFinder);
      // The panel's SizedBox constraint should be 240
      // Find the constraining SizedBox inside the panel
      final sizedBoxFinder = find.descendant(
        of: panelFinder,
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 240,
        ),
      );
      check(sizedBoxFinder).findsOneWidget();
    });

    testWidgets('shows cancel button when listening', (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      fake.setState(const VoiceListening());
      await tester.pumpAndSettle();

      // Cancel text should appear (localized)
      check(find.byType(TextButton)).findsOneWidget();
    });

    testWidgets('shows success icon and auto-dismiss text', (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      fake.setState(const VoiceSuccess(message: 'Playing'));
      await tester.pumpAndSettle();

      check(find.text('Playing')).findsOneWidget();
    });

    testWidgets('shows disambiguation candidates', (tester) async {
      final fake = FakeVoiceCommandOrchestrator();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            voiceCommandOrchestratorProvider.overrideWith(() => fake),
          ],
        ),
      );
      await tester.pumpAndSettle();

      fake.setState(
        VoiceSettingsDisambiguation(
          candidates: [
            SettingsResolutionCandidate(
              key: 'playbackSpeed',
              displayNameKey: 'playbackDefaultSpeed',
              newValue: '1.5',
              confidence: 0.92,
            ),
            SettingsResolutionCandidate(
              key: 'skipForwardSeconds',
              displayNameKey: 'playbackSkipForward',
              newValue: '15',
              confidence: 0.64,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should show both candidates
      check(find.text('1.5')).findsOneWidget();
      check(find.text('15')).findsOneWidget();
    });
  });
}
```

> **Note:** The test above is a structural sketch. The implementer must adjust for the actual `SettingsResolutionCandidate` constructor, l10n delegate setup, and fake orchestrator. Text matchers depend on how the panel formats values — adjust after implementing the panel.

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/voice_command_panel_test.dart`
Expected: FAIL — `voice_command_panel.dart` does not exist.

- [ ] **Step 3: Implement VoiceCommandPanel**

Create `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_command_panel.dart`.

This is the largest widget. Key implementation details:
- Fixed width `SizedBox(width: 240)` wrapping all content
- `AnimatedSwitcher` for crossfading between state content
- `AnimatedSize` wrapping the `AnimatedSwitcher` for smooth height transitions
- `FadeTransition` + `ScaleTransition` for panel appear/disappear
- `BackdropFilter` with `ImageFilter.blur(sigmaX: 20, sigmaY: 20)` for glassmorphic background
- `ClipRRect` around BackdropFilter (required for blur to clip correctly)
- Multi-layered `BoxShadow` on the outer `DecoratedBox`
- Content builders per state matching the spec exactly:
  - VoiceListening: `WaveformWidget(mode: .listening)` + status + partial transcript + cancel
  - VoiceProcessing: `WaveformWidget(mode: .processing)` + status + full transcript
  - VoiceExecuting: same as Processing with intent name
  - VoiceSuccess: check icon + message (tap to dismiss)
  - VoiceError: error icon + message + hint (tap to dismiss)
  - VoiceSettingsAutoApplied: check icon + old→new + undo button
  - VoiceSettingsDisambiguation: header + candidate list + cancel
  - VoiceSettingsLowConfidence: help icon + old→new? + cancel/confirm row
- Max height constraint: `ConstrainedBox(maxHeight: MediaQuery.sizeOf(context).height * 0.7)` with `SingleChildScrollView` inside for overflow

The implementer should reference the existing `VoiceListeningOverlay` for:
- `_resolveDisplayName()` method — copy it to the new panel
- `_formatIntent()` method — copy it to the new panel
- l10n keys used: `l10n.voiceListening`, `l10n.voiceProcessing`, `l10n.voiceExecuting(...)`, `l10n.voiceSettingsWhichSetting`, `l10n.undo`, `l10n.cancel`, `l10n.confirm`
- The `VoiceCommandController` import for settings actions (undo, confirm, select candidate)

```dart
import 'dart:ui';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/voice_command_controller.dart';
import 'waveform_painter.dart';

// Full implementation here — see spec for all state content.
// Key structural skeleton below:

class VoiceCommandPanel extends ConsumerStatefulWidget {
  const VoiceCommandPanel({super.key});

  @override
  ConsumerState<VoiceCommandPanel> createState() => _VoiceCommandPanelState();
}

class _VoiceCommandPanelState extends ConsumerState<VoiceCommandPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _appearController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCommandOrchestratorProvider);
    final shouldShow = voiceState is! VoiceIdle;

    // Drive appear/disappear animation
    if (shouldShow && !_isVisible) {
      _isVisible = true;
      _appearController.forward();
    } else if (!shouldShow && _isVisible) {
      _isVisible = false;
      _appearController.reverse();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.topRight,
        child: SizedBox(
          width: 240,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _buildPanel(context, voiceState),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, VoiceRecognitionState state) {
    if (state is VoiceIdle) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 8),
                  blurRadius: 32,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildContent(context, state),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VoiceRecognitionState state) {
    // Exhaustive switch — build content per state.
    // Each branch returns a Column with KeyedSubtree for AnimatedSwitcher.
    return switch (state) {
      VoiceIdle() => const SizedBox.shrink(),
      VoiceListening() => _buildListeningContent(context, state),
      VoiceProcessing() => _buildProcessingContent(context, state),
      VoiceExecuting() => _buildExecutingContent(context, state),
      VoiceSuccess() => _buildSuccessContent(context, state),
      VoiceError() => _buildErrorContent(context, state),
      VoiceSettingsAutoApplied() =>
        _buildSettingsAutoAppliedContent(context, state),
      VoiceSettingsDisambiguation() =>
        _buildSettingsDisambiguationContent(context, state),
      VoiceSettingsLowConfidence() =>
        _buildSettingsLowConfidenceContent(context, state),
    };
    // Each builder should:
    // 1. Wrap in KeyedSubtree(key: ValueKey('stateName')) for AnimatedSwitcher
    // 2. Use compact sizing (bodySmall/bodyMedium text styles)
    // 3. Reference l10n for all strings
    // 4. Port _resolveDisplayName and _formatIntent from VoiceListeningOverlay
  }

  // ... individual _build*Content methods ported from VoiceListeningOverlay
  // with compact sizing adapted for 240pt fixed width
}
```

The implementer should build out each `_build*Content` method by porting the logic from `voice_listening_overlay.dart` lines 61-409, adjusting sizing for the compact 240pt panel. Key differences from the overlay:
- No `Spacer()` widgets — use `SizedBox(height: N)` for fixed spacing
- Smaller text styles: `bodyMedium` → `bodySmall` for secondary text
- Disambiguation candidates: no `ListView` — use `Column` with candidates directly (panel height adapts)
- Cancel/Confirm buttons: use `TextButton.icon` with compact `visualDensity`

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/features/voice/presentation/widgets/voice_command_panel_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/voice/presentation/widgets/voice_command_panel.dart packages/audiflow_app/test/features/voice/presentation/widgets/voice_command_panel_test.dart
git commit -m "feat(voice): add compact floating voice command panel"
```

---

### Task 4: Integrate into scaffold_with_nav_bar.dart

**Files:**
- Modify: `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart`

This task modifies the shell scaffold to:
1. Remove `_VoiceNavButton` private class (lines 288-446)
2. Remove center voice button slot from `_CustomNavBar` (lines 199-213)
3. Replace `VoiceListeningOverlay` with `VoiceCommandPanel` in the Stack
4. Replace `_VoiceNavButton()` with `VoiceTriggerButton()` in tablet shells

- [ ] **Step 1: Remove the VoiceListeningOverlay import and replace with new imports**

In `scaffold_with_nav_bar.dart`, replace:

```dart
import '../features/voice/presentation/widgets/voice_listening_overlay.dart';
```

with:

```dart
import '../features/voice/presentation/widgets/voice_command_panel.dart';
import '../features/voice/presentation/widgets/voice_trigger_button.dart';
```

- [ ] **Step 2: Replace overlay with panel in ScaffoldWithNavBar.build()**

Replace:

```dart
    return Stack(
      children: [shell, if (showOverlay) const VoiceListeningOverlay()],
    );
```

with:

```dart
    return Stack(
      children: [
        shell,
        const Positioned(
          top: 0,
          right: 8,
          child: SafeArea(child: VoiceCommandPanel()),
        ),
      ],
    );
```

Also remove the `showOverlay` variable since the panel handles its own visibility internally:

Remove:
```dart
    final showOverlay = voiceState is! VoiceIdle;
```

> **Note:** Keep `voiceState` if still used elsewhere in `build()`. If the only consumer was `showOverlay`, the `ref.watch(voiceCommandOrchestratorProvider)` line can also be removed from this widget — the panel does its own watching.

- [ ] **Step 3: Remove center voice button from _CustomNavBar**

In `_CustomNavBar.build()`, remove the center placeholder and voice button. Replace the Stack+Row with a simple Row:

Remove:
```dart
                  // Center placeholder so the voice button has visual space
                  const SizedBox(width: 72),
```

Remove from the Stack:
```dart
              // Voice button raised above bar
              Positioned(top: -8, child: const _VoiceNavButton()),
```

And simplify the `Stack` to just the `Row` (remove `Stack` wrapper, keep only the `Row`).

- [ ] **Step 4: Replace _VoiceNavButton in tablet portrait shell**

In `_TabletPortraitShell.build()`, replace:

```dart
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: _VoiceNavButton()),
        ],
```

with:

```dart
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: VoiceTriggerButton(),
          ),
        ],
```

- [ ] **Step 5: Replace _VoiceNavButton in tablet landscape shell**

In `_TabletLandscapeShell.build()`, replace:

```dart
            leading: const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: _VoiceNavButton(),
            ),
```

with:

```dart
            leading: const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: VoiceTriggerButton(),
            ),
```

- [ ] **Step 6: Delete the _VoiceNavButton class**

Remove the entire `_VoiceNavButton` class and its state class `_VoiceNavButtonState` (lines 288-446). This is approximately 160 lines of private code that is now replaced by `VoiceTriggerButton`.

- [ ] **Step 7: Run analyze to verify no errors**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors. There may be warnings about unused imports — fix them.

- [ ] **Step 8: Commit**

```bash
git add packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart
git commit -m "refactor(voice): replace overlay and nav button with panel and trigger"
```

---

### Task 5: Add VoiceTriggerButton to tab screen app bars

**Files:**
- Modify: `packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart`
- Modify: `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart`
- Modify: `packages/audiflow_app/lib/features/queue/presentation/screens/queue_screen.dart`
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart`

Each screen gets `VoiceTriggerButton()` added to its `AppBar.actions`. This ensures the mic icon appears on phone layout where there is no shell-level app bar.

- [ ] **Step 1: Add import and action to search_screen.dart**

Add import:
```dart
import '../../../voice/presentation/widgets/voice_trigger_button.dart';
```

Change:
```dart
        appBar: AppBar(title: Text(l10n.searchTitle)),
```
to:
```dart
        appBar: AppBar(
          title: Text(l10n.searchTitle),
          actions: const [VoiceTriggerButton()],
        ),
```

- [ ] **Step 2: Add import and action to library_screen.dart**

Add import:
```dart
import '../../../voice/presentation/widgets/voice_trigger_button.dart';
```

Change:
```dart
      appBar: AppBar(title: Text(l10n.libraryTitle)),
```
to:
```dart
      appBar: AppBar(
        title: Text(l10n.libraryTitle),
        actions: const [VoiceTriggerButton()],
      ),
```

- [ ] **Step 3: Add VoiceTriggerButton to queue_screen.dart actions**

Add import:
```dart
import '../../../voice/presentation/widgets/voice_trigger_button.dart';
```

Change (add to existing actions list):
```dart
        actions: [
          queueAsync.when(
            data: (queue) => ClearQueueButton(
              enabled: queue.hasItems,
              onClear: () =>
                  ref.read(queueControllerProvider.notifier).clearQueue(),
            ),
            loading: () =>
                const ClearQueueButton(enabled: false, onClear: _noOp),
            error: (_, _) =>
                const ClearQueueButton(enabled: false, onClear: _noOp),
          ),
        ],
```
to:
```dart
        actions: [
          queueAsync.when(
            data: (queue) => ClearQueueButton(
              enabled: queue.hasItems,
              onClear: () =>
                  ref.read(queueControllerProvider.notifier).clearQueue(),
            ),
            loading: () =>
                const ClearQueueButton(enabled: false, onClear: _noOp),
            error: (_, _) =>
                const ClearQueueButton(enabled: false, onClear: _noOp),
          ),
          const VoiceTriggerButton(),
        ],
```

- [ ] **Step 4: Add import and action to settings_screen.dart**

Add import:
```dart
import '../../../voice/presentation/widgets/voice_trigger_button.dart';
```

Change:
```dart
      appBar: AppBar(title: Text(l10n.settingsTitle)),
```
to:
```dart
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: const [VoiceTriggerButton()],
      ),
```

> **Note:** `SettingsScreen` is a `StatelessWidget`, not a `ConsumerWidget`. Adding `VoiceTriggerButton` (which is a `ConsumerStatefulWidget`) is fine — it manages its own Riverpod subscription internally. The `SettingsScreen` itself does not need to become a `ConsumerWidget`.

- [ ] **Step 5: Run analyze**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart packages/audiflow_app/lib/features/queue/presentation/screens/queue_screen.dart packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart
git commit -m "feat(voice): add voice trigger button to tab screen app bars"
```

---

### Task 6: Delete old files and clean up

**Files:**
- Delete: `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_command_fab.dart`
- Delete: `packages/audiflow_app/lib/features/voice/presentation/widgets/voice_listening_overlay.dart`

- [ ] **Step 1: Delete voice_command_fab.dart**

```bash
git rm packages/audiflow_app/lib/features/voice/presentation/widgets/voice_command_fab.dart
```

- [ ] **Step 2: Delete voice_listening_overlay.dart**

```bash
git rm packages/audiflow_app/lib/features/voice/presentation/widgets/voice_listening_overlay.dart
```

- [ ] **Step 3: Search for any remaining references**

Run: `grep -r "VoiceCommandFab\|VoiceListeningOverlay\|voice_command_fab\|voice_listening_overlay" packages/audiflow_app/lib/`

Expected: No matches. If any found, update those imports/references.

- [ ] **Step 4: Run full analyze and test**

Run: `cd packages/audiflow_app && flutter analyze && flutter test`
Expected: All passing, zero issues.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore(voice): remove old FAB and overlay widgets"
```

---

### Task 7: Final verification

- [ ] **Step 1: Run full test suite**

Run: `melos run test`
Expected: All tests pass across all packages.

- [ ] **Step 2: Run analyze across all packages**

Run: `flutter analyze`
Expected: Zero issues.

- [ ] **Step 3: Verify domain tests still pass unmodified**

Run: `cd packages/audiflow_domain && flutter test`
Expected: All domain tests pass — no domain code was changed.

- [ ] **Step 4: Manual spot check (if device available)**

Build and run on device/simulator. Verify:
1. Mic icon appears in app bar on all 4 tab screens
2. Tapping mic opens the floating panel with waveform animation
3. Panel appears at top-right, below the app bar
4. Panel has fixed 240pt width
5. Speaking shows partial transcript
6. Success/error states display correctly and auto-dismiss
7. Panel dismiss animation works (fade + scale)
8. Tablet portrait: mic in app bar actions
9. Tablet landscape: mic in nav rail leading area
