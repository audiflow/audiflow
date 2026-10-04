import 'package:audiflow_app/features/player/presentation/widgets/transcript_timeline_view.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/player_stubs.dart';

const _transcriptId = 1;
const _episodeId = 1;
const _segmentCount = 200;
const _activeSegment = 150;
const _segmentLengthMs = 5000;

/// Segments of varying height so a fixed per-item estimate would drift.
List<TranscriptSegment> _buildSegments() {
  return List.generate(_segmentCount, (i) {
    final repeat = 1 + i % 4;
    return TranscriptSegment()
      ..transcriptId = _transcriptId
      ..startMs = i * _segmentLengthMs
      ..endMs = (i + 1) * _segmentLengthMs
      ..body = List.filled(repeat, 'Segment $i line').join('\n');
  });
}

Finder _activeText() => find.textContaining('Segment $_activeSegment line');

double _jumpButtonOpacity(WidgetTester tester) {
  final opacity = tester.widget<AnimatedOpacity>(
    find.ancestor(
      of: find.byType(FloatingActionButton),
      matching: find.byType(AnimatedOpacity),
    ),
  );
  return opacity.opacity;
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        transcriptSegmentsProvider(
          _transcriptId,
        ).overrideWith((ref) async => _buildSegments()),
        episodeChaptersProvider(
          _episodeId,
        ).overrideWith((ref) async => <EpisodeChapter>[]),
        playbackProgressProvider.overrideWith(
          (ref) => const PlaybackProgress(
            position: Duration(
              milliseconds: _activeSegment * _segmentLengthMs + 100,
            ),
            duration: Duration(hours: 1),
            bufferedPosition: Duration.zero,
          ),
        ),
        audioPlayerControllerProvider.overrideWith(
          () => StubAudioPlayerController(
            const PlaybackState.playing(episodeUrl: 'test'),
          ),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: TranscriptTimelineView(
              transcriptId: _transcriptId,
              episodeId: _episodeId,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the active segment and hides the jump button', (
    tester,
  ) async {
    await pumpView(tester);

    expect(_activeText(), findsOneWidget);
    expect(_jumpButtonOpacity(tester), 0);
  });

  testWidgets('user drag shows the jump button, which resumes following', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.fling(_activeText(), const Offset(0, 3000), 5000);
    await tester.pumpAndSettle();
    expect(_activeText(), findsNothing);
    expect(_jumpButtonOpacity(tester), 1);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(_activeText(), findsOneWidget);
    expect(_jumpButtonOpacity(tester), 0);
  });

  testWidgets('re-syncs five seconds after the user stops scrolling', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.fling(_activeText(), const Offset(0, 3000), 5000);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 4));
    expect(_activeText(), findsNothing);
    expect(_jumpButtonOpacity(tester), 1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(_activeText(), findsOneWidget);
    expect(_jumpButtonOpacity(tester), 0);
  });
}
