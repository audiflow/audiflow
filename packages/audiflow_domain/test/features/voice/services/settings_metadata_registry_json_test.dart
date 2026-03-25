import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_settings_repository.dart';

void main() {
  late SettingsMetadataRegistry registry;
  late FakeAppSettingsRepository fakeRepository;

  setUp(() {
    registry = SettingsMetadataRegistry();
    fakeRepository = FakeAppSettingsRepository();
  });

  group('SettingsMetadataRegistry.toJson', () {
    test('produces a Map with a "settings" key', () {
      final result = registry.toJson(fakeRepository);
      check(result).containsKey('settings');
    });

    test('"settings" is a non-empty list', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;
      check(settings).isNotEmpty();
    });

    test('"settings" length matches allSettings count', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;
      check(settings).length.equals(registry.allSettings.length);
    });

    test('each entry contains required fields', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      for (final entry in settings) {
        final map = entry as Map<String, dynamic>;
        check(map).containsKey('key');
        check(map).containsKey('displayName');
        check(map).containsKey('type');
        check(map).containsKey('currentValue');
        check(map).containsKey('constraints');
        check(map).containsKey('synonyms');
      }
    });

    test('each entry has non-empty key string', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      for (final entry in settings) {
        final map = entry as Map<String, dynamic>;
        check(map['key'] as String).isNotEmpty();
      }
    });

    test('each entry has non-empty synonyms list', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      for (final entry in settings) {
        final map = entry as Map<String, dynamic>;
        final synonyms = map['synonyms'] as List<dynamic>;
        check(synonyms).isNotEmpty();
      }
    });

    test('range constraint has type, min, max, step fields', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      final playbackEntry =
          settings.firstWhere(
                (e) =>
                    (e as Map<String, dynamic>)['key'] ==
                    SettingsKeys.playbackSpeed,
              )
              as Map<String, dynamic>;

      final constraints = playbackEntry['constraints'] as Map<String, dynamic>;

      check(constraints['type'] as String).equals('range');
      check(constraints).containsKey('min');
      check(constraints).containsKey('max');
      check(constraints).containsKey('step');
      check(constraints['min'] as double).equals(0.5);
      check(constraints['max'] as double).equals(3.0);
      check(constraints['step'] as double).equals(0.1);
    });

    test('options constraint has type and values list', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      final themeEntry =
          settings.firstWhere(
                (e) =>
                    (e as Map<String, dynamic>)['key'] ==
                    SettingsKeys.themeMode,
              )
              as Map<String, dynamic>;

      final constraints = themeEntry['constraints'] as Map<String, dynamic>;

      check(constraints['type'] as String).equals('options');
      check(constraints).containsKey('values');
      final values = constraints['values'] as List<dynamic>;
      check(values).isNotEmpty();
      check(values.cast<String>()).unorderedEquals(['light', 'dark', 'system']);
    });

    test('boolean constraint has type "boolean"', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      final continuousEntry =
          settings.firstWhere(
                (e) =>
                    (e as Map<String, dynamic>)['key'] ==
                    SettingsKeys.continuousPlayback,
              )
              as Map<String, dynamic>;

      final constraints =
          continuousEntry['constraints'] as Map<String, dynamic>;

      check(constraints['type'] as String).equals('boolean');
    });

    test('currentValue reflects repository state', () {
      fakeRepository.playbackSpeed = 2.0;

      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      final playbackEntry =
          settings.firstWhere(
                (e) =>
                    (e as Map<String, dynamic>)['key'] ==
                    SettingsKeys.playbackSpeed,
              )
              as Map<String, dynamic>;

      check(playbackEntry['currentValue'] as String).equals('2.0');
    });

    test('int range constraint (skipForwardSeconds) has correct bounds', () {
      final result = registry.toJson(fakeRepository);
      final settings = result['settings'] as List<dynamic>;

      final skipEntry =
          settings.firstWhere(
                (e) =>
                    (e as Map<String, dynamic>)['key'] ==
                    SettingsKeys.skipForwardSeconds,
              )
              as Map<String, dynamic>;

      final constraints = skipEntry['constraints'] as Map<String, dynamic>;

      check(constraints['type'] as String).equals('range');
      check(constraints['min'] as double).equals(5.0);
      check(constraints['max'] as double).equals(60.0);
      check(constraints['step'] as double).equals(5.0);
    });
  });
}
