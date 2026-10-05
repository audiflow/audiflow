import 'package:audiflow_app/features/player/presentation/screens/player_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/player_stubs.dart';

const _episodeUrl = 'https://example.com/episode.mp3';

const _nowPlaying = NowPlayingInfo(
  episodeUrl: _episodeUrl,
  episodeTitle: 'Episode',
  podcastTitle: 'Podcast',
);

/// One minute into a ten-minute episode, played at 1.5x: nine minutes of
/// media take six minutes.
const _progress = PlaybackProgress(
  position: Duration(minutes: 1),
  duration: Duration(minutes: 10),
  bufferedPosition: Duration.zero,
);

Future<Widget> _buildPlayer(StubAppSettingsRepository settings) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
      nowPlayingControllerProvider.overrideWith(
        () => StubNowPlayingController(_nowPlaying),
      ),
      audioPlayerControllerProvider.overrideWith(
        () => StubAudioPlayerController(
          const PlaybackState.paused(episodeUrl: _episodeUrl),
        ),
      ),
      appSettingsRepositoryProvider.overrideWithValue(settings),
      playbackProgressProvider.overrideWith((ref) => _progress),
      playbackSpeedProvider.overrideWith((ref) => Stream.value(1.5)),
      playerLifecycleEventsProvider.overrideWith((ref) => const Stream.empty()),
      nowPlayingSpeedProvider.overrideWith((ref) => 1.5),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PlayerScreen()),
    ),
  );
}

Finder get _track => find.byKey(PlayerSeekBar.trackKey);

Finder get _sleepGlyph => find.byIcon(Symbols.sleep);

SleepTimerController _timer(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(PlayerScreen)),
  );
  return container.read(sleepTimerControllerProvider.notifier);
}

Future<StubAppSettingsRepository> _pumpWithEndOfEpisode(
  WidgetTester tester,
) async {
  final settings = StubAppSettingsRepository();
  await tester.pumpWidget(await _buildPlayer(settings));
  await tester.pump();
  _timer(tester).setEndOfEpisode();
  await tester.pump();
  return settings;
}

void main() {
  group('PlayerScreen sleep countdown', () {
    testWidgets('shows the time left at the speed in effect', (tester) async {
      await _pumpWithEndOfEpisode(tester);

      check(find.text('06:00').evaluate()).isNotEmpty();
      check(find.text('-09:00').evaluate()).isEmpty();
      check(_sleepGlyph.evaluate()).isNotEmpty();
    });

    testWidgets('shows the time label while no timer runs', (tester) async {
      await tester.pumpWidget(await _buildPlayer(StubAppSettingsRepository()));
      await tester.pump();

      check(find.text('-09:00').evaluate()).isNotEmpty();
      check(_sleepGlyph.evaluate()).isEmpty();
    });

    testWidgets('a tap toggles to the time label and back', (tester) async {
      final settings = await _pumpWithEndOfEpisode(tester);

      await tester.tap(find.text('06:00'));
      await tester.pump();
      check(find.text('-09:00').evaluate()).isNotEmpty();
      check(_sleepGlyph.evaluate()).isEmpty();

      await tester.tap(find.text('-09:00'));
      await tester.pump();
      check(find.text('06:00').evaluate()).isNotEmpty();
      // The remaining/total choice is left alone.
      check(settings.showRemainingTime).isTrue();
    });

    testWidgets('a newly armed timer shows the countdown again', (
      tester,
    ) async {
      await _pumpWithEndOfEpisode(tester);
      await tester.tap(find.text('06:00'));
      await tester.pump();
      check(_sleepGlyph.evaluate()).isEmpty();

      await _timer(tester).setEpisodes(1);
      await tester.pump();
      check(find.text('06:00').evaluate()).isNotEmpty();
      check(_sleepGlyph.evaluate()).isNotEmpty();
    });

    testWidgets('scrubbing shows the remaining time until release', (
      tester,
    ) async {
      await _pumpWithEndOfEpisode(tester);

      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      check(_sleepGlyph.evaluate()).isEmpty();
      check(find.textContaining(RegExp(r'^-\d')).evaluate()).isNotEmpty();

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
      check(_sleepGlyph.evaluate()).isNotEmpty();
      check(find.text('06:00').evaluate()).isNotEmpty();
    });

    testWidgets('screen readers hear the countdown as a sleep status', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpWithEndOfEpisode(tester);

      final node = tester.getSemantics(
        find.bySemanticsLabel('Sleep timer, 6 minutes left'),
      );
      check(node.flagsCollection.isButton).isTrue();
      semantics.dispose();
    });
  });
}
