import 'package:audiflow_app/features/settings/presentation/controllers/theme_controller.dart';
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

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  }

  group('ThemeModeController', () {
    test('defaults to system', () {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeControllerProvider), ThemeMode.system);
    });

    test('setThemeMode updates state to dark', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeControllerProvider), ThemeMode.dark);
    });

    test('setThemeMode updates state to light', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.light);

      expect(container.read(themeModeControllerProvider), ThemeMode.light);
    });

    test('setThemeMode persists to SharedPreferences', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      // Verify persistence by creating a fresh container
      final container2 = createContainer();
      addTearDown(container2.dispose);

      expect(container2.read(themeModeControllerProvider), ThemeMode.dark);
    });

    test('reads persisted value on build', () async {
      // Persist a value first
      final container1 = createContainer();
      addTearDown(container1.dispose);

      await container1
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.light);

      // New container should read the persisted value
      final container2 = createContainer();
      addTearDown(container2.dispose);

      expect(container2.read(themeModeControllerProvider), ThemeMode.light);
    });
  });

  group('TextScaleController', () {
    test('defaults to 1.0', () {
      final container = createContainer();
      addTearDown(container.dispose);

      expect(container.read(textScaleControllerProvider), 1.0);
    });

    test('setTextScale updates state', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(textScaleControllerProvider.notifier)
          .setTextScale(1.15);

      expect(container.read(textScaleControllerProvider), 1.15);
    });

    test('setTextScale to small value updates state', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(textScaleControllerProvider.notifier)
          .setTextScale(0.85);

      expect(container.read(textScaleControllerProvider), 0.85);
    });

    test('setTextScale persists to SharedPreferences', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container
          .read(textScaleControllerProvider.notifier)
          .setTextScale(1.15);

      // Verify persistence by creating a fresh container
      final container2 = createContainer();
      addTearDown(container2.dispose);

      expect(container2.read(textScaleControllerProvider), 1.15);
    });

    test('reads persisted value on build', () async {
      // Persist a value first
      final container1 = createContainer();
      addTearDown(container1.dispose);

      await container1
          .read(textScaleControllerProvider.notifier)
          .setTextScale(0.85);

      // New container should read the persisted value
      final container2 = createContainer();
      addTearDown(container2.dispose);

      expect(container2.read(textScaleControllerProvider), 0.85);
    });
  });
}
