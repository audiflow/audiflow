import 'package:audiflow_ui/src/widgets/cards/episode_card.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    String title = 'Test Episode',
    String subtitle = 'Jan 1 · 30 min',
    String? description,
    bool isPlaying = false,
    bool isLoading = false,
    bool isNew = false,
    bool isCompleted = false,
    bool isCurrentEpisode = false,
    VoidCallback? onPlayPause,
    VoidCallback? onTap,
    List<Widget> actionButtons = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: episodeCardExtent,
          child: EpisodeCard(
            title: title,
            subtitle: subtitle,
            description: description,
            isPlaying: isPlaying,
            isLoading: isLoading,
            isNew: isNew,
            isCompleted: isCompleted,
            isCurrentEpisode: isCurrentEpisode,
            onPlayPause: onPlayPause,
            onTap: onTap,
            actionButtons: actionButtons,
          ),
        ),
      ),
    );
  }

  group('EpisodeCard', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildSubject(title: 'My Episode', subtitle: 'Mar 22 · 45 min'),
      );

      check(
        find.text('My Episode'),
      ).has((f) => f.evaluate().length, 'count').equals(1);
      check(
        find.text('Mar 22 · 45 min'),
      ).has((f) => f.evaluate().length, 'count').equals(1);
    });

    testWidgets('shows play icon when not playing', (tester) async {
      await tester.pumpWidget(buildSubject());

      check(
        find.byIcon(Icons.play_circle_filled),
      ).has((f) => f.evaluate().length, 'count').equals(1);
      check(
        find.byIcon(Icons.pause_circle_filled),
      ).has((f) => f.evaluate().length, 'count').equals(0);
    });

    testWidgets('shows pause icon when playing', (tester) async {
      await tester.pumpWidget(buildSubject(isPlaying: true));

      check(
        find.byIcon(Icons.pause_circle_filled),
      ).has((f) => f.evaluate().length, 'count').equals(1);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));

      check(
        find.byType(CircularProgressIndicator),
      ).has((f) => f.evaluate().length, 'count').equals(1);
      // Play/pause icons should not be visible
      check(
        find.byIcon(Icons.play_circle_filled),
      ).has((f) => f.evaluate().length, 'count').equals(0);
    });

    testWidgets('loading placeholder is 44x44', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));

      final sizedBoxes = find.byType(SizedBox).evaluate().where((e) {
        final widget = e.widget as SizedBox;
        return widget.width == 44 && widget.height == 44;
      });
      check(sizedBoxes.length).isGreaterThan(0);
    });

    testWidgets('play button has 44x44 minimum touch target', (tester) async {
      await tester.pumpWidget(buildSubject());

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.play_circle_filled),
      );
      check(iconButton.constraints?.minWidth).equals(44);
      check(iconButton.constraints?.minHeight).equals(44);
    });

    testWidgets('shows new badge when isNew is true', (tester) async {
      await tester.pumpWidget(buildSubject(isNew: true));

      check(
        find.text('new'),
      ).has((f) => f.evaluate().length, 'count').equals(1);
    });

    testWidgets('does not show new badge when isNew is false', (tester) async {
      await tester.pumpWidget(buildSubject());

      check(
        find.text('new'),
      ).has((f) => f.evaluate().length, 'count').equals(0);
    });

    testWidgets('fires onPlayPause when play button tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onPlayPause: () => tapped = true));

      await tester.tap(find.byIcon(Icons.play_circle_filled));
      check(tapped).isTrue();
    });

    testWidgets('fires onTap when card body tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildSubject(onTap: () => tapped = true));

      await tester.tap(find.text('Test Episode'));
      check(tapped).isTrue();
    });

    testWidgets('action row height accommodates 44dp play button', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      // The card should render without layout overflow errors
      // (previously _actionRowHeight was 36, conflicting with 44dp button)
      check(tester.takeException()).isNull();
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(
        buildSubject(description: 'This is a test description'),
      );

      check(
        find.text('This is a test description'),
      ).has((f) => f.evaluate().length, 'count').equals(1);
    });

    testWidgets('episodeCardExtent matches actual rendered height', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final cardFinder = find.byType(EpisodeCard);
      final cardSize = tester.getSize(cardFinder);
      check(cardSize.height).equals(episodeCardExtent);
    });
  });
}
