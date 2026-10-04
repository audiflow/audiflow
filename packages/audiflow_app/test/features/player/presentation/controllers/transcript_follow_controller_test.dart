import 'package:audiflow_app/features/player/presentation/controllers/transcript_follow_controller.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const resumeDelay = Duration(seconds: 5);

  group('TranscriptFollowController', () {
    late TranscriptFollowController controller;
    late int resumeCount;

    TranscriptFollowController create() {
      resumeCount = 0;
      return TranscriptFollowController(
        resumeDelay: resumeDelay,
        onAutoResume: () => resumeCount++,
      );
    }

    test('starts in following state', () {
      controller = create();
      addTearDown(controller.dispose);

      check(controller.isFollowing).isTrue();
    });

    test('user drag stops following and notifies listeners', () {
      controller = create();
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);

      controller.handleUserScrollStart();

      check(controller.isFollowing).isFalse();
      check(notified).equals(1);
    });

    test('scroll end while following does nothing', () {
      fakeAsync((async) {
        controller = create();

        controller.handleScrollEnd();
        async.elapse(resumeDelay * 2);

        check(controller.isFollowing).isTrue();
        check(resumeCount).equals(0);
        controller.dispose();
      });
    });

    test('resumes following after the delay without user scrolling', () {
      fakeAsync((async) {
        controller = create();

        controller
          ..handleUserScrollStart()
          ..handleScrollEnd();
        async.elapse(resumeDelay - const Duration(milliseconds: 1));
        check(controller.isFollowing).isFalse();
        check(resumeCount).equals(0);

        async.elapse(const Duration(milliseconds: 1));
        check(controller.isFollowing).isTrue();
        check(resumeCount).equals(1);
        controller.dispose();
      });
    });

    test('a new user drag before the delay restarts the countdown', () {
      fakeAsync((async) {
        controller = create();

        controller
          ..handleUserScrollStart()
          ..handleScrollEnd();
        async.elapse(const Duration(seconds: 4));
        controller.handleUserScrollStart();
        async.elapse(const Duration(seconds: 4));
        check(controller.isFollowing).isFalse();

        controller.handleScrollEnd();
        async.elapse(const Duration(seconds: 4));
        check(controller.isFollowing).isFalse();
        async.elapse(const Duration(seconds: 1));
        check(controller.isFollowing).isTrue();
        check(resumeCount).equals(1);
        controller.dispose();
      });
    });

    test('does not resume while the user is still dragging', () {
      fakeAsync((async) {
        controller = create();

        controller.handleUserScrollStart();
        async.elapse(resumeDelay * 3);

        check(controller.isFollowing).isFalse();
        check(resumeCount).equals(0);
        controller.dispose();
      });
    });

    test('resumeNow follows immediately and cancels the pending timer', () {
      fakeAsync((async) {
        controller = create();
        var notified = 0;
        controller
          ..handleUserScrollStart()
          ..handleScrollEnd()
          ..addListener(() => notified++);

        controller.resumeNow();
        check(controller.isFollowing).isTrue();
        check(notified).equals(1);

        async.elapse(resumeDelay * 2);
        check(resumeCount).equals(0);
        controller.dispose();
      });
    });

    test('resumeNow while following does not notify', () {
      controller = create();
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);

      controller.resumeNow();

      check(notified).equals(0);
    });

    test('a resting pointer holds the countdown until lifted', () {
      fakeAsync((async) {
        controller = create();

        controller
          ..handleUserScrollStart()
          ..handleScrollEnd()
          ..handlePointerDown();
        async.elapse(resumeDelay * 2);
        check(controller.isFollowing).isFalse();

        controller.handlePointerUp();
        async.elapse(resumeDelay - const Duration(milliseconds: 1));
        check(controller.isFollowing).isFalse();
        async.elapse(const Duration(milliseconds: 1));
        check(controller.isFollowing).isTrue();
        check(resumeCount).equals(1);
        controller.dispose();
      });
    });

    test('scroll end while a pointer is down does not arm the countdown', () {
      fakeAsync((async) {
        controller = create();

        controller
          ..handlePointerDown()
          ..handleUserScrollStart()
          ..handleScrollEnd();
        async.elapse(resumeDelay * 2);

        check(controller.isFollowing).isFalse();
        controller.dispose();
      });
    });

    test('countdown waits for every pointer to lift', () {
      fakeAsync((async) {
        controller = create();

        controller
          ..handlePointerDown()
          ..handlePointerDown()
          ..handleUserScrollStart()
          ..handlePointerUp();
        async.elapse(resumeDelay * 2);
        check(controller.isFollowing).isFalse();

        controller.handlePointerUp();
        async.elapse(resumeDelay);
        check(controller.isFollowing).isTrue();
        controller.dispose();
      });
    });

    test('pointer events while following do not change state', () {
      fakeAsync((async) {
        controller = create();

        controller
          ..handlePointerDown()
          ..handlePointerUp();
        async.elapse(resumeDelay * 2);

        check(controller.isFollowing).isTrue();
        check(resumeCount).equals(0);
        controller.dispose();
      });
    });

    test('dispose cancels the pending resume', () {
      fakeAsync((async) {
        controller = create();

        controller
          ..handleUserScrollStart()
          ..handleScrollEnd()
          ..dispose();
        async.elapse(resumeDelay * 2);

        check(resumeCount).equals(0);
      });
    });
  });
}
