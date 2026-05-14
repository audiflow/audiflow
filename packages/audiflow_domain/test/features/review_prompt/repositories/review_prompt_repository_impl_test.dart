import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ReviewPromptRepositoryImpl> buildRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return ReviewPromptRepositoryImpl(SharedPreferencesDataSource(prefs));
  }

  group('ReviewPromptRepositoryImpl', () {
    test('defaults when no values persisted', () async {
      final repo = await buildRepo();
      final stats = repo.getStats();
      check(stats.totalListenedMs).equals(0);
      check(
        stats.nextPromptThresholdMs,
      ).equals(ReviewPromptStats.initialThresholdMs);
      check(stats.userOptedOut).isFalse();
      check(stats.userTappedRateNow).isFalse();
      check(stats.lastPromptedAt).isNull();
    });

    test('addListenedMs accumulates and persists', () async {
      final repo = await buildRepo();
      await repo.addListenedMs(1000);
      await repo.addListenedMs(500);
      check(repo.getStats().totalListenedMs).equals(1500);

      final reload = await buildRepo();
      check(reload.getStats().totalListenedMs).equals(1500);
    });

    test('addListenedMs ignores non-positive deltas', () async {
      final repo = await buildRepo();
      await repo.addListenedMs(0);
      await repo.addListenedMs(-100);
      check(repo.getStats().totalListenedMs).equals(0);
    });

    test('recordPromptShown advances threshold and stores timestamp', () async {
      final repo = await buildRepo();
      final shownAt = DateTime.utc(2026, 5, 15, 10, 0, 0);
      await repo.recordPromptShown(shownAt);
      final stats = repo.getStats();
      check(stats.nextPromptThresholdMs).equals(
        ReviewPromptStats.initialThresholdMs +
            ReviewPromptStats.promptIntervalMs,
      );
      check(stats.lastPromptedAt).equals(shownAt);
    });

    test('markOptedOut persists across reload', () async {
      final repo = await buildRepo();
      await repo.markOptedOut();
      check(repo.getStats().userOptedOut).isTrue();
      final reload = await buildRepo();
      check(reload.getStats().userOptedOut).isTrue();
    });

    test('markUserRated persists across reload', () async {
      final repo = await buildRepo();
      await repo.markUserRated();
      check(repo.getStats().userTappedRateNow).isTrue();
      final reload = await buildRepo();
      check(reload.getStats().userTappedRateNow).isTrue();
    });

    test('reset clears all state', () async {
      final repo = await buildRepo();
      await repo.addListenedMs(123);
      await repo.markOptedOut();
      await repo.recordPromptShown(DateTime.utc(2026, 5, 15));
      await repo.reset();
      final stats = repo.getStats();
      check(stats.totalListenedMs).equals(0);
      check(stats.userOptedOut).isFalse();
      check(stats.lastPromptedAt).isNull();
      check(
        stats.nextPromptThresholdMs,
      ).equals(ReviewPromptStats.initialThresholdMs);
    });
  });
}
