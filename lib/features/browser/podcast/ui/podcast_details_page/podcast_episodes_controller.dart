import 'dart:async';
import 'dart:math' as math;

import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_episodes_controller.freezed.dart';
part 'podcast_episodes_controller.g.dart';

@riverpod
class PodcastEpisodesController extends _$PodcastEpisodesController {
  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  AudioPlayerState? get _audioPlayerState =>
      ref.read(audioPlayerServiceProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  AudioQueueService get _audioQueueService =>
      ref.read(audioQueueServiceProvider);

  late final _UnplayedEpisodesLoader _unplayedEpisodesLoader;

  final _episodes = <Episode>[];
  bool _loadedAllEpisodes = false;
  Completer<void>? _loadNextCompleter;

  @override
  Future<EpisodeListState> build({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 30,
  }) async {
    logger.d(
      () => 'build (pid: $pid, filterMode: $filterMode, ascend: $ascending,'
          ' episodesPerPage: $episodesPerPage)',
    );

    if (filterMode == EpisodeFilterMode.unplayed) {
      _unplayedEpisodesLoader = _UnplayedEpisodesLoader(
        ref,
        pid: pid,
        ascending: ascending,
        episodesPerPage: episodesPerPage,
      );
      await _unplayedEpisodesLoader.countEpisodes();
    }

    _listen();
    final v = await Future.wait<dynamic>([
      _countEpisodes(),
      _loadMoreEpisodes(),
    ]);

    final totalEpisodes = v[0] as int;

    return EpisodeListState(
      pid: pid,
      filterMode: filterMode,
      ascending: ascending,
      episodesPerPage: episodesPerPage,
      totalEpisodes: totalEpisodes,
    );
  }

  Episode? getEpisodeAt(int index) {
    _loadMoreIfNeeded(index);
    if (index < _episodes.length) {
      return _episodes[index];
    }

    logger.w('getEpisodeAt(index) - out of index. this should not be happen');
    // TODO(reedom): replace with more better solution.
    final oldState = state;
    state = const AsyncValue.loading();
    _loadNextCompleter?.future.then((_) {
      state = oldState;
    });
    return null;
  }

  Future<void> _loadMoreIfNeeded(int index) async {
    if (index < _episodes.length - episodesPerPage ~/ 2) {
      return;
    }
    if (!state.hasValue ||
        state.requireValue.totalEpisodes <= _episodes.length) {
      return;
    }
    if (_loadNextCompleter?.isCompleted == false) {
      // guard; it's loading.
      return;
    }

    _loadNextCompleter = Completer();
    await _loadMoreEpisodes();
    _loadNextCompleter?.complete();
    _loadNextCompleter = null;
  }

  Future<void> _loadMoreEpisodes() async {
    final episodes =
        await _loadEpisodes(lastOrdinal: _episodes.lastOrNull?.ordinal);
    _episodes.addAll(episodes);
    if (episodes.length < episodesPerPage ||
        state.hasValue &&
            state.requireValue.totalEpisodes <= _episodes.length) {
      _loadedAllEpisodes = true;
    }
  }

  Future<List<Episode>> _loadEpisodes({int? lastOrdinal}) async {
    logger.d(() => '_loadEpisodes(lastOrdinal: $lastOrdinal)');
    switch (filterMode) {
      case EpisodeFilterMode.all:
        return _episodeRepository.queryEpisodes(
          pid: pid,
          lastOrdinal: lastOrdinal,
          ascending: ascending,
          limit: episodesPerPage,
        );
      case EpisodeFilterMode.completed || EpisodeFilterMode.downloaded:
        final statsList = await _episodeStatsRepository.queryEpisodeStatsList(
          pid: pid,
          filterBy: filterMode.filterBy,
          lastOrdinal: lastOrdinal,
          ascending: ascending,
          limit: episodesPerPage,
        );
        return statsList.isEmpty
            ? []
            : _episodeRepository
                .findEpisodes(statsList.map((e) => e.eid))
                .then((list) => list.whereNotNull().toList());
      case EpisodeFilterMode.unplayed:
        return _unplayedEpisodesLoader.loadEpisodes();
    }
  }

  Future<int> _countEpisodes() async {
    switch (filterMode) {
      case EpisodeFilterMode.all:
        return _episodeRepository.count(pid: pid);
      case EpisodeFilterMode.completed || EpisodeFilterMode.downloaded:
        return _episodeStatsRepository.count(
          pid: pid,
          filterBy: filterMode.filterBy,
        );
      case EpisodeFilterMode.unplayed:
        return _episodeRepository.count(pid: pid);
    }
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

    final eid = episodes.first.eid;
    var index = _episodes.indexWhere((e) => e.id == eid);
    while (index < 0 && !_loadedAllEpisodes) {
      final len = _episodes.length;
      await _loadMoreEpisodes();
      index = _episodes.indexWhere((e) => e.id == eid, len);
    }
    if (0 <= index) {
      await _loadMoreIfNeeded(index);
      return index;
    } else {
      return null;
    }
  }

  Future<void> togglePlayState(Episode episode) async {
    if (_audioPlayerState?.episode.id == episode.id) {
      return _audioPlayerService.togglePlayPause();
    }

    final index = _episodes.indexWhere((e) => e.id == episode.id);
    if (!ascending) {
      await _audioQueueService.buildAndPlay(
        pid: pid,
        eid: episode.id,
        queueingEpisodeIds: _episodes.slice(0, index).reversed.map((e) => e.id),
      );
    } else {
      await _loadMoreIfNeeded(index);
      await _audioQueueService.buildAndPlay(
        pid: pid,
        eid: episode.id,
        queueingEpisodeIds: _episodes.slice(index + 1).map((e) => e.id),
      );
    }
  }

  void _listen() {
    void addTotalEpisode(int delta) {
      state = AsyncData(
        state.requireValue
            .copyWith(totalEpisodes: state.requireValue.totalEpisodes + delta),
      );
    }

    var addedEpisodes = 0;
    ref.listen(episodeEventStreamProvider, (_, next) {
      if (next.requireValue case EpisodesAddedEvent(episodes: final episodes)) {
        if (state.hasValue) {
          addTotalEpisode(episodes.length);
        } else {
          addedEpisodes += episodes.length;
          ref.listenSelf((_, next) {
            if (0 < addedEpisodes && next.hasValue) {
              final delta = addedEpisodes;
              addedEpisodes = 0;
              addTotalEpisode(delta);
            }
          });
        }
      }
    });
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
  }) = _EpisodeListState;
}

