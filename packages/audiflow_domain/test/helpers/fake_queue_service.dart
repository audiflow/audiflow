import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:audiflow_domain/src/features/feed/models/episode.dart';
import 'package:audiflow_domain/src/features/feed/models/feed_parse_progress.dart';
import 'package:audiflow_domain/src/features/feed/models/numbering_extractor.dart';
import 'package:audiflow_domain/src/features/feed/models/smart_playlist_pattern_config.dart';
import 'package:audiflow_domain/src/features/feed/repositories/episode_repository.dart';
import 'package:audiflow_domain/src/features/queue/models/playback_queue.dart';
import 'package:audiflow_domain/src/features/queue/models/queue_item.dart';
import 'package:audiflow_domain/src/features/queue/repositories/queue_repository.dart';
import 'package:audiflow_domain/src/features/queue/services/queue_service.dart';
import 'package:logger/logger.dart';

import 'fake_app_settings_repository.dart';

/// Fake implementation of [QueueService] for use in tests.
///
/// Overrides [clearQueue] to record the call without touching real
/// repositories or database.
class FakeQueueService extends QueueService {
  FakeQueueService()
    : super(
        repository: _NoOpQueueRepository(),
        episodeRepository: _NoOpEpisodeRepository(),
        settingsRepository: FakeAppSettingsRepository(),
        logger: Logger(printer: SimplePrinter(), level: Level.off),
      );

  bool clearQueueCalled = false;

  @override
  Future<void> clearQueue() async => clearQueueCalled = true;
}

// ---------------------------------------------------------------------------
// Internal no-op implementations used solely to satisfy the super constructor.
// ---------------------------------------------------------------------------

class _NoOpQueueRepository implements QueueRepository {
  @override
  Future<QueueItem> addToEnd(int episodeId) async => QueueItem()
    ..episodeId = episodeId
    ..position = 0;

  @override
  Future<QueueItem> addToFront(int episodeId) async => QueueItem()
    ..episodeId = episodeId
    ..position = 0;

  @override
  Future<void> replaceWithAdhoc({
    required List<int> episodeIds,
    required String sourceContext,
  }) async {}

  @override
  Future<void> remove(int queueItemId) async {}

  @override
  Future<void> removeFirst() async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> reorder(int queueItemId, int newIndex) async {}

  @override
  Future<PlaybackQueue> getQueue() async =>
      const PlaybackQueue(manualItems: [], adhocItems: []);

  @override
  Stream<PlaybackQueue> watchQueue() =>
      Stream.value(const PlaybackQueue(manualItems: [], adhocItems: []));

  @override
  Future<bool> hasManualItems() async => false;

  @override
  Future<Episode?> getNextEpisode() async => null;
}

class _NoOpEpisodeRepository implements EpisodeRepository {
  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async => const [];

  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) =>
      Stream.value(const []);

  @override
  Future<Episode?> getById(int id) async => null;

  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => null;

  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) async =>
      null;

  @override
  Future<void> upsertEpisodes(List<Episode> episodes) async {}

  @override
  Future<void> upsertFromFeedItems(
    int podcastId,
    List<PodcastItem> items, {
    NumberingExtractor? extractor,
  }) async {}

  @override
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List<PodcastItem> items, {
    required SmartPlaylistPatternConfig config,
  }) async {}

  @override
  Future<List<Episode>> getByIds(List<int> ids) async => const [];

  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async => {};

  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async => null;

  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) async {}

  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) async => const [];
}
