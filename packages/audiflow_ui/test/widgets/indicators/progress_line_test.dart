import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TapCounter extends StatefulWidget {
  const _TapCounter();

  @override
  State<_TapCounter> createState() => _TapCounterState();
}

class _TapCounterState extends State<_TapCounter> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: TextButton(
        onPressed: () => setState(() => _count++),
        child: Text('count $_count'),
      ),
    );
  }
}

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: Scaffold(
      body: Center(child: SizedBox(width: 200, child: child)),
    ),
  );

  Finder fillFinder() => find.byKey(ProgressLine.fillKey);

  group('ProgressLine', () {
    testWidgets('is 3px tall and fills by fraction', (tester) async {
      await tester.pumpWidget(host(const ProgressLine(fraction: 0.25)));
      check(tester.getSize(find.byType(ProgressLine)).height).equals(3);
      check(tester.getSize(fillFinder()).width).equals(50);
    });

    testWidgets('uses hairline track and accent fill by default', (
      tester,
    ) async {
      await tester.pumpWidget(host(const ProgressLine(fraction: 0.5)));
      final track = tester.widget<ColoredBox>(
        find.byKey(ProgressLine.trackKey),
      );
      final fill = tester.widget<ColoredBox>(fillFinder());
      check(track.color).equals(AppColors.light.hairline);
      check(fill.color).equals(AppColors.light.accent);
    });

    testWidgets('accepts a fill override such as brand', (tester) async {
      await tester.pumpWidget(
        host(ProgressLine(fraction: 0.5, fillColor: AppColors.light.brand)),
      );
      check(
        tester.widget<ColoredBox>(fillFinder()).color,
      ).equals(AppColors.light.brand);
    });

    testWidgets('clamps out-of-range fractions', (tester) async {
      await tester.pumpWidget(host(const ProgressLine(fraction: 1.7)));
      check(tester.getSize(fillFinder()).width).equals(200);
      await tester.pumpWidget(host(const ProgressLine(fraction: -0.3)));
      check(tester.getSize(fillFinder()).width).equals(0);
    });

    testWidgets('treats NaN as empty', (tester) async {
      await tester.pumpWidget(host(const ProgressLine(fraction: double.nan)));
      check(tester.getSize(fillFinder()).width).equals(0);
    });

    testWidgets('resolves dark tokens in dark theme', (tester) async {
      await tester.pumpWidget(
        host(const ProgressLine(fraction: 0.5), theme: AppTheme.dark()),
      );
      check(
        tester.widget<ColoredBox>(fillFinder()).color,
      ).equals(AppColors.dark.accent);
    });
  });

  group('ProgressLine.isStarted', () {
    test('true once fraction is above 0, including finished', () {
      check(ProgressLine.isStarted(0.5)).isTrue();
      check(ProgressLine.isStarted(0.001)).isTrue();
      check(ProgressLine.isStarted(1)).isTrue();
      check(ProgressLine.isStarted(1.2)).isTrue();
      check(ProgressLine.isStarted(null)).isFalse();
      check(ProgressLine.isStarted(0)).isFalse();
      check(ProgressLine.isStarted(-0.1)).isFalse();
      check(ProgressLine.isStarted(double.nan)).isFalse();
    });
  });

  group('BottomEdgeProgress', () {
    Widget card(double? fraction) => host(
      BottomEdgeProgress(
        fraction: fraction,
        child: const SizedBox(height: 80, child: Text('row')),
      ),
    );

    testWidgets('pins the line to the bottom edge once started', (
      tester,
    ) async {
      await tester.pumpWidget(card(0.4));
      final line = find.byType(ProgressLine);
      check(line.evaluate().length).equals(1);
      final cardRect = tester.getRect(find.byType(BottomEdgeProgress));
      final lineRect = tester.getRect(line);
      check(lineRect.bottom).equals(cardRect.bottom);
      check(lineRect.width).equals(cardRect.width);
    });

    testWidgets('does not change the child size', (tester) async {
      await tester.pumpWidget(card(0.4));
      check(tester.getSize(find.byType(BottomEdgeProgress)).height).equals(80);
    });

    testWidgets('child state survives the line appearing and leaving', (
      tester,
    ) async {
      Widget withFraction(double? fraction) => host(
        BottomEdgeProgress(fraction: fraction, child: const _TapCounter()),
      );
      await tester.pumpWidget(withFraction(0));
      await tester.tap(find.text('count 0'));
      await tester.pump();
      check(find.text('count 1').evaluate().length).equals(1);

      await tester.pumpWidget(withFraction(0.5));
      check(find.byType(ProgressLine).evaluate().length).equals(1);
      check(find.text('count 1').evaluate().length).equals(1);

      await tester.pumpWidget(withFraction(0));
      check(find.byType(ProgressLine).evaluate().length).equals(0);
      check(find.text('count 1').evaluate().length).equals(1);
    });

    testWidgets('shows a full line when finished', (tester) async {
      await tester.pumpWidget(card(1));
      final line = find.byType(ProgressLine);
      check(line.evaluate().length).equals(1);
      check(
        tester.getSize(find.byKey(ProgressLine.fillKey)).width,
      ).equals(tester.getSize(line).width);
    });

    for (final fraction in <double?>[null, 0]) {
      testWidgets('hides the line for fraction $fraction', (tester) async {
        await tester.pumpWidget(card(fraction));
        check(find.byType(ProgressLine).evaluate().length).equals(0);
        check(find.text('row').evaluate().length).equals(1);
      });
    }
  });
}
