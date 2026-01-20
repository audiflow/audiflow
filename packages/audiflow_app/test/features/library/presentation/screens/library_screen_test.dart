import 'package:audiflow_app/features/library/presentation/screens/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('LibraryScreen', () {
    Widget buildTestWidget() {
      return const MaterialApp(home: LibraryScreen());
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(LibraryScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Library title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AppBar), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final titleWidget = appBar.title as Text;
      expect(titleWidget.data, equals('Library'));
    });

    testWidgets('displays placeholder icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Symbols.library_music), findsOneWidget);
    });

    testWidgets('displays placeholder text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(
        find.text('Your subscribed podcasts will appear here'),
        findsOneWidget,
      );
    });

    testWidgets('body content is centered', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isA<Center>());
    });
  });
}
