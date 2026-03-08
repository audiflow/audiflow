import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackState', () {
    group('idle', () {
      test('creates idle state', () {
        const state = PlaybackState.idle();
        expect(state, isA<PlaybackIdle>());
      });

      test('two idle states are equal', () {
        const a = PlaybackState.idle();
        const b = PlaybackState.idle();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('loading', () {
      test('holds episode URL', () {
        const state = PlaybackState.loading(
          episodeUrl: 'https://example.com/ep1.mp3',
        );
        expect(state, isA<PlaybackLoading>());
        expect(
          (state as PlaybackLoading).episodeUrl,
          'https://example.com/ep1.mp3',
        );
      });

      test('two loading states with same URL are equal', () {
        const a = PlaybackState.loading(episodeUrl: 'url');
        const b = PlaybackState.loading(episodeUrl: 'url');
        expect(a, equals(b));
      });

      test('two loading states with different URLs are not equal', () {
        const a = PlaybackState.loading(episodeUrl: 'url1');
        const b = PlaybackState.loading(episodeUrl: 'url2');
        expect(a, isNot(equals(b)));
      });

      test('accepts empty string URL', () {
        const state = PlaybackState.loading(episodeUrl: '');
        expect((state as PlaybackLoading).episodeUrl, '');
      });
    });

    group('playing', () {
      test('holds episode URL', () {
        const state = PlaybackState.playing(
          episodeUrl: 'https://example.com/ep1.mp3',
        );
        expect(state, isA<PlaybackPlaying>());
        expect(
          (state as PlaybackPlaying).episodeUrl,
          'https://example.com/ep1.mp3',
        );
      });

      test('is not equal to loading with same URL', () {
        const playing = PlaybackState.playing(episodeUrl: 'url');
        const loading = PlaybackState.loading(episodeUrl: 'url');
        expect(playing, isNot(equals(loading)));
      });
    });

    group('paused', () {
      test('holds episode URL', () {
        const state = PlaybackState.paused(
          episodeUrl: 'https://example.com/ep1.mp3',
        );
        expect(state, isA<PlaybackPaused>());
        expect(
          (state as PlaybackPaused).episodeUrl,
          'https://example.com/ep1.mp3',
        );
      });

      test('is not equal to playing with same URL', () {
        const paused = PlaybackState.paused(episodeUrl: 'url');
        const playing = PlaybackState.playing(episodeUrl: 'url');
        expect(paused, isNot(equals(playing)));
      });
    });

    group('error', () {
      test('holds error message', () {
        const state = PlaybackState.error(message: 'Network error');
        expect(state, isA<PlaybackError>());
        expect((state as PlaybackError).message, 'Network error');
      });

      test('accepts empty message', () {
        const state = PlaybackState.error(message: '');
        expect((state as PlaybackError).message, '');
      });

      test('two errors with same message are equal', () {
        const a = PlaybackState.error(message: 'fail');
        const b = PlaybackState.error(message: 'fail');
        expect(a, equals(b));
      });

      test('two errors with different messages are not equal', () {
        const a = PlaybackState.error(message: 'fail1');
        const b = PlaybackState.error(message: 'fail2');
        expect(a, isNot(equals(b)));
      });
    });

    group('pattern matching', () {
      test('exhaustive switch covers all variants', () {
        const states = <PlaybackState>[
          PlaybackState.idle(),
          PlaybackState.loading(episodeUrl: 'url'),
          PlaybackState.playing(episodeUrl: 'url'),
          PlaybackState.paused(episodeUrl: 'url'),
          PlaybackState.error(message: 'err'),
        ];

        final results = states.map((state) {
          return switch (state) {
            PlaybackIdle() => 'idle',
            PlaybackLoading() => 'loading',
            PlaybackPlaying() => 'playing',
            PlaybackPaused() => 'paused',
            PlaybackError() => 'error',
          };
        }).toList();

        expect(results, ['idle', 'loading', 'playing', 'paused', 'error']);
      });

      test('destructuring extracts fields', () {
        const PlaybackState state = PlaybackState.playing(
          episodeUrl: 'test.mp3',
        );

        final url = switch (state) {
          PlaybackLoading(:final episodeUrl) => episodeUrl,
          PlaybackPlaying(:final episodeUrl) => episodeUrl,
          PlaybackPaused(:final episodeUrl) => episodeUrl,
          _ => null,
        };

        expect(url, 'test.mp3');
      });
    });

    group('copyWith', () {
      test('copies loading with new URL', () {
        const original = PlaybackState.loading(episodeUrl: 'old');
        final copied = (original as PlaybackLoading).copyWith(
          episodeUrl: 'new',
        );
        expect(copied.episodeUrl, 'new');
      });

      test('copies error with new message', () {
        const original = PlaybackState.error(message: 'old');
        final copied = (original as PlaybackError).copyWith(message: 'new');
        expect(copied.message, 'new');
      });
    });
  });
}
