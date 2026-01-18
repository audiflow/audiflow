import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_podcast/src/models/podcast_chapter.dart';

void main() {
  group('PodcastChapter', () {
    test('should create chapter with required fields', () {
      const title = 'Introduction';
      const startTime = Duration(minutes: 5);

      const chapter = PodcastChapter(title: title, startTime: startTime);

      expect(chapter.title, equals(title));
      expect(chapter.startTime, equals(startTime));
      expect(chapter.endTime, isNull);
      expect(chapter.url, isNull);
      expect(chapter.imageUrl, isNull);
    });

    test('should create chapter with all fields', () {
      const title = 'Chapter 1: Getting Started';
      const startTime = Duration(minutes: 2, seconds: 30);
      const endTime = Duration(minutes: 10, seconds: 15);
      const url = 'https://example.com/chapter1';
      const imageUrl = 'https://example.com/chapter1.jpg';

      const chapter = PodcastChapter(
        title: title,
        startTime: startTime,
        endTime: endTime,
        url: url,
        imageUrl: imageUrl,
      );

      expect(chapter.title, equals(title));
      expect(chapter.startTime, equals(startTime));
      expect(chapter.endTime, equals(endTime));
      expect(chapter.url, equals(url));
      expect(chapter.imageUrl, equals(imageUrl));
    });

    group('duration calculation', () {
      test('should calculate duration when end time is provided', () {
        const chapter = PodcastChapter(
          title: 'Test Chapter',
          startTime: Duration(minutes: 5),
          endTime: Duration(minutes: 10, seconds: 30),
        );

        expect(
          chapter.duration,
          equals(const Duration(minutes: 5, seconds: 30)),
        );
      });

      test('should return null duration when end time is not provided', () {
        const chapter = PodcastChapter(
          title: 'Test Chapter',
          startTime: Duration(minutes: 5),
        );

        expect(chapter.duration, isNull);
      });

      test('should handle zero duration', () {
        const chapter = PodcastChapter(
          title: 'Test Chapter',
          startTime: Duration(minutes: 5),
          endTime: Duration(minutes: 5),
        );

        expect(chapter.duration, equals(Duration.zero));
      });
    });

    group('convenience getters', () {
      test('should correctly identify if chapter has end time', () {
        const chapterWithEnd = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
          endTime: Duration(minutes: 2),
        );

        const chapterWithoutEnd = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
        );

        expect(chapterWithEnd.hasEndTime, isTrue);
        expect(chapterWithoutEnd.hasEndTime, isFalse);
      });

      test('should correctly identify if chapter has URL', () {
        const chapterWithUrl = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
          url: 'https://example.com',
        );

        const chapterWithEmptyUrl = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
          url: '',
        );

        const chapterWithoutUrl = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
        );

        expect(chapterWithUrl.hasUrl, isTrue);
        expect(chapterWithEmptyUrl.hasUrl, isFalse);
        expect(chapterWithoutUrl.hasUrl, isFalse);
      });

      test('should correctly identify if chapter has image', () {
        const chapterWithImage = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
          imageUrl: 'https://example.com/image.jpg',
        );

        const chapterWithEmptyImage = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
          imageUrl: '',
        );

        const chapterWithoutImage = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 1),
        );

        expect(chapterWithImage.hasImage, isTrue);
        expect(chapterWithEmptyImage.hasImage, isFalse);
        expect(chapterWithoutImage.hasImage, isFalse);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const chapter1 = PodcastChapter(
          title: 'Test Chapter',
          startTime: Duration(minutes: 5),
          endTime: Duration(minutes: 10),
          url: 'https://example.com',
          imageUrl: 'https://example.com/image.jpg',
        );

        const chapter2 = PodcastChapter(
          title: 'Test Chapter',
          startTime: Duration(minutes: 5),
          endTime: Duration(minutes: 10),
          url: 'https://example.com',
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(chapter1, equals(chapter2));
        expect(chapter1.hashCode, equals(chapter2.hashCode));
      });

      test('should not be equal when titles differ', () {
        const chapter1 = PodcastChapter(
          title: 'Chapter 1',
          startTime: Duration(minutes: 5),
        );

        const chapter2 = PodcastChapter(
          title: 'Chapter 2',
          startTime: Duration(minutes: 5),
        );

        expect(chapter1, isNot(equals(chapter2)));
      });

      test('should not be equal when start times differ', () {
        const chapter1 = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 5),
        );

        const chapter2 = PodcastChapter(
          title: 'Test',
          startTime: Duration(minutes: 10),
        );

        expect(chapter1, isNot(equals(chapter2)));
      });
    });

    test('should have meaningful toString representation', () {
      const title = 'Test Chapter';
      const startTime = Duration(minutes: 5);
      const endTime = Duration(minutes: 10);
      const url = 'https://example.com';
      const imageUrl = 'https://example.com/image.jpg';

      const chapter = PodcastChapter(
        title: title,
        startTime: startTime,
        endTime: endTime,
        url: url,
        imageUrl: imageUrl,
      );

      final string = chapter.toString();
      expect(string, contains('PodcastChapter'));
      expect(string, contains(title));
      expect(string, contains(startTime.toString()));
      expect(string, contains(endTime.toString()));
      expect(string, contains(url));
      expect(string, contains(imageUrl));
    });
  });
}
