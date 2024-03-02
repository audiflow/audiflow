import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/services/queue/queue_manager.dart';

part 'queue_list_provider.freezed.dart';
part 'queue_list_provider.g.dart';

@Riverpod(keepAlive: true)
class QueueList extends _$QueueList {
  final _queueInputState = PublishSubject<Queue>();

  @override
  QueueListState build() {
    _listen();
    ref.listen(
      queueManagerProvider,
      (_, next) => _queueInputState.add(next),
      fireImmediately: true,
    );
    return const QueueListState();
  }

  void _listen() {
    final sub = _queueInputState
        .asyncMap(Future.value)
        .map((queue) => queue.queue)
        .listen((queue) async {
      final episodes = <Episode>{...state.queue.map((e) => e.episode)};

      final guidsToLoad = Set<String>.from(
        queue
            .map((i) => i.guid)
            .where((guid) => !episodes.any((e) => e.guid == guid)),
      );
      if (guidsToLoad.isNotEmpty) {
        final episodes =
            await ref.read(podcastServiceProvider).loadEpisodes(guidsToLoad);
        episodes.addAll(episodes.where((e) => e != null).cast<Episode>());
      }

      state = QueueListState(
        queue: _generate(queue, episodes),
      );
    });
    ref.onDispose(sub.cancel);
  }

  List<QueuedEpisode> _generate(
    Iterable<QueueItem> items,
    Set<Episode> episodes,
  ) {
    return items
        .map(
          (item) {
            final e = episodes.firstWhereOrNull((e) => e.guid == item.guid);
            return (item, e);
          },
        )
        .where((e) => e.$2 != null)
        .map((e) => QueuedEpisode(item: e.$1, episode: e.$2!))
        .toList();
  }
}

@freezed
class QueueListState with _$QueueListState {
  const factory QueueListState({
    @Default(<QueuedEpisode>[]) List<QueuedEpisode> queue,
  }) = _QueueListState;
}

@freezed
class QueuedEpisode with _$QueuedEpisode {
  const factory QueuedEpisode({
    required QueueItem item,
    required Episode episode,
  }) = _QueuedEpisode;
}
