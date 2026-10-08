import 'package:audiflow_domain/audiflow_domain.dart';

/// [NowPlayingController] seeded with a fixed value instead of null.
class StubNowPlayingController extends NowPlayingController {
  StubNowPlayingController(this._initial);
  final NowPlayingInfo? _initial;

  @override
  NowPlayingInfo? build() => _initial;
}

/// [AppSettingsRepository] exposing only the settings the player widgets
/// read; anything else throws so an unexpected call is loud.
class StubAppSettingsRepository implements AppSettingsRepository {
  StubAppSettingsRepository({
    this.skipForwardSeconds = 30,
    this.skipBackwardSeconds = 15,
    this.showRemainingTime = true,
  });

  final int skipForwardSeconds;
  final int skipBackwardSeconds;
  bool showRemainingTime;

  @override
  bool getShowRemainingTime() => showRemainingTime;

  @override
  Future<void> setShowRemainingTime(bool enabled) async =>
      showRemainingTime = enabled;

  @override
  int getSkipForwardSeconds() => skipForwardSeconds;

  @override
  int getSkipBackwardSeconds() => skipBackwardSeconds;

  @override
  double getPlaybackSpeed() => 1.0;

  @override
  List<double> getRecentPlaybackSpeeds() => const [];

  @override
  bool getSkipSilence() => false;

  @override
  bool getVoiceBoost() => false;

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

/// [TranscriptService] answering a fixed load result instead of fetching.
///
/// Pass [result] to control when the answer arrives; by default the
/// episode has no transcript that loads.
class StubTranscriptService implements TranscriptService {
  StubTranscriptService([Future<int?>? result])
    : _result = result ?? Future.value();

  final Future<int?> _result;

  @override
  Future<int?> ensureContent(int episodeId) => _result;
}
