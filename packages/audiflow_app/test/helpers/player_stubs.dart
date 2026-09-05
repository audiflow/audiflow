import 'package:audiflow_domain/audiflow_domain.dart';

/// [NowPlayingController] seeded with a fixed value instead of null.
class StubNowPlayingController extends NowPlayingController {
  StubNowPlayingController(this._initial);
  final NowPlayingInfo? _initial;

  @override
  NowPlayingInfo? build() => _initial;
}

/// [AppSettingsRepository] exposing only the skip intervals the player
/// widgets read; anything else throws so an unexpected call is loud.
class StubAppSettingsRepository implements AppSettingsRepository {
  StubAppSettingsRepository({
    this.skipForwardSeconds = 30,
    this.skipBackwardSeconds = 15,
  });

  final int skipForwardSeconds;
  final int skipBackwardSeconds;

  @override
  int getSkipForwardSeconds() => skipForwardSeconds;

  @override
  int getSkipBackwardSeconds() => skipBackwardSeconds;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// [AudioPlayerController] that starts in a fixed state and records skips.
///
/// Only [skipForward] is overridden; the real methods touch the audio
/// player, so tests that tap other controls must override them too.
class StubAudioPlayerController extends AudioPlayerController {
  StubAudioPlayerController(this._initial);
  final PlaybackState _initial;

  bool skipForwardCalled = false;

  @override
  PlaybackState build() => _initial;

  @override
  Future<void> skipForward() async {
    skipForwardCalled = true;
  }
}
