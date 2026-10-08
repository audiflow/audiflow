import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_description_card.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  Future<void> pump(WidgetTester tester, String content) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: EpisodeDescriptionCard(content: content),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double cardHeight(WidgetTester tester) =>
      tester.getSize(find.byType(EpisodeDescriptionCard)).height;

  group('EpisodeDescriptionCard', () {
    testWidgets('short notes show no toggle', (tester) async {
      await pump(tester, 'One short line.');

      check(find.text(l10n.episodeDetailAbout).evaluate()).length.equals(1);
      check(find.text(l10n.episodeDetailShowMore).evaluate()).isEmpty();
    });

    testWidgets('long notes clamp and expand with the toggle', (tester) async {
      final long = List.generate(30, (i) => 'Line $i of the notes.').join('\n');
      await tester.binding.setSurfaceSize(const Size(400, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pump(tester, long);
      final collapsed = cardHeight(tester);

      await tester.tap(find.text(l10n.episodeDetailShowMore));
      await tester.pumpAndSettle();
      check(cardHeight(tester)).isGreaterThan(collapsed);

      await tester.tap(find.text(l10n.episodeDetailShowLess));
      await tester.pumpAndSettle();
      check(cardHeight(tester)).equals(collapsed);
      check(find.text(l10n.episodeDetailShowMore).evaluate()).length.equals(1);
    });
  });
}
