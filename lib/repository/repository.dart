import 'package:audiflow/entities/entities.dart';
import 'package:isar/isar.dart';

/// An abstract class that represent the actions supported by the chosen
/// database or storage implementation.
///
/// An implementation of [Repository] that is backed by
/// [Sembast](https://github.com/tekartik/sembast.dart/tree/master/sembast)
///
///
/// <Data Management Rules>
///
/// It utilize [PodcastMetadata], [EpisodeMetadata] to reduce the data size.
/// It stores in [Podcast] only for subscribed podcasts. Otherwise, it stores in
/// [PodcastMetadata].
/// Either [Podcast] or [PodcastMetadata] must be found if any of their episode
/// is saved under the following state:
///  - downloaded
///  - queued
///  - once played(for Recently Played feature)
///
/// It stores in [Episode] if the episode in the following state:
///  - its podcast is subscribed
///  - downloaded
///  - queued
/// Or it stores in [EpisodeMetadata] if the episode in the following state:
///  - once played(for Recently Played feature)
///
/// xxxStats never get deleted.
///  - [PodcastStats]
///  - [PodcastViewStats]
///  - [EpisodeStats]
abstract class Repository {
  // --- General
  Future<void> ensureInitialized();

  Future<void> close();

  // --- feedUrl

  Future<String?> findFeedUrl({required int collectionId});

  Future<void> saveFeedUrl({
    required int collectionId,
    required String feedUrl,
  });

  // --- collectionId

  Future<int?> findCollectionId({required String feedUrl});

  // --- Podcast

  Future<Podcast?> findPodcast(Id id);

  Future<Podcast?> findPodcastBy({
    String? feedUrl,
    int? collectionId,
  });

  Future<void> savePodcasts(Iterable<Podcast> podcasts);

  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? param,
  });

  Future<List<Podcast>> subscriptions();

  Future<void> subscribePodcast(Podcast podcast);

  Future<void> unsubscribePodcast(Podcast podcast);

  // -- PodcastStats

  Future<PodcastStats?> findPodcastStats(int pid);

  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param);

  // -- PodcastViewStats

  Future<PodcastViewStats?> findPodcastViewStats(int pid);

  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  );

  // --- Episode

  Future<Episode?> findEpisode(Id id);

  Future<List<Episode?>> findEpisodes(Iterable<Id> ids);

  Future<List<Episode>> findEpisodesByPodcastId(Id pid);

  Future<void> saveEpisode(Episode episode);

  Future<void> saveEpisodes(Iterable<Episode> episodes);

  // --- EpisodeStats

  Future<EpisodeStats?> findEpisodeStats(Id id);

  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids);

  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param);

  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  );

  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(Id pid);

  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid);

  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid);

  // --- Recently played episodes

  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  });

  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  });

  // --- Downloads

  Future<List<Downloadable>> findDownloadsByPodcastId(int pid);

  Future<List<Downloadable>> findAllDownloads();

  Future<List<Downloadable?>> findDownloads(Iterable<Id> ids);

  Future<Downloadable?> findDownload(Id id);

  Future<Downloadable?> findDownloadByTaskId(String taskId);

  Future<void> saveDownload(Downloadable download);

  Future<void> deleteDownload(Downloadable download);

  // --- Transcript

  Future<Transcript?> findTranscriptById(int id);

  Future<Transcript> saveTranscript(Transcript transcript);

  Future<void> deleteTranscriptById(int id);

  Future<void> deleteTranscriptsById(List<int> ids);

  // --- Queue

  Future<Queue> loadQueue();

  Future<void> saveQueue(Queue queue);

  // --- Player

  Future<int?> playingEpisodeId();

  Future<void> savePlayingEpisodeId(int eid);

  Future<void> clearPlayingEpisodeId();
}
