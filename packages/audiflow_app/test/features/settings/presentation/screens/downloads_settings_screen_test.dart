import 'package:audiflow_app/features/settings/presentation/screens/downloads_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
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
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DownloadsSettingsScreen(),
      ),
    );
  }

  group('DownloadsSettingsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(DownloadsSettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Downloads title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('Downloads'));
    });

    testWidgets('shows WiFi-only enabled by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('WiFi-Only Downloads'), findsOneWidget);

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      // First SwitchListTile is WiFi-only
      expect(tiles[0].value, isTrue);
    });

    testWidgets('shows auto-delete disabled by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Auto-Delete After Played'), findsOneWidget);

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      // Second SwitchListTile is auto-delete
      expect(tiles[1].value, isFalse);
    });

    testWidgets('shows max concurrent downloads with default 1', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Max Concurrent Downloads'), findsOneWidget);

      final segmented = tester.widget<SegmentedButton<int>>(
        find.byType(SegmentedButton<int>),
      );
      expect(segmented.selected, equals({1}));
    });

    testWidgets('toggling WiFi-only updates state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap the first Switch (WiFi-only)
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      expect(tiles[0].value, isFalse);
    });

    testWidgets(
      'tapping max concurrent segment persists and reflects new value',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Default is 1; tap '3' segment
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        final segmented = tester.widget<SegmentedButton<int>>(
          find.byType(SegmentedButton<int>),
        );
        expect(segmented.selected, equals({3}));

        // Verify persisted
        expect(prefs.getInt('settings_max_concurrent_downloads'), equals(3));
      },
    );

    testWidgets('shows Max Batch Download label', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      check(find.text('Max Batch Download').evaluate()).isNotEmpty();
    });

    testWidgets('batch limit text field shows default value 25', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final fields = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      final batchField = fields.where((f) => f.controller.text == '25');
      check(batchField.length).equals(1);
    });

    testWidgets('batch limit text field shows pre-set value from preferences', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'settings_batch_download_limit': 50,
      });
      prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(buildTestWidget());

      final fields = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      final batchField = fields.where((f) => f.controller.text == '50');
      check(batchField.length).equals(1);
    });
  });
}
