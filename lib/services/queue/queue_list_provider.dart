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
    final sub = _queueInputState.asyncMap(Future.value).listen((queue) async {
      final known = <Episode>{...state.primary, ...state.adhoc};

      final toLoad = <String>{
        ...queue.queue.map((i) => i.guid).where(
              (guid) =>
                  !state.primary.any((e) => e.guid == guid) &&
                  !state.adhoc.any((e) => e.guid == guid),
            ),
      };
      if (toLoad.isNotEmpty) {
        final episodes =
            await ref.read(podcastServiceProvider).loadEpisodes(toLoad);
        known.addAll(episodes.where((e) => e != null).cast<Episode>());
      }

      state = QueueListState(
        primary: queue.primary
            .map((item) => known.firstWhereOrNull((e) => e.guid == item.guid))
            .where((e) => e != null)
            .cast<Episode>()
            .toList(),
        adhoc: queue.adhoc
            .map((item) => known.firstWhereOrNull((e) => e.guid == item.guid))
            .where((e) => e != null)
            .cast<Episode>()
            .toList(),
      );
    });
    ref.onDispose(sub.cancel);
  }
}

@freezed
class QueueListState with _$QueueListState {
  const factory QueueListState({
    @Default(<Episode>[]) List<Episode> primary,
    @Default(<Episode>[]) List<Episode> adhoc,
  }) = _QueueListState;
}
