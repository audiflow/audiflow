import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsMetadataRegistry registry;

  setUp(() {
    registry = SettingsMetadataRegistry();
  });

  group('SettingsMetadataRegistry', () {
    group('allSettings', () {
      test('returns an unmodifiable list', () {
        final settings = registry.allSettings;
        check(
          () => settings.add(
            const SettingMetadata(
              key: 'test',
              displayNameKey: 'test',
              type: SettingType.boolean,
              constraints: SettingConstraints.boolean(),
              synonyms: [],
            ),
          ),
        ).throws<UnsupportedError>();
      });

      test('contains exactly 17 entries', () {
        check(registry.allSettings).length.equals(17);
      });

      test(
        'every SettingsKeys constant (except lastTabIndex) has an entry',
        () {
          final keys = registry.allSettings.map((m) => m.key).toSet();

          check(keys).contains(SettingsKeys.themeMode);
          check(keys).contains(SettingsKeys.locale);
          check(keys).contains(SettingsKeys.textScale);
          check(keys).contains(SettingsKeys.playbackSpeed);
          check(keys).contains(SettingsKeys.skipForwardSeconds);
          check(keys).contains(SettingsKeys.skipBackwardSeconds);
          check(keys).contains(SettingsKeys.autoCompleteThreshold);
          check(keys).contains(SettingsKeys.continuousPlayback);
          check(keys).contains(SettingsKeys.autoPlayOrder);
          check(keys).contains(SettingsKeys.wifiOnlyDownload);
          check(keys).contains(SettingsKeys.autoDeletePlayed);
          check(keys).contains(SettingsKeys.maxConcurrentDownloads);
          check(keys).contains(SettingsKeys.autoSync);
          check(keys).contains(SettingsKeys.syncIntervalMinutes);
          check(keys).contains(SettingsKeys.wifiOnlySync);
          check(keys).contains(SettingsKeys.notifyNewEpisodes);
          check(keys).contains(SettingsKeys.searchCountry);
        },
      );

      test(
        'lastTabIndex is NOT registered (navigation state, not user setting)',
        () {
          final keys = registry.allSettings.map((m) => m.key).toSet();
          check(keys).not((k) => k.contains(SettingsKeys.lastTabIndex));
        },
      );

      test('every entry has non-empty synonyms', () {
        for (final metadata in registry.allSettings) {
          check(metadata.synonyms).isNotEmpty();
        }
      });
    });

    group('findByKey', () {
      test('returns null for unknown key', () {
        check(registry.findByKey('unknown_key')).isNull();
      });

      test('returns null for empty string', () {
        check(registry.findByKey('')).isNull();
      });

      test('returns null for lastTabIndex (not registered)', () {
        check(registry.findByKey(SettingsKeys.lastTabIndex)).isNull();
      });

      test('finds themeMode by exact key', () {
        final result = registry.findByKey(SettingsKeys.themeMode);
        check(result).isNotNull()
          ..has((m) => m.key, 'key').equals(SettingsKeys.themeMode)
          ..has((m) => m.type, 'type').equals(SettingType.enumValue);
      });

      test('finds playbackSpeed by exact key', () {
        final result = registry.findByKey(SettingsKeys.playbackSpeed);
        check(result).isNotNull()
          ..has((m) => m.key, 'key').equals(SettingsKeys.playbackSpeed)
          ..has((m) => m.type, 'type').equals(SettingType.doubleValue);
      });

      test('finds continuousPlayback by exact key', () {
        final result = registry.findByKey(SettingsKeys.continuousPlayback);
        check(result).isNotNull();
        check(result!).has((m) => m.type, 'type').equals(SettingType.boolean);
      });
    });

    group('playbackSpeed constraints', () {
      test('has correct range: 0.5 to 3.0, step 0.1', () {
        final metadata = registry.findByKey(SettingsKeys.playbackSpeed);
        check(metadata).isNotNull();

        final constraints = metadata!.constraints;
        check(constraints).isA<RangeConstraints>()
          ..has((c) => c.min, 'min').equals(0.5)
          ..has((c) => c.max, 'max').equals(3.0)
          ..has((c) => c.step, 'step').equals(0.1);
      });
    });

    group('themeMode constraints', () {
      test('has correct options: light, dark, system', () {
        final metadata = registry.findByKey(SettingsKeys.themeMode);
        check(metadata).isNotNull();

        final constraints = metadata!.constraints;
        check(constraints)
            .isA<OptionsConstraints>()
            .has((c) => c.values, 'values')
            .unorderedEquals(['light', 'dark', 'system']);
      });
    });

    group('additional constraint correctness', () {
      test('textScale has range 0.8 to 1.4, step 0.1', () {
        final constraints = registry
            .findByKey(SettingsKeys.textScale)!
            .constraints;
        check(constraints).isA<RangeConstraints>()
          ..has((c) => c.min, 'min').equals(0.8)
          ..has((c) => c.max, 'max').equals(1.4)
          ..has((c) => c.step, 'step').equals(0.1);
      });

      test('skipForwardSeconds has range 5 to 60, step 5', () {
        final constraints = registry
            .findByKey(SettingsKeys.skipForwardSeconds)!
            .constraints;
        check(constraints).isA<RangeConstraints>()
          ..has((c) => c.min, 'min').equals(5.0)
          ..has((c) => c.max, 'max').equals(60.0)
          ..has((c) => c.step, 'step').equals(5.0);
      });

      test('skipBackwardSeconds has range 5 to 60, step 5', () {
        final constraints = registry
            .findByKey(SettingsKeys.skipBackwardSeconds)!
            .constraints;
        check(constraints).isA<RangeConstraints>()
          ..has((c) => c.min, 'min').equals(5.0)
          ..has((c) => c.max, 'max').equals(60.0)
          ..has((c) => c.step, 'step').equals(5.0);
      });

      test('autoCompleteThreshold has range 0.8 to 1.0, step 0.01', () {
        final constraints = registry
            .findByKey(SettingsKeys.autoCompleteThreshold)!
            .constraints;
        check(constraints).isA<RangeConstraints>()
          ..has((c) => c.min, 'min').equals(0.8)
          ..has((c) => c.max, 'max').equals(1.0)
          ..has((c) => c.step, 'step').equals(0.01);
      });

      test('maxConcurrentDownloads has range 1 to 5, step 1', () {
        final constraints = registry
            .findByKey(SettingsKeys.maxConcurrentDownloads)!
            .constraints;
        check(constraints).isA<RangeConstraints>()
          ..has((c) => c.min, 'min').equals(1.0)
          ..has((c) => c.max, 'max').equals(5.0)
          ..has((c) => c.step, 'step').equals(1.0);
      });

      test('syncIntervalMinutes has range 15 to 1440, step 15', () {
        final constraints = registry
            .findByKey(SettingsKeys.syncIntervalMinutes)!
            .constraints;
        check(constraints).isA<RangeConstraints>()
          ..has((c) => c.min, 'min').equals(15.0)
          ..has((c) => c.max, 'max').equals(1440.0)
          ..has((c) => c.step, 'step').equals(15.0);
      });

      test('locale has options: en, ja, system', () {
        final constraints = registry
            .findByKey(SettingsKeys.locale)!
            .constraints;
        check(constraints)
            .isA<OptionsConstraints>()
            .has((c) => c.values, 'values')
            .unorderedEquals(['en', 'ja', 'system']);
      });

      test('autoPlayOrder has options: newestFirst, oldestFirst', () {
        final constraints = registry
            .findByKey(SettingsKeys.autoPlayOrder)!
            .constraints;
        check(constraints)
            .isA<OptionsConstraints>()
            .has((c) => c.values, 'values')
            .unorderedEquals(['newestFirst', 'oldestFirst']);
      });

      test('searchCountry has correct country codes', () {
        final constraints = registry
            .findByKey(SettingsKeys.searchCountry)!
            .constraints;
        check(constraints)
            .isA<OptionsConstraints>()
            .has((c) => c.values, 'values')
            .unorderedEquals(['us', 'jp', 'gb', 'de', 'fr', 'au', 'ca']);
      });

      test('boolean settings use BooleanConstraints', () {
        final booleanKeys = [
          SettingsKeys.continuousPlayback,
          SettingsKeys.wifiOnlyDownload,
          SettingsKeys.autoDeletePlayed,
          SettingsKeys.autoSync,
          SettingsKeys.wifiOnlySync,
          SettingsKeys.notifyNewEpisodes,
        ];

        for (final key in booleanKeys) {
          final metadata = registry.findByKey(key);
          check(metadata).isNotNull();
          check(metadata!.constraints).isA<BooleanConstraints>();
          check(metadata.type).equals(SettingType.boolean);
        }
      });
    });
  });
}
