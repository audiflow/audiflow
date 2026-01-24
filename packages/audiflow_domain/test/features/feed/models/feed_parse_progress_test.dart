import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedParseProgress', () {
    test('FeedMetaReady holds metadata', () {
      final meta = FeedMetaReady(
        title: 'Test Podcast',
        description: 'A test',
        imageUrl: 'https://example.com/img.jpg',
      );

      expect(meta.title, 'Test Podcast');
      expect(meta.description, 'A test');
      expect(meta.imageUrl, 'https://example.com/img.jpg');
    });

    test('EpisodesBatchStored reports progress', () {
      final batch = EpisodesBatchStored(totalSoFar: 40);
      expect(batch.totalSoFar, 40);
    });

    test('FeedParseComplete reports final stats', () {
      final complete = FeedParseComplete(total: 100, stoppedEarly: true);

      expect(complete.total, 100);
      expect(complete.stoppedEarly, isTrue);
    });

    test('exhaustive switch works', () {
      FeedParseProgress progress = FeedParseComplete(
        total: 1,
        stoppedEarly: false,
      );

      final result = switch (progress) {
        FeedMetaReady() => 'meta',
        EpisodesBatchStored() => 'batch',
        FeedParseComplete() => 'complete',
      };

      expect(result, 'complete');
    });
  });
}
