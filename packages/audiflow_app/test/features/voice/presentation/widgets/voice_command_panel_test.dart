import 'package:audiflow_app/features/voice/presentation/controllers/voice_command_controller.dart';
import 'package:audiflow_app/features/voice/presentation/widgets/voice_command_panel.dart';
import 'package:audiflow_app/features/voice/presentation/widgets/waveform_painter.dart';
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

class _FakeController extends VoiceCommandController {
  bool undoCalled = false;
  String? undoKey;
  String? undoPreviousValue;

  bool resetControllerCalled = false;

  bool confirmCalled = false;
  String? confirmKey;
  String? confirmValue;

  bool selectCandidateCalled = false;
  SettingsResolutionCandidate? selectedCandidate;

  @override
  void build() {}

  void trackUndoSettingsChange(String key, String previousValue) {
    undoCalled = true;
    undoKey = key;
    undoPreviousValue = previousValue;
  }

  void trackReset() {
    resetControllerCalled = true;
  }

  void trackConfirmSettingsChange(String key, String value) {
    confirmCalled = true;
    confirmKey = key;
    confirmValue = value;
  }

  void trackSelectSettingsCandidate(SettingsResolutionCandidate candidate) {
    selectCandidateCalled = true;
    selectedCandidate = candidate;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestApp(
  ProviderContainer container, {
  Widget body = const VoiceCommandPanel(),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Stack(children: [body])),
    ),
  );
}

ProviderContainer _containerFor(
  _FakeOrchestrator fake, {
  _FakeController? controller,
}) {
  return ProviderContainer(
    overrides: [
      voiceCommandOrchestratorProvider.overrideWith(() => fake),
      if (controller != null)
        voiceCommandControllerProvider.overrideWith(() => controller),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VoiceCommandPanel', () {
    group('idle state', () {
      testWidgets('renders SizedBox.shrink when idle', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.idle());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // The panel should render nothing visible
        final panelFinder = find.byType(VoiceCommandPanel);
        check(panelFinder.evaluate().length).equals(1);

        // Should contain a SizedBox.shrink (zero size)
        final sizedBoxFinder = find.descendant(
          of: panelFinder,
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == 0.0 && w.height == 0.0,
          ),
        );
        check(sizedBoxFinder.evaluate().isNotEmpty).isTrue();
      });
    });

    group('listening state', () {
      testWidgets('shows waveform widget', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.listening());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Should find the WaveformWidget
        final waveformFinder = find.byType(WaveformWidget);
        check(waveformFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('shows partial transcript when provided', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.listening(partialTranscript: 'play the'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final transcriptFinder = find.text('play the');
        check(transcriptFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('has fixed 240pt width', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.listening());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final sizedBoxFinder = find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 240,
        );
        check(sizedBoxFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('shows cancel button', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.listening());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Find cancel text button
        final cancelFinder = find.text('Cancel');
        check(cancelFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('cancel button calls cancelVoiceCommand', (tester) async {
        final fake = _FakeOrchestrator(const VoiceRecognitionState.listening());
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.text('Cancel'));
        await tester.pump();

        check(fake.cancelCalled).isTrue();
      });
    });

    group('processing state', () {
      testWidgets('shows waveform in processing mode', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.processing(transcription: 'play music'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final waveformFinder = find.byType(WaveformWidget);
        check(waveformFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('shows full transcript in quotes', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.processing(transcription: 'play music'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Transcript is shown in quotes
        final quotedText = find.textContaining('"play music"');
        check(quotedText.evaluate().isNotEmpty).isTrue();
      });
    });

    group('success state', () {
      testWidgets('shows success message', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.success(message: 'Paused'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        check(find.text('Paused').evaluate().isNotEmpty).isTrue();
      });

      testWidgets('shows check icon', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.success(message: 'Done'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.check_circle,
        );
        check(iconFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('tap dismisses panel (calls resetToIdle)', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.success(message: 'Done'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Tap the panel
        await tester.tap(find.byType(VoiceCommandPanel));
        await tester.pump();

        check(fake.resetCalled).isTrue();
      });
    });

    group('error state', () {
      testWidgets('shows error message', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.error(message: 'No speech detected'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        check(find.text('No speech detected').evaluate().isNotEmpty).isTrue();
      });

      testWidgets('shows error icon', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.error(message: 'Oops'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.error,
        );
        check(iconFinder.evaluate().isNotEmpty).isTrue();
      });

      testWidgets('tap dismisses panel (calls resetToIdle)', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.error(message: 'Oops'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        await tester.tap(find.byType(VoiceCommandPanel));
        await tester.pump();

        check(fake.resetCalled).isTrue();
      });

      testWidgets('shows retry hint text', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.error(message: 'Oops'),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        final hintFinder = find.text('Tap mic to try again');
        check(hintFinder.evaluate().isNotEmpty).isTrue();
      });
    });

    group('settings disambiguation state', () {
      testWidgets('shows disambiguation candidates', (tester) async {
        final fake = _FakeOrchestrator(
          VoiceRecognitionState.settingsDisambiguation(
            candidates: [
              const SettingsResolutionCandidate(
                key: 'playbackDefaultSpeed',
                displayNameKey: 'playbackDefaultSpeed',
                oldValue: '1.0',
                newValue: '1.5',
                confidence: 0.9,
              ),
              const SettingsResolutionCandidate(
                key: 'playbackSkipForward',
                displayNameKey: 'playbackSkipForward',
                oldValue: '30',
                newValue: '15',
                confidence: 0.6,
              ),
            ],
          ),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Should show "Which setting?" header
        final headerFinder = find.text('Which setting do you mean?');
        check(headerFinder.evaluate().isNotEmpty).isTrue();

        // Should show cancel button
        final cancelFinder = find.text('Cancel');
        check(cancelFinder.evaluate().isNotEmpty).isTrue();
      });
    });

    group('settings auto-applied state', () {
      testWidgets('shows check icon and undo button', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.settingsAutoApplied(
            key: 'playbackDefaultSpeed',
            displayNameKey: 'playbackDefaultSpeed',
            oldValue: '1.0',
            newValue: '1.5',
          ),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Check icon
        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.check_circle,
        );
        check(iconFinder.evaluate().isNotEmpty).isTrue();

        // Undo button
        final undoFinder = find.text('Undo');
        check(undoFinder.evaluate().isNotEmpty).isTrue();
      });
    });

    group('settings low confidence state', () {
      testWidgets('shows help icon and confirm/cancel buttons', (tester) async {
        final fake = _FakeOrchestrator(
          const VoiceRecognitionState.settingsLowConfidence(
            key: 'playbackDefaultSpeed',
            displayNameKey: 'playbackDefaultSpeed',
            oldValue: '1.0',
            newValue: '1.5',
            confidence: 0.5,
          ),
        );
        final container = _containerFor(fake);
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildTestApp(container));
        await tester.pump();

        // Help icon
        final iconFinder = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Symbols.help,
        );
        check(iconFinder.evaluate().isNotEmpty).isTrue();

        // Confirm and Cancel buttons
        check(find.text('Confirm').evaluate().isNotEmpty).isTrue();
        check(find.text('Cancel').evaluate().isNotEmpty).isTrue();
      });
    });
  });
}
