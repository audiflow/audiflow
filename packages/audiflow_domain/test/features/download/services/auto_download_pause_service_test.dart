import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSubscriptionRepository implements SubscriptionRepository {
  final Map<int, int> sinceLastPlay = {};
  final Map<int, DateTime> pausedAt = {};
  final List<int> resetIds = [];

  @override
  Future<bool> recordAutoDownloads(
    int id,
    int count, {
    required int pauseThreshold,
    required DateTime at,
  }) async {
    final total = sinceLastPlay[id] = (sinceLastPlay[id] ?? 0) + count;
    if (pausedAt.containsKey(id) || total < pauseThreshold) return false;
    pausedAt[id] = at;
    return true;
  }

  @override
  Future<void> resetAutoDownloadActivity(int id) async => resetIds.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeEpisodeRepository implements EpisodeRepository {
  final Map<int, Episode> byId = {};

  @override
  Future<Episode?> getById(int id) async => byId[id];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime(2026, 10, 6, 12);
  const threshold = AppConstants.autoDownloadPauseThreshold;
  late _FakeSubscriptionRepository subscriptions;
  late _FakeEpisodeRepository episodes;
  late AutoDownloadPauseService service;

  setUp(() {
    subscriptions = _FakeSubscriptionRepository();
    episodes = _FakeEpisodeRepository();
    service = AutoDownloadPauseService(
      subscriptionRepository: subscriptions,
      episodeRepository: episodes,
      clock: () => now,
    );
  });

  group('recordAutoDownloads', () {
    test('stays active below the threshold', () async {
      await service.recordAutoDownloads(1, threshold - 1);

      check(subscriptions.pausedAt).isEmpty();
    });

    test('pauses once the threshold is reached', () async {
      await service.recordAutoDownloads(1, threshold - 1);
      await service.recordAutoDownloads(1, 1);

      check(subscriptions.pausedAt).deepEquals({1: now});
    });

    test('ignores passes that created nothing', () async {
      await service.recordAutoDownloads(1, 0);

      check(subscriptions.sinceLastPlay).isEmpty();
    });
  });

  group('recordPlayback', () {
    test("resets the played episode's podcast", () async {
      episodes.byId[10] = Episode()
        ..id = 10
        ..podcastId = 3
        ..guid = 'guid'
        ..title = 'Episode'
        ..audioUrl = 'https://example.com/10.mp3';

      await service.recordPlayback(10);

      check(subscriptions.resetIds).deepEquals([3]);
    });

    test('does nothing for an unknown episode', () async {
      await service.recordPlayback(10);

      check(subscriptions.resetIds).isEmpty();
    });
  });
}
