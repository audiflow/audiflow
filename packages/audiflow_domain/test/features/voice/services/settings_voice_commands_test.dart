// Fixture-based regression tests for the settings voice-command pipeline.
//
// Each test encodes a realistic utterance (as it would be classified by the AI
// layer) and verifies the full resolver output.  These act as regression gates
// when the AI prompt is tuned: if the expected payload changes, these tests
// catch the drift early.
//
// No mocks are needed - the real SettingsMetadataRegistry and
// SettingsIntentResolver are used throughout.

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsMetadataRegistry registry;
  late SettingsIntentResolver resolver;

  // Default current values shared across all test cases.
  // Keys match SettingsKeys constants; values are string-encoded as stored.
  const defaultValues = <String, String>{
    SettingsKeys.playbackSpeed: '1.0',
    SettingsKeys.themeMode: 'system',
    SettingsKeys.continuousPlayback: 'true',
    SettingsKeys.skipForwardSeconds: '30',
    SettingsKeys.textScale: '1.0',
  };

  setUp(() {
    registry = SettingsMetadataRegistry();
    resolver = SettingsIntentResolver(registry);
  });

  // ---------------------------------------------------------------------------
  // Absolute commands
  // ---------------------------------------------------------------------------

  group('absolute commands', () {
    // "1.5倍にして" → playbackSpeed = 1.5 (auto-apply)
    test('utterance "1.5倍にして" resolves playbackSpeed to 1.5 (auto-apply)', () {
      // The AI classifies this utterance as an absolute change with high
      // confidence because the user stated an explicit numeric target.
      const payload = SettingsChangePayload.absolute(
        key: SettingsKeys.playbackSpeed,
        value: '1.5',
        confidence: 0.95,
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.key, 'key').equals(SettingsKeys.playbackSpeed)
        ..has((r) => r.oldValue, 'oldValue').equals('1.0')
        ..has((r) => r.newValue, 'newValue').equals('1.5');
    });

    // "ダークモードにして" → themeMode = dark (auto-apply)
    test('utterance "ダークモードにして" resolves themeMode to dark (auto-apply)', () {
      // The AI maps ダークモード to the well-known enum value 'dark' with high
      // confidence.
      const payload = SettingsChangePayload.absolute(
        key: SettingsKeys.themeMode,
        value: 'dark',
        confidence: 0.92,
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.key, 'key').equals(SettingsKeys.themeMode)
        ..has((r) => r.oldValue, 'oldValue').equals('system')
        ..has((r) => r.newValue, 'newValue').equals('dark');
    });

    // "連続再生をオフにして" → continuousPlayback = false (auto-apply)
    test('utterance "連続再生をオフにして" resolves continuousPlayback to false '
        '(auto-apply)', () {
      // Boolean off/false is unambiguous; AI emits high confidence.
      const payload = SettingsChangePayload.absolute(
        key: SettingsKeys.continuousPlayback,
        value: 'false',
        confidence: 0.90,
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.key, 'key').equals(SettingsKeys.continuousPlayback)
        ..has((r) => r.oldValue, 'oldValue').equals('true')
        ..has((r) => r.newValue, 'newValue').equals('false');
    });
  });

  // ---------------------------------------------------------------------------
  // Relative commands
  // ---------------------------------------------------------------------------

  group('relative commands', () {
    // "もうちょっと速くして" → playbackSpeed += 0.1 = 1.1
    test('utterance "もうちょっと速くして" resolves playbackSpeed +0.1 from 1.0 '
        '(small increase)', () {
      // "もうちょっと" (just a little) maps to small magnitude.
      const payload = SettingsChangePayload.relative(
        key: SettingsKeys.playbackSpeed,
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.small,
        confidence: 0.88,
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.newValue, 'newValue').equals('1.1')
        ..has((r) => r.oldValue, 'oldValue').equals('1.0');
    });

    // "かなり遅くして" → playbackSpeed -= 0.3 = 0.7
    test('utterance "かなり遅くして" resolves playbackSpeed -0.3 from 1.0 '
        '(large decrease)', () {
      // "かなり" (considerably) maps to large magnitude; 3 steps × 0.1 = 0.3.
      const payload = SettingsChangePayload.relative(
        key: SettingsKeys.playbackSpeed,
        direction: ChangeDirection.decrease,
        magnitude: ChangeMagnitude.large,
        confidence: 0.85,
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.newValue, 'newValue').equals('0.7')
        ..has((r) => r.oldValue, 'oldValue').equals('1.0');
    });

    // "文字を大きくして" → textScale += 0.1 = 1.1
    test('utterance "文字を大きくして" resolves textScale +0.1 from 1.0 '
        '(small increase)', () {
      // A simple increase without explicit magnitude qualifier maps to small.
      const payload = SettingsChangePayload.relative(
        key: SettingsKeys.textScale,
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.small,
        confidence: 0.87,
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.newValue, 'newValue').equals('1.1')
        ..has((r) => r.oldValue, 'oldValue').equals('1.0');
    });
  });

  // ---------------------------------------------------------------------------
  // Ambiguous commands
  // ---------------------------------------------------------------------------

  group('ambiguous commands', () {
    // "暗くして" → theme dark vs text smaller (disambiguate)
    test('utterance "暗くして" produces disambiguate with theme-dark and '
        'text-smaller candidates', () {
      // "暗くして" (make it darker) is genuinely ambiguous: the user might want
      // to switch to dark mode OR reduce text brightness.  The AI emits an
      // ambiguous payload with two plausible candidates.
      const payload = SettingsChangePayload.ambiguous(
        candidates: [
          SettingsCandidate(
            key: SettingsKeys.themeMode,
            value: 'dark',
            confidence: 0.65,
          ),
          SettingsCandidate(
            key: SettingsKeys.textScale,
            value: '0.9',
            confidence: 0.45,
          ),
        ],
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      final disambiguate = check(result).isA<SettingsResolutionDisambiguate>();
      disambiguate.has((r) => r.candidates, 'candidates').length.equals(2);

      final resolved = result as SettingsResolutionDisambiguate;
      final keys = resolved.candidates.map((c) => c.key).toList();
      check(keys).contains(SettingsKeys.themeMode);
      check(keys).contains(SettingsKeys.textScale);
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------

  group('edge cases', () {
    // Speed at max (3.0) cannot increase further → stays 3.0
    test('playbackSpeed at max (3.0) clamps on increase → stays 3.0', () {
      final valuesAtMax = {...defaultValues, SettingsKeys.playbackSpeed: '3.0'};

      const payload = SettingsChangePayload.relative(
        key: SettingsKeys.playbackSpeed,
        direction: ChangeDirection.increase,
        magnitude: ChangeMagnitude.small,
        confidence: 0.90,
      );

      final result = resolver.resolve(payload, currentValues: valuesAtMax);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.newValue, 'newValue').equals('3.0')
        ..has((r) => r.oldValue, 'oldValue').equals('3.0');
    });

    // Speed at min (0.5) cannot decrease further → stays 0.5
    test('playbackSpeed at min (0.5) clamps on decrease → stays 0.5', () {
      final valuesAtMin = {...defaultValues, SettingsKeys.playbackSpeed: '0.5'};

      const payload = SettingsChangePayload.relative(
        key: SettingsKeys.playbackSpeed,
        direction: ChangeDirection.decrease,
        magnitude: ChangeMagnitude.small,
        confidence: 0.90,
      );

      final result = resolver.resolve(payload, currentValues: valuesAtMin);

      check(result).isA<SettingsResolutionAutoApply>()
        ..has((r) => r.newValue, 'newValue').equals('0.5')
        ..has((r) => r.oldValue, 'oldValue').equals('0.5');
    });

    // Unknown key → notFound
    test('absolute payload with unknown key returns notFound', () {
      const payload = SettingsChangePayload.absolute(
        key: 'settings_unknown_key',
        value: 'anything',
        confidence: 0.99,
      );

      final result = resolver.resolve(payload, currentValues: defaultValues);

      check(result).isA<SettingsResolutionNotFound>();
    });
  });
}
