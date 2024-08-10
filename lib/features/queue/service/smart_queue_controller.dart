import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/feed/model/episode.dart';
import 'package:audiflow/features/queue/model/queue_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'smart_queue_controller.g.dart';

@Riverpod(keepAlive: true)
class SmartQueueController extends _$SmartQueueController {
  @override
  List<QueueItem> build() => [];

  Future<QueueItem?> pop() => throw UnimplementedError();

  Future<void> buildFromPodcastDetailsPage({
    required Episode start,
    required EpisodeFilterMode filterMode,
  }) =>
      throw UnimplementedError();
}
