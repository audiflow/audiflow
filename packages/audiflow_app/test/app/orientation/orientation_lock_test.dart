import 'package:audiflow_app/app/orientation/orientation_lock.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('preferredOrientationsFor', () {
    test('locks phones to portrait', () {
      expect(preferredOrientationsFor(const Size(412, 915)), const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });

    test('allows every orientation on tablets', () {
      expect(
        preferredOrientationsFor(const Size(800, 1280)),
        DeviceOrientation.values,
      );
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

      expect(applied, hasLength(1));
    });

    testWidgets('waits for the first resume when started detached', (
      tester,
    ) async {
      // Headless start: audio_service runs main() with no activity attached.
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      addTearDown(lock.dispose);
      expect(applied, isEmpty);

      setLifecycle(tester, AppLifecycleState.resumed);
      expect(applied, hasLength(1));
    });

    testWidgets('applies only once across later resumes', (tester) async {
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      addTearDown(lock.dispose);

      setLifecycle(tester, AppLifecycleState.resumed);
      setLifecycle(tester, AppLifecycleState.inactive);
      setLifecycle(tester, AppLifecycleState.resumed);

      expect(applied, hasLength(1));
    });

    testWidgets('never applies once disposed before a resume', (tester) async {
      setLifecycle(tester, AppLifecycleState.detached);
      lock = createLock(tester)..applyWhenResumed();
      lock.dispose();

      setLifecycle(tester, AppLifecycleState.resumed);
      expect(applied, isEmpty);
    });
  });
}
