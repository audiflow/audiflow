import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audiflow_app/features/car/services/car_artwork_resolver.dart';
import 'package:audiflow_app/features/car/services/car_media_controls.dart';
import 'package:audiflow_app/features/car/services/car_providers.dart';
import 'package:audiflow_app/features/player/services/audiflow_audio_handler.dart';
import 'package:audiflow_app/features/player/services/session_queue_channel.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/locale_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:rxdart/rxdart.dart';

import '../../../helpers/player_stubs.dart';

class _FakeAudioPlayer extends Fake implements just_audio.AudioPlayer {
  final events = StreamController<just_audio.PlaybackEvent>.broadcast();

  @override
  Stream<just_audio.PlaybackEvent> get playbackEventStream => events.stream;

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

class _EnglishLocale extends LocaleController {
  static const locale = Locale('en');

  @override
  Locale? build() => locale;
}

class _FakeArtworkResolver implements CarArtworkResolver {
  _FakeArtworkResolver(this.uri);

  final Uri? uri;
  final requests = <String>[];
  final backgroundFlags = <bool>[];

  @override
  Future<Uri?> resolve(String artworkUrl, {bool background = false}) async {
    requests.add(artworkUrl);
    backgroundFlags.add(background);
    return uri;
  }
}

class _RecordingTitleChannel extends Fake implements SessionQueueChannel {
  _RecordingTitleChannel({this.delivers = true});

  final bool delivers;
  final titles = <String>[];

  @override
  Future<bool> setTitle(String title) async {
    titles.add(title);
    return delivers;
  }
}

class _EmptyEpisodeRepository extends Fake implements EpisodeRepository {
  @override
  Future<Episode?> getById(int id) async => null;
}

class _FakeQueueService extends Fake implements QueueService {
  final skippedTo = <int>[];

  @override
  Future<Episode?> skipToItem(int queueItemId) async {
    skippedTo.add(queueItemId);
    return null;
  }
}

class _SpeedRecordingPlayer extends StubAudioPlayerController {
  _SpeedRecordingPlayer() : super(const PlaybackState.idle());

  final calls = <({double speed, AudioSettingsScope scope})>[];
  Object? failure;
  var resumed = 0;

  @override
  Future<void> resume() async => resumed++;

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

