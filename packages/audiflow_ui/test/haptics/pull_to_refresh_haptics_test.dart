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
  late int refreshes;

  setUp(() {
    player = _RecordingHapticPlayer();
    refreshes = 0;
  });

  Future<void> pumpList(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HapticsScope(
        player: player,
        child: MaterialApp(
          home: Scaffold(
            body: PullToRefreshHaptics(
              child: RefreshIndicator(
                onRefresh: () async => refreshes++,
                child: ListView(
                  children: [
                    for (var i = 0; i < 30; i++)
                      SizedBox(height: 60, child: Text('Item $i')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pulls down by [pull] in small steps, then optionally back up by [back].
  Future<void> pull(WidgetTester tester, double pull, {double back = 0}) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Item 0')),
    );
    for (var moved = 0.0; moved < pull; moved += 10) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    for (var moved = 0.0; moved < back; moved += 10) {
      await gesture.moveBy(const Offset(0, -10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  group('Android', () {
    testWidgets('a full pull plays one cross and refreshes', (tester) async {
      await pumpList(tester);
      await pull(tester, 400);
      check(player.played).deepEquals([HapticToken.thresholdCross]);
      check(refreshes).equals(1);
    });

    testWidgets('a short pull plays nothing', (tester) async {
      await pumpList(tester);
      await pull(tester, 60);
      check(player.played).isEmpty();
      check(refreshes).equals(0);
    });

    testWidgets('pulling back below the trigger plays release', (tester) async {
      await pumpList(tester);
      await pull(tester, 400, back: 250);
      check(
        player.played,
      ).deepEquals([HapticToken.thresholdCross, HapticToken.thresholdRelease]);
      check(refreshes).equals(0);
    });
  });

  group('iOS', () {
    testWidgets(
      'pulling back after arming plays no release',
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      (tester) async {
        await pumpList(tester);
        await pull(tester, 400, back: 250);
        check(player.played).deepEquals([HapticToken.thresholdCross]);
      },
    );
  });
}
