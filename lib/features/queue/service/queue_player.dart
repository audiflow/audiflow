import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/feed/model/episode.dart';
import 'package:audiflow/features/queue/data/queue_repository.dart';
import 'package:audiflow/features/queue/model/auto_queue_builder_info.dart';
import 'package:audiflow/features/queue/service/auto_queue_builder/auto_queue_builder.dart';
import 'package:audiflow/features/queue/service/auto_queue_builder/auto_queue_from_podcast_details_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'queue_player.g.dart';

@Riverpod(keepAlive: true)
QueuePlayer queuePlayer(QueuePlayerRef ref) => QueuePlayer(ref);

class QueuePlayer {
  QueuePlayer(this._ref);

  final Ref _ref;
  AutoQueueBuilder? _current;

  Future<void> playFromPodcastDetailsPage({
    required Episode start,
    required EpisodeFilterMode filterMode,
  }) async {
    final builder = _ref.read(autoQueueFromPodcastDetailsPageProvider.notifier)
      ..setup(start: start, filterMode: filterMode);
    _current?.clear();
    _current = builder;

    final json = builder.encodeState();
    await _ref
        .read(queueRepositoryProvider)
        .saveAutoQueueBuilderData(AutoQueueBuilderType.detailsPage, json);
  }
}
