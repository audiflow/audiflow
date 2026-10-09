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

      check(find.byType(SettingsScreen).evaluate()).length.equals(1);
    });

    testWidgets('shows a large Settings title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      check(find.byType(AppBar).evaluate()).isEmpty();
      check(
        tester.widget<LargeTitle>(find.byType(LargeTitle)).title,
      ).equals('Settings');
    });

    testWidgets('renders 10 rows in three groups', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        check(find.byType(SettingsRow).evaluate()).length.equals(10);
        check(find.byType(GroupedSection).evaluate()).length.equals(3);
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

        check(find.text('Appearance').evaluate()).length.equals(1);
        check(find.text('Playback').evaluate()).length.equals(1);
        check(find.text('Downloads').evaluate()).length.equals(1);
        check(find.text('Feed Sync').evaluate()).length.equals(1);
        check(find.text('Storage & Data').evaluate()).length.equals(1);
        check(find.text('About').evaluate()).length.equals(1);
        check(find.text('Getting Started').evaluate()).length.equals(1);
        check(find.text('Privacy').evaluate()).length.equals(1);
        check(find.text('Parental Control').evaluate()).length.equals(1);
        check(find.text('Developer').evaluate()).length.equals(1);
      });
    });

    testWidgets('uses a list, not a grid', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      check(find.byType(GridView).evaluate()).isEmpty();
      check(find.byType(ListView).evaluate()).length.equals(1);
    });

    testWidgets('each row has subtitle text', (tester) async {
      await withTallSurface(tester, () async {
        await tester.pumpWidget(buildTestWidget());

        check(
          find.text('Theme, language, text size, haptics').evaluate(),
        ).length.equals(1);
        check(
          find.text('Speed, skipping, auto-complete').evaluate(),
        ).length.equals(1);
        check(
          find.text('WiFi, auto-delete, concurrency').evaluate(),
        ).length.equals(1);
        check(
          find.text('Refresh interval, background sync').evaluate(),
        ).length.equals(1);
        check(
          find.text('Cache, OPML, data management').evaluate(),
        ).length.equals(1);
        check(
          find.text('Version, licenses, support').evaluate(),
        ).length.equals(1);
        check(
          find.text('Control what data audiflow collects').evaluate(),
        ).length.equals(1);
        check(
          find.text('PIN, restricted mode, re-lock timer').evaluate(),
        ).length.equals(1);
        check(
          find.text('Smart playlist patterns and debug info').evaluate(),
        ).length.equals(1);
      });
    });
  });
}
