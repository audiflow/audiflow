import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_review_prompt_repository.dart';

void main() {
  group('ReviewPromptTrigger', () {
    test('emits after delay when threshold reached', () {
      fakeAsync((async) {
        final repo = FakeReviewPromptRepository(
          initial: const ReviewPromptStats(
            totalListened: reviewPromptInitialThreshold,
          ),
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
        final repo = FakeReviewPromptRepository(
          initial: const ReviewPromptStats(
            totalListened: Duration(milliseconds: 1000),
          ),
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

    test('does not emit when opted out', () {
      fakeAsync((async) {
        final repo = FakeReviewPromptRepository(
          initial: const ReviewPromptStats(
            totalListened: reviewPromptInitialThreshold,
            status: ReviewPromptStatus.optedOut,
          ),
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
        final repo = FakeReviewPromptRepository(
          initial: const ReviewPromptStats(
            totalListened: reviewPromptInitialThreshold,
          ),
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
        final repo = FakeReviewPromptRepository(
          initial: const ReviewPromptStats(
            totalListened: reviewPromptInitialThreshold,
          ),
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

    test('single arm emits exactly once even if more time passes', () {
      fakeAsync((async) {
        final repo = FakeReviewPromptRepository(
          initial: const ReviewPromptStats(
            totalListened: reviewPromptInitialThreshold,
          ),
        );
        final trigger = ReviewPromptTrigger(repository: repo);
        var emitted = 0;
        trigger.events.listen((_) => emitted++);

        trigger.armForPlayback();
        async.elapse(const Duration(seconds: 30));
        check(emitted).equals(1);

        trigger.dispose();
      });
    });

    test('arm after dispose is a no-op (no throw)', () {
      fakeAsync((async) {
        final repo = FakeReviewPromptRepository();
        final trigger = ReviewPromptTrigger(repository: repo);
        trigger.dispose();
        trigger.armForPlayback();
        async.elapse(const Duration(seconds: 5));
      });
    });
  });
}
