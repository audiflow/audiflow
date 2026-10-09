import 'package:audiflow_app/features/settings/presentation/screens/developer_settings_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

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
      FlavorConfig.initialize(FlavorConfig.stg);
    });

    testWidgets('offers test notifications outside production', (tester) async {
      await tester.pumpWidget(
        _buildApp([sharedPreferencesProvider.overrideWithValue(prefs)]),
      );
      await tester.pumpAndSettle();

      check(find.text('Send test notifications').evaluate()).isNotEmpty();
      check(find.text('Haptics catalog').evaluate()).isNotEmpty();
    });

    testWidgets('hides test notifications in production', (tester) async {
      FlavorConfig.initialize(FlavorConfig.prod);
      await tester.pumpWidget(
        _buildApp([sharedPreferencesProvider.overrideWithValue(prefs)]),
      );
      await tester.pumpAndSettle();

      check(find.text('Send test notifications').evaluate()).isEmpty();
      check(find.text('Haptics catalog').evaluate()).isEmpty();
    });

    testWidgets('renders contribute link', (tester) async {
      await tester.pumpWidget(
        _buildApp([sharedPreferencesProvider.overrideWithValue(prefs)]),
      );
      await tester.pumpAndSettle();

      check(find.text('Contribute presets').evaluate()).isNotEmpty();
      check(
        find.text('How to ask questions and contribute').evaluate(),
      ).isNotEmpty();
    });

    testWidgets('contribute row opens the contribute guide', (tester) async {
      final launcher = _FakeUrlLauncher();
      final original = UrlLauncherPlatform.instance;
      UrlLauncherPlatform.instance = launcher;
      addTearDown(() => UrlLauncherPlatform.instance = original);

      await tester.pumpWidget(
        _buildApp([sharedPreferencesProvider.overrideWithValue(prefs)]),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contribute presets'));
      await tester.pumpAndSettle();

      check(launcher.launchedUrls).deepEquals([PresetUrls.contribute]);
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
        const PresetSummary(
          id: 'coten_radio',
          dataVersion: 1,
          displayName: 'Coten Radio',
          feedUrlHint: 'anchor.fm/s/8c2088c',
          playlistCount: 3,
        ),
        const PresetSummary(
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
          presetSummariesProvider.overrideWith(
            () => _FakePresetSummaries(summaries),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      check(find.text('Coten Radio').evaluate()).isNotEmpty();
      check(find.text('News Connect').evaluate()).isNotEmpty();
    });
  });
}

class _FakePresetSummaries extends PresetSummaries {
  _FakePresetSummaries(this._initial);
  final List<PresetSummary> _initial;

  @override
  List<PresetSummary> build() => _initial;
}

class _FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  final List<String> launchedUrls = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrls.add(url);
    return true;
  }
}
