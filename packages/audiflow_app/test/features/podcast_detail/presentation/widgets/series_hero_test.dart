import 'package:audiflow_app/features/podcast_detail/presentation/widgets/series_hero.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    String title = 'Mongol invasions',
    String? resumeLabel,
    VoidCallback? onResume,
    VoidCallback? onPodcastTap,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SeriesHero(
          title: title,
          podcastTitle: 'COTEN RADIO',
          meta: '8 episodes · 4h',
          resumeLabel: resumeLabel,
          onResume: onResume,
          onPodcastTap: onPodcastTap,
        ),
      ),
    ),
  );

  testWidgets('artwork sits beside the title', (tester) async {
    await pump(tester);
    final artwork = tester.getRect(find.byKey(SeriesHero.artworkKey));
    final title = tester.getRect(find.text('Mongol invasions'));
    check(artwork.width).equals(SeriesHero.artworkSize);
    check(artwork.right).isLessThan(title.left);
    check(find.text('8 episodes · 4h').evaluate()).length.equals(1);
  });

  testWidgets('resume button spans the width and plays', (tester) async {
    var resumed = 0;
    await pump(tester, resumeLabel: 'Resume #3', onResume: () => resumed++);
    final button = tester.getRect(find.byType(FilledButton));
    check(button.width).equals(800 - 2 * Spacing.screenHorizontal);
    await tester.tap(find.text('Resume #3'));
    check(resumed).equals(1);
  });

  testWidgets('no resume button without a label', (tester) async {
    await pump(tester);
    check(find.byType(FilledButton).evaluate()).isEmpty();
  });

  testWidgets('podcast name links back', (tester) async {
    var tapped = 0;
    await pump(tester, onPodcastTap: () => tapped++);
    await tester.tap(find.text('COTEN RADIO'));
    check(tapped).equals(1);
  });

  testWidgets('long titles use the smaller hero style', (tester) async {
    await pump(tester, title: 'A' * 30);
    final text = tester.widget<Text>(find.text('A' * 30));
    check(text.style?.fontSize).equals(AppTextStyles.heroTitleLong.fontSize);
  });
}
