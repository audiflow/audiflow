import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod/riverpod.dart';

class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository(this._subscription);

  final Subscription _subscription;

  @override
  Future<Subscription?> getById(int id) async => _subscription;

  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) async => _subscription;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Serves a mutable episode list so tests can simulate feed syncs
/// adding, removing, or editing episodes between reads.
class FakeEpisodeRepository implements EpisodeRepository {
  FakeEpisodeRepository(this.episodes);

  final List<Episode> episodes;
  final List<Episode> upserted = [];

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async =>
      List.of(episodes);

  @override
  Future<List<Episode>> getByIds(List<int> ids) async =>
      episodes.where((e) => ids.contains(e.id)).toList();

  @override
  Future<void> upsertEpisodes(List<Episode> episodes) async {
    upserted.addAll(episodes);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeConfigRepository implements PresetConfigRepository {
  FakeConfigRepository({this.summary, this.config});

  /// Mutable so tests can simulate a root-meta refresh mid-load.
  PresetSummary? summary;
  final PresetConfig? config;

  /// Runs inside [getConfig], before it returns.
  void Function()? onGetConfig;

  /// Number of [getConfig] calls; a cache hit never loads the config.
  int getConfigCalls = 0;

  /// Simulates an offline device with no disk-cached config.
  bool failGetConfig = false;

  @override
  PresetSummary? findMatchingPreset(String? podcastGuid, String feedUrl) =>
      summary;

  @override
  Future<PresetConfig> getConfig(PresetSummary summary) async {
    getConfigCalls++;
    if (failGetConfig) throw StateError('config unavailable');
    onGetConfig?.call();
    return config!;
  }

  @override
  void setPresetSummaries(List<PresetSummary> summaries) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Episode testEpisode({
  required int id,
  required String title,
  int? seasonNumber,
  int? episodeNumber,
  DateTime? publishedAt,
}) => Episode()
  ..id = id
  ..podcastId = 1
  ..guid = 'ep-$id'
  ..title = title
  ..audioUrl = 'https://example.com/ep-$id.mp3'
  ..seasonNumber = seasonNumber
  ..episodeNumber = episodeNumber
  ..publishedAt = publishedAt;

Subscription testSubscription() => Subscription()
  ..id = 1
  ..itunesId = 'itunes-1'
  ..feedUrl = 'https://example.com/feed.xml'
  ..title = 'Test Podcast'
  ..artistName = 'Test Artist'
  ..subscribedAt = DateTime(2025);

/// Reads [podcastSmartPlaylistsProvider] while keeping it alive
/// via [listen] so the Ref survives async gaps.
Future<SmartPlaylistGrouping?> readSmartPlaylists(
  ProviderContainer container,
  int podcastId,
) {
  final completer = Completer<SmartPlaylistGrouping?>();
  final sub = container.listen(podcastSmartPlaylistsProvider(podcastId), (
    _,
    next,
  ) {
    if (completer.isCompleted) return;
    next.when(
      data: completer.complete,
      error: completer.completeError,
      loading: () {},
    );
  }, fireImmediately: true);
  return completer.future.whenComplete(sub.close);
}
