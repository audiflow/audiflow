// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiCapability', () {
    group('enum values', () {
      test('has all required values', () {
        expect(AiCapability.values, hasLength(4));
        expect(AiCapability.values, contains(AiCapability.full));
        expect(AiCapability.values, contains(AiCapability.limited));
        expect(AiCapability.values, contains(AiCapability.unavailable));
        expect(AiCapability.values, contains(AiCapability.needsSetup));
      });
    });

    group('isUsable extension', () {
      test('returns true for full capability', () {
        expect(AiCapability.full.isUsable, isTrue);
      });

      test('returns true for limited capability', () {
        expect(AiCapability.limited.isUsable, isTrue);
      });

      test('returns false for unavailable capability', () {
        expect(AiCapability.unavailable.isUsable, isFalse);
      });

      test('returns false for needsSetup capability', () {
        expect(AiCapability.needsSetup.isUsable, isFalse);
      });
    });

    group('requiresAction extension', () {
      test('returns false for full capability', () {
        expect(AiCapability.full.requiresAction, isFalse);
      });

      test('returns false for limited capability', () {
        expect(AiCapability.limited.requiresAction, isFalse);
      });

      test('returns false for unavailable capability', () {
        expect(AiCapability.unavailable.requiresAction, isFalse);
      });

      test('returns true for needsSetup capability', () {
        expect(AiCapability.needsSetup.requiresAction, isTrue);
      });
    });

    group('description extension', () {
      test('returns correct description for full', () {
        expect(
          AiCapability.full.description,
          equals('Full AI capability available'),
        );
      });

      test('returns correct description for limited', () {
        expect(
          AiCapability.limited.description,
          equals('Limited AI capability'),
        );
      });

      test('returns correct description for unavailable', () {
        expect(
          AiCapability.unavailable.description,
          equals('AI not available on this device'),
        );
      });

      test('returns correct description for needsSetup', () {
        expect(
          AiCapability.needsSetup.description,
          equals('AI requires setup'),
        );
      });
    });
  });
}
