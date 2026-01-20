import 'package:audiflow_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('SettingsScreen', () {
    Widget buildTestWidget() {
      return const MaterialApp(home: SettingsScreen());
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Settings title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AppBar), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final titleWidget = appBar.title as Text;
      expect(titleWidget.data, equals('Settings'));
    });

    testWidgets('displays placeholder icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Symbols.settings), findsOneWidget);
    });

    testWidgets('displays placeholder text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('App settings will appear here'), findsOneWidget);
    });

    testWidgets('body content is centered', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isA<Center>());
    });
  });
}
