// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeSummary', () {
    group('constructor', () {
      test('creates instance with required parameters', () {
        const summary = EpisodeSummary(
          summary: 'This is a summary',
          keyTopics: ['Topic 1', 'Topic 2'],
        );

        expect(summary.summary, equals('This is a summary'));
        expect(summary.keyTopics, equals(['Topic 1', 'Topic 2']));
        expect(summary.estimatedListeningMinutes, isNull);
      });

      test('creates instance with all parameters', () {
        const summary = EpisodeSummary(
          summary: 'This is a summary',
          keyTopics: ['Topic 1', 'Topic 2'],
          estimatedListeningMinutes: 45,
        );

        expect(summary.summary, equals('This is a summary'));
        expect(summary.keyTopics, equals(['Topic 1', 'Topic 2']));
        expect(summary.estimatedListeningMinutes, equals(45));
      });

      test('creates instance with empty key topics', () {
        const summary = EpisodeSummary(
          summary: 'Summary without topics',
          keyTopics: [],
        );

        expect(summary.keyTopics, isEmpty);
      });

      test('creates instance with empty summary', () {
        const summary = EpisodeSummary(
          summary: '',
          keyTopics: ['Topic'],
        );

        expect(summary.summary, isEmpty);
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const summary1 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1', 'Topic 2'],
          estimatedListeningMinutes: 30,
        );
        const summary2 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1', 'Topic 2'],
          estimatedListeningMinutes: 30,
        );

        expect(summary1, equals(summary2));
      });

      test('different summary makes instances unequal', () {
        const summary1 = EpisodeSummary(
          summary: 'Summary 1',
          keyTopics: ['Topic'],
        );
        const summary2 = EpisodeSummary(
          summary: 'Summary 2',
          keyTopics: ['Topic'],
        );

        expect(summary1, isNot(equals(summary2)));
      });

      test('different keyTopics makes instances unequal', () {
        const summary1 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1'],
        );
        const summary2 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 2'],
        );

        expect(summary1, isNot(equals(summary2)));
      });

      test('different keyTopics order makes instances unequal', () {
        const summary1 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1', 'Topic 2'],
        );
        const summary2 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 2', 'Topic 1'],
        );

        expect(summary1, isNot(equals(summary2)));
      });

      test('different keyTopics length makes instances unequal', () {
        const summary1 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1'],
        );
        const summary2 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1', 'Topic 2'],
        );

        expect(summary1, isNot(equals(summary2)));
      });

      test('different estimatedListeningMinutes makes instances unequal', () {
        const summary1 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: [],
          estimatedListeningMinutes: 30,
        );
        const summary2 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: [],
          estimatedListeningMinutes: 45,
        );

        expect(summary1, isNot(equals(summary2)));
      });

      test('identical instance is equal to itself', () {
        const summary = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic'],
        );

        expect(summary, equals(summary));
      });
    });

    group('hashCode', () {
      test('equal instances have same hashCode', () {
        const summary1 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1', 'Topic 2'],
          estimatedListeningMinutes: 30,
        );
        const summary2 = EpisodeSummary(
          summary: 'Summary',
          keyTopics: ['Topic 1', 'Topic 2'],
          estimatedListeningMinutes: 30,
        );

        expect(summary1.hashCode, equals(summary2.hashCode));
      });
    });

    group('toString', () {
      test('returns formatted string with all values', () {
        const summary = EpisodeSummary(
          summary: 'A short summary',
          keyTopics: ['Tech', 'AI'],
          estimatedListeningMinutes: 60,
        );

        expect(
          summary.toString(),
          equals(
            'EpisodeSummary(summary: 15 chars, keyTopics: 2, '
            'estimatedListeningMinutes: 60)',
          ),
        );
      });

      test('returns formatted string with null listening minutes', () {
        const summary = EpisodeSummary(
          summary: 'Test',
          keyTopics: [],
        );

        expect(
          summary.toString(),
          equals(
            'EpisodeSummary(summary: 4 chars, keyTopics: 0, '
            'estimatedListeningMinutes: null)',
          ),
        );
      });
    });
  });
}
