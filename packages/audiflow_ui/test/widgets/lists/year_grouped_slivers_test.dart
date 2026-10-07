import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildYearGroupedSlivers', () {
    late ScrollController scrollController;

    setUp(() {
      scrollController = ScrollController();
    });

    tearDown(() {
      scrollController.dispose();
    });

    testWidgets('single year produces no sticky headers', (tester) async {
      final itemsByYear = {
        2024: ['A', 'B', 'C'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: buildYearGroupedSlivers<String>(
                itemsByYear: itemsByYear,
                sortedYears: [2024],
                itemBuilder: (_, item) => ListTile(title: Text(item)),
                scrollController: scrollController,
                yearGroupingEnabled: true,
                itemExtent: 56.0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('2024'), findsNothing);
    });

    testWidgets('yearGroupingEnabled=false produces flat list', (tester) async {
      final itemsByYear = {
        2024: ['A'],
        2023: ['B'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: buildYearGroupedSlivers<String>(
                itemsByYear: itemsByYear,
                sortedYears: [2024, 2023],
                itemBuilder: (_, item) => ListTile(title: Text(item)),
                scrollController: scrollController,
                yearGroupingEnabled: false,
                itemExtent: 56.0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('2024'), findsNothing);
      expect(find.text('2023'), findsNothing);
    });

    testWidgets('multiple years shows pinned header and inline dividers', (
      tester,
    ) async {
      final itemsByYear = {
        2024: ['A'],
        2023: ['B'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: buildYearGroupedSlivers<String>(
                itemsByYear: itemsByYear,
                sortedYears: [2024, 2023],
                itemBuilder: (_, item) => ListTile(title: Text(item)),
                scrollController: scrollController,
                yearGroupingEnabled: true,
                itemExtent: 56.0,
              ),
            ),
          ),
        ),
      );

      // Pinned header shows "2024"; first inline divider is hidden spacer
      expect(find.text('2024'), findsOneWidget);
      // Second year has visible inline divider
      expect(find.text('2023'), findsOneWidget);
      // Items visible
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      // No dropdown arrow
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('tapping pinned header opens year picker', (tester) async {
      final itemsByYear = {
        2024: ['A'],
        2023: ['B'],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: buildYearGroupedSlivers<String>(
                itemsByYear: itemsByYear,
                sortedYears: [2024, 2023],
                itemBuilder: (_, item) => ListTile(title: Text(item)),
                scrollController: scrollController,
                yearGroupingEnabled: true,
                itemExtent: 56.0,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('2024'));
      await tester.pumpAndSettle();

      expect(find.text('Jump to year'), findsOneWidget);
      expect(find.text('2024'), findsWidgets);
      expect(find.text('2023'), findsWidgets);
    });
  });

  group('buildYearGroupedSlivers grouped', () {
    late ScrollController scrollController;

    setUp(() => scrollController = ScrollController());
    tearDown(() => scrollController.dispose());

    Future<void> pump(
      WidgetTester tester,
      Map<int, List<String>> itemsByYear,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: buildYearGroupedSlivers<String>(
                itemsByYear: itemsByYear,
                sortedYears: itemsByYear.keys.toList(),
                itemBuilder: (_, item) =>
                    SizedBox(height: 60, child: Text(item)),
                scrollController: scrollController,
                yearGroupingEnabled: true,
                grouped: true,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('each year sits on its own grouped surface', (tester) async {
      await pump(tester, {
        2025: ['A', 'B'],
        2024: ['C'],
      });
      check(find.byType(SliverGroupedSection).evaluate()).length.equals(2);
      check(find.byType(Divider).evaluate()).length.equals(1);
    });

    testWidgets('a single year still gets the surface', (tester) async {
      await pump(tester, {
        2025: ['A', 'B', 'C'],
      });
      check(find.byType(SliverGroupedSection).evaluate()).length.equals(1);
    });
  });

  group('buildYearGroupedSlivers under pinned headers', () {
    late ScrollController scrollController;

    setUp(() => scrollController = ScrollController());
    tearDown(() => scrollController.dispose());

    const topInset = 100.0;
    const rowHeight = 120.0;

    Future<void> pump(WidgetTester tester) async {
      final itemsByYear = {
        2025: [for (var i = 0; i < 5; i++) 'a$i'],
        2024: [for (var i = 0; i < 5; i++) 'b$i'],
        2023: [for (var i = 0; i < 5; i++) 'c$i'],
      };
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: [
                // Stands in for the floating navigation and sticky bar.
                const PinnedHeaderSliver(child: SizedBox(height: topInset)),
                ...buildYearGroupedSlivers<String>(
                  itemsByYear: itemsByYear,
                  sortedYears: itemsByYear.keys.toList(),
                  // Rows far from the 88px estimate, as series rows are.
                  itemBuilder: (_, item) =>
                      SizedBox(height: rowHeight, child: Text(item)),
                  scrollController: scrollController,
                  yearGroupingEnabled: true,
                  grouped: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// Year shown in the sticky header, which pins right under the inset.
    String stickyYear(WidgetTester tester) {
      for (final year in ['2025', '2024', '2023']) {
        for (final element in find.text(year).evaluate()) {
          final top = tester.getTopLeft(find.byWidget(element.widget)).dy;
          if (topInset <= top && top < topInset + yearHeaderHeight) {
            return year;
          }
        }
      }
      return 'none';
    }

    Future<void> scrollDividerTo(
      WidgetTester tester,
      String year,
      double screenY,
    ) async {
      // Lazy lists build only what shows: scroll near first, then read
      // the divider's position as a scroll offset.
      scrollController.jumpTo(400);
      await tester.pump();
      final dividerOffset =
          scrollController.offset + tester.getTopLeft(find.text(year).last).dy;
      scrollController.jumpTo(dividerOffset - screenY);
      await tester.pump();
    }

    testWidgets('switches when the next divider reaches the pinned bar', (
      tester,
    ) async {
      await pump(tester);
      check(stickyYear(tester)).equals('2025');

      await scrollDividerTo(tester, '2024', topInset + 30);
      check(stickyYear(tester)).equals('2025');

      await scrollDividerTo(tester, '2024', topInset - 1);
      check(stickyYear(tester)).equals('2024');
    });

    testWidgets('a rebuild at a scrolled position shows the right year', (
      tester,
    ) async {
      await pump(tester);
      await scrollDividerTo(tester, '2024', topInset - 1);
      check(stickyYear(tester)).equals('2024');

      // Coming back to the screen rebuilds the slivers with no scroll
      // event; the header must not fall back to the first year.
      await pump(tester);
      await tester.pump();
      check(stickyYear(tester)).equals('2024');
    });

    testWidgets('jumping to a year lands its rows under the header', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('2025').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023').last);
      await tester.pumpAndSettle();

      check(stickyYear(tester)).equals('2023');
      final firstRow = tester.getTopLeft(find.text('c0')).dy;
      check(firstRow).isCloseTo(topInset + yearHeaderHeight, yearHeaderHeight);
    });
  });

  group('showYearPickerBottomSheet', () {
    testWidgets('shows all years and returns selected', (tester) async {
      int? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selected = await showModalBottomSheet<int>(
                    context: context,
                    builder: (_) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final year in [2024, 2023, 2022])
                          ListTile(
                            title: Text('$year'),
                            onTap: () => Navigator.pop(context, year),
                          ),
                      ],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('2024'), findsOneWidget);
      expect(find.text('2023'), findsOneWidget);
      expect(find.text('2022'), findsOneWidget);

      await tester.tap(find.text('2023'));
      await tester.pumpAndSettle();

      expect(selected, 2023);
    });
  });
}
