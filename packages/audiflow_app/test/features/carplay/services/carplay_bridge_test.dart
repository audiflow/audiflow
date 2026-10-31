import 'package:audiflow_app/features/car/models/car_list_item.dart';
import 'package:audiflow_app/features/carplay/services/carplay_bridge.dart';
import 'package:audiflow_app/features/car/services/car_catalog.dart';
import 'package:audiflow_app/features/car/services/car_playback.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

class _FakeCatalog extends Fake implements CarCatalog {
  final requests = <(CarSection, int?)>[];
  List<CarListItem> rows = const [];
  Object? error;

  @override
  Future<List<CarListItem>> items(CarSection section, {int? podcastId}) async {
    requests.add((section, podcastId));
    if (error case final e?) throw e;
    return rows;
  }
}

class _FakePlayback extends Fake implements CarPlayback {
  final playedEpisodes = <int>[];
  final playedQueueItems = <int>[];
  double? nextSpeed = 1.5;

  bool found = true;

  @override
  Future<bool> playEpisode(int episodeId) async {
    playedEpisodes.add(episodeId);
    return found;
  }

  @override
  Future<bool> playQueueItem(int queueItemId) async {
    playedQueueItems.add(queueItemId);
    return found;
  }

  @override
  Future<double?> cycleSpeed() async => nextSpeed;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(CarPlayBridge.channelName);
  const codec = StandardMethodCodec();
  const labels = {'upNext': 'Up Next'};
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> sent;
  late List<bool> connectionChanges;
  late _FakeCatalog catalog;
  late _FakePlayback playback;
  late CarPlayBridge bridge;

  setUp(() {
    sent = [];
    connectionChanges = [];
    catalog = _FakeCatalog();
    playback = _FakePlayback();
    messenger.setMockMethodCallHandler(channel, (call) async {
      sent.add(call);
      return null;
    });
    bridge = CarPlayBridge(
      catalog: () => catalog,
      playback: playback,
      labels: () => labels,
      logger: Logger(level: Level.off),
      onConnectionChanged: ({required connected}) =>
          connectionChanges.add(connected),
      invalidationDelay: Duration.zero,
    )..start();
  });

  tearDown(() {
    bridge.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });

  /// Sends [method] from the native side and returns the decoded reply.
  Future<Object?> fromNative(String method, [Object? arguments]) async {
    final reply = await messenger.handlePlatformMessage(
      CarPlayBridge.channelName,
      codec.encodeMethodCall(MethodCall(method, arguments)),
      (_) {},
    );
    return codec.decodeEnvelope(reply!);
  }

  Iterable<MethodCall> sentNamed(String method) =>
      sent.where((c) => c.method == method);

  test('announces ready with the labels on start', () async {
    await pumpEventQueue();
    check(sentNamed('ready').single.arguments)
        .isA<Map<Object?, Object?>>()
        .has((a) => a['labels'], 'labels')
        .isA<Map<Object?, Object?>>()
        .deepEquals(labels);
  });

  test('tracks connection and reports each change once', () async {
    await fromNative('connected');
    await fromNative('connected');
    check(bridge.isConnected).isTrue();
    await fromNative('disconnected');

    check(bridge.isConnected).isFalse();
    check(connectionChanges).deepEquals([true, false]);
  });

  test('answers listItems with the catalog rows', () async {
    const item = CarListItem(id: 3, title: 'Episode 3', isPlaying: true);
    catalog.rows = [item];

    final reply = await fromNative('listItems', {
      'section': CarSection.podcast.name,
      'podcastId': 7,
    });

    check(catalog.requests.single).equals((CarSection.podcast, 7));
    check(reply).isA<List<Object?>>().deepEquals([item.toMap()]);
  });

  test('rejects an unknown section', () async {
    await check(
      fromNative('listItems', {'section': 'radio'}),
    ).throws<PlatformException>();
    check(catalog.requests).isEmpty();
  });

  test('reports a catalog failure as an error reply', () async {
    catalog.error = StateError('db closed');

    await check(
      fromNative('listItems', {'section': CarSection.library.name}),
    ).throws<PlatformException>();
  });

  test('plays a queue item from upNext and an episode elsewhere', () async {
    await fromNative('playItem', {'section': CarSection.upNext.name, 'id': 11});
    await fromNative('playItem', {
      'section': CarSection.downloads.name,
      'id': 22,
    });

    check(playback.playedQueueItems).deepEquals([11]);
    check(playback.playedEpisodes).deepEquals([22]);
  });

  test('reports a row that is gone as an error', () async {
    playback.found = false;

    await check(
      fromNative('playItem', {'section': CarSection.upNext.name, 'id': 5}),
    ).throws<PlatformException>();
  });

  test('rejects playing a podcast row', () async {
    await check(
      fromNative('playItem', {'section': CarSection.library.name, 'id': 1}),
    ).throws<PlatformException>();
    check(playback.playedEpisodes).isEmpty();
  });

  test('returns the new speed from cycleSpeed', () async {
    check(await fromNative('cycleSpeed')).equals(playback.nextSpeed);
  });

  test('sends now-playing controls even while disconnected', () async {
    await bridge.sendNowPlayingControls(
      speed: 1.5,
      skipForwardSeconds: 30,
      skipBackwardSeconds: 15,
    );

    check(
      sentNamed('nowPlayingControls').single.arguments,
    ).isA<Map<Object?, Object?>>().deepEquals({
      'speed': 1.5,
      'skipForwardSeconds': 30,
      'skipBackwardSeconds': 15,
    });
  });

  test('ignores invalidations while disconnected', () async {
    bridge.invalidate({CarSection.upNext});
    await pumpEventQueue();

    check(sentNamed('invalidate')).isEmpty();
  });

  test('coalesces invalidations while connected', () async {
    await fromNative('connected');
    bridge
      ..invalidate({CarSection.upNext})
      ..invalidate({CarSection.upNext, CarSection.downloads});
    await pumpEventQueue();

    final invalidation = sentNamed('invalidate').single.arguments;
    check(invalidation)
        .isA<Map<Object?, Object?>>()
        .has((a) => a['sections'], 'sections')
        .isA<List<Object?>>()
        .unorderedEquals([CarSection.upNext.name, CarSection.downloads.name]);
  });

  test('drops pending invalidations on disconnect', () async {
    await fromNative('connected');
    bridge.invalidate({CarSection.upNext});
    await fromNative('disconnected');
    await pumpEventQueue();

    check(sentNamed('invalidate')).isEmpty();
  });
}
