import 'package:audiflow_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsScreen', () {
    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          // Restricted mode off: all cards including Developer are visible.
          isRestrictedModeOnProvider.overrideWith((ref) => false),
          isUnlockedProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      );
    }

    /// Sets a surface size tall enough to render all 9
    /// cards without scrolling, then restores it.
    Future<void> withTallSurface(
      WidgetTester tester,
      Future<void> Function() body,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await body();
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('shows a large Settings title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(AppBar), findsNothing);
      check(
        tester.widget<LargeTitle>(find.byType(LargeTitle)).title,
      ).equals('Settings');
    });

    testWidgets('renders 10 rows in three groups', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(SettingsRow), findsNWidgets(10));
        expect(find.byType(GroupedSection), findsNWidgets(3));
      });
    });

    testWidgets('groups follow the redesign order', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        List<String> titlesIn(int group) => tester
            .widgetList<SettingsRow>(
              find.descendant(
                of: find.byType(GroupedSection).at(group),
                matching: find.byType(SettingsRow),
              ),
            )
            .map((row) => row.title)
            .toList();
        check(
          titlesIn(0),
        ).deepEquals(['Appearance', 'Playback', 'Downloads', 'Feed Sync']);
        check(
          titlesIn(1),
        ).deepEquals(['Storage & Data', 'Privacy', 'Parental Control']);
        check(
          titlesIn(2),
        ).deepEquals(['Getting Started', 'Developer', 'About']);
      });
    });

    testWidgets('each row has correct title text', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('Playback'), findsOneWidget);
        expect(find.text('Downloads'), findsOneWidget);
        expect(find.text('Feed Sync'), findsOneWidget);
        expect(find.text('Storage & Data'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('Getting Started'), findsOneWidget);
        expect(find.text('Privacy'), findsOneWidget);
        expect(find.text('Parental Control'), findsOneWidget);
        expect(find.text('Developer'), findsOneWidget);
      });
    });

    testWidgets('uses a list, not a grid', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('each row has subtitle text', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Theme, language, text size'), findsOneWidget);
        expect(find.text('Speed, skipping, auto-complete'), findsOneWidget);
        expect(find.text('WiFi, auto-delete, concurrency'), findsOneWidget);
        expect(find.text('Refresh interval, background sync'), findsOneWidget);
        expect(find.text('Cache, OPML, data management'), findsOneWidget);
        expect(find.text('Version, licenses, support'), findsOneWidget);
        expect(
          find.text('Control what data audiflow collects'),
          findsOneWidget,
        );
        expect(
          find.text('PIN, restricted mode, re-lock timer'),
          findsOneWidget,
        );
        expect(
          find.text('Smart playlist patterns and debug info'),
          findsOneWidget,
        );
      });
    });
  });
}
