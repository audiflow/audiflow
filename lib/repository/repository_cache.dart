//  Copyright (c) 2024 by HANAI, Tohru.
//  Copyright (c) 2024 Reedom, Inc.
//  Additional contributions from project contributors.
//  All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:logging/logging.dart';

class RepositoryCache extends Repository {
  RepositoryCache(this._inner);

  final Repository _inner;
  final Map<String, Podcast> _podcasts = {};
  final Map<String, Episode> _episodes = {};

  final log = Logger('RepositoryCache');

  // --- charts

  @override
  Future<void> savePodcastChart(PodcastChartState chart) async {
    await _inner.savePodcastChart(chart);
  }

  @override
  Future<PodcastChartState?> loadPodcastChart() async {
    return _inner.loadPodcastChart();
  }

  // --- PodcastMetadata

  @override
  Future<void> savePodcastMetadataList(Iterable<PodcastMetadata> list) async {
    final toSave = list.where((metadata) {
      final known = _podcasts[metadata.guid];
      return known == null || known.metadataOnly && known.metadata != metadata;
    });
    if (toSave.isNotEmpty) {
      final newPodcasts = toSave.map(Podcast.fromMetadata);
      _podcasts.addEntries(newPodcasts.map((p) => MapEntry(p.guid, p)));
      await _inner.savePodcasts(newPodcasts);
    }
  }

  @override
  Future<void> savePodcastMetadata(PodcastMetadata metadata) async {
    final known = _podcasts[metadata.guid];
    if (known == null || known.metadataOnly && known.metadata != metadata) {
      final newPodcast = Podcast.fromMetadata(metadata);
      _podcasts[newPodcast.guid] = newPodcast;
      await _inner.savePodcast(newPodcast);
    }
  }

  @override
  Future<PodcastMetadata?> findPodcastMetadata(String guid) async {
    final known = _podcasts[guid];
    if (known != null) {
      return known.metadata;
    }

    final podcast = await _inner.findPodcast(guid);
    if (podcast == null) {
      return null;
    }

    _podcasts[podcast.guid] = podcast;
    return podcast.metadata;
  }

  @override
  Future<List<PodcastMetadata>> populatePodcastFeedUrl(
    Iterable<PodcastMetadata> items,
  ) =>
      _inner.populatePodcastFeedUrl(items);

  @override
  Future<String?> findFeedUrl(String guid) async {
    return _podcasts[guid]?.feedUrl ?? await _inner.findFeedUrl(guid);
  }

  @override
  Future<List<(PodcastMetadata, PodcastStats)>> subscriptions() =>
      _inner.subscriptions();

  // --- Podcast

  @override
  Future<void> savePodcasts(Iterable<Podcast> podcasts) async {
    final toSave = podcasts.where((podcast) {
      final known = _podcasts[podcast.guid];
      return known == null || known.metadataOnly || known != podcast;
    });
    if (toSave.isNotEmpty) {
      _podcasts.addEntries(toSave.map((p) => MapEntry(p.guid, p)));
      _episodes.addEntries(
        toSave.expand((p) => p.episodes).map((e) => MapEntry(e.guid, e)),
      );
      await _inner.savePodcasts(toSave);
    }
  }

