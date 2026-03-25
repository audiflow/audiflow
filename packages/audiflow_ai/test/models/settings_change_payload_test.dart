import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChangeDirection', () {
    test('has increase value', () {
      check(ChangeDirection.values).contains(ChangeDirection.increase);
    });

    test('has decrease value', () {
      check(ChangeDirection.values).contains(ChangeDirection.decrease);
    });

    test('has exactly two values', () {
      check(ChangeDirection.values).length.equals(2);
    });
  });

  group('ChangeMagnitude', () {
    test('has small value', () {
      check(ChangeMagnitude.values).contains(ChangeMagnitude.small);
    });

    test('has medium value', () {
      check(ChangeMagnitude.values).contains(ChangeMagnitude.medium);
    });

    test('has large value', () {
      check(ChangeMagnitude.values).contains(ChangeMagnitude.large);
    });

    test('has exactly three values', () {
      check(ChangeMagnitude.values).length.equals(3);
    });
  });

  group('SettingsCandidate', () {
    test('creates with all fields', () {
      const candidate = SettingsCandidate(
        key: 'playbackSpeed',
        value: '1.5',
        confidence: 0.9,
      );

      check(candidate.key).equals('playbackSpeed');
      check(candidate.value).equals('1.5');
      check(candidate.confidence).equals(0.9);
    });

    test('equality holds for identical field values', () {
      const a = SettingsCandidate(
        key: 'skipInterval',
        value: '30',
        confidence: 0.8,
      );
      const b = SettingsCandidate(
        key: 'skipInterval',
        value: '30',
        confidence: 0.8,
      );

      check(a).equals(b);
    });
  });

  group('SettingsChangePayload', () {
    group('absolute variant', () {
      test('creates with key, value, and confidence', () {
        const payload = SettingsChangePayload.absolute(
          key: 'playbackSpeed',
          value: '2.0',
          confidence: 0.95,
        );

        check(payload).isA<SettingsChangePayloadAbsolute>();
        const absolute = payload as SettingsChangePayloadAbsolute;
        check(absolute.key).equals('playbackSpeed');
        check(absolute.value).equals('2.0');
        check(absolute.confidence).equals(0.95);
      });

      test('equality holds for identical fields', () {
        const a = SettingsChangePayload.absolute(
          key: 'theme',
          value: 'dark',
          confidence: 1,
        );
        const b = SettingsChangePayload.absolute(
          key: 'theme',
          value: 'dark',
          confidence: 1,
        );

        check(a).equals(b);
      });
    });

    group('relative variant', () {
      test('creates with key, direction, magnitude, and confidence', () {
        const payload = SettingsChangePayload.relative(
          key: 'playbackSpeed',
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.85,
        );

        check(payload).isA<SettingsChangePayloadRelative>();
        const relative = payload as SettingsChangePayloadRelative;
        check(relative.key).equals('playbackSpeed');
        check(relative.direction).equals(ChangeDirection.increase);
        check(relative.magnitude).equals(ChangeMagnitude.small);
        check(relative.confidence).equals(0.85);
      });

      test('decrease direction is preserved', () {
        const payload = SettingsChangePayload.relative(
          key: 'volume',
          direction: ChangeDirection.decrease,
          magnitude: ChangeMagnitude.large,
          confidence: 0.7,
        );

        const relative = payload as SettingsChangePayloadRelative;
        check(relative.direction).equals(ChangeDirection.decrease);
        check(relative.magnitude).equals(ChangeMagnitude.large);
      });

      test('equality holds for identical fields', () {
        const a = SettingsChangePayload.relative(
          key: 'skipInterval',
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.medium,
          confidence: 0.9,
        );
        const b = SettingsChangePayload.relative(
          key: 'skipInterval',
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.medium,
          confidence: 0.9,
        );

        check(a).equals(b);
      });
    });

    group('ambiguous variant', () {
      test('creates with a list of candidates', () {
        const payload = SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(
              key: 'playbackSpeed',
              value: '1.5',
              confidence: 0.6,
            ),
            SettingsCandidate(
              key: 'skipInterval',
              value: '15',
              confidence: 0.4,
            ),
          ],
        );

        check(payload).isA<SettingsChangePayloadAmbiguous>();
        const ambiguous = payload as SettingsChangePayloadAmbiguous;
        check(ambiguous.candidates).length.equals(2);
        check(ambiguous.candidates.first.key).equals('playbackSpeed');
        check(ambiguous.candidates.last.key).equals('skipInterval');
      });

      test('creates with empty candidates list', () {
        const payload = SettingsChangePayload.ambiguous(candidates: []);

        const ambiguous = payload as SettingsChangePayloadAmbiguous;
        check(ambiguous.candidates).isEmpty();
      });

      test('equality holds for identical candidates', () {
        const a = SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(key: 'theme', value: 'dark', confidence: 0.5),
          ],
        );
        const b = SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(key: 'theme', value: 'dark', confidence: 0.5),
          ],
        );

        check(a).equals(b);
      });
    });

    group('sealed type exhaustive switching', () {
      test('switch covers all three variants without default', () {
        const payloads = <SettingsChangePayload>[
          SettingsChangePayload.absolute(key: 'k', value: 'v', confidence: 1),
          SettingsChangePayload.relative(
            key: 'k',
            direction: ChangeDirection.increase,
            magnitude: ChangeMagnitude.small,
            confidence: 1,
          ),
          SettingsChangePayload.ambiguous(candidates: []),
        ];

        for (final payload in payloads) {
          final label = switch (payload) {
            SettingsChangePayloadAbsolute() => 'absolute',
            SettingsChangePayloadRelative() => 'relative',
            SettingsChangePayloadAmbiguous() => 'ambiguous',
          };
          check(label).isNotEmpty();
        }
      });
    });
  });
}
