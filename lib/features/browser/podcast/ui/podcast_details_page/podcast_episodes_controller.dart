import 'dart:async';

import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/episode/data/episode_list_entry_repository.dart';
import 'package:audiflow/features/browser/episode/model/episode_list_entry.dart';
import 'package:audiflow/features/browser/episode/service/episode_list_entry_populator.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
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

  StatsRepository get _statsRepository => ref.read(statsRepositoryProvider);

  EpisodeListEntryRepository get _episodeListEntryRepository =>
      ref.read(episodeListEntryRepositoryProvider);

  late Completer<(int, int, String?)> _completer;
  late EpisodeListEntryPopulator _populator;

  @override
  Future<EpisodeListState> build({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 10,
    EpisodeListEntryRole role = EpisodeListEntryRole.page,
  }) async {
    logger.d(
      () => 'build (pid: $pid, filterMode: $filterMode, ascend: $ascending,'
          ' episodesPerPage: $episodesPerPage, role: $role)',
    );

    _completer = Completer<(int, int, String?)>();
    _populator = EpisodeListEntryPopulator(
      pid: pid,
      filterMode: filterMode,
      ascending: ascending,
      role: role,
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
        role: role,
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
                role: role,
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
    final episodes = await _statsRepository.findEpisodeStatsListBy(
      pid: pid,
      sortBy: EpisodeStatsSortBy.playedDate,
      limit: 1,
    );
    if (episodes.isEmpty) {
      return null;
    }
    final entry = await _episodeListEntryRepository.findBy(
      pid: pid,
      role: role,
      eid: episodes.first!.eid,
    );
    return entry?.order;
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
