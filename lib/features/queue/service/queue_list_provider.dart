import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'queue_list_provider.freezed.dart';
part 'queue_list_provider.g.dart';

@Riverpod(keepAlive: true)
class QueueList extends _$QueueList {
  final _queueInputState = PublishSubject<Queue>();

  @override
  QueueListState build() {
    _listen();
    ref.listen(
      queueControllerProvider,
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
      final knownEpisodes = <Episode>{...state.queue.map((e) => e.episode)};

      final idsToLoad = Set<int>.from(
        queue
            .map((i) => i.eid)
            .where((eid) => !knownEpisodes.any((e) => e.id == eid)),
      );
      if (idsToLoad.isNotEmpty) {
        final episodes =
            await ref.read(episodeRepositoryProvider).findEpisodes(idsToLoad);
        knownEpisodes.addAll(episodes.where((e) => e != null).cast<Episode>());
      }

      state = QueueListState(
        queue: _generate(queue, knownEpisodes),
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
            final e = episodes.firstWhereOrNull((e) => e.id == item.eid);
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
