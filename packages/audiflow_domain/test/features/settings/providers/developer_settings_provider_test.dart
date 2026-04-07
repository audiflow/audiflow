import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DevShowDeveloperInfo', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('defaults to false', () {
      final value = container.read(devShowDeveloperInfoProvider);
      check(value).equals(false);
    });

    test('persists true after toggle', () async {
      container.read(devShowDeveloperInfoProvider.notifier).toggle();
      check(container.read(devShowDeveloperInfoProvider)).equals(true);

      // Verify persisted to SharedPreferences
      final prefs = container.read(sharedPreferencesProvider);
      check(prefs.getBool('dev_show_developer_info')).equals(true);
    });

    test('reads persisted value on rebuild', () async {
      SharedPreferences.setMockInitialValues({'dev_show_developer_info': true});
      final prefs = await SharedPreferences.getInstance();
      final container2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container2.dispose);

      check(container2.read(devShowDeveloperInfoProvider)).equals(true);
    });
  });
}
