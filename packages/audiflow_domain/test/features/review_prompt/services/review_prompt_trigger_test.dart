import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements ReviewPromptRepository {
  ReviewPromptStats stats = const ReviewPromptStats();

  @override
  ReviewPromptStats getStats() => stats;

  @override
  Future<void> addListenedMs(int deltaMs) async {
    stats = stats.copyWith(totalListenedMs: stats.totalListenedMs + deltaMs);
  }

  @override
  Future<void> markOptedOut() async {
    stats = stats.copyWith(userOptedOut: true);
  }

  @override
  Future<void> markUserRated() async {
    stats = stats.copyWith(userTappedRateNow: true);
  }

  @override
  Future<void> recordPromptShown(DateTime shownAt) async {
    stats = stats.copyWith(
      nextPromptThresholdMs:
          stats.nextPromptThresholdMs + ReviewPromptStats.promptIntervalMs,
      lastPromptedAt: shownAt,
    );
  }

  @override
  Future<void> reset() async {
    stats = const ReviewPromptStats();
  }
}

void main() {
  group('ReviewPromptTrigger', () {
    test('emits after delay when threshold reached', () {
      fakeAsync((async) {
        final repo = _FakeRepository()
          ..stats = const ReviewPromptStats(
            totalListenedMs: ReviewPromptStats.initialThresholdMs,
          );
        final trigger = ReviewPromptTrigger(repository: repo);
        var emitted = 0;
        trigger.events.listen((_) => emitted++);

        trigger.armForPlayback();
        async.elapse(const Duration(milliseconds: 1999));
        check(emitted).equals(0);
        async.elapse(const Duration(milliseconds: 2));
        check(emitted).equals(1);

        trigger.dispose();
      });
    });

    test('does not emit when threshold not reached', () {
      fakeAsync((async) {
        final repo = _FakeRepository()
          ..stats = const ReviewPromptStats(totalListenedMs: 1000);
        final trigger = ReviewPromptTrigger(repository: repo);
        var emitted = 0;
        trigger.events.listen((_) => emitted++);

        trigger.armForPlayback();
        async.elapse(const Duration(seconds: 5));
        check(emitted).equals(0);

        trigger.dispose();
      });
    });

    test('does not emit when user opted out', () {
      fakeAsync((async) {
        final repo = _FakeRepository()
          ..stats = const ReviewPromptStats(
            totalListenedMs: ReviewPromptStats.initialThresholdMs,
            userOptedOut: true,
          );
        final trigger = ReviewPromptTrigger(repository: repo);
        var emitted = 0;
        trigger.events.listen((_) => emitted++);

        trigger.armForPlayback();
        async.elapse(const Duration(seconds: 5));
        check(emitted).equals(0);

        trigger.dispose();
      });
    });

    test('cancel before delay prevents emit', () {
      fakeAsync((async) {
        final repo = _FakeRepository()
          ..stats = const ReviewPromptStats(
            totalListenedMs: ReviewPromptStats.initialThresholdMs,
          );
        final trigger = ReviewPromptTrigger(repository: repo);
        var emitted = 0;
        trigger.events.listen((_) => emitted++);

        trigger.armForPlayback();
        async.elapse(const Duration(milliseconds: 1000));
        trigger.cancel();
        async.elapse(const Duration(seconds: 5));
        check(emitted).equals(0);

        trigger.dispose();
      });
    });

    test('re-arming resets the timer', () {
      fakeAsync((async) {
        final repo = _FakeRepository()
          ..stats = const ReviewPromptStats(
            totalListenedMs: ReviewPromptStats.initialThresholdMs,
          );
        final trigger = ReviewPromptTrigger(repository: repo);
        var emitted = 0;
        trigger.events.listen((_) => emitted++);

        trigger.armForPlayback();
        async.elapse(const Duration(milliseconds: 1500));
        trigger.armForPlayback();
        async.elapse(const Duration(milliseconds: 1500));
        check(emitted).equals(0);
        async.elapse(const Duration(milliseconds: 600));
        check(emitted).equals(1);

        trigger.dispose();
      });
    });
  });
}
