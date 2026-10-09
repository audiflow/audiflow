import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_list_section.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/menu_selector_button.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart' show SortOrder;
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

  Widget host(Widget child) => HapticsScope(
    player: player,
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: Center(child: child)),
    ),
  );

  group('MenuSelectorButton', () {
    Future<List<String>> choose(WidgetTester tester, String label) async {
      final chosen = <String>[];
      await tester.pumpWidget(
        host(
          MenuSelectorButton<String>(
            choices: const ['All', 'Unplayed'],
            selected: 'All',
            labelOf: (choice) => choice,
            onSelected: chosen.add,
          ),
        ),
      );
      await tester.tap(find.byType(MenuSelectorButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      return chosen;
    }

    testWidgets('a new choice plays selection', (tester) async {
      check(await choose(tester, 'Unplayed')).deepEquals(['Unplayed']);
      check(player.played).deepEquals([HapticToken.selection]);
    });

    testWidgets('sliding to a new choice and releasing plays it once', (
      tester,
    ) async {
      final chosen = <String>[];
      await tester.pumpWidget(
        host(
          MenuSelectorButton<String>(
            choices: const ['All', 'Unplayed'],
            selected: 'All',
            labelOf: (choice) => choice,
            onSelected: chosen.add,
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MenuSelectorButton<String>)),
      );
      await tester.pump(
        ActionMenuTrigger.holdDuration + const Duration(milliseconds: 10),
      );
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.text('Unplayed')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(chosen).deepEquals(['Unplayed']);
      check(player.played).deepEquals([HapticToken.selection]);
    });

    testWidgets('re-picking the current choice plays nothing', (tester) async {
      check(await choose(tester, 'All')).deepEquals(['All']);
      check(player.played).isEmpty();
    });
  });

  testWidgets('the sort order toggle plays selection', (tester) async {
    var toggles = 0;
    await tester.pumpWidget(
      host(
        SortOrderButton(
          sortOrder: SortOrder.descending,
          onPressed: () => toggles++,
        ),
      ),
    );

    await tester.tap(find.byType(SortOrderButton));

    check(toggles).equals(1);
    check(player.played).deepEquals([HapticToken.selection]);
  });
}
