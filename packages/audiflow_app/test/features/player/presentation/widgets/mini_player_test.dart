import 'package:audiflow_app/features/player/presentation/widgets/mini_player.dart';
import 'package:audiflow_app/features/player/presentation/widgets/sleep_timer_icon_button.dart';
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

const _nowPlaying = NowPlayingInfo(
  episodeUrl: 'https://example.com/episode.mp3',
  episodeTitle: 'Test Episode',
  podcastTitle: 'Test Podcast',
);

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

  group('MiniPlayer tablet layout', () {
    Future<ProviderContainer> tabletContainer(
      StubAudioPlayerController controller,
    ) async {
      SharedPreferences.setMockInitialValues({'settings_playback_speed': 1.3});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          nowPlayingControllerProvider.overrideWith(
            () => StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(() => controller),
          appSettingsRepositoryProvider.overrideWithValue(
            StubAppSettingsRepository(
              skipForwardSeconds: 30,
              skipBackwardSeconds: 10,
            ),
          ),
          playbackProgressProvider.overrideWith((ref) => null),
          sleepTimerTimeLeftProvider.overrideWith((ref) => null),
          nowPlayingSpeedProvider.overrideWith((ref) => 1.3),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    Future<void> pumpTablet(
      WidgetTester tester,
      ProviderContainer container,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildTestWidget(container));
      await tester.pumpAndSettle();
    }

    testWidgets('shows speed, skip back, play, skip forward, sleep in order', (
      tester,
    ) async {
      final container = await tabletContainer(
        StubAudioPlayerController(
          const PlaybackState.paused(episodeUrl: 'test'),
        ),
      );
      await pumpTablet(tester, container);

      final speed = find.text('1.3x');
      final skips = find.byType(SkipDurationIcon);
      final play = find.byIcon(Symbols.play_arrow);
      final sleep = find.byType(SleepTimerIconButton);
      check(skips.evaluate().length).equals(2);
      final xs = [
        speed,
        skips.at(0),
        play,
        skips.at(1),
        sleep,
      ].map((f) => tester.getCenter(f).dx).toList();
      for (var i = 1; i < xs.length; i++) {
        check(xs[i - 1]).isLessThan(xs[i]);
      }
      final back = tester.widget<SkipDurationIcon>(skips.at(0));
      check(back.isForward).isFalse();
      check(back.seconds).equals(10);
    });

    testWidgets('skip back button calls skipBackward', (tester) async {
      final controller = StubAudioPlayerController(
        const PlaybackState.playing(episodeUrl: 'test'),
      );
      final container = await tabletContainer(controller);
      await pumpTablet(tester, container);

      await tester.tap(find.byType(SkipDurationIcon).first);
      await tester.pump();

      check(controller.skipBackwardCalled).isTrue();
      check(controller.skipForwardCalled).isFalse();
      await tester.pump(const Duration(milliseconds: 200));
    });
  });

  group('MiniPlayer skip forward button', () {
    // The default 800x600 test view counts as a tablet; pin a phone size.
    setUp(() {
      final view =
          TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
      view.physicalSize = const Size(390, 844);
      view.devicePixelRatio = 1;
    });
    tearDown(
      () => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
          .reset(),
    );

    testWidgets('renders skip forward icon', (tester) async {
      final container = ProviderContainer(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(
            () => StubAudioPlayerController(
              const PlaybackState.paused(episodeUrl: 'test'),
            ),
          ),
          appSettingsRepositoryProvider.overrideWithValue(
            StubAppSettingsRepository(skipForwardSeconds: 30),
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
      final controller = StubAudioPlayerController(
        const PlaybackState.playing(episodeUrl: 'test'),
      );

      final container = ProviderContainer(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(() => controller),
          appSettingsRepositoryProvider.overrideWithValue(
            StubAppSettingsRepository(skipForwardSeconds: 15),
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
      // Use a controller that transitions to loading during skipForward(),
      // which would normally flip the icon from pause to a loading spinner.
      // The _isSeeking freeze logic should prevent the icon from changing.
      final controller = _StateTransitioningAudioPlayerController(
        const PlaybackState.playing(episodeUrl: 'test'),
      );

      final container = ProviderContainer(
        overrides: [
          nowPlayingControllerProvider.overrideWith(
            () => StubNowPlayingController(_nowPlaying),
          ),
          audioPlayerControllerProvider.overrideWith(() => controller),
          appSettingsRepositoryProvider.overrideWithValue(
            StubAppSettingsRepository(),
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

      // Tap skip forward - controller transitions to loading, but
      // _isSeeking freeze should keep showing the pause icon
      await tester.tap(find.byType(SkipDurationIcon));
      await tester.pump();

      // Pause icon should still be visible despite underlying state
      // being loading (the _isSeeking flag freezes the displayed icon)
      check(
        find.byIcon(Symbols.pause),
      ).has((f) => f.evaluate().length, 'count').equals(1);

      // Verify no loading spinner is shown (proving _isSeeking works)
      check(
        find.byType(CircularProgressIndicator),
      ).has((f) => f.evaluate().length, 'count').equals(0);

      // Let the 150ms stabilization delay complete
      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}

/// Controller that transitions state to [PlaybackLoading] during
/// [skipForward], simulating the real player behavior where state
/// temporarily changes during a seek operation.
class _StateTransitioningAudioPlayerController
    extends StubAudioPlayerController {
  _StateTransitioningAudioPlayerController(super._initial);

  @override
  Future<void> skipForward() async {
    skipForwardCalled = true;
    // Simulate a transient state change that would flip the icon
    // if the _isSeeking freeze logic were absent
    state = const PlaybackState.loading(episodeUrl: 'test');
  }
}
