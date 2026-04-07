import 'package:audiflow_app/features/settings/presentation/screens/developer_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildApp(List<dynamic> overrides) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: DeveloperSettingsScreen(),
    ),
  );
}

void main() {
  group('DeveloperSettingsScreen', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('renders contribute link', (tester) async {
      await tester.pumpWidget(
        _buildApp([sharedPreferencesProvider.overrideWithValue(prefs)]),
      );
      await tester.pumpAndSettle();

      check(
        find.text('Contribute smart playlist patterns').evaluate(),
      ).isNotEmpty();
      check(
        find.text('audiflow/audiflow-smartplaylist').evaluate(),
      ).isNotEmpty();
    });

    testWidgets('renders toggle defaulting to off', (tester) async {
      await tester.pumpWidget(
        _buildApp([sharedPreferencesProvider.overrideWithValue(prefs)]),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      check(switchFinder.evaluate()).isNotEmpty();
      final switchWidget = tester.widget<Switch>(switchFinder);
      check(switchWidget.value).equals(false);
    });

    testWidgets('toggle persists state', (tester) async {
      await tester.pumpWidget(
        _buildApp([sharedPreferencesProvider.overrideWithValue(prefs)]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      check(prefs.getBool('dev_show_developer_info')).equals(true);
    });

    testWidgets('renders pattern list when summaries available', (
      tester,
    ) async {
      final summaries = [
        const PatternSummary(
          id: 'coten_radio',
          dataVersion: 1,
          displayName: 'Coten Radio',
          feedUrlHint: 'anchor.fm/s/8c2088c',
          playlistCount: 3,
        ),
        const PatternSummary(
          id: 'news_connect',
          dataVersion: 1,
          displayName: 'News Connect',
          feedUrlHint: 'feeds.example.com',
          playlistCount: 2,
        ),
      ];

      await tester.pumpWidget(
        _buildApp([
          sharedPreferencesProvider.overrideWithValue(prefs),
          patternSummariesProvider.overrideWith(
            () => _FakePatternSummaries(summaries),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      check(find.text('Coten Radio').evaluate()).isNotEmpty();
      check(find.text('News Connect').evaluate()).isNotEmpty();
    });
  });
}

class _FakePatternSummaries extends PatternSummaries {
  _FakePatternSummaries(this._initial);
  final List<PatternSummary> _initial;

  @override
  List<PatternSummary> build() => _initial;
}
