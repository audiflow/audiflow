import 'package:audiflow_app/features/player/presentation/controllers/seek_undo_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/player_stubs.dart';

const _episodeA = NowPlayingInfo(
  episodeUrl: 'https://example.com/a.mp3',
  episodeTitle: 'A',
  podcastTitle: 'Podcast',
);

const _episodeB = NowPlayingInfo(
  episodeUrl: 'https://example.com/b.mp3',
  episodeTitle: 'B',
  podcastTitle: 'Podcast',
);

PlaybackProgress _progressAt(Duration position) => PlaybackProgress(
  position: position,
  duration: const Duration(hours: 1),
  bufferedPosition: Duration.zero,
);

/// Records now-playing seeks instead of touching the audio player.
class _RecordingAudioPlayerController extends AudioPlayerController {
  final List<Duration> seeks = [];

  @override
  PlaybackState build() => const PlaybackState.idle();

  @override
  Future<void> seekNowPlaying(Duration position) async => seeks.add(position);
}

class _Harness {
  _Harness() {
    container = ProviderContainer(
      overrides: [
        nowPlayingControllerProvider.overrideWith(
          () => StubNowPlayingController(_episodeA),
        ),
        audioPlayerControllerProvider.overrideWith(() => player),
        playbackProgressProvider.overrideWith((ref) => progress),
      ],
    );
  }

  final player = _RecordingAudioPlayerController();
  late final ProviderContainer container;
  PlaybackProgress? progress = _progressAt(const Duration(minutes: 3));

  SeekUndoController get controller =>
      container.read(seekUndoControllerProvider.notifier);

  SeekUndoState? get state => container.read(seekUndoControllerProvider);

  void moveTo(Duration position) {
    progress = _progressAt(position);
    container.invalidate(playbackProgressProvider);
  }
}

void main() {
  group('SeekUndoController', () {
    late _Harness harness;

    setUp(() {
      harness = _Harness();
      addTearDown(harness.container.dispose);
    });

    test('starts hidden', () {
      check(harness.state).isNull();
    });

    test('seekWithUndo records the origin and seeks to the target', () async {
      await harness.controller.seekWithUndo(const Duration(minutes: 20));

      check(harness.state).isNotNull()
        ..has((s) => s.origin, 'origin').equals(const Duration(minutes: 3))
        ..has((s) => s.episodeUrl, 'episodeUrl').equals(_episodeA.episodeUrl);
      check(harness.player.seeks).deepEquals([const Duration(minutes: 20)]);
    });

    test('goBack seeks to the origin and hides the pill', () async {
      await harness.controller.seekWithUndo(const Duration(minutes: 20));
      await harness.controller.goBack();

      check(harness.state).isNull();
      check(
        harness.player.seeks,
      ).deepEquals([const Duration(minutes: 20), const Duration(minutes: 3)]);
    });

    test('a second jump keeps the first origin', () async {
      await harness.controller.seekWithUndo(const Duration(minutes: 20));
      harness.moveTo(const Duration(minutes: 20));
      await harness.controller.seekWithUndo(const Duration(minutes: 40));
      await harness.controller.goBack();

      check(harness.player.seeks.last).equals(const Duration(minutes: 3));
    });

    test('hides after the visible duration', () {
      fakeAsync((async) {
        harness.controller.seekWithUndo(const Duration(minutes: 20));
        async.elapse(
          SeekUndoController.visibleDuration - const Duration(seconds: 1),
        );
        check(harness.state).isNotNull();

        async.elapse(const Duration(seconds: 1));
        check(harness.state).isNull();
      });
    });

    test('a second jump restarts the timer', () {
      fakeAsync((async) {
        harness.controller.seekWithUndo(const Duration(minutes: 20));
        async.elapse(const Duration(seconds: 8));
        harness.controller.seekWithUndo(const Duration(minutes: 30));
        async.elapse(const Duration(seconds: 8));
        check(harness.state).isNotNull();

        async.elapse(const Duration(seconds: 2));
        check(harness.state).isNull();
      });
    });

    test('dismiss hides without seeking', () async {
      await harness.controller.seekWithUndo(const Duration(minutes: 20));
      harness.controller.dismiss();

      check(harness.state).isNull();
      check(harness.player.seeks).deepEquals([const Duration(minutes: 20)]);
    });

    test('an episode change discards the origin', () async {
      await harness.controller.seekWithUndo(const Duration(minutes: 20));
      harness.container
          .read(nowPlayingControllerProvider.notifier)
          .setNowPlaying(_episodeB);

      check(harness.state).isNull();
      await harness.controller.goBack();
      check(harness.player.seeks).deepEquals([const Duration(minutes: 20)]);
    });

    test('a saved-position change on the same episode keeps it', () async {
      await harness.controller.seekWithUndo(const Duration(minutes: 20));
      harness.container
          .read(nowPlayingControllerProvider.notifier)
          .setNowPlaying(
            _episodeA.copyWith(savedPosition: const Duration(minutes: 20)),
          );

      check(harness.state).isNotNull();
    });

    test('uses the saved position when no audio is loaded', () async {
      harness.progress = null;
      harness.container
          .read(nowPlayingControllerProvider.notifier)
          .setNowPlaying(
            _episodeA.copyWith(savedPosition: const Duration(minutes: 7)),
          );
      await harness.controller.seekWithUndo(const Duration(minutes: 20));

      check(harness.state)
          .isNotNull()
          .has((s) => s.origin, 'origin')
          .equals(const Duration(minutes: 7));
    });
  });
}
