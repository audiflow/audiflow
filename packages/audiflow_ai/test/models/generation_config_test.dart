// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenerationConfig', () {
    group('constructor', () {
      test('creates instance with default values', () {
        const config = GenerationConfig();

        expect(config.temperature, equals(0.7));
        expect(config.maxOutputTokens, isNull);
        expect(config.stopSequences, isNull);
      });

      test('creates instance with custom temperature', () {
        const config = GenerationConfig(temperature: 0.5);

        expect(config.temperature, equals(0.5));
      });

      test('creates instance with maxOutputTokens', () {
        const config = GenerationConfig(maxOutputTokens: 256);

        expect(config.maxOutputTokens, equals(256));
      });

      test('creates instance with stopSequences', () {
        const config = GenerationConfig(stopSequences: ['END', 'STOP']);

        expect(config.stopSequences, equals(['END', 'STOP']));
      });

      test('creates instance with all parameters', () {
        const config = GenerationConfig(
          temperature: 0.9,
          maxOutputTokens: 512,
          stopSequences: ['END'],
        );

        expect(config.temperature, equals(0.9));
        expect(config.maxOutputTokens, equals(512));
        expect(config.stopSequences, equals(['END']));
      });
    });

    group('toMap', () {
      test('includes temperature', () {
        const config = GenerationConfig(temperature: 0.8);
        final map = config.toMap();

        expect(map['temperature'], equals(0.8));
      });

      test('excludes maxOutputTokens when null', () {
        const config = GenerationConfig();
        final map = config.toMap();

        expect(map.containsKey('maxOutputTokens'), isFalse);
      });

      test('includes maxOutputTokens when set', () {
        const config = GenerationConfig(maxOutputTokens: 256);
        final map = config.toMap();

        expect(map['maxOutputTokens'], equals(256));
      });

      test('excludes stopSequences when null', () {
        const config = GenerationConfig();
        final map = config.toMap();

        expect(map.containsKey('stopSequences'), isFalse);
      });

      test('includes stopSequences when set', () {
        const config = GenerationConfig(stopSequences: ['END']);
        final map = config.toMap();

        expect(map['stopSequences'], equals(['END']));
      });

      test('returns complete map with all values', () {
        const config = GenerationConfig(
          temperature: 0.6,
          maxOutputTokens: 128,
          stopSequences: ['STOP', 'END'],
        );
        final map = config.toMap();

        expect(map, {
          'temperature': 0.6,
          'maxOutputTokens': 128,
          'stopSequences': ['STOP', 'END'],
        });
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const config1 = GenerationConfig(
          maxOutputTokens: 256,
        );
        const config2 = GenerationConfig(
          maxOutputTokens: 256,
        );

        expect(config1, equals(config2));
      });

      test('different temperature makes instances unequal', () {
        const config1 = GenerationConfig();
        const config2 = GenerationConfig(temperature: 0.8);

        expect(config1, isNot(equals(config2)));
      });

      test('different maxOutputTokens makes instances unequal', () {
        const config1 = GenerationConfig(maxOutputTokens: 256);
        const config2 = GenerationConfig(maxOutputTokens: 512);

        expect(config1, isNot(equals(config2)));
      });

      test('identical instance is equal to itself', () {
        const config = GenerationConfig();

        expect(config, equals(config));
      });
    });

    group('hashCode', () {
      test('equal instances have same hashCode', () {
        const config1 = GenerationConfig(
          maxOutputTokens: 256,
        );
        const config2 = GenerationConfig(
          maxOutputTokens: 256,
        );

        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('different instances may have different hashCodes', () {
        const config1 = GenerationConfig();
        const config2 = GenerationConfig(temperature: 0.8);

        // Note: Hash codes are not guaranteed to be different,
        // but for these values they should be
        expect(config1.hashCode, isNot(equals(config2.hashCode)));
      });
    });
  });
}
