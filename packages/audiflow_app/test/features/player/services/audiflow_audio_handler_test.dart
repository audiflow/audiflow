import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audiflow_app/features/car/services/car_media_controls.dart';
import 'package:audiflow_app/features/player/services/audiflow_audio_handler.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:rxdart/rxdart.dart';

import '../../../helpers/player_stubs.dart';

class _FakeAudioPlayer extends Fake implements just_audio.AudioPlayer {
  @override
  Stream<just_audio.PlaybackEvent> get playbackEventStream =>
      const Stream.empty();

  @override
  bool get playing => true;

  @override
  just_audio.ProcessingState get processingState =>
      just_audio.ProcessingState.ready;

  @override
  Duration get position => Duration.zero;

  @override
  Duration get bufferedPosition => Duration.zero;

  final _speed = BehaviorSubject<double>.seeded(1.0);

  void changeSpeed(double value) => _speed.add(value);

  @override
  Stream<double> get speedStream => _speed.stream;

  @override
  double get speed => _speed.value;
}

class _SpeedRecordingPlayer extends StubAudioPlayerController {
  _SpeedRecordingPlayer() : super(const PlaybackState.idle());

  final calls = <({double speed, AudioSettingsScope scope})>[];
  Object? failure;

  @override
  Future<void> setSpeed(
    double speed, {
    required AudioSettingsScope scope,
    bool transient = false,
  }) async {
    if (failure case final Object error) throw error;
    calls.add((speed: speed, scope: scope));
  }
}

EffectiveAudioSettings _resolved(double speed, AudioSettingsScope scope) => (
  scope: scope,
  settings: AudioSettings(speed: speed, effects: PlaybackEffects.off),
);

final _handlerProvider = Provider<AudiflowAudioHandler>(
  AudiflowAudioHandler.new,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _SpeedRecordingPlayer player;
  late _FakeAudioPlayer audioPlayer;

  // audio_session talks to its plugin from the handler's constructor.
  setUp(() {
    for (final channel in const [
      'com.ryanheise.audio_session',
      'com.ryanheise.android_audio_manager',
      'com.ryanheise.av_audio_session',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(channel), (_) async => null);
    }
    player = _SpeedRecordingPlayer();
    audioPlayer = _FakeAudioPlayer();
  });

  AudiflowAudioHandler handler({EffectiveAudioSettings? resolved}) {
    final container = ProviderContainer(
      overrides: [
        audioPlayerProvider.overrideWithValue(audioPlayer),
        audioPlayerControllerProvider.overrideWith(() => player),
        nowPlayingAudioSettingsProvider.overrideWithValue(resolved),
      ],
    );
    addTearDown(container.dispose);
    return container.read(_handlerProvider);
  }

  group('customAction', () {
    test('steps the speed and saves it to the podcast scope', () async {
      const scope = PodcastAudioSettingsScope(7);

      await handler(
        resolved: _resolved(1.2, scope),
      ).customAction(carCycleSpeedAction);

      check(player.calls).deepEquals([(speed: 1.5, scope: scope)]);
    });

    test('saves to the global scope for a podcast without its own', () async {
      const scope = GlobalAudioSettingsScope();

      await handler(
        resolved: _resolved(2.0, scope),
      ).customAction(carCycleSpeedAction);

      check(player.calls).deepEquals([(speed: 1.0, scope: scope)]);
    });

    test('does nothing while the now-playing settings load', () async {
      await handler().customAction(carCycleSpeedAction);

      check(player.calls).isEmpty();
    });

    test('ignores an action it does not know', () async {
      await handler(
        resolved: _resolved(1.0, const GlobalAudioSettingsScope()),
      ).customAction('other');

      check(player.calls).isEmpty();
    });

    test('keeps a failed speed change away from the platform call', () async {
      player.failure = StateError('engine');

      await check(
        handler(
          resolved: _resolved(1.0, const GlobalAudioSettingsScope()),
        ).customAction(carCycleSpeedAction),
      ).completes();
    });
  });

  group('updateMediaControlValues', () {
    const values = (
      speed: 1.5,
      skipForwardSeconds: 45,
      skipBackwardSeconds: 15,
    );

    test('republishes the controls for the new values', () {
      final subject = handler()..updateMediaControlValues(values);

      check(subject.playbackState.value.controls)
        ..contains(carSpeedControl(1.5))
        ..contains(carFastForwardControl(45))
        ..contains(carRewindControl(15));
    });

    test('publishes compact indices matching the new controls', () {
      final subject = handler()..updateMediaControlValues(values);

      check(
        subject.playbackState.value.androidCompactActionIndices,
      ).equals(nowPlayingCompactActionIndices(values: values));
    });

    test('keeps the published playing flag', () {
      // iOS interruptions publish `paused` while just_audio still says it is
      // playing; a settings change must not undo that.
      final subject = handler();
      subject.playbackState.add(
        subject.playbackState.value.copyWith(playing: false, queueIndex: 3),
      );

      subject.updateMediaControlValues(values);

      final state = subject.playbackState.value;
      check(state.playing).isFalse();
      check(state.queueIndex).equals(3);
      check(state.controls).contains(audio_service.MediaControl.play);
    });
  });

  test('publishes the rate the player actually changed to', () async {
    final subject = handler();

    audioPlayer.changeSpeed(1.5);
    await pumpEventQueue();

    check(subject.playbackState.value.speed).equals(1.5);
  });
}
