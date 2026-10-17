import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

/// Streams each episode's history from a controller the test drives.
class _StreamingHistoryRepository implements PlaybackHistoryRepository {
  final Map<int, StreamController<PlaybackHistory?>> controllers = {};

  StreamController<PlaybackHistory?> controllerFor(int episodeId) =>
      controllers.putIfAbsent(episodeId, StreamController.broadcast);

  @override
  Stream<PlaybackHistory?> watchByEpisodeId(int episodeId) =>
      controllerFor(episodeId).stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

PlaybackHistory _history(int episodeId, int totalListenedMs) =>
    PlaybackHistory()
      ..episodeId = episodeId
      ..totalListenedMs = totalListenedMs;

void main() {
  late _StreamingHistoryRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _StreamingHistoryRepository();
    container = ProviderContainer(
      overrides: [
        playbackHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('follows history writes for the episode', () async {
    final subscription = container.listen(
      episodePlaybackHistoryProvider(7),
      (_, _) {},
    );
    addTearDown(subscription.close);
    final controller = repository.controllerFor(7);

    controller.add(_history(7, 1000));
    await container.read(episodePlaybackHistoryProvider(7).future);
    check(subscription.read().value?.totalListenedMs).equals(1000);

    controller.add(_history(7, 61000));
    await Future<void>.delayed(Duration.zero);
    check(subscription.read().value?.totalListenedMs).equals(61000);
  });

  test('is keyed by episode id', () async {
    final subscription = container.listen(
      episodePlaybackHistoryProvider(7),
      (_, _) {},
    );
    addTearDown(subscription.close);

    repository.controllerFor(8).add(_history(8, 5000));
    await Future<void>.delayed(Duration.zero);

    check(subscription.read().hasValue).isFalse();
  });
}
