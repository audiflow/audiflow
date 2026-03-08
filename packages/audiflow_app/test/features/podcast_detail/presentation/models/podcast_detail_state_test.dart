import 'package:audiflow_app/features/podcast_detail/presentation/controllers/podcast_detail_controller.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/models/podcast_detail_state.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastDetailViewState', () {
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

    PodcastDetailViewState createState({
      ParsedFeed? feed,
      PodcastViewMode viewMode = PodcastViewMode.episodes,
      EpisodeFilter episodeFilter = EpisodeFilter.all,
      SortOrder episodeSortOrder = SortOrder.descending,
      List<PodcastItem> filteredEpisodes = const [],
      EpisodeProgressMap progressMap = const {},
      List<SmartPlaylist> smartPlaylists = const [],
      bool isSubscribed = false,
      bool hasSmartPlaylistView = false,
    }) {
      return PodcastDetailViewState(
        feed: feed ?? mockFeed,
        viewMode: viewMode,
        episodeFilter: episodeFilter,
        episodeSortOrder: episodeSortOrder,
        filteredEpisodes: filteredEpisodes,
        progressMap: progressMap,
        smartPlaylists: smartPlaylists,
        isSubscribed: isSubscribed,
        hasSmartPlaylistView: hasSmartPlaylistView,
      );
    }

    test('creates with required fields and defaults', () {
      final state = createState();

      expect(state.feed, mockFeed);
      expect(state.viewMode, PodcastViewMode.episodes);
      expect(state.episodeFilter, EpisodeFilter.all);
      expect(state.episodeSortOrder, SortOrder.descending);
      expect(state.filteredEpisodes, isEmpty);
      expect(state.progressMap, isEmpty);
      expect(state.smartPlaylists, isEmpty);
      expect(state.isSubscribed, isFalse);
      expect(state.hasSmartPlaylistView, isFalse);
      expect(state.activePlaylist, isNull);
      expect(state.feedImageUrl, isNull);
      expect(state.subscriptionId, isNull);
      expect(state.pattern, isNull);
    });

    test('copyWith updates fields', () {
      final state = createState();
      final updated = state.copyWith(
        isSubscribed: true,
        subscriptionId: 42,
        viewMode: PodcastViewMode.smartPlaylists,
      );

      expect(updated.isSubscribed, isTrue);
      expect(updated.subscriptionId, 42);
      expect(updated.viewMode, PodcastViewMode.smartPlaylists);
      expect(updated.feed, mockFeed);
    });

    test('equality works for identical values', () {
      final state1 = createState();
      final state2 = createState();

      expect(state1, equals(state2));
    });

    test('equality detects differences', () {
      final state1 = createState();
      final state2 = createState(isSubscribed: true);

      expect(state1, isNot(equals(state2)));
    });
  });
}
