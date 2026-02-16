import 'package:audiflow_app/features/settings/presentation/screens/feed_sync_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
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
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const FeedSyncSettingsScreen(),
      ),
    );
  }

  group('FeedSyncSettingsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(FeedSyncSettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Feed Sync title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title! as Text;
      expect(title.data, equals('Feed Sync'));
    });

    testWidgets('shows auto-sync enabled by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Auto-Sync'), findsOneWidget);

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      // First SwitchListTile is auto-sync
      expect(tiles[0].value, isTrue);
    });

    testWidgets('shows sync interval visible when auto-sync is on', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Sync Interval'), findsOneWidget);
      // Default should be 60 min = "1 hour"
      expect(find.text('1 hour'), findsOneWidget);
    });

    testWidgets('shows WiFi-only sync disabled by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('WiFi-Only Sync'), findsOneWidget);

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      // Second SwitchListTile is WiFi-only sync
      expect(tiles[1].value, isFalse);
    });

    testWidgets('hides sync interval when auto-sync is off', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Toggle auto-sync off
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Sync Interval should now be hidden via Visibility
      final visibility = tester.widget<Visibility>(find.byType(Visibility));
      expect(visibility.visible, isFalse);
    });

    testWidgets('toggling auto-sync updates state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      final tiles = tester
          .widgetList<SwitchListTile>(find.byType(SwitchListTile))
          .toList();
      expect(tiles[0].value, isFalse);
    });
  });
}
