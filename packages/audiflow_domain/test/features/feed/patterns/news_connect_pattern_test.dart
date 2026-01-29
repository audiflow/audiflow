import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('newsConnectPattern', () {
    test('matches anchor.fm feed URL with 81fb5eec', () {
      expect(
        newsConnectPattern.matchesPodcast(
          null,
          'https://anchor.fm/s/81fb5eec/podcast/rss',
        ),
        isTrue,
      );
    });

    test('does not match other feed URLs', () {
      expect(
        newsConnectPattern.matchesPodcast(
          null,
          'https://anchor.fm/s/8c2088c/podcast/rss',
        ),
        isFalse,
      );
    });

    test('has category resolver type', () {
      expect(newsConnectPattern.resolverType, 'category');
    });

    test('defines 2 categories', () {
      final categories =
          newsConnectPattern.config['categories'] as List<dynamic>;
      expect(categories, hasLength(2));
    });

    test('daily_news category pattern matches date titles', () {
      final categories =
          newsConnectPattern.config['categories'] as List<dynamic>;
      final dailyNews = categories.first as Map<String, dynamic>;
      final pattern = RegExp(dailyNews['pattern'] as String);

      expect(pattern.hasMatch('【1月29日】EU news'), isTrue);
      expect(pattern.hasMatch('【12月5日】morning update'), isTrue);
      expect(pattern.hasMatch('【土曜版 #62】direct prize'), isFalse);
    });

    test('programs category pattern matches non-date titles', () {
      final categories =
          newsConnectPattern.config['categories'] as List<dynamic>;
      final programs = categories[1] as Map<String, dynamic>;
      final pattern = RegExp(programs['pattern'] as String);

      expect(pattern.hasMatch('【土曜版 #62】direct prize'), isTrue);
      expect(pattern.hasMatch('【ニュース小話 #200】bonds'), isTrue);
      // Should not match date pattern
      expect(pattern.hasMatch('【1月29日】EU news'), isFalse);
    });
  });
}
