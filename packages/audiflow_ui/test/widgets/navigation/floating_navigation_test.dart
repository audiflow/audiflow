import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
    theme: theme ?? AppTheme.light(),
    home: Scaffold(body: Stack(children: [child])),
  );

  BoxDecoration decorationOf(WidgetTester tester, Key key) {
    return tester.widget<DecoratedBox>(find.byKey(key)).decoration
        as BoxDecoration;
  }

  group('FloatingNavScroll', () {
    test('everything at rest at the top', () {
      final p = FloatingNavScroll.at(offset: 0, heroExtent: 300);
      check(p.title).equals(0);
      check(p.background).equals(0);
      check(p.hero).equals(0);
    });

    test('hero collapses across its own extent', () {
      check(
        FloatingNavScroll.at(offset: 150, heroExtent: 300).hero,
      ).equals(0.5);
      check(FloatingNavScroll.at(offset: 600, heroExtent: 300).hero).equals(1);
    });

    test('title and background fade in only after the hero is gone', () {
      final before = FloatingNavScroll.at(offset: 300, heroExtent: 300);
      check(before.hero).equals(1);
      check(before.title).equals(0);
      check(before.background).equals(0);
      final midway = FloatingNavScroll.at(
        offset: 300 + FloatingNavScroll.fadeDistance / 2,
        heroExtent: 300,
      );
      check(midway.title).equals(0.5);
      check(midway.background).equals(0.5);
      final after = FloatingNavScroll.at(offset: 400, heroExtent: 300);
      check(after.title).equals(1);
      check(after.background).equals(1);
    });

    test('negative offsets (overscroll) stay at rest', () {
      final p = FloatingNavScroll.at(offset: -80, heroExtent: 300);
      check(p.title).equals(0);
      check(p.hero).equals(0);
    });

    test('search progress collapses the hero and fills the bar', () {
      final rest = FloatingNavScroll.at(offset: 0, heroExtent: 300);
      final half = rest.withSearch(0.5);
      check(half.hero).equals(0.5);
      check(half.background).equals(0.5);
      check(half.title).equals(0);
      final full = rest.withSearch(1);
      check(full.hero).equals(1);
      check(full.background).equals(1);
      final scrolled = FloatingNavScroll.at(offset: 400, heroExtent: 300);
      check(scrolled.withSearch(0).title).equals(1);
      check(scrolled.withSearch(0.25).title).equals(0.75);
      check(scrolled.withSearch(0.25).background).equals(1);
    });

    test('zero hero extent shows the bar immediately', () {
      final p = FloatingNavScroll.at(offset: 0, heroExtent: 0);
      check(p.title).equals(1);
      check(p.background).equals(1);
    });
  });

  group('FloatingNavButton', () {
    testWidgets('44px white circle with floating shadow', (tester) async {
      await tester.pumpWidget(
        host(
          FloatingNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: () {},
          ),
        ),
      );
      check(
        tester.getSize(find.byKey(FloatingNavButton.surfaceKey)),
      ).equals(const Size(44, 44));
      final decoration = decorationOf(tester, FloatingNavButton.surfaceKey);
      check(decoration.color).equals(AppColors.light.surface);
      check(decoration.shape).equals(BoxShape.circle);
      check(decoration.boxShadow).isNotNull().deepEquals(AppShadows.floating);
    });

    testWidgets('fires onPressed and exposes its tooltip', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          FloatingNavButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Back'));
      check(taps).equals(1);
    });
  });

  group('FloatingNavActions', () {
    Widget actions({List<int>? log}) => host(
      FloatingNavActions(
        actions: [
          FloatingNavAction(
            icon: Icons.search,
            tooltip: 'Search',
            onPressed: () => log?.add(0),
          ),
          FloatingNavAction(
            icon: Icons.tune,
            tooltip: 'Settings',
            onPressed: () => log?.add(1),
          ),
          FloatingNavAction(
            icon: Icons.more_horiz,
            tooltip: 'More',
            onPressed: () => log?.add(2),
          ),
        ],
      ),
    );

    testWidgets('groups buttons in one white pill, 44 tall', (tester) async {
      await tester.pumpWidget(actions());
      final decoration = decorationOf(tester, FloatingNavActions.surfaceKey);
      check(decoration.color).equals(AppColors.light.surface);
      check(decoration.borderRadius).equals(AppBorders.pill);
      check(
        tester.getSize(find.byKey(FloatingNavActions.surfaceKey)).height,
      ).equals(44);
    });

    testWidgets('each action is a 44px target firing its callback', (
      tester,
    ) async {
      final log = <int>[];
      await tester.pumpWidget(actions(log: log));
      for (final label in ['Search', 'Settings', 'More']) {
        final size = tester.getSize(find.byTooltip(label));
        check(size.width).isGreaterOrEqual(44);
        await tester.tap(find.byTooltip(label));
      }
      check(log).deepEquals([0, 1, 2]);
    });

    testWidgets('a menu action opens on a tap, or on a press-and-hold', (
      tester,
    ) async {
      final opened = <ActionMenuDrag?>[];
      await tester.pumpWidget(
        host(
          FloatingNavActions(
            actions: [
              FloatingNavAction.menu(
                icon: Icons.more_horiz_rounded,
                tooltip: 'More',
                onOpenMenu: (_, drag) => opened.add(drag),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byTooltip('More'));
      check(opened).deepEquals([null]);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byTooltip('More')),
      );
      await tester.pump(
        ActionMenuTrigger.holdDuration + const Duration(milliseconds: 10),
      );
      await gesture.up();
      await tester.pumpAndSettle();
      check(opened).length.equals(2);
      check(opened.last).isNotNull();
    });
  });

  group('FloatingNavigationBar', () {
    Widget bar({
      double titleOpacity = 0,
      double backgroundOpacity = 0,
      NavigationSearchField? search,
      ThemeData? theme,
    }) => host(
      FloatingNavigationBar(
        leading: FloatingNavButton(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: 'Back',
          onPressed: () {},
        ),
        title: 'Podcast title',
        titleOpacity: titleOpacity,
        backgroundOpacity: backgroundOpacity,
        trailing: FloatingNavActions(
          actions: [
            FloatingNavAction(
              icon: Icons.search,
              tooltip: 'Search',
              onPressed: () {},
            ),
          ],
        ),
        search: search,
      ),
      theme: theme,
    );

    double opacityOf(WidgetTester tester, Finder child) {
      return tester
          .widget<Opacity>(
            find.ancestor(of: child, matching: find.byType(Opacity)).first,
          )
          .opacity;
    }

    testWidgets('hides the title at rest and fades it in', (tester) async {
      await tester.pumpWidget(bar());
      check(opacityOf(tester, find.text('Podcast title'))).equals(0);
      await tester.pumpWidget(bar(titleOpacity: 0.6));
      check(opacityOf(tester, find.text('Podcast title'))).equals(0.6);
    });

    testWidgets('title is excluded from semantics while hidden', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(bar());
      check(find.bySemanticsLabel('Podcast title').evaluate().length).equals(0);
      await tester.pumpWidget(bar(titleOpacity: 1));
      check(find.bySemanticsLabel('Podcast title').evaluate().length).equals(1);
      handle.dispose();
    });

    testWidgets('background is transparent at rest, bg with hairline later', (
      tester,
    ) async {
      await tester.pumpWidget(bar());
      var decoration = decorationOf(
        tester,
        FloatingNavigationBar.backgroundKey,
      );
      check(decoration.color!.a).equals(0);

      await tester.pumpWidget(bar(backgroundOpacity: 1));
      decoration = decorationOf(tester, FloatingNavigationBar.backgroundKey);
      check(decoration.color).equals(AppColors.light.bg);
      final border = decoration.border! as Border;
      check(border.bottom.color).equals(AppColors.light.hairline);
    });

    testWidgets('sits below the status bar inset', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 47)),
          child: bar(),
        ),
      );
      check(tester.getTopLeft(find.byTooltip('Back')).dy).isGreaterOrEqual(47);
    });

    testWidgets('search mode replaces the whole row', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        bar(
          search: NavigationSearchField(
            controller: controller,
            hintText: 'Search episodes',
            cancelLabel: 'Cancel',
            onCancel: () {},
          ),
        ),
      );
      check(find.byTooltip('Back').evaluate().length).equals(0);
      check(find.byTooltip('Search').evaluate().length).equals(0);
      check(find.byType(TextField).evaluate().length).equals(1);
      check(find.text('Cancel').evaluate().length).equals(1);
    });
  });

  group('FloatingNavigationBar search transition', () {
    testWidgets('cross-fades from the toolbar to the search field', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      Widget bar({required bool searching}) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Stack(
            children: [
              FloatingNavigationBar(
                leading: FloatingNavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: 'Back',
                  onPressed: () {},
                ),
                search: searching
                    ? NavigationSearchField(
                        controller: controller,
                        hintText: 'Search episodes',
                        cancelLabel: 'Cancel',
                        onCancel: () {},
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(bar(searching: false));
      await tester.pumpWidget(bar(searching: true));
      await tester.pump(FloatingNavigationBar.switchDuration ~/ 2);
      // Both rows are on screen mid-transition.
      check(find.byTooltip('Back').evaluate()).length.equals(1);
      check(find.byType(TextField).evaluate()).length.equals(1);
      await tester.pumpAndSettle();
      check(find.byTooltip('Back').evaluate()).isEmpty();
      check(find.byType(TextField).evaluate()).length.equals(1);
    });
  });

  group('NavigationSearchField', () {
    Widget field(TextEditingController controller, {VoidCallback? onCancel}) {
      return host(
        Align(
          alignment: Alignment.topCenter,
          child: NavigationSearchField(
            controller: controller,
            hintText: 'Search episodes',
            cancelLabel: 'Cancel',
            onCancel: onCancel ?? () {},
          ),
        ),
      );
    }

    testWidgets('focuses on appear so the keyboard comes up', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(field(controller));
      await tester.pump();
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      check(editable.focusNode.hasFocus).isTrue();
    });

    testWidgets('cancel uses the accent color and clears the query', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'coten');
      addTearDown(controller.dispose);
      var cancelled = 0;
      await tester.pumpWidget(field(controller, onCancel: () => cancelled++));
      final cancel = tester.widget<Text>(find.text('Cancel'));
      final buttonStyle = tester
          .widget<TextButton>(find.byType(TextButton))
          .style;
      check(
        buttonStyle?.foregroundColor?.resolve({}) ?? cancel.style?.color,
      ).equals(AppColors.light.accent);
      await tester.tap(find.text('Cancel'));
      check(cancelled).equals(1);
      check(controller.text).equals('');
    });

    testWidgets('uses the sunken search field fill', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(field(controller));
      final textField = tester.widget<TextField>(find.byType(TextField));
      check(textField.decoration!.hintText).equals('Search episodes');
      check(
        Theme.of(
          tester.element(find.byType(TextField)),
        ).inputDecorationTheme.fillColor,
      ).equals(AppColors.light.surfaceSunken);
    });
  });

  group('CollapsingHero', () {
    Widget hero(double progress) => host(
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 200,
          height: 300,
          child: CollapsingHero(
            progress: progress,
            child: const SizedBox.expand(key: ValueKey('hero')),
          ),
        ),
      ),
    );

    double opacity(WidgetTester tester) =>
        tester.widget<Opacity>(find.byType(Opacity)).opacity;

    testWidgets('fully visible and unscaled at rest', (tester) async {
      await tester.pumpWidget(hero(0));
      check(opacity(tester)).equals(1);
      check(
        tester.getRect(find.byKey(const ValueKey('hero'))),
      ).equals(const Rect.fromLTWH(0, 0, 200, 300));
    });

    testWidgets('fades as it collapses', (tester) async {
      await tester.pumpWidget(hero(0.5));
      check(opacity(tester)).equals(0.5);
      await tester.pumpWidget(hero(1));
      check(opacity(tester)).equals(0);
    });

    testWidgets('shrinks toward its bottom center', (tester) async {
      await tester.pumpWidget(hero(1));
      final rect = tester.getRect(find.byKey(const ValueKey('hero')));
      const scale = CollapsingHero.minScale;
      check(rect.width).isCloseTo(200 * scale, 1e-6);
      check(rect.center.dx).isCloseTo(100, 1e-6);
      check(rect.bottom).isCloseTo(300, 1e-6);
    });
  });
}
