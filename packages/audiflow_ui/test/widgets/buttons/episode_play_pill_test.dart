import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  );

  Color pillFill(WidgetTester tester) {
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byKey(EpisodePlayPill.surfaceKey),
        matching: find.byType(Material),
      ),
    );
    return material.color!;
  }

  Color labelColor(WidgetTester tester, String label) {
    return tester.widget<Text>(find.text(label)).style!.color!;
  }

  group('EpisodePlayPill', () {
    testWidgets('idle: play glyph on muted surface, ink label', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '48m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
          ),
        ),
      );
      check(find.byIcon(Icons.play_arrow_rounded).evaluate().length).equals(1);
      check(pillFill(tester)).equals(AppColors.light.surfaceMuted);
      check(labelColor(tester, '48m')).equals(AppColors.light.ink);
    });

    testWidgets('playing: pause glyph on accent tint, accent label', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '17m left',
            isPlaying: true,
            isLoading: false,
            isCompleted: false,
          ),
        ),
      );
      check(find.byIcon(Icons.pause_rounded).evaluate().length).equals(1);
      check(find.byIcon(Icons.play_arrow_rounded).evaluate().length).equals(0);
      check(pillFill(tester)).equals(AppColors.light.accentTint);
      check(labelColor(tester, '17m left')).equals(AppColors.light.accent);
    });

    testWidgets('completed: check glyph in tertiary ink', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: 'Played',
            isPlaying: false,
            isLoading: false,
            isCompleted: true,
          ),
        ),
      );
      check(find.byIcon(Icons.check_rounded).evaluate().length).equals(1);
      check(pillFill(tester)).equals(AppColors.light.surfaceMuted);
      check(labelColor(tester, 'Played')).equals(AppColors.light.inkTertiary);
    });

    testWidgets('loading: indeterminate spinner, no progress ring', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '48m',
            isPlaying: false,
            isLoading: true,
            isCompleted: false,
          ),
        ),
      );
      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      check(spinner.value).isNull();
    });

    testWidgets('loading wins over playing and completed', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '48m',
            isPlaying: true,
            isLoading: true,
            isCompleted: true,
          ),
        ),
      );
      check(find.byType(CircularProgressIndicator).evaluate().length).equals(1);
      check(find.byIcon(Icons.pause_rounded).evaluate().length).equals(0);
      check(find.byIcon(Icons.check_rounded).evaluate().length).equals(0);
    });

    testWidgets('never draws a determinate progress ring', (tester) async {
      for (final playing in [true, false]) {
        await tester.pumpWidget(
          host(
            EpisodePlayPill(
              label: '17m left',
              isPlaying: playing,
              isLoading: false,
              isCompleted: false,
            ),
          ),
        );
        check(
          find.byType(CircularProgressIndicator).evaluate().length,
        ).equals(0);
      }
    });

    testWidgets('visual pill is 32 tall and fully rounded', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '48m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
          ),
        ),
      );
      check(
        tester.getSize(find.byKey(EpisodePlayPill.surfaceKey)).height,
      ).equals(32);
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byKey(EpisodePlayPill.surfaceKey),
          matching: find.byType(Material),
        ),
      );
      check(material.shape).isA<StadiumBorder>();
    });

    testWidgets('tap target is at least 44 tall', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '48m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
          ),
        ),
      );
      check(
        tester.getSize(find.byType(EpisodePlayPill)).height,
      ).isGreaterOrEqual(44);
    });

    testWidgets('tapping the pill or its margin fires onPressed', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        host(
          EpisodePlayPill(
            label: '48m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
            onPressed: () => tapped++,
          ),
        ),
      );
      await tester.tap(find.byKey(EpisodePlayPill.surfaceKey));
      check(tapped).equals(1);

      // Just above the 32px visual, still inside the 44px target.
      final pillRect = tester.getRect(find.byKey(EpisodePlayPill.surfaceKey));
      await tester.tapAt(Offset(pillRect.center.dx, pillRect.top - 4));
      check(tapped).equals(2);
    });

    testWidgets('empty label still gets a 44x44 tap target', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        host(
          EpisodePlayPill(
            label: '',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
            onPressed: () => tapped++,
          ),
        ),
      );
      final size = tester.getSize(find.byType(EpisodePlayPill));
      check(size.width).isGreaterOrEqual(44);
      check(size.height).isGreaterOrEqual(44);

      // Just left of the narrow visual, still inside the 44px target.
      final pillRect = tester.getRect(find.byKey(EpisodePlayPill.surfaceKey));
      await tester.tapAt(Offset(pillRect.left - 3, pillRect.center.dy));
      check(tapped).equals(1);
    });

    testWidgets('empty label: glyph only', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
          ),
        ),
      );
      check(find.byType(Text).evaluate().length).equals(0);
      check(find.byIcon(Icons.play_arrow_rounded).evaluate().length).equals(1);
    });

    testWidgets('label uses tabular figures', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '48m',
            isPlaying: false,
            isLoading: false,
            isCompleted: false,
          ),
        ),
      );
      check(
        tester.widget<Text>(find.text('48m')).style!.fontFeatures,
      ).isNotNull().contains(const FontFeature.tabularFigures());
    });

    testWidgets('dark theme resolves dark tokens', (tester) async {
      await tester.pumpWidget(
        host(
          const EpisodePlayPill(
            label: '17m left',
            isPlaying: true,
            isLoading: false,
            isCompleted: false,
          ),
          theme: AppTheme.dark(),
        ),
      );
      check(pillFill(tester)).equals(AppColors.dark.accentTint);
      check(labelColor(tester, '17m left')).equals(AppColors.dark.accent);
    });
  });
}
