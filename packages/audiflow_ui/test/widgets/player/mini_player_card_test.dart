import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      body: Align(alignment: Alignment.bottomCenter, child: child),
    ),
  );

  Widget card({double? progress, VoidCallback? onTap}) => MiniPlayerCard(
    artwork: const SizedBox.expand(key: ValueKey('art')),
    title: 'Episode title',
    subtitle: 'Podcast name',
    progress: progress,
    onTap: onTap,
    actions: [
      IconButton(
        tooltip: 'Play',
        icon: const Icon(Icons.play_arrow),
        onPressed: () {},
      ),
    ],
  );

  BoxDecoration surface(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(find.byKey(MiniPlayerCard.surfaceKey))
              .decoration
          as BoxDecoration;

  testWidgets('floating surface card with radius 16', (tester) async {
    await tester.pumpWidget(host(card()));
    final decoration = surface(tester);
    check(decoration.color).equals(AppColors.light.surface);
    check(decoration.borderRadius).equals(AppBorders.card);
    check(decoration.boxShadow).isNotNull().deepEquals(AppShadows.floating);
  });

  testWidgets('shows 44px artwork, title and subtitle on one line each', (
    tester,
  ) async {
    await tester.pumpWidget(host(card()));
    check(
      tester.getSize(find.byKey(const ValueKey('art'))),
    ).equals(const Size(44, 44));
    for (final text in ['Episode title', 'Podcast name']) {
      check(tester.widget<Text>(find.text(text)).maxLines).equals(1);
    }
  });

  testWidgets('progress line uses brand and hides before start', (
    tester,
  ) async {
    await tester.pumpWidget(host(card()));
    check(find.byType(ProgressLine).evaluate().length).equals(0);
    await tester.pumpWidget(host(card(progress: 0.4)));
    final line = tester.widget<ProgressLine>(find.byType(ProgressLine));
    check(line.fillColor).equals(AppColors.light.brand);
  });

  testWidgets('tapping the body fires onTap, actions stay separate', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(host(card(onTap: () => taps++)));
    await tester.tap(find.text('Episode title'));
    check(taps).equals(1);
    await tester.tap(find.byTooltip('Play'));
    check(taps).equals(1);
  });

  testWidgets('labels stay readable without a semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(card()));
    // The tappable card merges both labels into one node.
    check(
      find
          .bySemanticsLabel(RegExp('Episode title.*Podcast name', dotAll: true))
          .evaluate(),
    ).length.equals(1);
    handle.dispose();
  });

  testWidgets('semantic label replaces the visible labels', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        MiniPlayerCard(
          artwork: const SizedBox.expand(),
          title: 'Episode title',
          subtitle: 'Podcast name',
          semanticLabel: 'Now playing: Episode title, Podcast name',
          actions: const [],
        ),
      ),
    );
    check(
      find
          .bySemanticsLabel('Now playing: Episode title, Podcast name')
          .evaluate(),
    ).length.equals(1);
    check(
      find.bySemanticsLabel(RegExp(r'^Episode title')).evaluate(),
    ).isEmpty();
    handle.dispose();
  });
}
