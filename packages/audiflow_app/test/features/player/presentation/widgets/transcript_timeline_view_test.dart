import 'package:audiflow_app/features/player/presentation/controllers/seek_undo_controller.dart';
import 'package:audiflow_app/features/player/presentation/widgets/transcript_timeline_view.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../helpers/player_stubs.dart';

const _transcriptId = 1;
const _episodeId = 1;
const _segmentCount = 200;
const _activeSegment = 150;
const _segmentLengthMs = 5000;
const _segmentsPerChapter = 20;

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

/// A chapter header every few segments, so headers shift item offsets too.
List<EpisodeChapter> _buildChapters() {
  return List.generate(_segmentCount ~/ _segmentsPerChapter, (i) {
    return EpisodeChapter()
      ..episodeId = _episodeId
      ..sortOrder = i
      ..title = 'Chapter $i'
      ..startMs = i * _segmentsPerChapter * _segmentLengthMs;
  });
}

Finder _activeText() => find.textContaining('Segment $_activeSegment line');

/// Top of the active tile as a fraction of the list viewport height.
double _activeTileAlignment(WidgetTester tester) {
  final list = tester.getRect(find.byType(ScrollablePositionedList));
  final tile = tester.getRect(
    find.ancestor(of: _activeText(), matching: find.byType(InkWell)).first,
  );
  return (tile.top - list.top) / list.height;
}

double _jumpButtonOpacity(WidgetTester tester) {
  final opacity = tester.widget<AnimatedOpacity>(
    find.ancestor(
      of: find.byType(FloatingActionButton),
      matching: find.byType(AnimatedOpacity),
    ),
  );
  return opacity.opacity;
}

/// Playing controller that records now-playing seeks.
class _RecordingAudioPlayerController extends StubAudioPlayerController {
  _RecordingAudioPlayerController()
    : super(const PlaybackState.playing(episodeUrl: 'test'));

  final List<Duration> seeks = [];

  @override
  Future<void> seekNowPlaying(Duration position) async => seeks.add(position);
}

void main() {
  late ProviderContainer container;
  late _RecordingAudioPlayerController player;

  setUp(() {
    player = _RecordingAudioPlayerController();
    container = ProviderContainer(
      overrides: [
        transcriptSegmentsProvider(
          _transcriptId,
        ).overrideWith((ref) async => _buildSegments()),
        episodeChaptersProvider(
          _episodeId,
        ).overrideWith((ref) async => _buildChapters()),
        playbackProgressProvider.overrideWith(
          (ref) => const PlaybackProgress(
            position: Duration(
              milliseconds: _activeSegment * _segmentLengthMs + 100,
            ),
            duration: Duration(hours: 1),
            bufferedPosition: Duration.zero,
          ),
        ),
        audioPlayerControllerProvider.overrideWith(() => player),
        nowPlayingControllerProvider.overrideWith(
          () => StubNowPlayingController(
            const NowPlayingInfo(
              episodeUrl: 'test',
              episodeTitle: 'Episode',
              podcastTitle: 'Podcast',
            ),
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

    check(_activeText().evaluate()).length.equals(1);
    check(_jumpButtonOpacity(tester)).equals(0);
  });

  testWidgets('places the active segment one third down the viewport', (
    tester,
  ) async {
    await pumpView(tester);

    check(_activeTileAlignment(tester)).isCloseTo(0.33, 0.01);
  });

  testWidgets('jump button restores the one-third alignment', (tester) async {
    await pumpView(tester);

    await tester.fling(_activeText(), const Offset(0, 3000), 5000);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    check(_activeTileAlignment(tester)).isCloseTo(0.33, 0.01);
  });

  testWidgets('user drag shows the jump button, which resumes following', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.fling(_activeText(), const Offset(0, 3000), 5000);
    await tester.pumpAndSettle();
    check(_activeText().evaluate()).isEmpty();
    check(_jumpButtonOpacity(tester)).equals(1);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    check(_activeText().evaluate()).length.equals(1);
    check(_jumpButtonOpacity(tester)).equals(0);
  });

  testWidgets('re-syncs five seconds after the user stops scrolling', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.fling(_activeText(), const Offset(0, 3000), 5000);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 4));
    check(_activeText().evaluate()).isEmpty();
    check(_jumpButtonOpacity(tester)).equals(1);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    check(_activeText().evaluate()).length.equals(1);
    check(_jumpButtonOpacity(tester)).equals(0);
  });

  testWidgets('tapping a segment seeks there and offers to go back', (
    tester,
  ) async {
    await pumpView(tester);

    // The tile's padding, outside the text's selection gestures.
    final tile = find
        .ancestor(of: _activeText(), matching: find.byType(InkWell))
        .first;
    await tester.tapAt(tester.getTopLeft(tile) + const Offset(4, 4));
    await tester.pump();

    check(player.seeks).deepEquals([
      const Duration(milliseconds: _activeSegment * _segmentLengthMs),
    ]);
    check(container.read(seekUndoControllerProvider)).isNotNull();

    // Let the pill time out so no timer outlives the test.
    await tester.pump(SeekUndoController.visibleDuration);
    check(container.read(seekUndoControllerProvider)).isNull();
  });
}
