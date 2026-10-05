import 'package:audiflow_app/features/player/presentation/screens/player_screen.dart';
import 'package:audiflow_app/features/player/presentation/widgets/chapter_list_sheet.dart';
import 'package:audiflow_app/features/player/presentation/widgets/current_chapter_row.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/player_stubs.dart';

const _episodeUrl = 'https://example.com/episode.mp3';

NowPlayingInfo _nowPlaying() => NowPlayingInfo(
  episodeUrl: _episodeUrl,
  episodeTitle: 'Episode',
  podcastTitle: 'Podcast',
  episode: Episode()
    ..id = 1
    ..podcastId = 1,
);

PlaybackProgress _progressAt(Duration position) => PlaybackProgress(
  position: position,
  duration: const Duration(minutes: 10),
  bufferedPosition: Duration.zero,
);

EpisodeChapter _chapter(int sortOrder, Duration start, String title) =>
    EpisodeChapter()
      ..id = sortOrder + 1
      ..episodeId = 1
      ..sortOrder = sortOrder
      ..title = title
      ..startMs = start.inMilliseconds;

final _chapters = [
  _chapter(0, Duration.zero, 'Intro'),
  _chapter(1, const Duration(minutes: 5), 'Interview'),
];

/// Playing controller that records seeks.
class _RecordingAudioPlayerController extends AudioPlayerController {
  final List<Duration> seeks = [];

  @override
  PlaybackState build() => const PlaybackState.playing(episodeUrl: _episodeUrl);

  @override
  String? get currentUrl => _episodeUrl;

  @override
  Future<void> seek(Duration position) async => seeks.add(position);
}

class _Position extends Notifier<Duration> {
  @override
  Duration build() => const Duration(minutes: 1);

  void set(Duration value) => state = value;
}

final _positionProvider = NotifierProvider<_Position, Duration>(_Position.new);

Future<Widget> _buildPlayer({
  required List<EpisodeChapter> chapters,
  _RecordingAudioPlayerController? player,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      nowPlayingControllerProvider.overrideWith(
        () => StubNowPlayingController(_nowPlaying()),
      ),
      audioPlayerControllerProvider.overrideWith(
        () => player ?? _RecordingAudioPlayerController(),
      ),
      appSettingsRepositoryProvider.overrideWithValue(
        StubAppSettingsRepository(),
      ),
      playbackProgressProvider.overrideWith(
        (ref) => _progressAt(ref.watch(_positionProvider)),
      ),
      playbackSpeedProvider.overrideWith((ref) => Stream.value(1.0)),
      episodeHasTranscriptProvider.overrideWith((ref, id) async => false),
      currentEpisodeChaptersProvider.overrideWith(
        (ref) => Stream.value(chapters),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PlayerScreen()),
    ),
  );
}

Finder get _track => find.byKey(PlayerSeekBar.trackKey);

List<SeekBarSegment> _segments(WidgetTester tester) =>
    tester.widget<PlayerSeekBar>(find.byType(PlayerSeekBar)).segments;

void main() {
  group('PlayerScreen without chapters', () {
    testWidgets('shows no chapter row and an unsplit track', (tester) async {
      await tester.pumpWidget(await _buildPlayer(chapters: const []));
      await tester.pump();

      check(
        find
            .descendant(
              of: find.byType(CurrentChapterRow),
              matching: find.byType(InkWell),
            )
            .evaluate(),
      ).isEmpty();
      check(find.textContaining('Chapters').evaluate()).isEmpty();
      check(_segments(tester)).deepEquals(SeekBarSegment.single);
    });
  });

  group('PlayerScreen with chapters', () {
    testWidgets('splits the track at chapter starts', (tester) async {
      await tester.pumpWidget(await _buildPlayer(chapters: _chapters));
      await tester.pump();

      check(_segments(tester)).deepEquals(const [
        SeekBarSegment(start: 0, end: 0.5),
        SeekBarSegment(start: 0.5, end: 1),
      ]);
    });

    testWidgets('chapter row follows playback across a boundary', (
      tester,
    ) async {
      await tester.pumpWidget(await _buildPlayer(chapters: _chapters));
      await tester.pump();
      check(find.text('1. Intro').evaluate()).isNotEmpty();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PlayerScreen)),
      );
      container
          .read(_positionProvider.notifier)
          .set(const Duration(minutes: 6));
      await tester.pump();

      check(find.text('2. Interview').evaluate()).isNotEmpty();
      check(find.text('1. Intro').evaluate()).isEmpty();
    });

    testWidgets('chapter list seeks to the tapped chapter', (tester) async {
      final player = _RecordingAudioPlayerController();
      await tester.pumpWidget(
        await _buildPlayer(chapters: _chapters, player: player),
      );
      await tester.pump();

      await tester.tap(find.text('1. Intro'));
      await tester.pumpAndSettle();
      check(find.byType(ChapterListSheet).evaluate()).isNotEmpty();
      check(find.text('05:00').evaluate()).isNotEmpty();

      await tester.tap(find.text('Interview'));
      await tester.pumpAndSettle();

      check(player.seeks).deepEquals([const Duration(minutes: 5)]);
      check(find.byType(ChapterListSheet).evaluate()).isEmpty();
    });

    testWidgets('screen readers can open the list and pick a chapter', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final player = _RecordingAudioPlayerController();
      await tester.pumpWidget(
        await _buildPlayer(chapters: _chapters, player: player),
      );
      await tester.pump();

      final row = find.semantics.byLabel(RegExp(r'^Chapter 1: Intro'));
      tester.semantics.tap(row);
      await tester.pumpAndSettle();
      check(find.byType(ChapterListSheet).evaluate()).isNotEmpty();

      final item = find.semantics.byLabel(RegExp(r'^Chapter 2: Interview'));
      tester.semantics.tap(item);
      await tester.pumpAndSettle();
      check(player.seeks).deepEquals([const Duration(minutes: 5)]);
      handle.dispose();
    });

    testWidgets('row offers the list before the first chapter starts', (
      tester,
    ) async {
      await tester.pumpWidget(
        await _buildPlayer(
          chapters: [_chapter(0, const Duration(minutes: 2), 'Late')],
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle();
      check(find.byType(ChapterListSheet).evaluate()).isNotEmpty();
      check(find.text('Late').evaluate()).isNotEmpty();
    });

    testWidgets('scrub tooltip shows the chapter under the finger', (
      tester,
    ) async {
      await tester.pumpWidget(await _buildPlayer(chapters: _chapters));
      await tester.pump();
      final tooltip = find.byKey(PlayerSeekBar.tooltipKey);
      final width = tester.getSize(_track).width;

      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
      check(
        find.descendant(of: tooltip, matching: find.text('Intro')).evaluate(),
      ).isNotEmpty();

      // From 10% to past the 50% chapter boundary.
      await gesture.moveBy(Offset(width * 0.5, 0));
      await tester.pump();
      check(
        find
            .descendant(of: tooltip, matching: find.text('Interview'))
            .evaluate(),
      ).isNotEmpty();

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
      check(tooltip.evaluate()).isEmpty();
    });

    testWidgets('artwork keeps a 160 pt minimum height on a short screen', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(375, 420)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(await _buildPlayer(chapters: _chapters));
      await tester.pump();

      final artwork = tester.getSize(find.byType(AspectRatio).first);
      check(artwork.height).equals(160);
    });
  });
}
