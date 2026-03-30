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

(Widget, ProviderContainer) _buildTestApp({
  required VoiceRecognitionState voiceState,
  VoiceDebugInfo debugInfo = const VoiceDebugInfo(),
}) {
  final container = ProviderContainer(
    overrides: [
      voiceCommandOrchestratorProvider.overrideWith(
        () => _FakeOrchestrator(voiceState),
      ),
      voiceDebugInfoProvider.overrideWith(
        () => _FakeDebugInfoNotifier(debugInfo),
      ),
    ],
  );

  final widget = UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Stack(children: [VoiceDebugPanel()])),
    ),
  );

  return (widget, container);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VoiceDebugPanel', () {
    testWidgets('renders nothing when idle', (tester) async {
      final (widget, container) = _buildTestApp(
        voiceState: const VoiceRecognitionState.idle(),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(widget);
      await tester.pump();

      final finder = find.text('VOICE DEBUG');
      check(finder.evaluate().isEmpty).isTrue();
    });

    testWidgets('shows header and state when listening', (tester) async {
      final (widget, container) = _buildTestApp(
        voiceState: const VoiceRecognitionState.listening(
          partialTranscript: 'play the',
        ),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(widget);
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

      final (widget, container) = _buildTestApp(
        voiceState: VoiceRecognitionState.executing(command: command),
        debugInfo: VoiceDebugInfo(
          parserSource: VoiceParserSource.simplePattern,
          lastCommand: command,
        ),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(widget);
      await tester.pump();

      check(find.textContaining('EXECUTING').evaluate().isNotEmpty).isTrue();
      check(
        find.textContaining('simple (pattern)').evaluate().isNotEmpty,
      ).isTrue();
      check(find.textContaining('play').evaluate().isNotEmpty).isTrue();
      check(find.textContaining('0.90').evaluate().isNotEmpty).isTrue();
    });

    testWidgets('shows AI status', (tester) async {
      final (widget, container) = _buildTestApp(
        voiceState: const VoiceRecognitionState.listening(),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(widget);
      await tester.pump();

      check(find.textContaining('AI:').evaluate().isNotEmpty).isTrue();
    });

    testWidgets('shows params when command has parameters', (tester) async {
      final command = VoiceCommand(
        intent: VoiceIntent.play,
        parameters: const {'podcastName': 'news'},
        confidence: 0.9,
        rawTranscription: 'play the news',
      );

      final (widget, container) = _buildTestApp(
        voiceState: const VoiceRecognitionState.success(message: 'Playing'),
        debugInfo: VoiceDebugInfo(
          parserSource: VoiceParserSource.simplePattern,
          lastCommand: command,
        ),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(widget);
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

      final (widget, container) = _buildTestApp(
        voiceState: const VoiceRecognitionState.success(message: 'Paused'),
        debugInfo: VoiceDebugInfo(
          parserSource: VoiceParserSource.platformNlu,
          lastCommand: command,
        ),
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(widget);
      await tester.pump();

      check(find.textContaining('0.95').evaluate().isNotEmpty).isTrue();
      check(find.textContaining('platform NLU').evaluate().isNotEmpty).isTrue();
    });
  });
}
