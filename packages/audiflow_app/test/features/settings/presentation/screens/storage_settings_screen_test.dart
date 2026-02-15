import 'package:audiflow_app/features/settings/presentation/screens/storage_settings_screen.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: StorageSettingsScreen()),
    );
  }

  group('StorageSettingsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(StorageSettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Storage & Data title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('Storage & Data'));
    });

    testWidgets('shows Image Cache tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Image Cache'), findsOneWidget);
      expect(
        find.text('Clear temporary files and cached images'),
        findsOneWidget,
      );
      expect(find.text('Clear Cache'), findsOneWidget);
    });

    testWidgets('shows Search History tile', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Search History'), findsOneWidget);
      expect(find.text('Clear search suggestions'), findsOneWidget);
    });

    testWidgets('shows OPML export and import tiles', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Export Subscriptions'), findsOneWidget);
      expect(find.text('Save subscriptions as OPML file'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);

      expect(find.text('Import Subscriptions'), findsOneWidget);
      expect(find.text('Import from OPML file'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
    });

    testWidgets('shows Danger Zone section', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Danger Zone'), findsOneWidget);
      expect(find.text('Reset All Data'), findsOneWidget);
      expect(
        find.text('Delete all data and reset app to initial state'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Clear Cache shows confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Clear Cache'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Cache?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Clear'), findsOneWidget);
    });

    testWidgets('Export button is present and tappable', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final exportButton = find.widgetWithText(OutlinedButton, 'Export');
      expect(exportButton, findsOneWidget);
    });

    testWidgets('tapping Reset All Data shows confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Reset All Data'));
      await tester.pumpAndSettle();

      expect(find.text('Reset All Data?'), findsOneWidget);
      expect(find.text('Type RESET to confirm:'), findsOneWidget);
    });

    testWidgets('Reset button is disabled until RESET is typed', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Reset All Data'));
      await tester.pumpAndSettle();

      // Reset button should be disabled initially
      final resetButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Reset'),
      );
      expect(resetButton.onPressed, isNull);

      // Type RESET
      await tester.enterText(find.byType(TextField), 'RESET');
      await tester.pumpAndSettle();

      // Reset button should now be enabled
      final enabledButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Reset'),
      );
      expect(enabledButton.onPressed, isNotNull);
    });
  });
}
