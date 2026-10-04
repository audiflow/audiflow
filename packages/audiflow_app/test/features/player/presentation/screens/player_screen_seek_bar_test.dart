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

const _progress = PlaybackProgress(
  position: Duration(minutes: 1),
  duration: Duration(minutes: 10),
  bufferedPosition: Duration.zero,
);

/// Playing controller whose seek drops into a transient non-playing state,
/// the way the real player does while it rebuffers.
class _SeekingAudioPlayerController extends AudioPlayerController {
  final List<Duration> seeks = [];

  @override
  PlaybackState build() => const PlaybackState.playing(episodeUrl: _episodeUrl);

  @override
  String? get currentUrl => _episodeUrl;

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    state = const PlaybackState.loading(episodeUrl: _episodeUrl);
  }
}

Future<Widget> _buildPlayer({
  required StubAppSettingsRepository settings,
  AudioPlayerController Function()? player,
}) async {
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
        player ??
            () => StubAudioPlayerController(
              const PlaybackState.paused(episodeUrl: _episodeUrl),
            ),
      ),
      appSettingsRepositoryProvider.overrideWithValue(settings),
      playbackProgressProvider.overrideWith((ref) => _progress),
      playbackSpeedProvider.overrideWith((ref) => Stream.value(1.0)),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: PlayerScreen()),
    ),
  );
}

Finder get _track => find.byKey(PlayerSeekBar.trackKey);

void main() {
  group('PlayerScreen seek bar', () {
    testWidgets('shows elapsed and remaining time by default', (tester) async {
      final settings = StubAppSettingsRepository();
      await tester.pumpWidget(await _buildPlayer(settings: settings));
      await tester.pump();

      check(find.text('01:00').evaluate()).isNotEmpty();
      check(find.text('-09:00').evaluate()).isNotEmpty();
    });

    testWidgets('tapping the remaining time toggles to total and persists', (
      tester,
    ) async {
      final settings = StubAppSettingsRepository();
      await tester.pumpWidget(await _buildPlayer(settings: settings));
      await tester.pump();

      await tester.tap(find.text('-09:00'));
      await tester.pump();

      check(find.text('10:00').evaluate()).isNotEmpty();
      check(find.text('-09:00').evaluate()).isEmpty();
      check(settings.showRemainingTime).isFalse();
    });

    testWidgets('restores the total-duration label from settings', (
      tester,
    ) async {
      final settings = StubAppSettingsRepository(showRemainingTime: false);
      await tester.pumpWidget(await _buildPlayer(settings: settings));
      await tester.pump();

      check(find.text('10:00').evaluate()).isNotEmpty();
      check(find.text('-09:00').evaluate()).isEmpty();
    });

    testWidgets('exposes a slider with elapsed of total', (tester) async {
      final handle = tester.ensureSemantics();
      final settings = StubAppSettingsRepository();
      await tester.pumpWidget(await _buildPlayer(settings: settings));
      await tester.pump();

      final node = tester.getSemantics(find.byType(PlayerSeekBar));
      check(node.flagsCollection.isSlider).isTrue();
      check(node.value).equals('01:00 of 10:00');
      handle.dispose();
    });

    testWidgets('play/pause icon does not change while scrubbing', (
      tester,
    ) async {
      final player = _SeekingAudioPlayerController();
      final settings = StubAppSettingsRepository();
      await tester.pumpWidget(
        await _buildPlayer(settings: settings, player: () => player),
      );
      await tester.pump();
      check(find.byIcon(Symbols.pause).evaluate()).isNotEmpty();

      final gesture = await tester.startGesture(tester.getCenter(_track));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      check(find.byIcon(Symbols.pause).evaluate()).isNotEmpty();

      await gesture.up();
      await tester.pump();
      check(player.seeks).length.equals(1);
      check(find.byIcon(Symbols.pause).evaluate()).isNotEmpty();

      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}
