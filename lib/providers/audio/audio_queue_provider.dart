import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/events/queue_event.dart';
import 'package:seasoning/providers/audio_player_service_provider.dart';
import 'package:seasoning/providers/podcast_service_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';

part 'audio_queue_provider.g.dart';

@riverpod
class AudioQueue extends _$AudioQueue {
  AudioQueue() {
    _handleQueueEvents();
  }

  final PublishSubject<QueueEvent> _queueEvent = PublishSubject<QueueEvent>();

  @override
  QueueListState build() {
    return const QueueListState.empty();
  }

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider);

  PodcastService get _podcastService => ref.read(podcastServiceProvider);

  void _handleQueueEvents() {
    _queueEvent.listen((QueueEvent event) async {
      if (event is QueueAddEvent) {
        final e = event.episode;
        await _audioPlayerService.addUpNextEpisode(e);
      } else if (event is QueueRemoveEvent) {
        final e = event.episode;
        await _audioPlayerService.removeUpNextEpisode(e);
      } else if (event is QueueMoveEvent) {
        final e = event.episode;
        await _audioPlayerService.moveUpNextEpisode(
            e, event.oldIndex, event.newIndex,);
      } else if (event is QueueClearEvent) {
        await _audioPlayerService.clearUpNext();
      }
    });

    _audioPlayerService.queueState!
        .debounceTime(const Duration(seconds: 2))
        .listen((newState) {
      state = newState;
      if (newState is ReadyQueueListState) {
        _podcastService.saveQueue(newState.queue);
      }
    });
  }

  Function(QueueEvent) get queueEvent => _queueEvent.sink.add;
}
