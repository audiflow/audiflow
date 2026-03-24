import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/src/common/datasources/shared_preferences_datasource.dart';
import 'package:audiflow_domain/src/features/settings/repositories/app_settings_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesDataSource dataSource;
  late AppSettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesDataSource(prefs);
    repository = AppSettingsRepositoryImpl(dataSource);
  });

  group('LastTabIndex', () {
    test('returns default (0 = search) when no value stored', () {
      expect(repository.getLastTabIndex(), SettingsDefaults.lastTabIndex);
      expect(repository.getLastTabIndex(), 0);
    });

    test('persists and reads library tab index', () async {
      await repository.setLastTabIndex(1);
      expect(repository.getLastTabIndex(), 1);
    });

    test('persists and reads queue tab index', () async {
      await repository.setLastTabIndex(2);
      expect(repository.getLastTabIndex(), 2);
    });

    test('clamps negative index to default', () async {
      await repository.setLastTabIndex(-1);
      expect(repository.getLastTabIndex(), SettingsDefaults.lastTabIndex);
    });

    test('clamps index above max persistable tab to default', () async {
      // Only tabs 0-2 (search/library/queue) are persistable.
      // Settings tab (3) and anything higher should not be persisted.
      await repository.setLastTabIndex(3);
      expect(repository.getLastTabIndex(), SettingsDefaults.lastTabIndex);
    });

    test('clamps out-of-range index to default', () async {
      await repository.setLastTabIndex(99);
      expect(repository.getLastTabIndex(), SettingsDefaults.lastTabIndex);
    });

    test('handles corrupted stored value gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      // Store an out-of-range value directly
      await prefs.setInt(SettingsKeys.lastTabIndex, 42);
      expect(repository.getLastTabIndex(), SettingsDefaults.lastTabIndex);
    });

    test('clearAll resets to default', () async {
      await repository.setLastTabIndex(2);
      expect(repository.getLastTabIndex(), 2);

      await repository.clearAll();
      expect(repository.getLastTabIndex(), SettingsDefaults.lastTabIndex);
    });
  });
}
