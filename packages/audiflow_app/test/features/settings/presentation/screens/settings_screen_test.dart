import 'package:audiflow_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:audiflow_app/features/settings/presentation/widgets/settings_category_card.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsScreen', () {
    Widget buildTestWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsScreen(),
      );
    }

    /// Sets a surface size tall enough to render all 6
    /// cards without scrolling, then restores it.
    Future<void> withTallSurface(
      WidgetTester tester,
      Future<void> Function() body,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await body();
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('displays AppBar with Settings title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AppBar), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final titleWidget = appBar.title! as Text;
      expect(titleWidget.data, equals('Settings'));
    });

    testWidgets('renders 6 category cards', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(SettingsCategoryCard), findsNWidgets(6));
      });
    });

    testWidgets('each card has correct title text', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('Playback'), findsOneWidget);
        expect(find.text('Downloads'), findsOneWidget);
        expect(find.text('Feed Sync'), findsOneWidget);
        expect(find.text('Storage & Data'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
      });
    });

    testWidgets('uses GridView layout', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('each card has subtitle text', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Theme, language, text size'), findsOneWidget);
        expect(find.text('Speed, skipping, auto-complete'), findsOneWidget);
        expect(find.text('WiFi, auto-delete, concurrency'), findsOneWidget);
        expect(find.text('Refresh interval, background sync'), findsOneWidget);
        expect(find.text('Cache, OPML, data management'), findsOneWidget);
        expect(find.text('Version, licenses, support'), findsOneWidget);
      });
    });
  });
}
