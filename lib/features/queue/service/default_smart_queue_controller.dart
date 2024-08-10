import 'package:audiflow/events/queue_event.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/feed/model/episode.dart';
import 'package:audiflow/features/queue/data/smart_queue_repository.dart';
import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:audiflow/features/queue/model/smart_queue.dart';
import 'package:audiflow/features/queue/service/smart_queue_builder/smart_queue_from_podcast_details_page.dart';
import 'package:audiflow/features/queue/service/smart_queue_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_smart_queue_controller.g.dart';

@Riverpod(keepAlive: true)
class DefaultSmartQueueController extends _$DefaultSmartQueueController
    implements SmartQueueController {
  SmartQueueRepository get _repository =>
      ref.read(smartQueueRepositoryProvider);

  @override
  List<QueueItem> build() {
    _load();
    _listen();
    return [];
  }

  Future<void> _load() async {
    final info = await _repository.load();
    if (info != null) {
      ref
          .read(smartQueueEventStreamProvider.notifier)
          .add(SmartQueueUpdatedEvent(info));
    }
  }

  @override
  Future<QueueItem?> pop() async {
    final info = await _repository.load();
    if (info == null) {
      return null;
    }

    switch (info.type) {
      case SmartQueueType.detailsPage:
        final builder =
            ref.read(smartQueueFromPodcastDetailsPageProvider.notifier);
        if (await builder.decodeState(info.json) && await builder.moveNext()) {
          final json = builder.encodeState();
          final model = SmartQueueInfo(
            type: SmartQueueType.detailsPage,
            json: json,
          );
          await _repository.save(model);
          return builder.current;
        }
    }
    return null;
  }

  @override
  Future<void> buildFromPodcastDetailsPage({
    required Episode start,
    required EpisodeFilterMode filterMode,
  }) async {
    final builder =
    ref.read(smartQueueFromPodcastDetailsPageProvider.notifier)
      ..setup(start: start, filterMode: filterMode);
    final json = builder.encodeState();
    final model = SmartQueueInfo(
      type: SmartQueueType.detailsPage,
      json: json,
    );
    await _repository.save(model);
  }

  void _listen() {
    ref.listen(smartQueueEventStreamProvider, (_, next) async {
      switch (next.requireValue) {
        case SmartQueueUpdatedEvent(info: final info):
          switch (info.type) {
            case SmartQueueType.detailsPage:
              final builder =
                  ref.read(smartQueueFromPodcastDetailsPageProvider.notifier);
              if (await builder.decodeState(info.json)) {
                state = await builder.getQueuedItems(limit: 20);
              } else {
                state = [];
              }
          }
      }
    });
  }
}
