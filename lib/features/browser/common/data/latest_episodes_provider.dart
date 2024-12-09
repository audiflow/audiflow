import 'dart:async';

import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/podcast_subscriptions.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'latest_episodes_provider.freezed.dart';
part 'latest_episodes_provider.g.dart';

@riverpod
class LatestEpisodes extends _$LatestEpisodes {
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

  final borderOfPublishedDate =
      DateTime.now().subtract(const Duration(days: 7));

  @override
  Future<LatestEpisodesState> build() async {
    final podcasts = await ref.read(podcastSubscriptionsProvider.future);
    final items = await Future.wait(podcasts.map(_loadEpisodes));
    final episodes =
        items.map((e) => e.$1).expand((e) => e).newerToOlder().toList();
    final playedEids = items.map((e) => e.$2).expand((e) => e).toSet();
    _listen();
    return LatestEpisodesState(
      podcasts: podcasts,
      episodes: episodes,
      playedEids: playedEids,
    );
  }

  Future<(List<Episode>, Set<int>)> _loadEpisodes(Podcast podcast) async {
    final episodes = await _episodeRepository.findLatestEpisodes(
      podcast.id,
      publishedAfter: borderOfPublishedDate,
    );

    final stats = await _episodeStatsRepository
        .findEpisodeStatsList(episodes.map((e) => e.id));
    final playedEids = episodes
        .whereIndexed((i, e) => stats[i]?.played == true)
        .map((e) => e.id)
        .toSet();
    return (episodes, playedEids);
  }

  void _listen() {
    ref
      ..listen(
        podcastEventStreamProvider,
        (_, next) => next.whenData(_handlePodcastEvent),
      )
      ..listen(
        episodeEventStreamProvider,
        (_, next) => next.whenData(_handleEpisodeEvent),
      );
  }

  void _handlePodcastEvent(PodcastEvent event) {
    if (event case PodcastSubscribedEvent()) {
      _addPodcast(event.podcast);
    } else if (event case PodcastUnsubscribedEvent()) {
      _removePodcast(event.podcast);
    }
  }

  Future<void> _addPodcast(Podcast podcast) async {
    final item = await _loadEpisodes(podcast);

    final value = state.requireValue;
    final episodes = [...value.episodes, ...item.$1]
        .sorted((a, b) => b.publicationDate!.compareTo(a.publicationDate!))
        .toList();
    final playedEids = <int>{...value.playedEids, ...item.$2};

    state = AsyncData(value.copyWith(
      podcasts: [podcast, ...value.podcasts],
      episodes: episodes,
      playedEids: playedEids,
    ));
  }

  void _removePodcast(Podcast podcast) {
    final value = state.requireValue;
    final podcasts = value.podcasts.where((p) => p.id != podcast.id).toList();
    final episodes = value.episodes.where((e) => e.pid != podcast.id).toList();

    state = AsyncData(
      value.copyWith(
        podcasts: podcasts,
        episodes: episodes,
        playedEids: value.playedEids.where(episodes.contains).toSet(),
      ),
    );
  }

  Future<void> _handleEpisodeEvent(EpisodeEvent event) async {
    switch (event) {
      case EpisodeUpdatedEvent():
        await _updateEpisodes([event.episode]);
      case EpisodesUpdatedEvent():
        await _updateEpisodes(event.episodes);
      case EpisodesAddedEvent():
        final episodes = await _episodeRepository
            .findEpisodes(event.episodes.map((e) => e.id))
            .then((list) => list.whereNotNull());
        await _updateEpisodes(episodes);
      case EpisodeDeletedEvent():
        _removeEpisodes([event.eid]);
      case EpisodesDeletedEvent():
        _removeEpisodes(event.eids);
      case EpisodeStatsUpdatedEvent():
        _maybeUpdatePlayedEpisodes([event.stats]);
      case EpisodeStatsListUpdatedEvent():
        _maybeUpdatePlayedEpisodes(event.statsList);
    }
  }

  Future<void> _updateEpisodes(Iterable<Episode> updatedEpisodes) async {
    final value = state.requireValue;
    final filtered = updatedEpisodes
        .where((e) => value.podcasts.any((p) => p.id == e.pid))
        .where((e) =>
            e.publicationDate != null &&
            e.publicationDate!.isAfter(borderOfPublishedDate));
    if (filtered.isEmpty) {
      return;
    }

    var newList = [...value.episodes];
    for (final episode in filtered) {
      var modified = false;
      var podcastEpisodes = newList.where((e) => e.pid == episode.pid).map((e) {
        if (e.id == episode.id) {
          modified = true;
          return episode;
        } else {
          return e;
        }
      });
      if (!modified) {
        podcastEpisodes = [...podcastEpisodes, episode];
      }
      final otherEpisodes = newList.where((e) => e.pid != episode.pid);
      newList = [...podcastEpisodes, ...otherEpisodes];
    }

    final stats = await _episodeStatsRepository
        .findEpisodeStatsList(filtered.map((e) => e.id));
    final playedEids = <int>{
      ...value.playedEids,
      ...stats.whereIndexed((i, s) => s?.played == true).map((s) => s!.id)
    };

    state = AsyncData(
      value.copyWith(
        episodes: newList.newerToOlder().toList(),
        playedEids: playedEids,
      ),
    );
  }

  void _removeEpisodes(List<int> eids) {
    final value = state.requireValue;
    final episodes = value.episodes.where((e) => !eids.contains(e.id)).toList();
    final playedEids = value.playedEids.where((e) => !eids.contains(e)).toSet();

    state = AsyncData(
      value.copyWith(
        episodes: episodes,
        playedEids: playedEids,
      ),
    );
  }

  void _maybeUpdatePlayedEpisodes(List<EpisodeStats> statsList) {
    final value = state.requireValue;
    final playedStats = statsList
        .where((s) => s.played)
        .where((s) => value.episodes.any((e) => e.id == s.id))
        .toList();
    if (playedStats.isNotEmpty) {
      state = AsyncData(
        value.copyWith(
          playedEids: {
            ...value.playedEids,
            ...playedStats.map((s) => s.id),
          },
        ),
      );
    }
  }

  Future<void> togglePlayState(Episode episode) async {
    if (_audioPlayerState?.episode.id == episode.id) {
      return _audioPlayerService.togglePlayPause();
    }

    final episodes = state.requireValue.episodes;
    final index = episodes.indexWhere((e) => e.id == episode.id);
    await _audioQueueService.buildAndPlay(
      pid: episode.pid,
      eid: episode.id,
      queueingEpisodeIds: episodes.slice(index).map((e) => e.id),
    );
  }
}

@freezed
class LatestEpisodesState with _$LatestEpisodesState {
  const factory LatestEpisodesState({
    @Default(<Podcast>[]) List<Podcast> podcasts,
    @Default(<Episode>[]) List<Episode> episodes,
    @Default(<int>{}) Set<int> playedEids,
  }) = _LatestEpisodesState;
}

extension LatestEpisodesStateExt on LatestEpisodesState {
  List<Episode> get unplayedEpisodes {
    return episodes.where((e) => !playedEids.contains(e.id)).toList();
  }
}

extension _IterableEpisodes on Iterable<Episode> {
  Iterable<Episode> newerToOlder() {
    return sorted(
      (a, b) => a.publicationDate != null && b.publicationDate != null
          ? b.publicationDate!.compareTo(a.publicationDate!)
          : b.ordinal - a.ordinal,
    );
  }
}
