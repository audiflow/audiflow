import 'package:audiflow_ui/src/widgets/search/searchable_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchableAppBar', () {
    testWidgets('shows title and search icon by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: SearchableAppBar(
              title: const Text('Podcasts'),
              onSearchChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Podcasts'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('tapping search icon shows text field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: SearchableAppBar(
              title: const Text('Podcasts'),
              onSearchChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Podcasts'), findsNothing);
    });

    testWidgets('tapping close clears text and collapses', (tester) async {
      String lastQuery = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: SearchableAppBar(
              title: const Text('Podcasts'),
              onSearchChanged: (query) {
                lastQuery = query;
              },
              debounceDuration: Duration.zero,
            ),
          ),
        ),
      );

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Enter text
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      // Tap close
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(lastQuery, '');
      expect(find.text('Podcasts'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('debounces search input', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: SearchableAppBar(
              title: const Text('Podcasts'),
              onSearchChanged: queries.add,
              debounceDuration: const Duration(milliseconds: 300),
            ),
          ),
        ),
      );

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Type rapidly
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'abc');

      // Not yet debounced
      expect(queries, isEmpty);

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 300));

      expect(queries, ['abc']);
    });

    testWidgets('preserves additional actions alongside search', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: SearchableAppBar(
              title: const Text('Podcasts'),
              onSearchChanged: (_) {},
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Actions visible in default state
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Open search - actions hidden
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byIcon(Icons.filter_list), findsNothing);
    });
  });
}
