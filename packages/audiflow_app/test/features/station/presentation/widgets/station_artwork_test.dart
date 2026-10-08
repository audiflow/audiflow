import 'package:audiflow_app/features/station/presentation/widgets/station_artwork.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Null URLs render the fallback, so no test touches the network.
  Future<void> pump(
    WidgetTester tester,
    int podcasts, {
    VoidCallback? onAdd,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: SizedBox.square(
            dimension: 160,
            child: StationArtwork(
              artworkUrls: List<String?>.filled(podcasts, null),
              onAdd: onAdd,
            ),
          ),
        ),
      ),
    );
  }

  int cards() => find.byKey(StationArtwork.cardKey).evaluate().length;

  group('StationArtwork', () {
    testWidgets('one podcast fills the square without a card', (tester) async {
      await pump(tester, 1);
      check(cards()).equals(0);
      check(find.byIcon(Icons.podcasts).evaluate()).length.equals(1);
    });

    testWidgets('two podcasts stack as two cards', (tester) async {
      await pump(tester, 2);
      check(cards()).equals(2);
    });

    testWidgets('three podcasts stack as three cards', (tester) async {
      await pump(tester, 3);
      check(cards()).equals(3);
    });

    testWidgets('more podcasts show only the first three', (tester) async {
      await pump(tester, 5);
      check(cards()).equals(StationArtwork.maxCards);
    });

    testWidgets('cards overlap from top-left to bottom-right', (tester) async {
      await pump(tester, 3);
      final rects = find
          .byKey(StationArtwork.cardKey)
          .evaluate()
          .map((element) => tester.getRect(find.byWidget(element.widget)))
          .toList();
      check(rects[0].left < rects[1].left).isTrue();
      check(rects[1].top < rects[2].top).isTrue();
      check(rects[0].overlaps(rects[1])).isTrue();
    });

    testWidgets('an empty station offers the add button', (tester) async {
      var added = 0;
      await pump(tester, 0, onAdd: () => added++);
      await tester.tap(find.byKey(StationArtwork.addButtonKey));
      check(added).equals(1);
    });

    testWidgets('an empty station without onAdd has no button', (tester) async {
      await pump(tester, 0);
      check(find.byKey(StationArtwork.addButtonKey).evaluate()).isEmpty();
    });

    testWidgets('a station with podcasts has no add button', (tester) async {
      await pump(tester, 2, onAdd: () {});
      check(find.byKey(StationArtwork.addButtonKey).evaluate()).isEmpty();
    });
  });
}
