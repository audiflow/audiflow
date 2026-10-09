import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late int frameworkVibrations;

  setUp(() {
    player = _RecordingHapticPlayer();
    frameworkVibrations = 0;
  });

  // Counts Flutter's own haptics, which must stay silent so the catalog
  // token is the only feedback.
  void countFrameworkVibrations(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') frameworkVibrations++;
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
  }

  Widget host(Widget child) => HapticsScope(
    player: player,
    child: MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );

  test('longPressHaptic plays longPress, then calls through', () {
    var calls = 0;
    player.longPressHaptic(() => calls++)!();
    check(player.played).deepEquals([HapticToken.longPress]);
    check(calls).equals(1);
    check(player.longPressHaptic(null)).isNull();
  });

  group('AddToQueueButton', () {
    testWidgets('long press plays longPress only, tap plays nothing', (
      tester,
    ) async {
      countFrameworkVibrations(tester);
      var playNext = 0;
      var playLater = 0;
      await tester.pumpWidget(
        host(
          AddToQueueButton(
            onPlayLater: () => playLater++,
            onPlayNext: () => playNext++,
          ),
        ),
      );

      await tester.tap(find.byType(AddToQueueButton));
      await tester.longPress(find.byType(AddToQueueButton));
      await tester.pumpAndSettle();

      check(playLater).equals(1);
      check(playNext).equals(1);
      check(player.played).deepEquals([HapticToken.longPress]);
      check(frameworkVibrations).equals(0);
    });
  });

  group('EpisodeCard', () {
    testWidgets('long press plays longPress only', (tester) async {
      countFrameworkVibrations(tester);
      var longPresses = 0;
      await tester.pumpWidget(
        host(
          EpisodeCard(
            title: 'Episode',
            pillLabel: '33m',
            onTap: () {},
            onLongPress: () => longPresses++,
          ),
        ),
      );

      await tester.longPress(find.text('Episode'));
      await tester.pumpAndSettle();

      check(longPresses).equals(1);
      check(player.played).deepEquals([HapticToken.longPress]);
      check(frameworkVibrations).equals(0);
    });
  });
}
