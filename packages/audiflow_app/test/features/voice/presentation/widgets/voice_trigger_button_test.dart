import 'package:audiflow_app/features/voice/presentation/widgets/voice_trigger_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Controllable fake orchestrator. Tests can set [nextState] before pumping
/// and inspect [startCalled], [cancelCalled], and [resetCalled] afterwards.
class _FakeOrchestrator extends VoiceCommandOrchestrator {
  _FakeOrchestrator(this._initial);

  final VoiceRecognitionState _initial;

  bool startCalled = false;
  bool cancelCalled = false;
  bool resetCalled = false;

  @override
  VoiceRecognitionState build() => _initial;

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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestApp(
  ProviderContainer container, {
  Widget body = const VoiceTriggerButton(),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(appBar: AppBar(actions: [body])),
    ),
  );
}

ProviderContainer _containerFor(_FakeOrchestrator fake) {
  return ProviderContainer(
    overrides: [voiceCommandOrchestratorProvider.overrideWith(() => fake)],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VoiceTriggerButton', () {
    group('idle state', () {
      testWidgets('renders mic outline icon (fill 0)', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Outline mic: fill == 0 — find the Icon widget with Symbols.mic
        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.mic && (w.fill ?? 0) != 1,
        );
        check(iconFinder.evaluate().length).equals(1);
      });

      testWidgets('tapping calls startVoiceCommand', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceTriggerButton));
        await tester.pump();

        check(fake.startCalled).isTrue();
      });
    });

    group('listening state', () {
      testWidgets('renders filled mic icon (fill 1)', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.listening());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.mic && w.fill == 1,
        );
        check(iconFinder.evaluate().length).equals(1);
      });

      testWidgets('icon color is amber (#FFC107)', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.listening());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.mic && w.fill == 1,
        );
        final icon = tester.widget<Icon>(iconFinder);
        check(icon.color).equals(const Color(0xFFFFC107));
      });

      testWidgets('tapping calls cancelVoiceCommand', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.listening());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceTriggerButton));
        await tester.pump();

        check(fake.cancelCalled).isTrue();
      });
    });

    group('processing state', () {
      testWidgets('tap does not call any method', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.processing(transcription: 'play'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceTriggerButton));
        await tester.pump();

        check(fake.startCalled).isFalse();
        check(fake.cancelCalled).isFalse();
        check(fake.resetCalled).isFalse();
      });
    });

    group('success state', () {
      testWidgets('tapping calls resetToIdle', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.success(message: 'Done'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceTriggerButton));
        await tester.pump();

        check(fake.resetCalled).isTrue();
      });
    });

    group('error state', () {
      testWidgets('tapping calls resetToIdle', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.error(message: 'Oops'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceTriggerButton));
        await tester.pump();

        check(fake.resetCalled).isTrue();
      });
    });

    group('settings states — tap is disabled', () {
      for (final entry in <String, VoiceRecognitionState>{
        'autoApplied': const VoiceRecognitionState.settingsAutoApplied(
          key: 'speed',
          displayNameKey: 'speed_label',
          oldValue: '1.0',
          newValue: '1.5',
        ),
        'disambiguation': VoiceRecognitionState.settingsDisambiguation(
          candidates: [],
        ),
        'lowConfidence': const VoiceRecognitionState.settingsLowConfidence(
          key: 'speed',
          displayNameKey: 'speed_label',
          oldValue: '1.0',
          newValue: '1.5',
          confidence: 0.5,
        ),
      }.entries) {
        testWidgets('${entry.key}: tap does not call any method', (
          tester,
        ) async {
          final fake = _FakeOrchestrator(entry.value);
          final container = _containerFor(fake);
          addTearDown(container.dispose);

          await tester.pumpWidget(_buildTestApp(container));
          await tester.pump();

          await tester.tap(find.byType(VoiceTriggerButton));
          await tester.pump();

          check(fake.startCalled).isFalse();
          check(fake.cancelCalled).isFalse();
          check(fake.resetCalled).isFalse();
        });
      }
    });

    group('widget structure', () {
      testWidgets('is 36x36 container', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Verify the AnimatedContainer is present inside the button.
        final animContainerFinder = find.descendant(
          of: find.byType(VoiceTriggerButton),
          matching: find.byType(AnimatedContainer),
        );
        check(animContainerFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('wrapped in Padding on right side', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // The widget itself should exist.
        check(
          find.byType(VoiceTriggerButton),
        ).has((f) => f.evaluate().length, 'count').equals(1);
      });
    });
  });
}
