import 'dart:async';

import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/episode/data/episode_list_entry_repository.dart';
import 'package:audiflow/features/browser/episode/service/episode_list_entry_populator.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_episodes_controller.freezed.dart';
part 'podcast_episodes_controller.g.dart';

@riverpod
class PodcastEpisodesController extends _$PodcastEpisodesController {
  String get _appDocDir => ref.read(appDocDirProvider);

  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  EpisodeListEntryRepository get _episodeListEntryRepository =>
      ref.read(episodeListEntryRepositoryProvider);

  AudioPlayerState? get _audioPlayerState =>
      ref.read(audioPlayerServiceProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  AudioQueueService get _audioQueueService =>
      ref.read(audioQueueServiceProvider);

  late Completer<(int, int, String?)> _completer;
  late EpisodeListEntryPopulator _populator;

  @override
  Future<EpisodeListState> build({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 10,
  }) async {
    logger.d(
      () => 'build (pid: $pid, filterMode: $filterMode, ascend: $ascending,'
          ' episodesPerPage: $episodesPerPage)',
    );

    _completer = Completer<(int, int, String?)>();
    _populator = EpisodeListEntryPopulator(
      pid: pid,
      filterMode: filterMode,
      ascending: ascending,
      firstReadCount: episodesPerPage,
      appDocDir: _appDocDir,
    );

    final subscription = _populator.stream.listen(
      (event) {
        if (!_completer.isCompleted) {
          _completer.complete((event.total, event.loaded, null));
        } else {
          state = state.whenData(
            (value) => value.copyWith(
              loadedCount: event.loaded,
              totalEpisodes: event.total,
            ),
          );
        }
      },
      onError: (Object error) {
        _completer.complete((0, 0, error.toString()));
      },
    );

    ref.onDispose(() {
      _populator.dispose();
      subscription.cancel();
      if (!_completer.isCompleted) {
        _completer.complete((0, 0, null));
      }
    });

    return _completer.future.then((message) {
      final (totalEpisodes, loadedCount, errorMessage) = message;
      return EpisodeListState(
        pid: pid,
        filterMode: filterMode,
        ascending: ascending,
        episodesPerPage: episodesPerPage,
        totalEpisodes: totalEpisodes,
        loadedCount: loadedCount,
        errorMessage: errorMessage,
      );
    });
  }

  Future<Episode?> getEpisodeAt(int index) async {
    if (index < (state.valueOrNull?.loadedCount ?? 0)) {
      final entry = await _episodeListEntryRepository.findBy(
        pid: pid,
        order: index,
      );
      return entry == null ? null : _episodeRepository.findEpisode(entry.eid);
    } else if (state.requireValue.totalEpisodes <= index) {
      return null;
    }

    final completer = Completer<Episode?>();
    ref
      ..listenSelf((_, next) {
        if (completer.isCompleted) {
          return;
        }
        next.whenData(
          (value) async {
            if (index < value.loadedCount) {
              final entry = await _episodeListEntryRepository.findBy(
                pid: pid,
                order: index,
              );
              final episode = entry == null
                  ? null
                  : _episodeRepository.findEpisode(entry.eid);
              completer.complete(episode);
            } else if (state.requireValue.totalEpisodes <= index) {
              completer.complete(null);
            }
          },
        );
      })
      ..onDispose(() {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
    return completer.future;
  }

  Future<int?> getLastPlayedIndex() async {
    final episodes = await _episodeStatsRepository.findEpisodeStatsListBy(
      pid: pid,
      sortBy: EpisodeStatsSortBy.playedDate,
      limit: 1,
    );
    if (episodes.isEmpty) {
      return null;
    }
    final entry = await _episodeListEntryRepository.findBy(
      pid: pid,
      eid: episodes.first!.eid,
    );
    return entry?.order;
  }

  Future<void> togglePlayState(Episode episode) async {
    if (_audioPlayerState?.episode.id == episode.id) {
      return _audioPlayerService.togglePlayPause();
    } else {
      final entry = await _episodeListEntryRepository.findBy(
        pid: pid,
        eid: episode.id,
      );
      if (entry == null) {
        return;
      }

      final entries = await _episodeListEntryRepository.query(
        pid,
        lastOrdinal: entry.order,
        ascending: ascending,
      );
      await _audioQueueService.buildAndPlay(
        pid: pid,
        eid: episode.id,
        queueingEpisodeIds: entries.map((e) => e.eid),
      );
    }
  }
}

@freezed
class EpisodeListState with _$EpisodeListState {
  const factory EpisodeListState({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    required int episodesPerPage,
    required int totalEpisodes,
    @Default(0) int loadedCount,
    String? errorMessage,
  }) = _EpisodeListState;
}
