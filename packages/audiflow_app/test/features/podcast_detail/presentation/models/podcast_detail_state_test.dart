import 'package:audiflow_app/features/podcast_detail/presentation/models/podcast_detail_state.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastDetailState', () {
    final mockFeed = ParsedFeed(
      podcast: PodcastFeed.fromData(
        parsedAt: DateTime.now(),
        sourceUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        description: 'Test description',
      ),
      episodes: [],
      errors: [],
      warnings: [],
    );

    test('loaded state has default values', () {
      final state = PodcastDetailState.loaded(feed: mockFeed);

      expect(state.feed, mockFeed);
      expect(state.isRefreshing, isFalse);
      expect(state.refreshProgress, isNull);
      expect(state.refreshError, isNull);
    });

    test('copyWith updates fields', () {
      final state = PodcastDetailState.loaded(feed: mockFeed);
      final updated = state.copyWith(isRefreshing: true, refreshProgress: 50);

      expect(updated.isRefreshing, isTrue);
      expect(updated.refreshProgress, 50);
      expect(updated.feed, mockFeed);
    });

    test('copyWith clears refresh state', () {
      final state = PodcastDetailState.loaded(
        feed: mockFeed,
        isRefreshing: true,
        refreshProgress: 100,
      );
      final cleared = state.copyWith(
        isRefreshing: false,
        refreshProgress: null,
      );

      expect(cleared.isRefreshing, isFalse);
      expect(cleared.refreshProgress, isNull);
    });
  });
}
