import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({
    String title = 'Test Episode',
    String pillLabel = '33m',
    String? dateLabel = 'Apr 29',
    String? description,
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
      home: Scaffold(
        body: SizedBox(
          height: episodeCardExtent,
          child: EpisodeCard(
            title: title,
            pillLabel: pillLabel,
            dateLabel: dateLabel,
            description: description,
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

    testWidgets('not played pill: filled play icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      check(find.byIcon(Icons.play_circle_filled).evaluate().length).equals(1);
    });

    testWidgets('completed pill: check icon', (tester) async {
      await tester.pumpWidget(
        buildSubject(pillLabel: 'Completed', isCompleted: true),
      );
      check(
        find.byIcon(Icons.check_circle_outline).evaluate().length,
      ).equals(1);
      check(find.text('Completed').evaluate().length).equals(1);
    });

    testWidgets('playing pill: ring with pause and progress value', (
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
      check(find.byIcon(Icons.pause).evaluate().length).equals(1);
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(0.4);
    });

    testWidgets('in-progress paused pill: ring with play', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          pillLabel: '12m left',
          isInProgress: true,
          progressFraction: 0.4,
        ),
      );
      check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
    });

    testWidgets('loading pill: indeterminate spinner', (tester) async {
      await tester.pumpWidget(buildSubject(isLoading: true));
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(spinner.value).isNull();
    });

    testWidgets('shows new badge when isNew is true', (tester) async {
      await tester.pumpWidget(buildSubject(isNew: true));
      check(find.text('new').evaluate().length).equals(1);
    });

    testWidgets('does not show new badge when isNew is false', (tester) async {
      await tester.pumpWidget(buildSubject());
      check(find.text('new').evaluate().length).equals(0);
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
  });
}
