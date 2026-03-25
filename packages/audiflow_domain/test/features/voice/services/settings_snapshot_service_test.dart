import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_settings_repository.dart';

void main() {
  late SettingsSnapshotService service;
  late FakeAppSettingsRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAppSettingsRepository();
    service = SettingsSnapshotService(
      registry: SettingsMetadataRegistry(),
      settingsRepository: fakeRepository,
    );
  });

  group('SettingsSnapshotService', () {
    group('buildPromptSnapshot', () {
      test('returns non-empty string', () {
        final snapshot = service.buildPromptSnapshot();
        check(snapshot).isNotEmpty();
      });

      test('contains playbackSpeed entry with value 1.0', () {
        final snapshot = service.buildPromptSnapshot();
        check(snapshot).contains('${SettingsKeys.playbackSpeed}: 1.0');
      });

      test('contains range constraint text for playbackSpeed', () {
        final snapshot = service.buildPromptSnapshot();
        check(snapshot).contains('(range: 0.5-3.0, step: 0.1)');
      });

      test('contains options constraint text for themeMode', () {
        final snapshot = service.buildPromptSnapshot();
        check(snapshot).contains('(options:');
      });

      test('contains boolean constraint text for continuousPlayback', () {
        final snapshot = service.buildPromptSnapshot();
        check(snapshot).contains('(boolean)');
      });

      test('contains synonyms section', () {
        final snapshot = service.buildPromptSnapshot();
        check(snapshot).contains('[synonyms:');
      });

      test('has one line per registered setting', () {
        final snapshot = service.buildPromptSnapshot();
        final registry = SettingsMetadataRegistry();
        final lines = snapshot
            .trimRight()
            .split('\n')
            .where((l) => l.isNotEmpty)
            .toList();
        check(lines.length).equals(registry.allSettings.length);
      });
    });

    group('getCurrentValue', () {
      test('returns "system" for ThemeMode.system', () {
        fakeRepository.themeMode = ThemeMode.system;
        check(service.getCurrentValue(SettingsKeys.themeMode)).equals('system');
      });

      test('returns "light" for ThemeMode.light', () {
        fakeRepository.themeMode = ThemeMode.light;
        check(service.getCurrentValue(SettingsKeys.themeMode)).equals('light');
      });

      test('returns "dark" for ThemeMode.dark', () {
        fakeRepository.themeMode = ThemeMode.dark;
        check(service.getCurrentValue(SettingsKeys.themeMode)).equals('dark');
      });

      test('returns "system" for null locale', () {
        fakeRepository.locale = null;
        check(service.getCurrentValue(SettingsKeys.locale)).equals('system');
      });

      test('returns locale string when set', () {
        fakeRepository.locale = 'ja';
        check(service.getCurrentValue(SettingsKeys.locale)).equals('ja');
      });

      test('returns playbackSpeed as string', () {
        fakeRepository.playbackSpeed = 1.5;
        check(
          service.getCurrentValue(SettingsKeys.playbackSpeed),
        ).equals('1.5');
      });

      test('returns autoPlayOrder enum name', () {
        fakeRepository.autoPlayOrder = AutoPlayOrder.oldestFirst;
        check(
          service.getCurrentValue(SettingsKeys.autoPlayOrder),
        ).equals('oldestFirst');
      });

      test('returns empty string for unknown key', () {
        check(service.getCurrentValue('unknown_key')).equals('');
      });

      test('returns skipForwardSeconds as string', () {
        fakeRepository.skipForwardSeconds = 15;
        check(
          service.getCurrentValue(SettingsKeys.skipForwardSeconds),
        ).equals('15');
      });

      test('returns continuousPlayback as string', () {
        fakeRepository.continuousPlayback = false;
        check(
          service.getCurrentValue(SettingsKeys.continuousPlayback),
        ).equals('false');
      });

      test('returns "system" for null searchCountry', () {
        fakeRepository.searchCountry = null;
        check(
          service.getCurrentValue(SettingsKeys.searchCountry),
        ).equals('system');
      });
    });
  });
}
