import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_podcast/src/models/podcast_image.dart';

void main() {
  group('PodcastImage', () {
    test('should create image with required URL', () {
      const url = 'https://example.com/image.jpg';
      const image = PodcastImage(url: url);

      expect(image.url, equals(url));
      expect(image.width, isNull);
      expect(image.height, isNull);
      expect(image.title, isNull);
      expect(image.description, isNull);
    });

    test('should create image with all fields', () {
      const url = 'https://example.com/image.jpg';
      const width = 600;
      const height = 600;
      const title = 'Podcast Artwork';
      const description = 'Official podcast cover art';

      const image = PodcastImage(
        url: url,
        width: width,
        height: height,
        title: title,
        description: description,
      );

      expect(image.url, equals(url));
      expect(image.width, equals(width));
      expect(image.height, equals(height));
      expect(image.title, equals(title));
      expect(image.description, equals(description));
    });

    group('size convenience methods', () {
      test('should identify small images correctly', () {
        const smallImages = [
          PodcastImage(url: 'test.jpg', width: 100),
          PodcastImage(url: 'test.jpg', width: 300),
          PodcastImage(url: 'test.jpg', width: 1),
        ];

        for (final image in smallImages) {
          expect(
            image.isSmall,
            isTrue,
            reason: 'Width ${image.width} should be small',
          );
          expect(image.isMedium, isFalse);
          expect(image.isLarge, isFalse);
          expect(image.sizeCategory, equals('small'));
        }
      });

      test('should identify medium images correctly', () {
        const mediumImages = [
          PodcastImage(url: 'test.jpg', width: 301),
          PodcastImage(url: 'test.jpg', width: 450),
          PodcastImage(url: 'test.jpg', width: 600),
        ];

        for (final image in mediumImages) {
          expect(image.isSmall, isFalse);
          expect(
            image.isMedium,
            isTrue,
            reason: 'Width ${image.width} should be medium',
          );
          expect(image.isLarge, isFalse);
          expect(image.sizeCategory, equals('medium'));
        }
      });

      test('should identify large images correctly', () {
        const largeImages = [
          PodcastImage(url: 'test.jpg', width: 601),
          PodcastImage(url: 'test.jpg', width: 1200),
          PodcastImage(url: 'test.jpg', width: 3000),
        ];

        for (final image in largeImages) {
          expect(image.isSmall, isFalse);
          expect(image.isMedium, isFalse);
          expect(
            image.isLarge,
            isTrue,
            reason: 'Width ${image.width} should be large',
          );
          expect(image.sizeCategory, equals('large'));
        }
      });

      test('should handle unknown size when width is null', () {
        const image = PodcastImage(url: 'test.jpg');

        expect(image.isSmall, isFalse);
        expect(image.isMedium, isFalse);
        expect(image.isLarge, isFalse);
        expect(image.sizeCategory, equals('unknown'));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all fields match', () {
        const image1 = PodcastImage(
          url: 'https://example.com/image.jpg',
          width: 600,
          height: 600,
          title: 'Test',
          description: 'Test description',
        );

        const image2 = PodcastImage(
          url: 'https://example.com/image.jpg',
          width: 600,
          height: 600,
          title: 'Test',
          description: 'Test description',
        );

        expect(image1, equals(image2));
        expect(image1.hashCode, equals(image2.hashCode));
      });

      test('should not be equal when URLs differ', () {
        const image1 = PodcastImage(url: 'https://example.com/image1.jpg');
        const image2 = PodcastImage(url: 'https://example.com/image2.jpg');

        expect(image1, isNot(equals(image2)));
      });

      test('should not be equal when dimensions differ', () {
        const image1 = PodcastImage(url: 'test.jpg', width: 600, height: 600);
        const image2 = PodcastImage(url: 'test.jpg', width: 300, height: 300);

        expect(image1, isNot(equals(image2)));
      });
    });

    test('should have meaningful toString representation', () {
      const url = 'https://example.com/image.jpg';
      const width = 600;
      const height = 600;
      const title = 'Test Image';
      const description = 'A test image';

      const image = PodcastImage(
        url: url,
        width: width,
        height: height,
        title: title,
        description: description,
      );

      final string = image.toString();
      expect(string, contains('PodcastImage'));
      expect(string, contains(url));
      expect(string, contains(width.toString()));
      expect(string, contains(title));
      expect(string, contains(description));
    });
  });
}
