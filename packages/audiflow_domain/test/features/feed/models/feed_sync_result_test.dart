import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedSyncResult', () {
    test('stores all counts', () {
      const result = FeedSyncResult(
        totalCount: 10,
        successCount: 7,
        skipCount: 2,
        errorCount: 1,
      );

      expect(result.totalCount, 10);
      expect(result.successCount, 7);
      expect(result.skipCount, 2);
      expect(result.errorCount, 1);
    });

    test('handles zero counts', () {
      const result = FeedSyncResult(
        totalCount: 0,
        successCount: 0,
        skipCount: 0,
        errorCount: 0,
      );

      expect(result.totalCount, 0);
      expect(result.successCount, 0);
      expect(result.skipCount, 0);
      expect(result.errorCount, 0);
    });

    test('toString includes all fields', () {
      const result = FeedSyncResult(
        totalCount: 5,
        successCount: 3,
        skipCount: 1,
        errorCount: 1,
      );

      final str = result.toString();

      expect(str, contains('total: 5'));
      expect(str, contains('success: 3'));
      expect(str, contains('skip: 1'));
      expect(str, contains('error: 1'));
    });
  });

  group('SingleFeedSyncResult', () {
    test('stores successful result', () {
      const result = SingleFeedSyncResult(
        podcastId: 42,
        success: true,
        skipped: false,
        newEpisodeCount: 5,
      );

      expect(result.podcastId, 42);
      expect(result.success, isTrue);
      expect(result.skipped, isFalse);
      expect(result.newEpisodeCount, 5);
      expect(result.errorMessage, isNull);
    });

    test('stores failed result with error message', () {
      const result = SingleFeedSyncResult(
        podcastId: 7,
        success: false,
        skipped: false,
        errorMessage: 'Network timeout',
      );

      expect(result.podcastId, 7);
      expect(result.success, isFalse);
      expect(result.skipped, isFalse);
      expect(result.newEpisodeCount, isNull);
      expect(result.errorMessage, 'Network timeout');
    });

    test('stores skipped result', () {
      const result = SingleFeedSyncResult(
        podcastId: 99,
        success: true,
        skipped: true,
      );

      expect(result.success, isTrue);
      expect(result.skipped, isTrue);
      expect(result.newEpisodeCount, isNull);
    });

    test('toString includes all fields', () {
      const result = SingleFeedSyncResult(
        podcastId: 1,
        success: true,
        skipped: false,
        newEpisodeCount: 3,
      );

      final str = result.toString();

      expect(str, contains('podcastId: 1'));
      expect(str, contains('success: true'));
      expect(str, contains('skipped: false'));
      expect(str, contains('newEpisodes: 3'));
    });

    test('toString with null newEpisodeCount', () {
      const result = SingleFeedSyncResult(
        podcastId: 2,
        success: false,
        skipped: true,
      );

      final str = result.toString();

      expect(str, contains('newEpisodes: null'));
    });
  });
}
