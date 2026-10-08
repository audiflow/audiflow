import 'package:audiflow_app/features/player/presentation/controllers/seek_undo_controller.dart';
import 'package:audiflow_app/features/player/presentation/screens/player_screen.dart';
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

const _origin = Duration(minutes: 1);

const _progress = PlaybackProgress(
  position: _origin,
  duration: Duration(minutes: 10),
  bufferedPosition: Duration.zero,
);

final _chapters = [
  EpisodeChapter()
    ..id = 1
    ..episodeId = 1
    ..sortOrder = 0
    ..title = 'Intro'
    ..startMs = 0,
  EpisodeChapter()
    ..id = 2
    ..episodeId = 1
    ..sortOrder = 1
    ..title = 'Interview'
    ..startMs = const Duration(minutes: 5).inMilliseconds,
];

/// Playing controller that records seeks and skips.
class _RecordingAudioPlayerController extends AudioPlayerController {
  final List<Duration> seeks = [];
  int skipForwardCount = 0;

  @override
  PlaybackState build() => const PlaybackState.playing(episodeUrl: _episodeUrl);

  @override
  String? get currentUrl => _episodeUrl;

  @override
  Future<void> seek(Duration position) async => seeks.add(position);

  @override
  Future<void> skipForward() async => skipForwardCount++;
}

Future<Widget> _buildPlayer(_RecordingAudioPlayerController player) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      nowPlayingControllerProvider.overrideWith(
        () => StubNowPlayingController(_nowPlaying()),
      ),
      audioPlayerControllerProvider.overrideWith(() => player),
      appSettingsRepositoryProvider.overrideWithValue(
        StubAppSettingsRepository(),
      ),
      playbackProgressProvider.overrideWith((ref) => _progress),
      playbackSpeedProvider.overrideWith((ref) => Stream.value(1.0)),
      transcriptServiceProvider.overrideWithValue(StubTranscriptService()),
      currentEpisodeChaptersProvider.overrideWith(
        (ref) => Stream.value(_chapters),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PlayerScreen()),
    ),
  );
}

Finder get _goBack => find.text('Go back');

Future<void> _pickInterviewChapter(WidgetTester tester) async {
  await tester.tap(find.text('1. Intro'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Interview'));
  await tester.pumpAndSettle();
}

void main() {
  group('PlayerScreen go-back pill', () {
    testWidgets('is hidden until a jump', (tester) async {
      await tester.pumpWidget(
        await _buildPlayer(_RecordingAudioPlayerController()),
      );
      await tester.pump();

      check(_goBack.evaluate()).isEmpty();
    });

    testWidgets('a chapter pick shows it and Go back returns', (tester) async {
      final player = _RecordingAudioPlayerController();
      await tester.pumpWidget(await _buildPlayer(player));
      await tester.pump();

      await _pickInterviewChapter(tester);
      check(_goBack.evaluate()).isNotEmpty();

      await tester.tap(_goBack);
      await tester.pumpAndSettle();

      check(player.seeks).deepEquals([const Duration(minutes: 5), _origin]);
      check(_goBack.evaluate()).isEmpty();
    });

    testWidgets('a seek bar release shows it', (tester) async {
      final player = _RecordingAudioPlayerController();
      await tester.pumpWidget(await _buildPlayer(player));
      await tester.pump();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(PlayerSeekBar.trackKey)),
      );
      await gesture.moveBy(const Offset(30, 0));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      check(player.seeks).length.equals(1);
      check(_goBack.evaluate()).isNotEmpty();
    });

    testWidgets('the skip buttons do not show it', (tester) async {
      final player = _RecordingAudioPlayerController();
      await tester.pumpWidget(await _buildPlayer(player));
      await tester.pump();

      await tester.tap(find.bySemanticsLabel('Forward 30 seconds'));
      await tester.pumpAndSettle();

      check(player.skipForwardCount).equals(1);
      check(_goBack.evaluate()).isEmpty();
    });

    testWidgets('the close button hides it without seeking', (tester) async {
      final player = _RecordingAudioPlayerController();
      await tester.pumpWidget(await _buildPlayer(player));
      await tester.pump();

      await _pickInterviewChapter(tester);
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();

      check(_goBack.evaluate()).isEmpty();
      check(player.seeks).deepEquals([const Duration(minutes: 5)]);
    });

    testWidgets('fades out after the visible duration', (tester) async {
      await tester.pumpWidget(
        await _buildPlayer(_RecordingAudioPlayerController()),
      );
      await tester.pump();

      await _pickInterviewChapter(tester);
      await tester.pump(SeekUndoController.visibleDuration);
      await tester.pumpAndSettle();

      check(_goBack.evaluate()).isEmpty();
    });
  });
}
