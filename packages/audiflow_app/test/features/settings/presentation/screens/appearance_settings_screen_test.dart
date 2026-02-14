import 'package:audiflow_app/features/settings/presentation/screens/appearance_settings_screen.dart';
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
      child: const MaterialApp(home: AppearanceSettingsScreen()),
    );
  }

  group('AppearanceSettingsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AppearanceSettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Appearance title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('Appearance'));
    });

    testWidgets('shows theme mode setting with System default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      // "System" appears in both theme mode and language controls
      expect(find.text('System'), findsWidgets);

      // System should be selected by default
      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(segmented.selected, equals({ThemeMode.system}));
    });

    testWidgets('shows language setting with System default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Language'), findsOneWidget);
      // Default dropdown should show System
      expect(find.text('System'), findsWidgets);
    });

    testWidgets('shows text size setting with Medium default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      final segmented = tester.widget<SegmentedButton<double>>(
        find.byType(SegmentedButton<double>),
      );
      expect(segmented.selected, equals({1.0}));
    });

    testWidgets('shows preview text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Preview text at current size'), findsOneWidget);
    });

    testWidgets('changing theme mode updates selection', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap Dark segment
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final segmented = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(segmented.selected, equals({ThemeMode.dark}));
    });
  });
}
