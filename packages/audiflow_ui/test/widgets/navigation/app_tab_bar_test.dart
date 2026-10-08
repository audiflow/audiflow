import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show Tristate;

import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(bottomNavigationBar: child),
  );

  Widget bar({List<int>? log}) => AppTabBar(
    items: [
      AppTabBarItem(
        icon: Icons.search,
        label: 'Search',
        selected: false,
        onTap: () => log?.add(0),
      ),
      AppTabBarItem(
        icon: Icons.library_music,
        label: 'Library',
        selected: true,
        onTap: () => log?.add(1),
      ),
    ],
  );

  Text label(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text));

  Icon icon(WidgetTester tester, IconData data) =>
      tester.widget<Icon>(find.byIcon(data));

  testWidgets('active tab is accent, filled, weight 600', (tester) async {
    await tester.pumpWidget(host(bar()));
    check(label(tester, 'Library').style!.color).equals(AppColors.light.accent);
    check(label(tester, 'Library').style!.fontWeight).equals(FontWeight.w600);
    check(
      icon(tester, Icons.library_music).color,
    ).equals(AppColors.light.accent);
    check(icon(tester, Icons.library_music).fill).equals(1);
  });

  testWidgets('inactive tabs use inkTertiary, outlined', (tester) async {
    await tester.pumpWidget(host(bar()));
    check(
      label(tester, 'Search').style!.color,
    ).equals(AppColors.light.inkTertiary);
    check(icon(tester, Icons.search).color).equals(AppColors.light.inkTertiary);
    check(icon(tester, Icons.search).fill).equals(0);
  });

  testWidgets('tapping a tab fires its callback', (tester) async {
    final log = <int>[];
    await tester.pumpWidget(host(bar(log: log)));
    await tester.tap(find.text('Search'));
    await tester.tap(find.text('Library'));
    check(log).deepEquals([0, 1]);
  });

  testWidgets('exposes selected state to semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(bar()));
    final node = tester.getSemantics(find.text('Library'));
    check(node.flagsCollection.isSelected).equals(Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('pads for the bottom inset', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
        child: host(bar()),
      ),
    );
    check(
      tester.getSize(find.byType(AppTabBar)).height,
    ).equals(AppTabBar.height + 34);
  });
}
