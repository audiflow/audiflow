import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingType', () {
    test('has all expected values', () {
      check(SettingType.values).length.equals(4);
      check(SettingType.values).contains(SettingType.boolean);
      check(SettingType.values).contains(SettingType.intValue);
      check(SettingType.values).contains(SettingType.doubleValue);
      check(SettingType.values).contains(SettingType.enumValue);
    });
  });

  group('SettingConstraints', () {
    group('boolean', () {
      test('creates boolean constraints', () {
        const constraints = SettingConstraints.boolean();
        check(constraints).isA<BooleanConstraints>();
      });

      test('two boolean constraints are equal', () {
        const a = SettingConstraints.boolean();
        const b = SettingConstraints.boolean();
        check(a).equals(b);
      });
    });

    group('range', () {
      test('creates range constraints with min, max, step', () {
        const constraints = SettingConstraints.range(
          min: 0.5,
          max: 3.0,
          step: 0.25,
        );
        check(constraints).isA<RangeConstraints>();
        final range = constraints as RangeConstraints;
        check(range.min).equals(0.5);
        check(range.max).equals(3.0);
        check(range.step).equals(0.25);
      });

      test('two range constraints with same values are equal', () {
        const a = SettingConstraints.range(min: 0.0, max: 1.0, step: 0.1);
        const b = SettingConstraints.range(min: 0.0, max: 1.0, step: 0.1);
        check(a).equals(b);
      });

      test('range constraints with different values are not equal', () {
        const a = SettingConstraints.range(min: 0.0, max: 1.0, step: 0.1);
        const b = SettingConstraints.range(min: 0.0, max: 2.0, step: 0.1);
        check(a).not((it) => it.equals(b));
      });
    });

    group('options', () {
      test('creates options constraints with values list', () {
        const constraints = SettingConstraints.options(
          values: ['light', 'dark', 'system'],
        );
        check(constraints).isA<OptionsConstraints>();
        final options = constraints as OptionsConstraints;
        check(options.values).deepEquals(['light', 'dark', 'system']);
      });

      test('accepts empty options list', () {
        const constraints = SettingConstraints.options(values: []);
        check((constraints as OptionsConstraints).values).isEmpty();
      });

      test('two options constraints with same values are equal', () {
        const a = SettingConstraints.options(values: ['a', 'b']);
        const b = SettingConstraints.options(values: ['a', 'b']);
        check(a).equals(b);
      });

      test('options constraints with different values are not equal', () {
        const a = SettingConstraints.options(values: ['a', 'b']);
        const b = SettingConstraints.options(values: ['a', 'c']);
        check(a).not((it) => it.equals(b));
      });
    });

    group('pattern matching', () {
      test('exhaustive switch covers all variants', () {
        const constraints = <SettingConstraints>[
          SettingConstraints.boolean(),
          SettingConstraints.range(min: 0.0, max: 1.0, step: 0.1),
          SettingConstraints.options(values: ['x']),
        ];

        final labels = constraints.map((c) {
          return switch (c) {
            BooleanConstraints() => 'boolean',
            RangeConstraints() => 'range',
            OptionsConstraints() => 'options',
          };
        }).toList();

        check(labels).deepEquals(['boolean', 'range', 'options']);
      });
    });
  });

  group('SettingMetadata', () {
    test('creates metadata for boolean setting', () {
      const metadata = SettingMetadata(
        key: 'skipSilence',
        displayNameKey: 'settings_skip_silence',
        type: SettingType.boolean,
        constraints: SettingConstraints.boolean(),
        synonyms: ['remove silence', 'skip quiet parts'],
      );

      check(metadata.key).equals('skipSilence');
      check(metadata.displayNameKey).equals('settings_skip_silence');
      check(metadata.type).equals(SettingType.boolean);
      check(metadata.constraints).isA<BooleanConstraints>();
      check(
        metadata.synonyms,
      ).deepEquals(['remove silence', 'skip quiet parts']);
    });

    test('creates metadata for range setting', () {
      const metadata = SettingMetadata(
        key: 'playbackSpeed',
        displayNameKey: 'settings_playback_speed',
        type: SettingType.doubleValue,
        constraints: SettingConstraints.range(min: 0.5, max: 3.0, step: 0.25),
        synonyms: ['speed', 'tempo'],
      );

      check(metadata.key).equals('playbackSpeed');
      check(metadata.type).equals(SettingType.doubleValue);
      final range = metadata.constraints as RangeConstraints;
      check(range.min).equals(0.5);
      check(range.max).equals(3.0);
      check(range.step).equals(0.25);
    });

    test('creates metadata for enum setting', () {
      const metadata = SettingMetadata(
        key: 'theme',
        displayNameKey: 'settings_theme',
        type: SettingType.enumValue,
        constraints: SettingConstraints.options(
          values: ['light', 'dark', 'system'],
        ),
        synonyms: ['appearance', 'color scheme'],
      );

      check(metadata.key).equals('theme');
      check(metadata.type).equals(SettingType.enumValue);
      check(
        (metadata.constraints as OptionsConstraints).values,
      ).deepEquals(['light', 'dark', 'system']);
    });

    test('accepts empty synonyms list', () {
      const metadata = SettingMetadata(
        key: 'volume',
        displayNameKey: 'settings_volume',
        type: SettingType.intValue,
        constraints: SettingConstraints.range(min: 0.0, max: 100.0, step: 1.0),
        synonyms: [],
      );

      check(metadata.synonyms).isEmpty();
    });

    test('two metadata with same values are equal', () {
      const a = SettingMetadata(
        key: 'skipSilence',
        displayNameKey: 'settings_skip_silence',
        type: SettingType.boolean,
        constraints: SettingConstraints.boolean(),
        synonyms: ['skip silence'],
      );
      const b = SettingMetadata(
        key: 'skipSilence',
        displayNameKey: 'settings_skip_silence',
        type: SettingType.boolean,
        constraints: SettingConstraints.boolean(),
        synonyms: ['skip silence'],
      );

      check(a).equals(b);
    });

    test('two metadata with different keys are not equal', () {
      const a = SettingMetadata(
        key: 'a',
        displayNameKey: 'key_a',
        type: SettingType.boolean,
        constraints: SettingConstraints.boolean(),
        synonyms: [],
      );
      const b = SettingMetadata(
        key: 'b',
        displayNameKey: 'key_b',
        type: SettingType.boolean,
        constraints: SettingConstraints.boolean(),
        synonyms: [],
      );

      check(a).not((it) => it.equals(b));
    });

    test('copyWith produces updated metadata', () {
      const original = SettingMetadata(
        key: 'skipSilence',
        displayNameKey: 'settings_skip_silence',
        type: SettingType.boolean,
        constraints: SettingConstraints.boolean(),
        synonyms: ['skip silence'],
      );

      final updated = original.copyWith(key: 'skipSilenceEnabled');
      check(updated.key).equals('skipSilenceEnabled');
      check(updated.displayNameKey).equals('settings_skip_silence');
      check(updated.type).equals(SettingType.boolean);
    });
  });
}
