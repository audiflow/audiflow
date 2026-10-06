import 'package:audiflow_app/features/download/presentation/controllers/auto_download_keep_count_controller.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fakes.dart';

class _FakeDownloadRetentionService implements DownloadRetentionService {
  final List<({int podcastId, int? override, int defaultKeepCount})> trims = [];

  @override
  Future<int> trimForSubscription(
    Subscription subscription, {
    required int defaultKeepCount,
  }) async {
    trims.add((
      podcastId: subscription.id,
      override: subscription.autoDownloadKeepCount,
      defaultKeepCount: defaultKeepCount,
    ));
    return 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Subscription _subscription(int id) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/feed/$id'
    ..title = 'Podcast $id'
    ..artistName = 'Artist'
    ..subscribedAt = DateTime(2026)
    ..autoDownload = true;
}

void main() {
  late SharedPreferences prefs;
  late _FakeDownloadRetentionService retention;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    retention = _FakeDownloadRetentionService();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        subscriptionRepositoryProvider.overrideWithValue(
          FakeSubscriptionRepository(
            subscriptions: [_subscription(1), _subscription(2)],
          ),
        ),
        downloadRetentionServiceProvider.overrideWithValue(retention),
      ],
    );
  });

  tearDown(() => container.dispose());

  AutoDownloadKeepCountController controller() =>
      container.read(autoDownloadKeepCountControllerProvider.notifier);

  test('setGlobal saves the keep count and trims every podcast', () async {
    await controller().setGlobal(5);

    check(
      container.read(appSettingsRepositoryProvider).getAutoDownloadKeepCount(),
    ).equals(5);
    check(retention.trims.map((t) => t.podcastId)).deepEquals([1, 2]);
    check(retention.trims.every((t) => t.defaultKeepCount == 5)).isTrue();
  });

  test(
    'setForPodcast saves the override and trims only that podcast',
    () async {
      await controller().setForPodcast(2, 1);

      check(retention.trims).deepEquals([
        (
          podcastId: 2,
          override: 1,
          defaultKeepCount: SettingsDefaults.autoDownloadKeepCount,
        ),
      ]);
    },
  );
}
