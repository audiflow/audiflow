import 'dart:async';

import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/player/model/play_order.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episodes_group.freezed.dart';
part 'episodes_group.g.dart';

@riverpod
class EpisodesGroup extends _$EpisodesGroup {
  final _completer = Completer<EpisodesGroupState>();

  // PodcastService get _podcastService => ref.read(podcastServiceProvider);

  @override
  Future<EpisodesGroupState> build(Key key) async {
    return _completer.future;
  }

  Future<void> setup(Iterable<Episode> episodes) async {
    if (_completer.isCompleted) {
      return;
    }

    final initialState = EpisodesGroupState(
      episodes: episodes.toList(),
    );
    _completer.complete(initialState);
  }

  Future<void> togglePlayState({required Episode episode}) async {
    // return _podcastService.handlePlay(
    //     episode,
    //     group: state.requireValue.episodes
    //         .sorted((a, b) =>
    //         a.publicationDate!.compareTo(b.publicationDate!)),
    //   );
  }

  Future<int?> getLastListenedEpisode() async {
    final stats = await _lastPlayedStats();
    return stats?.eid;
  }

  Future<EpisodeStats?> _lastPlayedStats() async {
    final episodes = state.valueOrNull?.episodes;
    if (episodes == null || episodes.isEmpty) {
      return null;
    }

    final stats = await ref
        .read(statsRepositoryProvider)
        .findEpisodeStatsList(episodes.map((e) => e.id));

    final playedStatsList =
        stats.where((s) => s?.lastPlayedAt != null).cast<EpisodeStats>();

    return playedStatsList.isEmpty
        ? null
        : playedStatsList.reduce(
            (a, b) => a.lastPlayedAt!.isBefore(b.lastPlayedAt!) ? b : a,
          );
  }

  Future<(Episode?, ConditionalPlayButtonState)> nextEpisodeToPlay({
    required PlayOrder playOrder,
    bool isSeries = false,
  }) async {
    final episodes = state.valueOrNull?.episodes;
    if (episodes == null || episodes.isEmpty) {
      return (null, ConditionalPlayButtonState.fromStart);
    }

    final lastPlayedStats = await _lastPlayedStats();
    final lastPlayedEpisode = lastPlayedStats == null
        ? null
        : episodes.firstWhereOrNull((e) => e.id == lastPlayedStats.eid);
    if (lastPlayedStats == null ||
        lastPlayedEpisode == null ||
        lastPlayedEpisode.publicationDate == null) {
      return playOrder == PlayOrder.timeDescend || !isSeries
          ? (_latestEpisode(), ConditionalPlayButtonState.latest)
          : (_earliestEpisode(), ConditionalPlayButtonState.fromStart);
    }

    if (lastPlayedStats.percentagePlayed(lastPlayedEpisode.duration) < 0.999 &&
        // means the user would have interest in the episode
        (isSeries || const Duration(minutes: 1) <= lastPlayedStats.position)) {
      return (lastPlayedEpisode, ConditionalPlayButtonState.resume);
    }

    final countToPlay = playOrder == PlayOrder.timeAscend
        ? episodes
            .where(
              (e) =>
                  e.publicationDate != null &&
                  e.publicationDate!
                      .isAfter(lastPlayedEpisode.publicationDate!),
            )
            .length
        : episodes
            .where(
              (e) =>
                  e.publicationDate != null &&
                  e.publicationDate!
                      .isBefore(lastPlayedEpisode.publicationDate!),
            )
            .length;

    switch (countToPlay) {
      case 0:
        return isSeries
            ? (_earliestEpisode(), ConditionalPlayButtonState.fromStart)
            : (_latestEpisode(), ConditionalPlayButtonState.latestAgain);
      case 1:
        return (_latestEpisode(), ConditionalPlayButtonState.latest);
      default:
        if (isSeries || playOrder == PlayOrder.timeAscend && countToPlay < 4) {
          final nextEpisode = episodes.lastWhere(
            (e) =>
                e.publicationDate != null &&
                e.publicationDate!.isAfter(lastPlayedEpisode.publicationDate!),
          );
          return (nextEpisode, ConditionalPlayButtonState.resume);
        } else {
          return (_latestEpisode(), ConditionalPlayButtonState.latest);
        }
    }
  }

  Episode? _earliestEpisode() {
    return state.valueOrNull?.episodes.fold(null, (Episode? acc, e) {
      if (acc?.publicationDate == null) {
        return e;
      } else if (e.publicationDate == null) {
        return acc;
      }
      return acc!.publicationDate!.isBefore(e.publicationDate!) ? acc : e;
    });
  }

  Episode? _latestEpisode() {
    return state.valueOrNull?.episodes.fold(null, (Episode? acc, e) {
      if (acc?.publicationDate == null) {
        return e;
      } else if (e.publicationDate == null) {
        return acc;
      }
      return acc!.publicationDate!.isBefore(e.publicationDate!) ? e : acc;
    });
  }
}

@freezed
class EpisodesGroupState with _$EpisodesGroupState {
  const factory EpisodesGroupState({
    required List<Episode> episodes,
    // required Map<String, EpisodeStats> statsMap,
  }) = _EpisodesGroupState;
}

enum ConditionalPlayButtonState {
  fromStart,
  latest,
  latestAgain,
  resume;
}
