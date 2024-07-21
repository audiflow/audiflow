import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/entities/playing_episode.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';

class IsarRepository implements Repository {
  IsarRepository({
    required String storageDir,
  }) : _storageDir = storageDir;

  final String _storageDir;
  late Isar isar;
  bool _initialized = false;

  @override
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    isar = Isar.getInstance() ??
        await Isar.open(
          [
            BlockSchema,
            DownloadableSchema,
            EpisodeSchema,
            EpisodeStatsSchema,
            FeedUrlSchema,
            FundingSchema,
            LockedSchema,
            PersonSchema,
            PlayingEpisodeSchema,
            PodcastSchema,
            PodcastStatsSchema,
            PodcastViewStatsSchema,
            QueueSchema,
            TranscriptUrlSchema,
            TranscriptSchema,
            SubtitleSchema,
            ValueSchema,
            ValueRecipientSchema,
          ],
          directory: _storageDir,
        );
  }

  @override
  Future<void> close() async {
    await isar.close();
  }

  // --- feedUrl

  @override
  Future<String?> findFeedUrl({required int collectionId}) async {
    final podcast = await isar.podcasts
        .where()
        .filter()
        .collectionIdEqualTo(collectionId)
        .findFirst();
    if (podcast != null) {
      return podcast.feedUrl;
    }

    final record = await isar.feedUrls
        .where()
        .filter()
        .collectionIdEqualTo(collectionId)
        .findFirst();
    if (record != null) {
      return record.feedUrl;
    }

    return null;
  }

  @override
  Future<int?> findCollectionId({required String feedUrl}) async {
    final podcast = await isar.podcasts
        .where()
        .filter()
        .feedUrlEqualTo(feedUrl)
        .findFirst();
    return podcast?.collectionId;
  }

  @override
  Future<void> saveFeedUrl({
    required int collectionId,
    required String feedUrl,
  }) async {
    final record = FeedUrl(collectionId: collectionId, feedUrl: feedUrl);
    await isar.writeTxn(() => isar.feedUrls.put(record));
  }

  // --- Podcast

  @override
  Future<Podcast?> findPodcast(Id id) {
    return isar.podcasts.get(id);
  }

  @override
  Future<Podcast?> findPodcastBy({
    String? feedUrl,
    int? collectionId,
  }) async {
    if (feedUrl != null) {
      return isar.podcasts.where().filter().feedUrlEqualTo(feedUrl).findFirst();
    }
    if (collectionId != null) {
      return isar.podcasts
          .where()
          .filter()
          .collectionIdEqualTo(collectionId)
          .findFirst();
    }
    return null;
  }

  @override
  Future<void> savePodcasts(Iterable<Podcast> podcasts) async {
    await isar.writeTxn(() => isar.podcasts.putAll(podcasts.toList()));
  }

  @override
  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? param,
  }) async {
    await isar.writeTxn(() async {
      await isar.podcasts.put(podcast);
      if (param != null) {
        await _updatePodcastStats(param);
      }
    });
  }

  @override
  Future<List<Podcast>> subscriptions() async {
    final statsList = await isar.podcastStats
        .where()
        .filter()
        .subscribedDateIsNotNull()
        .findAll();
    return isar.podcasts
        .getAll(statsList.map((e) => e.id).toList())
        .then((value) => value.whereNotNull().toList());
  }

  @override
  Future<void> subscribePodcast(Podcast podcast) async {
    return savePodcast(
      podcast,
      param: PodcastStatsUpdateParam(
        id: podcast.id,
        subscribed: true,
      ),
    );
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    await updatePodcastStats(
      PodcastStatsUpdateParam(
        id: podcast.id,
        subscribed: false,
      ),
    );
  }

  // -- PodcastStats

  @override
  Future<PodcastStats?> findPodcastStats(int pid) async {
    return isar.podcastStats.get(pid);
  }

  @override
  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param) async {
    return isar.writeTxn(() => _updatePodcastStats(param));
  }

  Future<PodcastStats> _updatePodcastStats(
    PodcastStatsUpdateParam param,
  ) async {
    final stats = await isar.podcastStats.get(param.id);
    final newStats = PodcastStats(
      id: param.id,
      subscribedDate: param.subscribed == null
          ? stats?.subscribedDate
          : param.subscribed!
              ? DateTime.now()
              : null,
      lastCheckedAt: param.lastCheckedAt ?? stats?.lastCheckedAt,
    );
    await isar.podcastStats.put(newStats);
    return newStats;
  }

  // -- PodcastViewStats

  @override
  Future<PodcastViewStats?> findPodcastViewStats(int pid) async {
    return isar.podcastViewStats.get(pid);
  }

  @override
  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  ) async {
    final stats = await isar.podcastViewStats.get(param.id);
    final newStats = stats != null
        ? stats.copyWith(
            viewMode: param.viewMode ?? stats.viewMode,
            ascend: param.ascend ?? stats.ascend,
            ascendSeasonEpisodes:
                param.ascendSeasonEpisodes ?? stats.ascendSeasonEpisodes,
          )
        : PodcastViewStats(
            id: param.id,
            viewMode: param.viewMode ?? PodcastDetailViewMode.seasons,
            ascend: param.ascend ?? false,
            ascendSeasonEpisodes: param.ascendSeasonEpisodes ?? true,
          );
    await isar.writeTxn(() => isar.podcastViewStats.put(newStats));
    return newStats;
  }

  // --- Episode

  @override
  Future<Episode?> findEpisode(Id id) async {
    return isar.episodes.get(id);
  }

  @override
  Future<List<Episode?>> findEpisodes(Iterable<Id> ids) async {
    return isar.episodes.getAll(ids.toList());
  }

  @override
  Future<List<Episode>> findEpisodesByPodcastId(Id pid) async {
    return isar.episodes.where().filter().pidEqualTo(pid).findAll();
  }

  @override
  Future<List<Episode>> findLatestEpisodes(
    Id pid, {
    DateTime? lastPubDate,
    required int limit,
  }) async {
    var filter = isar.episodes.where().filter().pidEqualTo(pid);
    if (lastPubDate != null) {
      filter = filter.publicationDateGreaterThan(lastPubDate);
    }
    return filter.sortByPublicationDateDesc().limit(limit).findAll();
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    await isar.writeTxn(() => isar.episodes.put(episode));
  }

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) async {
    await isar.writeTxn(() => isar.episodes.putAll(episodes.toList()));
  }

  // --- EpisodeStats

  @override
  Future<EpisodeStats?> findEpisodeStats(Id id) async {
    return isar.episodeStats.get(id);
  }

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(Iterable<Id> ids) async {
    return isar.episodeStats.getAll(ids.toList());
  }

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) async {
    return isar.writeTxn(() => _updateEpisodeStats(param));
  }

  Future<EpisodeStats> _updateEpisodeStats(
    EpisodeStatsUpdateParam param,
  ) async {
    final stats = await isar.episodeStats.get(param.id);
    final newStats = EpisodeStats(
      id: param.id,
      pid: param.pid,
      positionMS: param.position?.inMilliseconds ?? stats?.positionMS ?? 0,
      playCount: (stats?.playCount ?? 0) + (param.played == true ? 1 : 0),
      playTotalMS: (stats?.playTotalMS ?? 0) +
          (param.playTotalDelta?.inMilliseconds ?? 0),
      played: (stats?.played ?? false) || (param.played ?? false),
      completeCount:
          (stats?.completeCount ?? 0) + (param.completed == true ? 1 : 0),
      inQueue: (stats?.inQueue ?? false) || (param.inQueue ?? false),
      downloadedTime: param.downloaded == null
          ? stats?.downloadedTime
          : param.downloaded!
              ? DateTime.now()
              : null,
      lastPlayedAt: param.lastPlayedAt ?? stats?.lastPlayedAt,
    );
    await isar.episodeStats.put(newStats);
    return newStats;
  }

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  ) async {
    return isar.writeTxn(() => Future.wait(params.map(_updateEpisodeStats)));
  }

  @override
  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(Id pid) async {
    return isar.episodeStats
        .where()
        .filter()
        .pidEqualTo(pid)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(Id pid) async {
    return isar.episodeStats
        .where()
        .filter()
        .playedEqualTo(true)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(Id pid) async {
    return isar.episodeStats
        .where()
        .filter()
        .playedEqualTo(false)
        .downloadedTimeIsNotNull()
        .findAll();
  }

  // --- Recently played episodes

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  }) async {
    final ids = await isar.episodeStats
        .where(sort: Sort.desc)
        .sortByLastPlayedAtDesc()
        .offset(cursor ?? 0)
        .limit(limit)
        .idProperty()
        .findAll();
    final nextCursor = ids.length < limit ? null : (cursor ?? 0) + limit;
    final episodes = await isar.episodes
        .getAll(ids)
        .then((value) => value.whereNotNull().toList());
    return (episodes, nextCursor);
  }

  @override
  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  }) async {
    await updateEpisodeStats(
      EpisodeStatsUpdateParam(
        id: episode.id,
        pid: episode.pid,
        lastPlayedAt: playedAt ?? DateTime.now(),
      ),
    );
  }

  // --- Downloads

  @override
  Future<List<Downloadable>> findDownloadsByPodcastId(int pid) async {
    return isar.downloadables.where().filter().pidEqualTo(pid).findAll();
  }

  @override
  Future<List<Downloadable>> findAllDownloads() async {
    return isar.downloadables.where().findAll();
  }

  @override
  Future<List<Downloadable?>> findDownloads(Iterable<Id> ids) async {
    return isar.downloadables.getAll(ids.toList());
  }

  @override
  Future<Downloadable?> findDownload(Id id) async {
    return isar.downloadables.get(id);
  }

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) async {
    return isar.downloadables
        .where()
        .filter()
        .taskIdEqualTo(taskId)
        .findFirst();
  }

  @override
  Future<void> saveDownload(Downloadable download) async {
    await isar.writeTxn(() => isar.downloadables.put(download));
  }

  @override
  Future<void> deleteDownload(Downloadable download) async {
    await isar.writeTxn(() => isar.downloadables.delete(download.id));
  }

  // --- Transcript

  @override
  Future<Transcript?> findTranscriptById(Id id) async {
    return isar.transcripts.get(id);
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) async {
    return isar.writeTxn(() async {
      await isar.transcripts.put(transcript);
      return transcript;
    });
  }

  @override
  Future<void> deleteTranscriptById(int id) async {
    await isar.writeTxn(() async {
      await isar.transcripts.delete(id);
    });
  }

  @override
  Future<void> deleteTranscriptsById(List<int> ids) async {
    await isar.writeTxn(() async {
      await isar.transcripts.deleteAll(ids);
    });
  }

  // --- Queue

  @override
  Future<Queue> loadQueue() async {
    return await isar.queues.get(1) ?? Queue.empty();
  }

  @override
  Future<void> saveQueue(Queue queue) async {
    await isar.writeTxn(() => isar.queues.put(queue));
  }

  // --- Player

  @override
  Future<int?> playingEpisodeId() async {
    final e = await isar.playingEpisodes.get(1);
    return e?.eid;
  }

  @override
  Future<void> savePlayingEpisodeId(int eid) async {
    await isar
        .writeTxn(() => isar.playingEpisodes.put(PlayingEpisode(eid: eid)));
  }

  @override
  Future<void> clearPlayingEpisodeId() async {
    await isar.writeTxn(() => isar.playingEpisodes.delete(1));
  }
}
