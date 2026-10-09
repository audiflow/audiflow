import 'package:audiflow_app/features/player/presentation/controllers/seek_undo_controller.dart';
import 'package:audiflow_app/features/player/presentation/widgets/seek_undo_overlay.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

/// Starts with an origin so the pill is visible without driving a seek.
class _VisibleSeekUndo extends SeekUndoController {
  @override
  SeekUndoState? build() =>
      const SeekUndoState(origin: Duration(minutes: 5), episodeUrl: 'e');

  @override
  void dismiss() => state = null;
}

void main() {
  testWidgets('Go back plays the tap haptic and seeks back', (tester) async {
    final player = _RecordingHapticPlayer();
    var goBacks = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seekUndoControllerProvider.overrideWith(_VisibleSeekUndo.new),
        ],
        child: HapticsScope(
          player: player,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(body: SeekUndoOverlay(onGoBack: () => goBacks++)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Go back'));

    check(goBacks).equals(1);
    check(player.played).deepEquals([HapticToken.tap]);
  });
}
