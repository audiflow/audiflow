import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NowPlayingInfo', () {
    group('construction', () {
      test('creates with required fields only', () {
        final info = NowPlayingInfo(
          episodeUrl: 'https://example.com/ep1.mp3',
          episodeTitle: 'Episode 1',
          podcastTitle: 'My Podcast',
        );

        expect(info.episodeUrl, 'https://example.com/ep1.mp3');
        expect(info.episodeTitle, 'Episode 1');
        expect(info.podcastTitle, 'My Podcast');
        expect(info.artworkUrl, isNull);
        expect(info.totalDuration, isNull);
        expect(info.savedPosition, isNull);
        expect(info.episode, isNull);
      });

      test('creates with all fields', () {
        final info = NowPlayingInfo(
          episodeUrl: 'https://example.com/ep1.mp3',
          episodeTitle: 'Episode 1',
          podcastTitle: 'My Podcast',
          artworkUrl: 'https://example.com/art.jpg',
          totalDuration: const Duration(minutes: 45),
          savedPosition: const Duration(minutes: 10),
        );

        expect(info.artworkUrl, 'https://example.com/art.jpg');
        expect(info.totalDuration, const Duration(minutes: 45));
        expect(info.savedPosition, const Duration(minutes: 10));
      });

      test('accepts empty strings', () {
        final info = NowPlayingInfo(
          episodeUrl: '',
          episodeTitle: '',
          podcastTitle: '',
        );

        expect(info.episodeUrl, '');
        expect(info.episodeTitle, '');
        expect(info.podcastTitle, '');
      });

      test('accepts zero durations', () {
        final info = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
          totalDuration: Duration.zero,
          savedPosition: Duration.zero,
        );

        expect(info.totalDuration, Duration.zero);
        expect(info.savedPosition, Duration.zero);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        final a = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
          artworkUrl: 'art',
          totalDuration: const Duration(seconds: 100),
          savedPosition: const Duration(seconds: 50),
        );
        final b = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
          artworkUrl: 'art',
          totalDuration: const Duration(seconds: 100),
          savedPosition: const Duration(seconds: 50),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when episode URL differs', () {
        final a = NowPlayingInfo(
          episodeUrl: 'url1',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
        );
        final b = NowPlayingInfo(
          episodeUrl: 'url2',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
        );

        expect(a, isNot(equals(b)));
      });

      test('not equal when title differs', () {
        final a = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title1',
          podcastTitle: 'podcast',
        );
        final b = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title2',
          podcastTitle: 'podcast',
        );

        expect(a, isNot(equals(b)));
      });

      test('not equal when artwork differs (null vs value)', () {
        final a = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
        );
        final b = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
          artworkUrl: 'art',
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copies with new episode URL', () {
        final original = NowPlayingInfo(
          episodeUrl: 'old-url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
        );
        final copied = original.copyWith(episodeUrl: 'new-url');

        expect(copied.episodeUrl, 'new-url');
        expect(copied.episodeTitle, 'title');
        expect(copied.podcastTitle, 'podcast');
      });

      test('copies with new artwork URL', () {
        final original = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
        );
        final copied = original.copyWith(artworkUrl: 'new-art');

        expect(copied.artworkUrl, 'new-art');
      });

      test('copies with new durations', () {
        final original = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
        );
        final copied = original.copyWith(
          totalDuration: const Duration(minutes: 30),
          savedPosition: const Duration(minutes: 5),
        );

        expect(copied.totalDuration, const Duration(minutes: 30));
        expect(copied.savedPosition, const Duration(minutes: 5));
      });

      test('returns equal instance when no changes', () {
        final original = NowPlayingInfo(
          episodeUrl: 'url',
          episodeTitle: 'title',
          podcastTitle: 'podcast',
          artworkUrl: 'art',
        );
        final copied = original.copyWith();

        expect(copied, equals(original));
      });
    });
  });
}