  group('session queue', () {
    const flushDelay = Duration(milliseconds: 500);
    final queued = QueueItemWithEpisode(
      queueItem: QueueItem()
        ..id = 11
        ..episodeId = 2
        ..position = 0
        ..addedAt = DateTime(2026),
      episode: Episode()
        ..id = 2
        ..podcastId = 1
        ..guid = 'g'
        ..title = 'Up next'
        ..audioUrl = 'https://example.com/2.mp3',
      artworkUrl: 'https://example.com/2.jpg',
    );
    const nowPlaying = NowPlayingInfo(
      episodeUrl: 'https://example.com/1.mp3',
      episodeTitle: 'Playing',
      podcastTitle: 'Podcast',
    );

    late _FakeQueueService queueService;
    late ProviderContainer container;
    late _RecordingTitleChannel titleChannel;

    AudiflowAudioHandler started(
      FakeAsync async, {
      CarArtworkResolver? resolver,
      NowPlayingInfo info = nowPlaying,
      bool titleDelivered = true,
    }) {
      queueService = _FakeQueueService();
      titleChannel = _RecordingTitleChannel(delivers: titleDelivered);
      container = ProviderContainer(
        overrides: [
          sessionQueueChannelProvider.overrideWithValue(titleChannel),
          localeControllerProvider.overrideWith(_EnglishLocale.new),
          audioPlayerProvider.overrideWithValue(audioPlayer),
          audioPlayerControllerProvider.overrideWith(() => player),
          nowPlayingAudioSettingsProvider.overrideWithValue(null),
          nowPlayingControllerProvider.overrideWith(
            () => StubNowPlayingController(info),
          ),
          playbackQueueProvider.overrideWith(
            (ref) => Stream.value(PlaybackQueue(manualItems: [queued])),
          ),
          queueServiceProvider.overrideWithValue(queueService),
          episodeRepositoryProvider.overrideWithValue(
            _EmptyEpisodeRepository(),
          ),
          if (resolver != null)
            carArtworkResolverProvider.overrideWith((ref) async => resolver),
        ],
      );
      addTearDown(container.dispose);
      final subject = container.read(_handlerProvider)..startSessionQueue();
      async
        ..flushMicrotasks()
        ..elapse(flushDelay);
      return subject;
    }

    test('publishes the rows and marks the playing one', () {
      fakeAsync((async) {
        final subject = started(async);

        check(
          subject.queue.value.map((item) => item.title),
        ).deepEquals([nowPlaying.episodeTitle, queued.episode.title]);
        check(subject.playbackState.value.queueIndex).equals(0);
      });
    });

    test('titles the queue in the app language', () {
      fakeAsync((async) {
        started(async);

        check(titleChannel.titles).deepEquals([
          lookupAppLocalizations(_EnglishLocale.locale).carUpNextTab,
        ]);
      });
    });

    test('fetches images only after a head unit browses', () {
      fakeAsync((async) {
        final artUri = Uri.parse('content://art/1');
        final resolver = _FakeArtworkResolver(artUri);
        final subject = started(async, resolver: resolver);
        check(resolver.requests).isEmpty();

        container.read(carBrowsedProvider.notifier).mark();
        async
          ..elapse(flushDelay)
          ..flushMicrotasks();

        check(resolver.requests).deepEquals([queued.artworkUrl!]);
        check(resolver.backgroundFlags).deepEquals([true]);
        check(subject.queue.value.last.artUri).equals(artUri);
      });
    });

    test('updates the playing row when its podcast title changes', () {
      fakeAsync((async) {
        final subject = started(async);
        final changed = nowPlaying.copyWith(podcastTitle: 'Renamed');

        container
            .read(nowPlayingControllerProvider.notifier)
            .setNowPlaying(changed);
        async.elapse(flushDelay);

        check(subject.queue.value.first.artist).equals(changed.podcastTitle);
      });
    });

    test('fetches the playing row image when its artwork changes', () {
      fakeAsync((async) {
        final resolver = _FakeArtworkResolver(Uri.parse('content://art/1'));
        started(async, resolver: resolver);
        container.read(carBrowsedProvider.notifier).mark();
        async.elapse(flushDelay);
        const artworkUrl = 'https://example.com/1.jpg';

        container
            .read(nowPlayingControllerProvider.notifier)
            .updateArtworkUrl(artworkUrl);
        async.elapse(flushDelay);

        check(resolver.requests).contains(artworkUrl);
      });
    });

    test('sends an undelivered title again with the next flush', () {
      fakeAsync((async) {
        started(
          async,
          resolver: _FakeArtworkResolver(null),
          titleDelivered: false,
        );
        check(titleChannel.titles).length.equals(1);

        container.read(carBrowsedProvider.notifier).mark();
        async.elapse(flushDelay);

        check(titleChannel.titles).length.isGreaterThan(1);
      });
    });

    test('does not send a delivered title again for an unchanged list', () {
      fakeAsync((async) {
        started(async, resolver: _FakeArtworkResolver(null));

        container.read(carBrowsedProvider.notifier).mark();
        async.elapse(flushDelay);

        check(titleChannel.titles).length.equals(1);
      });
    });

    test('keeps the queue index when the player reports an event', () {
      fakeAsync((async) {
        final subject = started(async);

        audioPlayer.events.add(just_audio.PlaybackEvent(currentIndex: 5));
        async.flushMicrotasks();

        check(subject.playbackState.value.queueIndex).equals(0);
      });
    });

    test('a tap on an up-next row jumps the queue to it', () {
      fakeAsync((async) {
        final subject = started(async);

        unawaited(subject.skipToQueueItem(1));
        async.flushMicrotasks();

        check(queueService.skippedTo).deepEquals([queued.queueItem.id]);
      });
    });

    test('a tap on the playing row resumes it when its record is gone', () {
      fakeAsync((async) {
        final subject = started(
          async,
          info: nowPlaying.copyWith(
            episode: Episode()
              ..id = 1
              ..podcastId = 1
              ..guid = 'gone'
              ..title = nowPlaying.episodeTitle
              ..audioUrl = nowPlaying.episodeUrl,
          ),
        );

        unawaited(subject.skipToQueueItem(0));
        async.flushMicrotasks();

        check(player.resumed).equals(1);
      });
    });

    test('a tap on the playing row resumes it', () {
      fakeAsync((async) {
        final subject = started(async);

        unawaited(subject.skipToQueueItem(0));
        async.flushMicrotasks();

        check(player.resumed).equals(1);
        check(queueService.skippedTo).isEmpty();
      });
    });
  });

  test('leaves the queue alone until the session queue starts', () async {
    final subject = handler();

    await subject.skipToQueueItem(0);

    check(subject.queue.value).isEmpty();
    check(player.resumed).equals(0);
  });

  test('never reports the player index as the queue index', () async {
    final subject = handler();

    audioPlayer.events.add(just_audio.PlaybackEvent(currentIndex: 5));
    await pumpEventQueue();

    check(subject.playbackState.value.queueIndex).isNull();
  });

  test('publishes the rate the player actually changed to', () async {
    final subject = handler();

    audioPlayer.changeSpeed(1.5);
    await pumpEventQueue();

    check(subject.playbackState.value.speed).equals(1.5);
  });
}
