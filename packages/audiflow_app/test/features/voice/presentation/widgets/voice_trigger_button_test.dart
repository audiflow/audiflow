import 'package:audiflow_app/features/voice/presentation/widgets/voice_trigger_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Controllable fake orchestrator. Tests can set [nextState] before pumping
/// and inspect call flags afterwards.
class _FakeOrchestrator extends VoiceCommandOrchestrator {
  _FakeOrchestrator(this._initial);

  final VoiceRecognitionState _initial;

  bool startCalled = false;
  bool stopCalled = false;
  bool cancelCalled = false;
  bool resetCalled = false;

  @override
  VoiceRecognitionState build() => _initial;

  @override
  Future<void> startVoiceCommand() async {
    startCalled = true;
  }

  @override
  Future<void> stopVoiceCommand() async {
    stopCalled = true;
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

void main() {
  group('VoiceTriggerButton', () {
    group('idle state', () {
      testWidgets('renders mic outline icon (fill 0)', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.mic && (w.fill ?? 0) != 1,
        );
        check(iconFinder.evaluate().length).equals(1);
      });

      testWidgets('hold-to-talk: long-press start calls startVoiceCommand', (
        tester,
      ) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.longPress(find.byType(VoiceTriggerButton));
        await tester.pump();

        // longPress fires both start and end; verify start was hit.
        check(fake.startCalled).isTrue();
      });

      testWidgets('hold-to-talk: long-press release calls stopVoiceCommand', (
        tester,
      ) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.longPress(find.byType(VoiceTriggerButton));
        await tester.pump(const Duration(milliseconds: 100));

        check(fake.stopCalled).isTrue();
      });

      testWidgets('short tap does not start voice command', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceTriggerButton));
        await tester.pump();

        check(fake.startCalled).isFalse();
        check(fake.stopCalled).isFalse();
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
    });

    group('processing state', () {
      testWidgets('tap and long-press are disabled', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.processing(transcription: ''),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceTriggerButton));
        await tester.longPress(find.byType(VoiceTriggerButton));
        await tester.pump(const Duration(milliseconds: 100));

        check(fake.startCalled).isFalse();
        check(fake.stopCalled).isFalse();
        check(fake.cancelCalled).isFalse();
        check(fake.resetCalled).isFalse();
      });
    });

    group('success state', () {
      testWidgets('tap calls resetToIdle', (tester) async {
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
      testWidgets('tap calls resetToIdle', (tester) async {
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

    group('settings states — tap and long-press are disabled', () {
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
        testWidgets('${entry.key}: gestures do not call any method', (
          tester,
        ) async {
          final fake = _FakeOrchestrator(entry.value);
          final container = _containerFor(fake);
          addTearDown(container.dispose);

          await tester.pumpWidget(_buildTestApp(container));
          await tester.pump();

          await tester.tap(find.byType(VoiceTriggerButton));
          await tester.longPress(find.byType(VoiceTriggerButton));
          await tester.pump(const Duration(milliseconds: 100));

          check(fake.startCalled).isFalse();
          check(fake.stopCalled).isFalse();
          check(fake.cancelCalled).isFalse();
          check(fake.resetCalled).isFalse();
        });
      }
    });

    group('widget structure', () {
      testWidgets('contains an AnimatedContainer for the visual', (
        tester,
      ) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final animContainerFinder = find.descendant(
          of: find.byType(VoiceTriggerButton),
          matching: find.byType(AnimatedContainer),
        );
        check(animContainerFinder.evaluate().isNotEmpty).isTrue();
      });
    });
  });
}
