import 'package:audiflow_app/features/queue/presentation/widgets/clear_queue_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
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
  testWidgets('arming the confirmation plays warning, confirming does not', (
    tester,
  ) async {
    final player = _RecordingHapticPlayer();
    var clears = 0;
    await tester.pumpWidget(
      HapticsScope(
        player: player,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            appBar: AppBar(
              actions: [
                ClearQueueButton(enabled: true, onClear: () => clears++),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ClearQueueButton));
    await tester.pump();
    check(player.played).deepEquals([HapticToken.warning]);

    await tester.tap(find.text('Confirm?'));
    await tester.pump();
    check(clears).equals(1);
    check(player.played).deepEquals([HapticToken.warning]);
  });
}
