import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/episode/data/episode_stats_provider.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/utils/duration.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'seekbar_controller.freezed.dart';
part 'seekbar_controller.g.dart';

class SeekbarController {
  void fastForward() => throw UnimplementedError();

  void rewind() => throw UnimplementedError();

  void seekTo(Duration position) => throw UnimplementedError();
}

@freezed
class SeekbarState with _$SeekbarState {
  const factory SeekbarState({
    required Duration position,
    required Duration duration,
  }) = _SeekbarState;
}

@riverpod
class AudioSeekbarController extends _$AudioSeekbarController
    implements SeekbarController {
  AudioPlayerService get audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  @override
  SeekbarState? build() {
    final (position, duration) = ref.watch(
      audioPlayerServiceProvider.select(
        (state) => (
          state?.position,
          state?.episode.duration,
        ),
      ),
    );

    return position == null || duration == null
        ? null
        : SeekbarState(position: position, duration: duration);
  }

  @override
  void fastForward() => audioPlayerService.fastForward();

  @override
  void rewind() => audioPlayerService.rewind();

  @override
  void seekTo(Duration position) => audioPlayerService.seek(position: position);
}

@riverpod
class EpisodeSeekbarController extends _$EpisodeSeekbarController
    implements SeekbarController {
  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  @override
  SeekbarState? build(Episode episode) {
    final stats = ref.watch(episodeStatsProvider(eid: episode.id));
    return stats.valueOrNull == null
        ? null
        : SeekbarState(
            position: stats.requireValue!.position,
            duration: stats.requireValue!.duration ??
                episode.duration ??
                Duration.zero,
          );
  }

  @override
  void fastForward() {
    if (state == null) {
      return;
    }

    _episodeStatsRepository.updateEpisodeStats(
      EpisodeStatsUpdateParam(
        pid: episode.pid,
        eid: episode.id,
        ordinal: episode.ordinal,
        position: minDuration(
          state!.duration,
          state!.position + const Duration(seconds: 30),
        ),
      ),
    );
  }

  @override
  void rewind() {
    if (state == null) {
      return;
    }

    _episodeStatsRepository.updateEpisodeStats(
      EpisodeStatsUpdateParam(
        pid: episode.pid,
        eid: episode.id,
        ordinal: episode.ordinal,
        position: minDuration(
          state!.duration,
          state!.position - const Duration(seconds: 10),
        ),
      ),
    );
  }

  @override
  void seekTo(Duration position) {
    if (state == null) {
      return;
    }

    _episodeStatsRepository.updateEpisodeStats(
      EpisodeStatsUpdateParam(
        pid: episode.pid,
        eid: episode.id,
        ordinal: episode.ordinal,
        position: maxDuration(
          Duration.zero,
          minDuration(
            state!.duration,
            position,
          ),
        ),
      ),
    );
  }
}
