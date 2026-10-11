import 'package:audiflow_app/app/orientation/orientation_lock.dart';
import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('preferredOrientationsFor', () {
    test('locks phones to portrait', () {
      check(preferredOrientationsFor(const Size(412, 915))).deepEquals(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });

    test('allows every orientation on tablets', () {
      check(
        preferredOrientationsFor(const Size(800, 1280)),
      ).deepEquals(DeviceOrientation.values);
    });
  });

  group('OrientationLock.applyWhenResumed', () {
    late List<List<DeviceOrientation>> applied;
    late OrientationLock lock;

    void setLifecycle(WidgetTester tester, AppLifecycleState state) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }

    OrientationLock createLock(WidgetTester tester) {
      return OrientationLock(
        binding: tester.binding,
        setPreferredOrientations: (orientations) async {
          applied.add(orientations);
        },
      );
    }

    setUp(() => applied = []);

    testWidgets('applies at once when already resumed', (tester) async {
      setLifecycle(tester, AppLifecycleState.resumed);
      lock = createLock(tester)..applyWhenResumed();
      addTearDown(lock.dispose);

      check(applied).length.equals(1);
    });

    testWidgets('waits for the first resume when started detached', (
      tester,
    ) async {
      // Headless start: audio_service runs main() with no activity attached.
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      addTearDown(lock.dispose);
      check(applied).isEmpty();

      setLifecycle(tester, AppLifecycleState.resumed);
      check(applied).length.equals(1);
    });

    testWidgets('applies only once across later resumes', (tester) async {
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      addTearDown(lock.dispose);

      setLifecycle(tester, AppLifecycleState.resumed);
      setLifecycle(tester, AppLifecycleState.inactive);
      setLifecycle(tester, AppLifecycleState.resumed);

      check(applied).length.equals(1);
    });

    void setView(WidgetTester tester, Size physicalSize, double pixelRatio) {
      tester.view
        ..physicalSize = physicalSize
        ..devicePixelRatio = pixelRatio;
      addTearDown(tester.view.reset);
    }

    testWidgets('locks a phone to portrait from its view size', (tester) async {
      // 1440x3120 px at 3.5x is a 411 dp wide phone; it only reads as a
      // tablet if the pixel ratio is ignored.
      setView(tester, const Size(1440, 3120), 3.5);
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      addTearDown(lock.dispose);

      setLifecycle(tester, AppLifecycleState.resumed);
      check(applied).deepEquals([
        const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
      ]);
    });

    testWidgets('frees a tablet from its view size', (tester) async {
      setView(tester, const Size(1600, 2560), 2);
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      addTearDown(lock.dispose);

      setLifecycle(tester, AppLifecycleState.resumed);
      check(applied).deepEquals([DeviceOrientation.values]);
    });

    testWidgets('never applies once disposed before a resume', (tester) async {
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      lock.dispose();

      setLifecycle(tester, AppLifecycleState.resumed);
      check(applied).isEmpty();
    });
  });
}
