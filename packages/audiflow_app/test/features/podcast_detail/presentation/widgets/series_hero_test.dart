import 'package:audiflow_app/features/podcast_detail/presentation/widgets/episode_detail_actions.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_detail_header.dart';
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
    String? thumbnailUrl,
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
          thumbnailUrl: thumbnailUrl,
          resumeLabel: resumeLabel,
          onResume: onResume,
          onPodcastTap: onPodcastTap,
        ),
      ),
    ),
  );

  void setScreenSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('artwork sits beside the title', (tester) async {
    await pump(tester);
    final artwork = tester.getRect(find.byKey(SeriesHero.artworkKey));
    final title = tester.getRect(find.text('Mongol invasions'));
    check(artwork.right).isLessThan(title.left);
    check(find.text('8 episodes · 4h').evaluate()).length.equals(1);
  });

  testWidgets('artwork keeps the compact size on phones', (tester) async {
    setScreenSize(tester, const Size(390, 844));
    await pump(tester);
    final artwork = tester.getRect(find.byKey(SeriesHero.artworkKey));
    final title = tester.getRect(find.text('Mongol invasions'));
    check(artwork.size).equals(const Size.square(SeriesHero.phoneArtworkSize));
    check(title.left - artwork.right).equals(Spacing.md);
  });

  testWidgets('artwork matches the podcast hero artwork on tablets', (
    tester,
  ) async {
    setScreenSize(tester, const Size(1024, 768));
    await pump(tester, thumbnailUrl: 'https://example.com/a.jpg');
    final artwork = tester.getRect(find.byKey(SeriesHero.artworkKey));
    final title = tester.getRect(find.text('Mongol invasions'));
    check(
      artwork.size,
    ).equals(const Size.square(PodcastDetailHeader.artworkSize));
    check(title.left - artwork.right).equals(Spacing.lg);
    // Decodes at the podcast hero's width, so a series showing the podcast
    // artwork shares that decoded image instead of adding another.
    final image = tester.widget<ArtworkImage>(find.byType(ArtworkImage));
    check(image.width).equals(PodcastDetailHeader.artworkSize);
  });

  testWidgets('the default test surface counts as a tablet', (tester) async {
    await pump(tester);
    final artwork = tester.getRect(find.byKey(SeriesHero.artworkKey));
    check(artwork.width).equals(SeriesHero.tabletArtworkSize);
  });

  testWidgets('resume button spans the width on phones and plays', (
    tester,
  ) async {
    setScreenSize(tester, const Size(390, 844));
    var resumed = 0;
    await pump(tester, resumeLabel: 'Resume #3', onResume: () => resumed++);
    final button = tester.getRect(find.byType(FilledButton));
    check(button.width).equals(390 - 2 * Spacing.screenHorizontal);
    check(button.left).equals(Spacing.screenHorizontal);
    await tester.tap(find.text('Resume #3'));
    check(resumed).equals(1);
  });

  testWidgets('resume button is centered at the episode pill width on '
      'tablets', (tester) async {
    setScreenSize(tester, const Size(1024, 768));
    var resumed = 0;
    await pump(tester, resumeLabel: 'Resume #3', onResume: () => resumed++);
    final button = tester.getRect(find.byType(FilledButton));
    check(button.width).equals(EpisodePrimaryPill.maxWidth);
    check(button.center.dx).equals(1024 / 2);
    await tester.tap(find.text('Resume #3'));
    check(resumed).equals(1);
  });

  testWidgets('no resume button without a label', (tester) async {
    await pump(tester);
    check(find.byType(FilledButton).evaluate()).isEmpty();
  });

  testWidgets('podcast name links back with a full-size target', (
    tester,
  ) async {
    var tapped = 0;
    await pump(tester, onPodcastTap: () => tapped++);
    final target = find.ancestor(
      of: find.text('COTEN RADIO'),
      matching: find.byType(InkWell),
    );
    check(
      tester.getSize(target).height,
    ).isGreaterOrEqual(Spacing.minTouchTarget);
    await tester.tap(find.text('COTEN RADIO'));
    check(tapped).equals(1);
  });

  testWidgets('artwork is a labeled button', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SeriesHero(
            title: 'Series',
            podcastTitle: 'Podcast',
            meta: 'meta',
            thumbnailUrl: 'https://example.com/a.jpg',
            artworkLabel: 'View series artwork',
            onArtworkTap: () {},
          ),
        ),
      ),
    );
    check(
      tester.getSemantics(find.bySemanticsLabel('View series artwork')),
    ).has((node) => node.flagsCollection.isButton, 'isButton').isTrue();
    handle.dispose();
  });

  testWidgets('long titles use the smaller hero style', (tester) async {
    await pump(tester, title: 'A' * 30);
    final text = tester.widget<Text>(find.text('A' * 30));
    check(text.style?.fontSize).equals(AppTextStyles.heroTitleLong.fontSize);
  });
}
