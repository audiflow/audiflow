import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart' show PodcastViewMode;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shouldFetchRemote', () {
    test('returns false when offline', () {
      expect(
        shouldFetchRemote(lastFetchedAt: DateTime.now(), isOnline: false),
        isFalse,
      );
    });

    test('returns true when never fetched', () {
      expect(shouldFetchRemote(lastFetchedAt: null, isOnline: true), isTrue);
    });

    test('returns false within refresh window', () {
      final recentFetch = DateTime.now().subtract(const Duration(minutes: 5));
      expect(
        shouldFetchRemote(lastFetchedAt: recentFetch, isOnline: true),
        isFalse,
      );
    });

    test('returns true after refresh window', () {
      final oldFetch = DateTime.now().subtract(const Duration(minutes: 15));
      expect(
        shouldFetchRemote(lastFetchedAt: oldFetch, isOnline: true),
        isTrue,
      );
    });
  });

  group('shouldShowSmartPlaylistToggle', () {
    test('hides toggle when no display playlists exist', () {
      expect(
        shouldShowSmartPlaylistToggle(
          hasPattern: false,
          displayPlaylistsCount: 0,
        ),
        isFalse,
      );
      expect(
        shouldShowSmartPlaylistToggle(
          hasPattern: true,
          displayPlaylistsCount: 0,
        ),
        isFalse,
      );
    });

    test('hides toggle for auto-detect single bucket', () {
      expect(
        shouldShowSmartPlaylistToggle(
          hasPattern: false,
          displayPlaylistsCount: 1,
        ),
        isFalse,
      );
    });

    test('shows toggle for pattern-driven single bucket', () {
      expect(
        shouldShowSmartPlaylistToggle(
          hasPattern: true,
          displayPlaylistsCount: 1,
        ),
        isTrue,
      );
    });

    test(
      'shows toggle for multiple display playlists regardless of pattern',
      () {
        expect(
          shouldShowSmartPlaylistToggle(
            hasPattern: false,
            displayPlaylistsCount: 2,
          ),
          isTrue,
        );
        expect(
          shouldShowSmartPlaylistToggle(
            hasPattern: true,
            displayPlaylistsCount: 3,
          ),
          isTrue,
        );
      },
    );
  });

  group('effectivePodcastViewMode', () {
    test('coerces to episodes when toggle is hidden', () {
      expect(
        effectivePodcastViewMode(
          preferredMode: PodcastViewMode.smartPlaylists,
          showPlaylistToggle: false,
        ),
        PodcastViewMode.episodes,
      );
      expect(
        effectivePodcastViewMode(
          preferredMode: PodcastViewMode.episodes,
          showPlaylistToggle: false,
        ),
        PodcastViewMode.episodes,
      );
    });

    test('honours preferred mode when toggle is visible', () {
      expect(
        effectivePodcastViewMode(
          preferredMode: PodcastViewMode.smartPlaylists,
          showPlaylistToggle: true,
        ),
        PodcastViewMode.smartPlaylists,
      );
      expect(
        effectivePodcastViewMode(
          preferredMode: PodcastViewMode.episodes,
          showPlaylistToggle: true,
        ),
        PodcastViewMode.episodes,
      );
    });
  });
}