  @override
  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? statsParam,
  }) async {
    final known = _podcasts[podcast.guid];
    if (known == null || known.metadataOnly || known != podcast) {
      _podcasts[podcast.guid] = podcast;
      _episodes.addEntries(podcast.episodes.map((e) => MapEntry(e.guid, e)));
      await _inner.savePodcast(podcast, statsParam: statsParam);
    } else if (statsParam != null) {
      await _inner.updatePodcastStats(statsParam);
    }
  }

  @override
  Future<Podcast?> findPodcast(String guid) async {
    final known = _podcasts[guid];
    if (known != null) {
      return known;
    }

    final podcast = await _inner.findPodcast(guid);
    if (podcast == null) {
      return null;
    }

    _podcasts[podcast.guid] = podcast;
    return podcast;
  }

  // -- PodcastStats

  @override
  Future<void> subscribePodcast(Podcast podcast) =>
      _inner.subscribePodcast(podcast);

  @override
  Future<void> unsubscribePodcast(Podcast podcast) =>
      _inner.unsubscribePodcast(podcast);

  @override
  Future<PodcastStats?> findPodcastStats(String guid) =>
      _inner.findPodcastStats(guid);

  @override
  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param) =>
      _inner.updatePodcastStats(param);

  // -- PodcastViewStats

  @override
  Future<PodcastViewStats?> findPodcastViewStats(String guid) =>
      _inner.findPodcastViewStats(guid);

  @override
  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  ) =>
      _inner.updatePodcastViewStats(param);

  // --- Episodes

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) async {
    final toSave =
        episodes.where((episode) => _episodes[episode.guid] != episode);
    if (toSave.isNotEmpty) {
      _episodes.addEntries(toSave.map((e) => MapEntry(e.guid, e)));
      await _inner.saveEpisodes(toSave);
    }
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    if (_episodes[episode.guid] != episode) {
      _episodes[episode.guid] = episode;
      await _inner.saveEpisode(episode);
    }
  }

  @override
  Future<Episode?> findEpisode(String guid) async {
    final known = _episodes[guid];
    if (known != null) {
      return known;
    }

    final episode = await _inner.findEpisode(guid);
    if (episode == null) {
      return null;
    }

    _episodes[episode.guid] = episode;
    return episode;
  }

  @override
  Future<List<Episode?>> findEpisodes(Iterable<String> guids) async {
    final toLoad = <String, int>{};
    var needsLoad = false;
    final ret = List<Episode?>.filled(guids.length, null);
    for (final (i, guid) in guids.indexed) {
      final episode = _episodes[guid];
      if (episode == null) {
        toLoad[guid] = i;
        needsLoad = true;
      } else {
        ret[i] = episode;
      }
    }
    if (!needsLoad) {
      return ret;
    }

    final loaded = await _inner.findEpisodes(toLoad.keys);
    for (final (i, j) in toLoad.values.indexed) {
      final episode = loaded[i];
      if (episode != null) {
        _episodes[episode.guid] = episode;
        ret[j] = episode;
      }
    }
    return ret;
  }

  @override
  Future<List<Episode>> findEpisodesByPodcastGuid(String pguid) async {
    final podcast = _podcasts[pguid];
    if (podcast != null) {
      return podcast.episodes;
    }
    final episodes = await _inner.findEpisodesByPodcastGuid(pguid);
    _episodes.addEntries(episodes.map((e) => MapEntry(e.guid, e)));
    return episodes;
  }

  // --- EpisodeStats

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) =>
      _inner.updateEpisodeStats(param);

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  ) =>
      _inner.updateEpisodeStatsList(params);

  @override
  Future<EpisodeStats?> findEpisodeStats(String guid) =>
      _inner.findEpisodeStats(guid);

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(
    Iterable<String> guids,
  ) =>
      _inner.findEpisodeStatsList(guids);

  @override
  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(
    String pguid,
  ) =>
      _inner.findDownloadedEpisodeStatsList(pguid);

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(String pguid) =>
      _inner.findPlayedEpisodeStatsList(pguid);

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(String pguid) =>
      _inner.findUnplayedEpisodeStatsList(pguid);

  // --- Recently played episodes

  @override
  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  }) =>
      _inner.saveRecentlyPlayedEpisode(episode, playedAt: playedAt);

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  }) =>
      _inner.findRecentlyPlayedEpisodeList(cursor: cursor, limit: limit);

  // --- Downloads

  @override
  Future<void> saveDownload(Downloadable download) =>
      _inner.saveDownload(download);

  @override
  Future<void> deleteDownload(Downloadable download) =>
      _inner.deleteDownload(download);

  @override
  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid) =>
      _inner.findDownloadsByPodcastGuid(pguid);

  @override
  Future<List<Downloadable>> findAllDownloads() => _inner.findAllDownloads();

  @override
  Future<List<Downloadable>> findDownloads(Iterable<String> guids) =>
      _inner.findDownloads(guids);

  @override
  Future<Downloadable?> findDownload(String guid) => _inner.findDownload(guid);

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) =>
      _inner.findDownloadByTaskId(taskId);

  // --- Transcript

  @override
  Future<Transcript> saveTranscript(Transcript transcript) =>
      _inner.saveTranscript(transcript);

  @override
  Future<void> deleteTranscriptById(int id) => _inner.deleteTranscriptById(id);

  @override
  Future<void> deleteTranscriptsById(List<int> id) =>
      _inner.deleteTranscriptsById(id);

  @override
  Future<Transcript?> findTranscriptById(int id) =>
      _inner.findTranscriptById(id);

  @override
  Future<Queue> loadQueue() => _inner.loadQueue();

  @override
  Future<void> saveQueue(Queue queue) => _inner.saveQueue(queue);

  // --- Player

  @override
  Future<void> savePlayingEpisodeGuid(String guid) =>
      _inner.savePlayingEpisodeGuid(guid);

  @override
  Future<void> clearPlayingEpisodeGuid() => _inner.clearPlayingEpisodeGuid();

  @override
  Future<String?> playingEpisodeGuid() => _inner.playingEpisodeGuid();

  @override
  Future<void> close() {
    _podcasts.clear();
    return _inner.close();
  }
}