extension _EpisodeFilterModeExt on EpisodeFilterMode {
  EpisodeStatsFilterBy? get filterBy {
    switch (this) {
      case EpisodeFilterMode.all:
        return null;
      case EpisodeFilterMode.unplayed:
        return null;
      case EpisodeFilterMode.completed:
        return EpisodeStatsFilterBy.completed;
      case EpisodeFilterMode.downloaded:
        return EpisodeStatsFilterBy.downloaded;
    }
  }
}

class _UnplayedEpisodesLoader {
  _UnplayedEpisodesLoader(
    this.ref, {
    required this.pid,
    required this.ascending,
    required this.episodesPerPage,
  });

  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  final Ref ref;
  final int pid;
  final bool ascending;
  final int episodesPerPage;

  late final Set<int> _playedIds;
  int? _totalEpisodes;
  int? _lastOrdinal;
  bool _readToEnd = false;
  List<Episode> _remainingEpisodes = [];

  Future<int> countEpisodes() async {
    if (_totalEpisodes != null) {
      return _totalEpisodes!;
    }

    final v = await Future.wait<dynamic>([
      _episodeRepository.count(pid: pid),
      _episodeStatsRepository.queryEpisodeStatsList(
        pid: pid,
        filterBy: EpisodeStatsFilterBy.played,
        ascending: ascending,
      )
    ]);

    final episodesCount = v[0] as int;
    _playedIds = Set.from((v[1] as List<EpisodeStats>).map((s) => s.eid));
    _totalEpisodes = math.max(0, episodesCount - _playedIds.length);
    return _totalEpisodes!;
  }

  Future<List<Episode>> loadEpisodes() async {
    if (episodesPerPage <= _remainingEpisodes.length) {
      final episodes = _remainingEpisodes.slice(0, episodesPerPage);
      _remainingEpisodes = _remainingEpisodes.slice(episodesPerPage).toList();
      return episodes;
    } else if (_readToEnd) {
      final episodes = _remainingEpisodes;
      _remainingEpisodes = [];
      return episodes;
    }

    final uncheckedEpisodes = await _episodeRepository.queryEpisodes(
      pid: pid,
      lastOrdinal: _lastOrdinal,
      ascending: ascending,
      limit: episodesPerPage * 2,
    );
    if (uncheckedEpisodes.isEmpty) {
      _readToEnd = true;
      return [];
    }

    _lastOrdinal = uncheckedEpisodes.last.ordinal;
    _readToEnd = uncheckedEpisodes.length < episodesPerPage * 2;
    _remainingEpisodes
        .addAll(uncheckedEpisodes.where((e) => !_playedIds.contains(e.id)));
    return loadEpisodes();
  }
}
