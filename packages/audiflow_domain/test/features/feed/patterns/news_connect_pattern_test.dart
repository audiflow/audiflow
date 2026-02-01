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

    test('defines 2 playlists', () {
      final playlists = newsConnectPattern.config['playlists'] as List<dynamic>;
      expect(playlists, hasLength(2));
    });

    test('by_category playlist has 7 groups', () {
      final playlists = newsConnectPattern.config['playlists'] as List<dynamic>;
      final byCategory = playlists[0] as Map<String, dynamic>;
      expect(byCategory['id'], 'by_category');
      final groups = byCategory['groups'] as List<dynamic>;
      expect(groups, hasLength(7));
    });

    test('by_year playlist has 7 groups', () {
      final playlists = newsConnectPattern.config['playlists'] as List<dynamic>;
      final byYear = playlists[1] as Map<String, dynamic>;
      expect(byYear['id'], 'by_year');
      final groups = byYear['groups'] as List<dynamic>;
      expect(groups, hasLength(7));
    });

    test('daily_news group pattern matches date titles', () {
      final playlists = newsConnectPattern.config['playlists'] as List<dynamic>;
      final byCategory = playlists[0] as Map<String, dynamic>;
      final groups = byCategory['groups'] as List<dynamic>;
      final dailyNews = groups[0] as Map<String, dynamic>;
      final pattern = RegExp(dailyNews['pattern'] as String);

      expect(pattern.hasMatch('【1月29日】EU news'), isTrue);
      expect(pattern.hasMatch('【12月5日】morning update'), isTrue);
      expect(pattern.hasMatch('【土曜版 #62】direct prize'), isFalse);
    });

    test('saturday group pattern matches saturday titles', () {
      final playlists = newsConnectPattern.config['playlists'] as List<dynamic>;
      final byCategory = playlists[0] as Map<String, dynamic>;
      final groups = byCategory['groups'] as List<dynamic>;
      final saturday = groups[1] as Map<String, dynamic>;
      final pattern = RegExp(saturday['pattern'] as String);

      expect(pattern.hasMatch('【土曜版 #62】direct prize'), isTrue);
      expect(pattern.hasMatch('【1月29日】EU news'), isFalse);
    });

    test('other group has no pattern', () {
      final playlists = newsConnectPattern.config['playlists'] as List<dynamic>;
      final byCategory = playlists[0] as Map<String, dynamic>;
      final groups = byCategory['groups'] as List<dynamic>;
      final other = groups[6] as Map<String, dynamic>;
      expect(other['id'], 'other');
      expect(other.containsKey('pattern'), isFalse);
    });
  });
}
