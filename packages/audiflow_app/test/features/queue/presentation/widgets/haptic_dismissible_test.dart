import 'package:audiflow_app/features/queue/presentation/widgets/haptic_dismissible.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

void main() {
  late _RecordingHapticPlayer player;

  setUp(() => player = _RecordingHapticPlayer());

  Future<void> pumpRow(
    WidgetTester tester, {
    required ConfirmDismissCallback confirmDismiss,
  }) async {
    await tester.pumpWidget(
      HapticsScope(
        player: player,
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                HapticDismissible(
                  key: const ValueKey('row'),
                  confirmDismiss: confirmDismiss,
                  background: const ColoredBox(color: Colors.green),
                  child: const SizedBox(height: 64, child: Text('Row')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<TestGesture> dragBy(WidgetTester tester, double dx) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Row')),
    );
    // Small steps so the drag passes through the threshold, as a finger does.
    for (var moved = 0.0; moved.abs() < dx.abs(); moved += dx.sign * 20) {
      await gesture.moveBy(Offset(dx.sign * 20, 0));
      await tester.pump();
    }
    return gesture;
  }

  testWidgets('crossing and un-crossing the threshold plays both tokens', (
    tester,
  ) async {
    await pumpRow(tester, confirmDismiss: (_) async => false);
    final gesture = await dragBy(tester, 600);
    for (var i = 0; i < 30; i++) {
      await gesture.moveBy(const Offset(-20, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    check(
      player.played,
    ).deepEquals([HapticToken.thresholdCross, HapticToken.thresholdRelease]);
  });

  testWidgets('springing back after an action plays no release', (
    tester,
  ) async {
    var actions = 0;
    await pumpRow(
      tester,
      confirmDismiss: (_) async {
        actions++;
        return false;
      },
    );
    final gesture = await dragBy(tester, 600);
    await gesture.up();
    await tester.pumpAndSettle();

    check(actions).equals(1);
    check(player.played).deepEquals([HapticToken.thresholdCross]);
  });

  testWidgets('a second swipe after the spring-back plays again', (
    tester,
  ) async {
    await pumpRow(tester, confirmDismiss: (_) async => false);
    for (var i = 0; i < 2; i++) {
      final gesture = await dragBy(tester, 600);
      await gesture.up();
      await tester.pumpAndSettle();
    }

    check(
      player.played,
    ).deepEquals([HapticToken.thresholdCross, HapticToken.thresholdCross]);
  });

  group('SwipeThresholdTracker', () {
    DismissUpdateDetails update(
      double progress, {
      required bool reached,
      required bool previousReached,
    }) => DismissUpdateDetails(
      direction: DismissDirection.startToEnd,
      reached: reached,
      previousReached: previousReached,
      progress: progress,
    );

    test('a new drag during the return trip plays again', () {
      final tracker = SwipeThresholdTracker();
      check(
        tracker.update(update(0.45, reached: true, previousReached: false)),
      ).equals(HapticToken.thresholdCross);
      tracker.released();
      // Return trip: dropping below the threshold is not the finger's doing.
      check(
        tracker.update(update(0.3, reached: false, previousReached: true)),
      ).isNull();
      // A new drag catches the row mid-return and pulls it past again.
      check(
        tracker.update(update(0.35, reached: false, previousReached: false)),
      ).isNull();
      check(
        tracker.update(update(0.45, reached: true, previousReached: false)),
      ).equals(HapticToken.thresholdCross);
    });

    test('the finger pulling back below the threshold plays release', () {
      final tracker = SwipeThresholdTracker();
      tracker.update(update(0.45, reached: true, previousReached: false));
      check(
        tracker.update(update(0.3, reached: false, previousReached: true)),
      ).equals(HapticToken.thresholdRelease);
    });
  });
}
