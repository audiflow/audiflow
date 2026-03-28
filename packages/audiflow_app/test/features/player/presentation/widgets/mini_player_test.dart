import 'package:audiflow_app/features/player/presentation/widgets/mini_player.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
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

/// Minimal fake that only implements methods used by mini player tests.
/// All other methods delegate to [noSuchMethod] which throws
/// [UnimplementedError].
class _FakeAppSettingsRepository implements AppSettingsRepository {
  _FakeAppSettingsRepository({this.skipForwardSeconds = 30});

  final int skipForwardSeconds;

  @override
  int getSkipForwardSeconds() => skipForwardSeconds;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
      // Use a controller that transitions to loading during skipForward(),
      // which would normally flip the icon from pause to a loading spinner.
      // The _isSeeking freeze logic should prevent the icon from changing.
      final controller = _StateTransitioningAudioPlayerController(
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

/// Controller that transitions state to [PlaybackLoading] during
/// [skipForward], simulating the real player behavior where state
/// temporarily changes during a seek operation.
class _StateTransitioningAudioPlayerController
    extends _StubAudioPlayerController {
  _StateTransitioningAudioPlayerController(super._initial);

  @override
  Future<void> skipForward() async {
    skipForwardCalled = true;
    // Simulate a transient state change that would flip the icon
    // if the _isSeeking freeze logic were absent
    state = const PlaybackState.loading(episodeUrl: 'test');
  }
}
