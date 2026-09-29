import 'package:audiflow_app/app/app_locale.dart';
import 'package:audiflow_app/features/settings/presentation/controllers/locale_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('resolveSupportedLocale', () {
    const supported = AppLocalizations.supportedLocales;

    test('matches a supported locale by language code', () {
      check(
        resolveSupportedLocale(const Locale('ja', 'JP'), supported),
      ).equals(const Locale('ja'));
    });

    test('falls back to the first supported locale when unsupported', () {
      check(
        resolveSupportedLocale(const Locale('fr'), supported),
      ).equals(supported.first);
    });

    test('falls back to the first supported locale when null', () {
      check(resolveSupportedLocale(null, supported)).equals(supported.first);
    });
  });

  group('root locale wiring', () {
    late SharedPreferences prefs;
    String? originalIntlLocale;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      originalIntlLocale = intl.Intl.defaultLocale;
    });

    tearDown(() => intl.Intl.defaultLocale = originalIntlLocale);

    Future<ProviderContainer> pumpApp(WidgetTester tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ja')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _LocaleWiredApp(),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    Future<void> select(
      WidgetTester tester,
      ProviderContainer container,
      Locale? locale,
    ) async {
      await container.read(localeControllerProvider.notifier).setLocale(locale);
      await tester.pumpAndSettle();
    }

    testWidgets('System follows the device locale', (tester) async {
      await pumpApp(tester);

      check(find.text('外観').evaluate()).isNotEmpty();
      check(intl.Intl.defaultLocale).equals('ja');
    });

    testWidgets('explicit choice switches UI and Intl immediately', (
      tester,
    ) async {
      final container = await pumpApp(tester);

      await select(tester, container, const Locale('en'));

      check(find.text('Appearance').evaluate()).isNotEmpty();
      check(intl.Intl.defaultLocale).equals('en');
    });

    testWidgets('returning to System restores device locale and Intl', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      await select(tester, container, const Locale('en'));

      await select(tester, container, null);

      check(find.text('外観').evaluate()).isNotEmpty();
      check(intl.Intl.defaultLocale).equals('ja');
    });

    testWidgets('persisted choice applies on launch', (tester) async {
      await prefs.setString(SettingsKeys.locale, 'en');

      await pumpApp(tester);

      check(find.text('Appearance').evaluate()).isNotEmpty();
      check(intl.Intl.defaultLocale).equals('en');
    });
  });
}

/// Mirrors the locale wiring of the root `MyApp` widget without its router
/// and platform plugins.
class _LocaleWiredApp extends ConsumerWidget {
  const _LocaleWiredApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      locale: ref.watch(localeControllerProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveSupportedLocale,
      builder: (context, child) => IntlLocaleSync(child: child!),
      home: Builder(
        builder: (context) =>
            Text(AppLocalizations.of(context).settingsAppearanceTitle),
      ),
    );
  }
}
