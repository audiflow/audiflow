import 'package:audiflow/entities/downloadable.dart';
import 'package:audiflow/entities/episode.dart';
import 'package:audiflow/entities/podcast.dart';
import 'package:audiflow/entities/queue.dart';
import 'package:audiflow/entities/transcript.dart';
import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class RepositoryEventAdapter implements Repository {
  RepositoryEventAdapter(this._ref, this.inner);

  final Ref _ref;
  final Repository inner;

  // --- General
  @override
  Future<void> ensureInitialized() => inner.ensureInitialized();

  @override
  Future<void> close() => inner.close();

  // --- feedUrl

  @override
  Future<String?> findFeedUrl({required int collectionId}) =>
      inner.findFeedUrl(collectionId: collectionId);

  @override
  Future<void> saveFeedUrl({
    required int collectionId,
    required String feedUrl,
  }) {
    return inner.saveFeedUrl(
      collectionId: collectionId,
      feedUrl: feedUrl,
    );
  }

  // --- collectionId

  @override
  Future<int?> findCollectionId({required String feedUrl}) =>
      inner.findCollectionId(feedUrl: feedUrl);

  // --- Podcast

  @override
  Future<Podcast?> findPodcast(Id id) => inner.findPodcast(id);

  @override
  Future<Podcast?> findPodcastBy({
    String? feedUrl,
    int? collectionId,
  }) =>
      inner.findPodcastBy(
        feedUrl: feedUrl,
        collectionId: collectionId,
      );

  @override
  Future<void> savePodcasts(Iterable<Podcast> podcasts) async {
    await inner.savePodcasts(podcasts);
    final sink = _ref.read(podcastEventStreamProvider.notifier);
    for (final podcast in podcasts) {
      sink.add(PodcastUpdatedEvent(podcast));
    }
  }

  @override
  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? param,
  }) async {
    await inner.savePodcast(podcast, param: param);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastUpdatedEvent(podcast));
  }

  @override
  Future<List<Podcast>> subscriptions() => inner.subscriptions();

  @override
  Future<void> subscribePodcast(Podcast podcast) async {
    await inner.subscribePodcast(podcast);
    final stats = await inner.findPodcastStats(podcast.id);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastSubscribedEvent(podcast, stats!));
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    await inner.unsubscribePodcast(podcast);
    final stats = await inner.findPodcastStats(podcast.id);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastUnsubscribedEvent(podcast, stats!));
  }

  // -- PodcastStats

  @override
  Future<PodcastStats?> findPodcastStats(int pid) =>
      inner.findPodcastStats(pid);

  @override
  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param) async {
    final updated = await inner.updatePodcastStats(param);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastStatsUpdatedEvent(updated));
    return updated;
  }

  // -- PodcastViewStats

  @override
  Future<PodcastViewStats?> findPodcastViewStats(int pid) =>
      inner.findPodcastViewStats(pid);

  @override
  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  ) {
    return inner.updatePodcastViewStats(param);
  }

  // --- Episode

  @override
  Future<Episode?> findEpisode(Id id) => inner.findEpisode(id);

  @override
  Future<List<Episode?>> findEpisodes(Iterable<Id> ids) =>
      inner.findEpisodes(ids);

  @override
  Future<List<Episode>> findEpisodesByPodcastId(Id pid) =>
      inner.findEpisodesByPodcastId(pid);

  @override
  Future<void> saveEpisode(Episode episode) async {
    await inner.saveEpisode(episode);
    _ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodeUpdatedEvent(episode));
  }

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) async {
    await inner.saveEpisodes(episodes);
    final sink = _ref.read(episodeEventStreamProvider.notifier);
    for (final episode in episodes) {
      sink.add(EpisodeUpdatedEvent(episode));
    }
  }

  // --- EpisodeStats

  @override
  Future<EpisodeStats?> findEpisodeStats(Id id) => inner.findEpisodeStats(id);

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids) =>
      inner.findEpisodeStatsList(ids);

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) async {
    final updated = await inner.updateEpisodeStats(param);
    _ref
        .read(episodeEventStreamProvider.notifier)
        .add(EpisodeStatsUpdatedEvent(updated));
    return updated;
  }

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  ) async {
    final updated = await inner.updateEpisodeStatsList(params);
    final sink = _ref.read(episodeEventStreamProvider.notifier);
    for (final stats in updated) {
      sink.add(EpisodeStatsUpdatedEvent(stats));
    }
    return updated;
  }

  @override
  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(Id pid) =>
      inner.findDownloadedEpisodeStatsList(pid);

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid) =>
      inner.findPlayedEpisodeStatsList(pid);

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid) =>
      inner.findUnplayedEpisodeStatsList(pid);

  // --- Recently played episodes

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  }) =>
      inner.findRecentlyPlayedEpisodeList(cursor: cursor, limit: limit);

  @override
  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  }) {
    return inner.saveRecentlyPlayedEpisode(episode, playedAt: playedAt);
  }

  // --- Downloads

  @override
  Future<List<Downloadable>> findDownloadsByPodcastId(int pid) =>
      inner.findDownloadsByPodcastId(pid);

  @override
  Future<List<Downloadable>> findAllDownloads() => inner.findAllDownloads();

  @override
  Future<List<Downloadable?>> findDownloads(Iterable<Id> ids) =>
      inner.findDownloads(ids);

  @override
  Future<Downloadable?> findDownload(Id id) => inner.findDownload(id);

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) =>
      inner.findDownloadByTaskId(taskId);

  @override
  Future<void> saveDownload(Downloadable download) async {
    await inner.saveDownload(download);
    _ref
        .read(downloadEventStreamProvider.notifier)
        .add(DownloadUpdatedEvent(download));
  }

  @override
  Future<void> deleteDownload(Downloadable download) async {
    await inner.deleteDownload(download);
    _ref
        .read(downloadEventStreamProvider.notifier)
        .add(DownloadDeletedEvent(download));
  }

  // --- Transcript

  @override
  Future<Transcript?> findTranscriptById(int id) =>
      inner.findTranscriptById(id);

  @override
  Future<Transcript> saveTranscript(Transcript transcript) =>
      inner.saveTranscript(transcript);

  @override
  Future<void> deleteTranscriptById(int id) => inner.deleteTranscriptById(id);

  @override
  Future<void> deleteTranscriptsById(List<int> ids) =>
      inner.deleteTranscriptsById(ids);

  // --- Queue

  @override
  Future<Queue> loadQueue() => inner.loadQueue();

  @override
  Future<void> saveQueue(Queue queue) {
    return inner.saveQueue(queue);
  }

  // --- Player

  @override
  Future<int?> playingEpisodeId() => inner.playingEpisodeId();

  @override
  Future<void> savePlayingEpisodeId(int eid) {
    return inner.savePlayingEpisodeId(eid);
  }

  @override
  Future<void> clearPlayingEpisodeId() {
    return inner.clearPlayingEpisodeId();
  }
}
