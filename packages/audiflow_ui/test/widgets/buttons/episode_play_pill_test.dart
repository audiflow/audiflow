import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  group('EpisodePlayPill', () {
    testWidgets('not played: filled play icon, no ring', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '33m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
            isInProgress: false,
          ),
        ),
      );
      check(find.byIcon(Icons.play_circle_filled).evaluate().length).equals(1);
      check(find.byType(CircularProgressIndicator).evaluate().length).equals(0);
      check(
        find.byIcon(Icons.check_circle_outline).evaluate().length,
      ).equals(0);
      check(find.text('33m').evaluate().length).equals(1);
    });

    testWidgets('completed: check_circle_outline, no ring', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: 'Completed',
            isPlaying: false,
            isLoading: false,
            isCompleted: true,
            isInProgress: false,
          ),
        ),
      );
      check(
        find.byIcon(Icons.check_circle_outline).evaluate().length,
      ).equals(1);
      check(find.byType(CircularProgressIndicator).evaluate().length).equals(0);
      check(find.byIcon(Icons.play_circle_filled).evaluate().length).equals(0);
      check(find.text('Completed').evaluate().length).equals(1);
    });

    testWidgets('in-progress paused: ring + play icon', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '12m left',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
            isInProgress: true,
            progressFraction: 0.5,
          ),
        ),
      );
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(0.5);
      check(find.byIcon(Icons.play_arrow).evaluate().length).equals(1);
      check(find.byIcon(Icons.pause).evaluate().length).equals(0);
    });

    testWidgets('playing: ring + pause icon', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '12m left',
            isPlaying: true,
            isLoading: false,
            isCompleted: false,
            isInProgress: true,
            progressFraction: 0.7,
          ),
        ),
      );
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(0.7);
      check(find.byIcon(Icons.pause).evaluate().length).equals(1);
      check(find.byIcon(Icons.play_arrow).evaluate().length).equals(0);
    });

    testWidgets('loading: indeterminate spinner', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '33m',
            isPlaying: false,
            isLoading: true,
            isCompleted: false,
            isInProgress: false,
          ),
        ),
      );
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(spinner.value).isNull();
    });

    testWidgets('progress fraction clamps above 1.0', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '0m left',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
            isInProgress: true,
            progressFraction: 1.5,
          ),
        ),
      );
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(ring.value).isNotNull().equals(1.0);
    });

    testWidgets('enforces 44dp minimum tap-target height', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '33m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
            isInProgress: false,
          ),
        ),
      );
      final size = tester.getSize(find.byType(EpisodePlayPill));
      check(size.height).isGreaterOrEqual(44.0);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        host(
          EpisodePlayPill(
            label: '33m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
            isInProgress: false,
            onPressed: () => tapped++,
          ),
        ),
      );
      await tester.tap(find.byType(EpisodePlayPill));
      check(tapped).equals(1);
    });
  });
}
