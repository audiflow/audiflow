import 'package:audiflow_app/features/settings/presentation/controllers/locale_controller.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('LocaleController', () {
    test('defaults to null (follow device locale)', () {
      final container = createContainer();

      check(container.read(localeControllerProvider)).isNull();
    });

    test('reads persisted language code on build', () async {
      await prefs.setString(SettingsKeys.locale, 'ja');
      final container = createContainer();

      check(
        container.read(localeControllerProvider),
      ).equals(const Locale('ja'));
    });

    test('setLocale updates state and persists the language code', () async {
      final container = createContainer();

      await container
          .read(localeControllerProvider.notifier)
          .setLocale(const Locale('en'));

      check(
        container.read(localeControllerProvider),
      ).equals(const Locale('en'));
      check(prefs.getString(SettingsKeys.locale)).equals('en');
    });

    test('setLocale(null) clears the choice and persists removal', () async {
      await prefs.setString(SettingsKeys.locale, 'ja');
      final container = createContainer();

      await container.read(localeControllerProvider.notifier).setLocale(null);

      check(container.read(localeControllerProvider)).isNull();
      check(prefs.getString(SettingsKeys.locale)).isNull();
    });

    test('choice survives a fresh container (app restart)', () async {
      final first = createContainer();
      await first
          .read(localeControllerProvider.notifier)
          .setLocale(const Locale('ja'));

      final second = createContainer();

      check(second.read(localeControllerProvider)).equals(const Locale('ja'));
    });
  });
}
