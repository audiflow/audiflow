import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsMetadataRegistry registry;
  late SettingsIntentResolver resolver;

  // Snapshot of current values used across all tests.
  const currentValues = {
    SettingsKeys.playbackSpeed: '1.0',
    SettingsKeys.textScale: '1.0',
    SettingsKeys.skipForwardSeconds: '30',
    SettingsKeys.skipBackwardSeconds: '10',
    SettingsKeys.maxConcurrentDownloads: '3',
    SettingsKeys.syncIntervalMinutes: '60',
    SettingsKeys.themeMode: 'system',
    SettingsKeys.continuousPlayback: 'true',
  };

  setUp(() {
    registry = SettingsMetadataRegistry();
    resolver = SettingsIntentResolver(registry);
  });

  group('SettingsIntentResolver', () {
    group('registry getter', () {
      test('exposes the injected registry', () {
        check(resolver.registry).identicalTo(registry);
      });
    });

    // ─── Absolute payloads ────────────────────────────────────────────────────

    group('absolute - high confidence → autoApply', () {
      test('confidence 0.8 (threshold) resolves to autoApply', () {
        final payload = const SettingsChangePayload.absolute(
          key: SettingsKeys.playbackSpeed,
          value: '1.5',
          confidence: 0.8,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionAutoApply>()
          ..has((r) => r.key, 'key').equals(SettingsKeys.playbackSpeed)
          ..has((r) => r.oldValue, 'oldValue').equals('1.0')
          ..has((r) => r.newValue, 'newValue').equals('1.5');
      });

      test('confidence 0.95 resolves to autoApply', () {
        final payload = const SettingsChangePayload.absolute(
          key: SettingsKeys.themeMode,
          value: 'dark',
          confidence: 0.95,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionAutoApply>()
          ..has((r) => r.key, 'key').equals(SettingsKeys.themeMode)
          ..has((r) => r.oldValue, 'oldValue').equals('system')
          ..has((r) => r.newValue, 'newValue').equals('dark');
      });
    });

    group('absolute - low confidence → confirm', () {
      test('confidence 0.5 resolves to confirm', () {
        final payload = const SettingsChangePayload.absolute(
          key: SettingsKeys.playbackSpeed,
          value: '2.0',
          confidence: 0.5,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionConfirm>()
          ..has((r) => r.key, 'key').equals(SettingsKeys.playbackSpeed)
          ..has((r) => r.oldValue, 'oldValue').equals('1.0')
          ..has((r) => r.newValue, 'newValue').equals('2.0')
          ..has((r) => r.confidence, 'confidence').equals(0.5);
      });

      test('confidence just below threshold (0.79) resolves to confirm', () {
        final payload = const SettingsChangePayload.absolute(
          key: SettingsKeys.textScale,
          value: '1.2',
          confidence: 0.79,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionConfirm>();
      });
    });

    group('absolute - unknown key → notFound', () {
      test('key not in registry returns notFound', () {
        final payload = const SettingsChangePayload.absolute(
          key: 'unknown_setting_xyz',
          value: 'someValue',
          confidence: 0.99,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionNotFound>();
      });
    });

    // ─── Relative payloads ────────────────────────────────────────────────────

    group('relative - increase small', () {
      test('increases by 1 step (0.1) from 1.0', () {
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.playbackSpeed,
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionAutoApply>()
          ..has((r) => r.newValue, 'newValue').equals('1.1')
          ..has((r) => r.oldValue, 'oldValue').equals('1.0');
      });
    });

    group('relative - increase medium', () {
      test('increases by 2 steps (0.2) from 1.0', () {
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.playbackSpeed,
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.medium,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result)
            .isA<SettingsResolutionAutoApply>()
            .has((r) => r.newValue, 'newValue')
            .equals('1.2');
      });
    });

    group('relative - decrease large', () {
      test('decreases by 3 steps (15s each) from 30', () {
        // skipForwardSeconds: step=5, current=30, large=3 steps → 30-15=15
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.skipForwardSeconds,
          direction: ChangeDirection.decrease,
          magnitude: ChangeMagnitude.large,
          confidence: 0.85,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionAutoApply>()
          ..has((r) => r.newValue, 'newValue').equals('15')
          ..has((r) => r.oldValue, 'oldValue').equals('30');
      });
    });

    group('relative - clamp to max', () {
      test('clamps to max when increase would exceed it', () {
        // playbackSpeed max=3.0, current=1.0, large=3 steps * 0.1 = 0.3 → 1.3
        // Use a value near max: set current to 2.9
        final values = {...currentValues, SettingsKeys.playbackSpeed: '2.9'};
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.playbackSpeed,
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.large,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: values);
        check(result)
            .isA<SettingsResolutionAutoApply>()
            .has((r) => r.newValue, 'newValue')
            .equals('3.0');
      });
    });

    group('relative - clamp to min', () {
      test('clamps to min when decrease would go below it', () {
        // playbackSpeed min=0.5, current=0.6, small=1 step * 0.1 = 0.1 → 0.5
        final values = {...currentValues, SettingsKeys.playbackSpeed: '0.6'};
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.playbackSpeed,
          direction: ChangeDirection.decrease,
          magnitude: ChangeMagnitude.large,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: values);
        check(result)
            .isA<SettingsResolutionAutoApply>()
            .has((r) => r.newValue, 'newValue')
            .equals('0.5');
      });
    });

    group('relative - intValue formats without decimal', () {
      test('skipForwardSeconds formats result as int string', () {
        // skipForwardSeconds: step=5, current=30, small=1 step → 35
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.skipForwardSeconds,
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result)
            .isA<SettingsResolutionAutoApply>()
            .has((r) => r.newValue, 'newValue')
            .equals('35');
      });
    });

    group('relative - non-range constraint → notFound', () {
      test('enum setting with relative payload returns notFound', () {
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.themeMode,
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionNotFound>();
      });

      test('boolean setting with relative payload returns notFound', () {
        final payload = const SettingsChangePayload.relative(
          key: SettingsKeys.continuousPlayback,
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionNotFound>();
      });
    });

    group('relative - unknown key → notFound', () {
      test('returns notFound for unregistered key', () {
        final payload = const SettingsChangePayload.relative(
          key: 'unknown_key',
          direction: ChangeDirection.increase,
          magnitude: ChangeMagnitude.small,
          confidence: 0.9,
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionNotFound>();
      });
    });

    // ─── Ambiguous payloads ───────────────────────────────────────────────────

    group('ambiguous - 2+ candidates above threshold → disambiguate', () {
      test('two candidates both above 0.4 → disambiguate', () {
        final payload = const SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(
              key: SettingsKeys.playbackSpeed,
              value: '1.5',
              confidence: 0.7,
            ),
            SettingsCandidate(
              key: SettingsKeys.textScale,
              value: '1.2',
              confidence: 0.6,
            ),
          ],
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result)
            .isA<SettingsResolutionDisambiguate>()
            .has((r) => r.candidates, 'candidates')
            .length
            .equals(2);

        final disambiguate = result as SettingsResolutionDisambiguate;
        final keys = disambiguate.candidates.map((c) => c.key).toList();
        check(keys).contains(SettingsKeys.playbackSpeed);
        check(keys).contains(SettingsKeys.textScale);
      });
    });

    group('ambiguous - all below discard threshold → notFound', () {
      test('candidates all below 0.4 returns notFound', () {
        final payload = const SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(
              key: SettingsKeys.playbackSpeed,
              value: '1.5',
              confidence: 0.3,
            ),
            SettingsCandidate(
              key: SettingsKeys.textScale,
              value: '1.2',
              confidence: 0.1,
            ),
          ],
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionNotFound>();
      });

      test('empty candidates list returns notFound', () {
        final payload = const SettingsChangePayload.ambiguous(candidates: []);
        final result = resolver.resolve(payload, currentValues: currentValues);
        check(result).isA<SettingsResolutionNotFound>();
      });
    });

    group(
      'ambiguous - single candidate above threshold → single-match path',
      () {
        test('one above 0.4 with high confidence → autoApply', () {
          final payload = const SettingsChangePayload.ambiguous(
            candidates: [
              SettingsCandidate(
                key: SettingsKeys.playbackSpeed,
                value: '1.5',
                confidence: 0.9,
              ),
              SettingsCandidate(
                key: SettingsKeys.textScale,
                value: '1.2',
                confidence: 0.2,
              ),
            ],
          );
          final result = resolver.resolve(
            payload,
            currentValues: currentValues,
          );
          check(result).isA<SettingsResolutionAutoApply>()
            ..has((r) => r.key, 'key').equals(SettingsKeys.playbackSpeed)
            ..has((r) => r.newValue, 'newValue').equals('1.5');
        });

        test('one above 0.4 with low confidence → confirm', () {
          final payload = const SettingsChangePayload.ambiguous(
            candidates: [
              SettingsCandidate(
                key: SettingsKeys.playbackSpeed,
                value: '2.0',
                confidence: 0.5,
              ),
              SettingsCandidate(
                key: SettingsKeys.textScale,
                value: '1.3',
                confidence: 0.35,
              ),
            ],
          );
          final result = resolver.resolve(
            payload,
            currentValues: currentValues,
          );
          check(result).isA<SettingsResolutionConfirm>()
            ..has((r) => r.key, 'key').equals(SettingsKeys.playbackSpeed)
            ..has((r) => r.confidence, 'confidence').equals(0.5);
        });
      },
    );

    group('ambiguous - discard threshold boundary', () {
      test('candidate at exactly 0.4 is kept (threshold is inclusive)', () {
        // _discardThreshold <= confidence → 0.4 <= 0.4 is true, so kept.
        final payload = const SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(
              key: SettingsKeys.playbackSpeed,
              value: '1.5',
              confidence: 0.4,
            ),
          ],
        );
        final result = resolver.resolve(payload, currentValues: currentValues);
        // Single candidate kept, confidence 0.4 < 0.8 → confirm.
        check(result)
            .isA<SettingsResolutionConfirm>()
            .has((r) => r.key, 'key')
            .equals(SettingsKeys.playbackSpeed);
      });
    });

    group('ambiguous - candidate populates oldValue from currentValues', () {
      test('disambiguate result carries correct oldValue', () {
        final values = {
          ...currentValues,
          SettingsKeys.playbackSpeed: '1.8',
          SettingsKeys.textScale: '0.9',
        };
        final payload = const SettingsChangePayload.ambiguous(
          candidates: [
            SettingsCandidate(
              key: SettingsKeys.playbackSpeed,
              value: '2.0',
              confidence: 0.7,
            ),
            SettingsCandidate(
              key: SettingsKeys.textScale,
              value: '1.0',
              confidence: 0.6,
            ),
          ],
        );
        final result = resolver.resolve(payload, currentValues: values);
        final disambiguate = result as SettingsResolutionDisambiguate;

        final speedCandidate = disambiguate.candidates.firstWhere(
          (c) => c.key == SettingsKeys.playbackSpeed,
        );
        check(speedCandidate.oldValue).equals('1.8');

        final scaleCandidate = disambiguate.candidates.firstWhere(
          (c) => c.key == SettingsKeys.textScale,
        );
        check(scaleCandidate.oldValue).equals('0.9');
      });
    });
  });
}
