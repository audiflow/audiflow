// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SummarizationStyle', () {
    test('has all required values', () {
      expect(SummarizationStyle.values, hasLength(3));
      expect(SummarizationStyle.values, contains(SummarizationStyle.concise));
      expect(SummarizationStyle.values, contains(SummarizationStyle.detailed));
      expect(
        SummarizationStyle.values,
        contains(SummarizationStyle.bulletPoints),
      );
    });
  });

  group('SummarizationConfig', () {
    group('constructor', () {
      test('creates instance with default values', () {
        const config = SummarizationConfig();

        expect(config.maxLength, equals(200));
        expect(config.style, equals(SummarizationStyle.concise));
        expect(config.includeBulletPoints, isFalse);
      });

      test('creates instance with custom maxLength', () {
        const config = SummarizationConfig(maxLength: 500);

        expect(config.maxLength, equals(500));
      });

      test('creates instance with detailed style', () {
        const config = SummarizationConfig(style: SummarizationStyle.detailed);

        expect(config.style, equals(SummarizationStyle.detailed));
      });

      test('creates instance with bulletPoints style', () {
        const config = SummarizationConfig(
          style: SummarizationStyle.bulletPoints,
        );

        expect(config.style, equals(SummarizationStyle.bulletPoints));
      });

      test('creates instance with includeBulletPoints true', () {
        const config = SummarizationConfig(includeBulletPoints: true);

        expect(config.includeBulletPoints, isTrue);
      });

      test('creates instance with all custom parameters', () {
        const config = SummarizationConfig(
          maxLength: 300,
          style: SummarizationStyle.detailed,
          includeBulletPoints: true,
        );

        expect(config.maxLength, equals(300));
        expect(config.style, equals(SummarizationStyle.detailed));
        expect(config.includeBulletPoints, isTrue);
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const config1 = SummarizationConfig(
          maxLength: 200,
          style: SummarizationStyle.concise,
          includeBulletPoints: false,
        );
        const config2 = SummarizationConfig(
          maxLength: 200,
          style: SummarizationStyle.concise,
          includeBulletPoints: false,
        );

        expect(config1, equals(config2));
      });

      test('default instances are equal', () {
        const config1 = SummarizationConfig();
        const config2 = SummarizationConfig();

        expect(config1, equals(config2));
      });

      test('different maxLength makes instances unequal', () {
        const config1 = SummarizationConfig(maxLength: 200);
        const config2 = SummarizationConfig(maxLength: 300);

        expect(config1, isNot(equals(config2)));
      });

      test('different style makes instances unequal', () {
        const config1 = SummarizationConfig(style: SummarizationStyle.concise);
        const config2 = SummarizationConfig(style: SummarizationStyle.detailed);

        expect(config1, isNot(equals(config2)));
      });

      test('different includeBulletPoints makes instances unequal', () {
        const config1 = SummarizationConfig(includeBulletPoints: false);
        const config2 = SummarizationConfig(includeBulletPoints: true);

        expect(config1, isNot(equals(config2)));
      });

      test('identical instance is equal to itself', () {
        const config = SummarizationConfig();

        expect(config, equals(config));
      });
    });

    group('hashCode', () {
      test('equal instances have same hashCode', () {
        const config1 = SummarizationConfig(
          maxLength: 200,
          style: SummarizationStyle.concise,
          includeBulletPoints: false,
        );
        const config2 = SummarizationConfig(
          maxLength: 200,
          style: SummarizationStyle.concise,
          includeBulletPoints: false,
        );

        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('different instances may have different hashCodes', () {
        const config1 = SummarizationConfig(maxLength: 200);
        const config2 = SummarizationConfig(maxLength: 500);

        expect(config1.hashCode, isNot(equals(config2.hashCode)));
      });
    });
  });
}
