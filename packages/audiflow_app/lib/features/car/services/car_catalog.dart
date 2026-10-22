import 'package:audiflow_domain/audiflow_domain.dart';

import '../models/car_list_item.dart';

/// Builds the in-car lists (CarPlay and Android Auto) from the same data the
/// phone screens show.
///
/// Parental control (FR 18) needs no gate here: the car has no search,
/// subscribe, or deep-link surface, so it only ever lists the subscribed
/// set. A podcast's "hide explicit episodes" flag is applied to its episode
/// list, as on podcast detail.
class CarCatalog {
  CarCatalog({
    required this._queueService,
    required this._historyRepository,
    required this._episodeRepository,
    required this._subscriptionRepository,
    required this._downloadRepository,
    required this._parentalControlRepository,
    required this._loadSubscriptions,
    required this._nowPlayingUrl,
    required this._formatDuration,
  });

  /// Rows sent for one list. The head unit shows fewer still (its own
  /// `CPListTemplate.maximumItemCount`); this bounds the channel payload
  /// for podcasts with thousands of episodes.
  static const itemLimit = 100;

  /// In-progress episodes listed, matching the depth a driver can use.
  static const inProgressLimit = 20;

  final QueueService _queueService;
  final PlaybackHistoryRepository _historyRepository;
  final EpisodeRepository _episodeRepository;
  final SubscriptionRepository _subscriptionRepository;
  final DownloadRepository _downloadRepository;
  final ParentalControlRepository _parentalControlRepository;
  final Future<List<Subscription>> Function() _loadSubscriptions;
  final String? Function() _nowPlayingUrl;
  final String Function(Duration duration) _formatDuration;

  /// The rows of [section]; [podcastId] picks the podcast for
  /// [CarSection.podcast].
  Future<List<CarListItem>> items(CarSection section, {int? podcastId}) async {
    return switch (section) {
      CarSection.upNext => _upNext(),
      CarSection.inProgress => _inProgress(),
      CarSection.library => _library(),
      CarSection.downloads => _downloads(),
      CarSection.podcast =>
        podcastId == null ? const [] : _podcastEpisodes(podcastId),
    };
  }

  Future<List<CarListItem>> _upNext() async {
    final queue = await _queueService.getQueue();
    final items = queue
        .upNextItems(nowPlayingUrl: _nowPlayingUrl())
        .take(itemLimit)
        .toList();
    final podcasts = await _podcastsById(items.map((i) => i.episode));
    return [
      for (final item in items)
        CarListItem(
          id: item.queueItem.id,
          title: item.episode.title,
          detail: podcasts[item.episode.podcastId]?.title,
          artworkUrl: item.artworkUrl,
        ),
    ];
  }

  Future<List<CarListItem>> _inProgress() async {
    final histories = await _historyRepository
        .watchInProgress(limit: inProgressLimit)
        .first;
    final episodes = await _episodesInOrder([
      for (final history in histories) history.episodeId,
    ]);
    final historyByEpisode = {for (final h in histories) h.episodeId: h};
    return _episodeItems(
      episodes,
      progressOf: (episode) => EpisodeWithProgress(
        episode: episode,
        history: historyByEpisode[episode.id],
      ).progressPercent,
    );
  }

  Future<List<CarListItem>> _downloads() async {
    final tasks = await _downloadRepository.getByStatus(
      const DownloadStatus.completed(),
    );
    final newestFirst = tasks.toList()
      ..sort((a, b) => _downloadedAt(b).compareTo(_downloadedAt(a)));
    final episodes = await _episodesInOrder([
      for (final task in newestFirst.take(itemLimit)) task.episodeId,
    ]);
    return _episodeItems(episodes);
  }

  static DateTime _downloadedAt(DownloadTask task) =>
      task.completedAt ?? task.createdAt;

  Future<List<CarListItem>> _library() async {
    final subscriptions = await _loadSubscriptions();
    return [
      for (final subscription in subscriptions.take(itemLimit))
        CarListItem(
          id: subscription.id,
          title: subscription.title,
          detail: subscription.artistName,
          artworkUrl: subscription.artworkUrl,
        ),
    ];
  }

  Future<List<CarListItem>> _podcastEpisodes(int podcastId) async {
    final subscription = await _subscriptionRepository.getById(podcastId);
    if (subscription == null) return const [];
    final hideExplicit = await _hidesExplicit(podcastId);
    final episodes = await _episodeRepository.getByPodcastId(podcastId);
    final visible = newestFirst(
      hideExplicit ? episodes.where((e) => !e.itunesExplicit) : episodes,
    ).take(itemLimit);
    final histories = await _historyRepository.getByPodcastId(podcastId);
    final nowPlayingUrl = _nowPlayingUrl();
    return [
      for (final episode in visible)
        CarListItem(
          id: episode.id,
          title: episode.title,
          detail: _durationOf(episode),
          artworkUrl: episode.imageUrl ?? subscription.artworkUrl,
          progress: _resumeProgress(episode, histories[episode.id]),
          isPlaying: episode.audioUrl == nowPlayingUrl,
        ),
    ];
  }

  /// The flag is keyed by the subscription id, as on podcast detail. An
  /// unreadable flag hides explicit episodes: parental control fails
  /// closed on storage errors (FR 18).
  Future<bool> _hidesExplicit(int podcastId) async {
    try {
      return await _parentalControlRepository.getHideExplicit(podcastId);
    } on Object {
      return true;
    }
  }

  String? _durationOf(Episode episode) {
    final durationMs = episode.durationMs;
    if (durationMs == null || durationMs <= 0) return null;
    return _formatDuration(Duration(milliseconds: durationMs));
  }

  static double? _resumeProgress(Episode episode, PlaybackHistory? history) {
    final progress = EpisodeWithProgress(episode: episode, history: history);
    return progress.isInProgress ? progress.progressPercent : null;
  }

  /// Episode rows titled with their podcast, for lists that mix podcasts.
  Future<List<CarListItem>> _episodeItems(
    List<Episode> episodes, {
    double? Function(Episode episode)? progressOf,
  }) async {
    final podcasts = await _podcastsById(episodes);
    final nowPlayingUrl = _nowPlayingUrl();
    return [
      for (final episode in episodes)
        CarListItem(
          id: episode.id,
          title: episode.title,
          detail: podcasts[episode.podcastId]?.title,
          artworkUrl:
              episode.imageUrl ?? podcasts[episode.podcastId]?.artworkUrl,
          progress: progressOf?.call(episode),
          isPlaying: episode.audioUrl == nowPlayingUrl,
        ),
    ];
  }

  /// [ids] resolved to episodes, kept in the order given; ids whose episode
  /// is gone are dropped.
  Future<List<Episode>> _episodesInOrder(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final episodes = await _episodeRepository.getByIds(ids);
    final byId = {for (final e in episodes) e.id: e};
    return [for (final id in ids) ?byId[id]];
  }

  Future<Map<int, Subscription>> _podcastsById(
    Iterable<Episode> episodes,
  ) async {
    final result = <int, Subscription>{};
    for (final podcastId in {for (final e in episodes) e.podcastId}) {
      final subscription = await _subscriptionRepository.getById(podcastId);
      if (subscription != null) result[podcastId] = subscription;
    }
    return result;
  }
}

/// [episodes] newest first; undated episodes go last.
List<Episode> newestFirst(Iterable<Episode> episodes) {
  return episodes.toList()..sort((a, b) {
    final aDate = a.publishedAt;
    final bDate = b.publishedAt;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  });
}
