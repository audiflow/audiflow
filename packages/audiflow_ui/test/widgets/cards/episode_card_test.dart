import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    String title = 'Test Episode',
    String pillLabel = '33m',
    String? dateLabel = 'Apr 29',
    String? description,
    String? thumbnailUrl,
    bool isPlaying = false,
    bool isLoading = false,
    bool isInProgress = false,
    bool isNew = false,
    bool isCompleted = false,
    bool isCurrentEpisode = false,
    double? progressFraction,
    VoidCallback? onPlayPause,
    VoidCallback? onTap,
    List<Widget> actionButtons = const [],
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: SizedBox(
          height: episodeCardExtent,
          child: EpisodeCard(
            title: title,
            pillLabel: pillLabel,
            dateLabel: dateLabel,
            description: description,
            thumbnailUrl: thumbnailUrl,
            isPlaying: isPlaying,
            isLoading: isLoading,
            isInProgress: isInProgress,
            isNew: isNew,
            isCompleted: isCompleted,
            isCurrentEpisode: isCurrentEpisode,
            progressFraction: progressFraction,
            onPlayPause: onPlayPause,
            onTap: onTap,
            actionButtons: actionButtons,
          ),
        ),
      ),
    );
  }

  group('EpisodeCard', () {
    testWidgets('renders title, pill, and date separately', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          title: 'My Episode',
          pillLabel: '45m',
          dateLabel: 'Mar 22',
        ),
      );
      check(find.text('My Episode').evaluate().length).equals(1);
      check(find.text('45m').evaluate().length).equals(1);
      check(find.text('Mar 22').evaluate().length).equals(1);
    });

    testWidgets('omits date text when dateLabel is null', (tester) async {
      await tester.pumpWidget(buildSubject(dateLabel: null));
      check(find.text('Apr 29').evaluate().length).equals(0);
    });

    testWidgets('not played pill: play glyph, no progress line', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      check(find.byIcon(Icons.play_arrow_rounded).evaluate().length).equals(1);
      check(find.byType(ProgressLine).evaluate().length).equals(0);
    });

    testWidgets('completed: check glyph and a full progress line', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          pillLabel: 'Completed',
          isCompleted: true,
          isInProgress: false,
          progressFraction: 0.99,
        ),
      );
      check(find.byIcon(Icons.check_rounded).evaluate().length).equals(1);
      check(find.text('Completed').evaluate().length).equals(1);
      final line = tester.widget<ProgressLine>(find.byType(ProgressLine));
      check(line.fraction).equals(1);
    });

    testWidgets('playing: pause glyph, progress on the bottom edge', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          pillLabel: '12m left',
          isPlaying: true,
          isInProgress: true,
          progressFraction: 0.4,
        ),
      );
      check(find.byIcon(Icons.pause_rounded).evaluate().length).equals(1);
      check(find.byType(CircularProgressIndicator).evaluate().length).equals(0);
      final line = tester.widget<ProgressLine>(find.byType(ProgressLine));
      check(line.fraction).equals(0.4);
      final cardRect = tester.getRect(find.byType(EpisodeCard));
      check(
        tester.getRect(find.byType(ProgressLine)).bottom,
      ).equals(cardRect.bottom);
    });

    testWidgets('in-progress paused: play glyph and progress line', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          pillLabel: '12m left',
          isInProgress: true,
          progressFraction: 0.4,
        ),
      );
      check(find.byIcon(Icons.play_arrow_rounded).evaluate().length).equals(1);
      check(find.byType(ProgressLine).evaluate().length).equals(1);
    });

    testWidgets('progress line keeps the fixed card extent', (tester) async {
      await tester.pumpWidget(
        buildSubject(isInProgress: true, progressFraction: 0.4),
      );
      check(
        tester.getSize(find.byType(EpisodeCard)).height,
      ).equals(episodeCardExtent);
    });

    testWidgets('loading pill: indeterminate spinner', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(spinner.value).isNull();
    });

    testWidgets('new episodes get an accent dot before the date', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(isNew: true));
      final dot = find.byKey(EpisodeCard.newDotKey);
      check(dot.evaluate().length).equals(1);
      final decoration =
          tester.widget<DecoratedBox>(dot).decoration as BoxDecoration;
      check(decoration.color).equals(AppColors.light.accent);
      check(
        tester.getCenter(dot).dx,
      ).isLessThan(tester.getTopLeft(find.text('Apr 29')).dx);
    });

    testWidgets('no dot when the episode is not new', (tester) async {
      await tester.pumpWidget(buildSubject());
      check(find.byKey(EpisodeCard.newDotKey).evaluate()).isEmpty();
    });

    testWidgets('date sits above a three-line title', (tester) async {
      await tester.pumpWidget(buildSubject(title: 'My Episode'));
      check(
        tester.getTopLeft(find.text('Apr 29')).dy,
      ).isLessThan(tester.getTopLeft(find.text('My Episode')).dy);
      final title = tester.widget<Text>(find.text('My Episode'));
      check(title.maxLines).equals(3);
      check(title.style?.color).equals(AppColors.light.ink);
    });

    testWidgets('played episodes fade the title and artwork', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          isCompleted: true,
          thumbnailUrl: 'https://example.com/art.jpg',
        ),
      );
      final title = tester.widget<Text>(find.text('Test Episode'));
      check(title.style?.color).equals(AppColors.light.inkTertiary);
      final artwork = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(ArtworkImage),
          matching: find.byType(Opacity),
        ),
      );
      check(artwork.opacity).isLessThan(1);
    });

    testWidgets('the playing episode title uses the accent', (tester) async {
      await tester.pumpWidget(buildSubject(isCurrentEpisode: true));
      final title = tester.widget<Text>(find.text('Test Episode'));
      check(title.style?.color).equals(AppColors.light.accent);
    });

    testWidgets('fires onPlayPause when pill tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onPlayPause: () => tapped = true));
      await tester.tap(find.byType(EpisodePlayPill));
      check(tapped).isTrue();
    });

    testWidgets('fires onTap when card body tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onTap: () => tapped = true));
      await tester.tap(find.text('Test Episode'));
      check(tapped).isTrue();
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(description: 'This is a test description'),
      );
      check(
        find.text('This is a test description').evaluate().length,
      ).equals(1);
    });

    testWidgets('episodeCardExtent matches actual rendered height', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      final cardSize = tester.getSize(find.byType(EpisodeCard));
      check(cardSize.height).equals(episodeCardExtent);
    });

    testWidgets('decodes thumbnail at display size to stay in memory cache', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(thumbnailUrl: 'https://example.com/art.jpg'),
      );

      final image = tester.widget<ExtendedImage>(find.byType(ExtendedImage));
      final expectedWidth = (56 * tester.view.devicePixelRatio).round();
      check(image.image).isA<ExtendedResizeImage>()
        ..has((it) => it.width, 'width').equals(expectedWidth)
        // Height stays null so non-square artwork keeps its aspect ratio.
        ..has((it) => it.height, 'height').isNull();
    });
  });
}
