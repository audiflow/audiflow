import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ReviewPromptRepositoryImpl> buildRepo({
    DateTime Function()? clock,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return ReviewPromptRepositoryImpl(
      SharedPreferencesDataSource(prefs),
      clock: clock,
    );
  }

  group('ReviewPromptRepositoryImpl', () {
    test('defaults when nothing persisted', () async {
      final repo = await buildRepo();
      final stats = repo.getStats();
      check(stats.totalListened).equals(Duration.zero);
      check(stats.nextPromptThreshold).equals(reviewPromptInitialThreshold);
      check(stats.status).equals(ReviewPromptStatus.accumulating);
      check(stats.lastPromptedAt).isNull();
    });

    test('addListened accumulates and persists', () async {
      final repo = await buildRepo();
      await repo.addListened(const Duration(milliseconds: 1000));
      await repo.addListened(const Duration(milliseconds: 500));
      check(
        repo.getStats().totalListened,
      ).equals(const Duration(milliseconds: 1500));
      final reload = await buildRepo();
      check(
        reload.getStats().totalListened,
      ).equals(const Duration(milliseconds: 1500));
    });

    test('addListened ignores non-positive deltas', () async {
      final repo = await buildRepo();
      await repo.addListened(Duration.zero);
      await repo.addListened(const Duration(milliseconds: -100));
      check(repo.getStats().totalListened).equals(Duration.zero);
    });

    test('recordPromptShown advances threshold and stores timestamp', () async {
      final shownAt = DateTime.utc(2026, 5, 15, 10);
      final repo = await buildRepo(clock: () => shownAt);
      await repo.recordPromptShown();
      final stats = repo.getStats();
      check(
        stats.nextPromptThreshold,
      ).equals(reviewPromptInitialThreshold + reviewPromptInterval);
      check(stats.lastPromptedAt).equals(shownAt);
    });

    test(
      'two prompts shown advance threshold cumulatively across reload',
      () async {
        final repo = await buildRepo(
          clock: () => DateTime.utc(2026, 5, 15, 10),
        );
        await repo.recordPromptShown();
        await repo.recordPromptShown();
        final reload = await buildRepo();
        check(
          reload.getStats().nextPromptThreshold,
        ).equals(reviewPromptInitialThreshold + reviewPromptInterval * 2);
      },
    );

    test('recordPromptShown is no-op once status is terminal', () async {
      final repo = await buildRepo();
      await repo.markOptedOut();
      final before = repo.getStats().nextPromptThreshold;
      await repo.recordPromptShown();
      check(repo.getStats().nextPromptThreshold).equals(before);
      check(repo.getStats().lastPromptedAt).isNull();
    });

    test('markOptedOut persists across reload', () async {
      final repo = await buildRepo();
      await repo.markOptedOut();
      check(repo.getStats().status).equals(ReviewPromptStatus.optedOut);
      final reload = await buildRepo();
      check(reload.getStats().status).equals(ReviewPromptStatus.optedOut);
    });

    test('markRated persists across reload', () async {
      final repo = await buildRepo();
      await repo.markRated();
      check(repo.getStats().status).equals(ReviewPromptStatus.rated);
      final reload = await buildRepo();
      check(reload.getStats().status).equals(ReviewPromptStatus.rated);
    });

    test('clamps a negative persisted total to zero', () async {
      SharedPreferences.setMockInitialValues({
        'review_prompt.total_listened_ms': -50,
      });
      final repo = await buildRepo();
      check(repo.getStats().totalListened).equals(Duration.zero);
    });

    test(
      'falls back to initial threshold when persisted threshold is 0',
      () async {
        SharedPreferences.setMockInitialValues({
          'review_prompt.next_threshold_ms': 0,
        });
        final repo = await buildRepo();
        check(
          repo.getStats().nextPromptThreshold,
        ).equals(reviewPromptInitialThreshold);
      },
    );

    test('reset clears all state', () async {
      final repo = await buildRepo();
      await repo.addListened(const Duration(milliseconds: 123));
      await repo.markOptedOut();
      await repo.recordPromptShown();
      await repo.reset();
      final stats = repo.getStats();
      check(stats.totalListened).equals(Duration.zero);
      check(stats.status).equals(ReviewPromptStatus.accumulating);
      check(stats.lastPromptedAt).isNull();
      check(stats.nextPromptThreshold).equals(reviewPromptInitialThreshold);
    });
  });
}
