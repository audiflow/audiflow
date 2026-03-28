import 'package:audiflow_app/features/player/presentation/widgets/mini_player.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

const _nowPlaying = NowPlayingInfo(
  episodeUrl: 'https://example.com/episode.mp3',
  episodeTitle: 'Test Episode',
  podcastTitle: 'Test Podcast',
);

class _FakeAppSettingsRepository implements AppSettingsRepository {
  _FakeAppSettingsRepository({this.skipForwardSeconds = 30});

  final int skipForwardSeconds;

  @override
  int getSkipForwardSeconds() => skipForwardSeconds;

  @override
  ThemeMode getThemeMode() => ThemeMode.system;

  @override
  String? getLocale() => null;

  @override
  double getTextScale() => 1.0;

  @override
  double getPlaybackSpeed() => 1.0;

  @override
  Future<void> setSkipForwardSeconds(int seconds) async {}

  @override
  int getSkipBackwardSeconds() => 10;

  @override
  Future<void> setSkipBackwardSeconds(int seconds) async {}

  @override
  double getAutoCompleteThreshold() => 0.95;

  @override
  Future<void> setAutoCompleteThreshold(double threshold) async {}

  @override
  bool getContinuousPlayback() => false;

  @override
  Future<void> setContinuousPlayback(bool enabled) async {}

  @override
  AutoPlayOrder getAutoPlayOrder() => AutoPlayOrder.oldestFirst;

  @override
  Future<void> setAutoPlayOrder(AutoPlayOrder order) async {}

  @override
  bool getWifiOnlyDownload() => false;

  @override
  Future<void> setWifiOnlyDownload(bool enabled) async {}

  @override
  bool getAutoDeletePlayed() => false;

  @override
  Future<void> setAutoDeletePlayed(bool enabled) async {}

  @override
  int getMaxConcurrentDownloads() => 3;

  @override
  Future<void> setMaxConcurrentDownloads(int count) async {}

  @override
  bool getAutoSync() => true;

  @override
  Future<void> setAutoSync(bool enabled) async {}

  @override
  int getSyncIntervalMinutes() => 60;

  @override
  Future<void> setSyncIntervalMinutes(int minutes) async {}

  @override
  bool getWifiOnlySync() => false;

  @override
  Future<void> setWifiOnlySync(bool enabled) async {}

  @override
  bool getNotifyNewEpisodes() => false;

  @override
  Future<void> setNotifyNewEpisodes(bool enabled) async {}

  @override
  String? getSearchCountry() => null;

  @override
  Future<void> setSearchCountry(String? country) async {}

  @override
  int getLastTabIndex() => 0;

  @override
  Future<void> setLastTabIndex(int index) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> setThemeMode(ThemeMode mode) async {}

  @override
  Future<void> setLocale(String? locale) async {}

  @override
  Future<void> setTextScale(double scale) async {}

  @override
  Future<void> setPlaybackSpeed(double speed) async {}
}

void main() {
  Widget buildTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: MiniPlayer()),
      ),
    );
  }

  group('MiniPlayer skip forward button', () {
    testWidgets('renders skip forward icon', (tester) async {
      final container = ProviderContainer(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => _StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(
            () => _StubAudioPlayerController(
              const PlaybackState.paused(episodeUrl: 'test'),
            ),
          ),
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(skipForwardSeconds: 30),
          ),
          playbackProgressProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      check(
        find.byType(SkipDurationIcon),
      ).has((f) => f.evaluate().length, 'count').equals(1);
    });

    testWidgets('calls skipForward on tap', (tester) async {
      final controller = _StubAudioPlayerController(
        const PlaybackState.playing(episodeUrl: 'test'),
      );

      final container = ProviderContainer(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => _StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(() => controller),
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(skipForwardSeconds: 15),
          ),
          playbackProgressProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SkipDurationIcon));
      await tester.pump();

      check(controller.skipForwardCalled).isTrue();

      // Drain the 150ms stabilization timer
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('preserves play/pause icon during skip', (tester) async {
      final controller = _StubAudioPlayerController(
        const PlaybackState.playing(episodeUrl: 'test'),
      );

      final container = ProviderContainer(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => _StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(() => controller),
          appSettingsRepositoryProvider.overrideWithValue(
            _FakeAppSettingsRepository(),
          ),
          playbackProgressProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();

      // Verify pause icon is shown (playing state)
      check(
        find.byIcon(Symbols.pause),
      ).has((f) => f.evaluate().length, 'count').equals(1);

      // Tap skip forward - state freezes during seek
      await tester.tap(find.byType(SkipDurationIcon));
      await tester.pump();

      // Pause icon should still be visible (not flashing to play)
      check(
        find.byIcon(Symbols.pause),
      ).has((f) => f.evaluate().length, 'count').equals(1);

      // Let the 150ms stabilization delay complete
      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}

class _StubNowPlayingController extends NowPlayingController {
  _StubNowPlayingController(this._initial);
  final NowPlayingInfo? _initial;

  @override
  NowPlayingInfo? build() => _initial;
}

class _StubAudioPlayerController extends AudioPlayerController {
  _StubAudioPlayerController(this._initial);
  final PlaybackState _initial;

  bool skipForwardCalled = false;

  @override
  PlaybackState build() => _initial;

  @override
  Future<void> skipForward() async {
    skipForwardCalled = true;
  }

  @override
  Future<void> skipBackward() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> togglePlayPause([String? episodeUrl]) async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> resume() async {}

  @override
  Future<void> setSpeed(double speed) async {}
}
