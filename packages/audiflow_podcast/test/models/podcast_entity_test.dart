import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_podcast/src/models/podcast_entity.dart';
import '../helpers/test_constants.dart';

class TestPodcastEntity extends PodcastEntity {
  const TestPodcastEntity({required super.parsedAt, required super.sourceUrl});
}

void main() {
  group('PodcastEntity', () {
    test('should create entity with required fields', () {
      final entity = TestPodcastEntity(
        parsedAt: testParsedAt,
        sourceUrl: testSourceUrl,
      );

      expect(entity.parsedAt, testParsedAt);
      expect(entity.sourceUrl, testSourceUrl);
    });
  });
}
