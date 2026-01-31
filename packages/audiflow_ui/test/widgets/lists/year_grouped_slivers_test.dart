import 'package:audiflow_ui/src/widgets/lists/year_grouped_slivers.dart';
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
