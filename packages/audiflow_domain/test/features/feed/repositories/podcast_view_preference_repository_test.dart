import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/feed/datasources/local/podcast_view_preference_local_datasource.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PodcastViewPreferenceLocalDatasource datasource;
  late PodcastViewPreferenceRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = PodcastViewPreferenceLocalDatasource(db);
    repository = PodcastViewPreferenceRepositoryImpl(datasource);

    // Insert a test subscription for foreign key constraint
    await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'itunes-1',
            feedUrl: 'https://example.com/feed.xml',
            title: 'Test Podcast',
            artistName: 'Test Artist',
            subscribedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('getPreference', () {
    test('returns defaults for non-existent podcast', () async {
      final pref = await repository.getPreference(1);

      expect(pref.podcastId, 1);
      expect(pref.viewMode, PodcastViewMode.episodes);
      expect(pref.episodeFilter, EpisodeFilter.all);
      expect(pref.episodeSortOrder, SortOrder.descending);
    });

    test('returns stored preference when exists', () async {
      // First, store some preferences
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);
      await repository.updateEpisodeFilter(1, EpisodeFilter.unplayed);
      await repository.updateEpisodeSortOrder(1, SortOrder.ascending);

      final pref = await repository.getPreference(1);

      expect(pref.podcastId, 1);
      expect(pref.viewMode, PodcastViewMode.smartPlaylists);
      expect(pref.episodeFilter, EpisodeFilter.unplayed);
      expect(pref.episodeSortOrder, SortOrder.ascending);
    });
  });

  group('updateViewMode', () {
    test('persists episodes mode', () async {
      await repository.updateViewMode(1, PodcastViewMode.episodes);
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.episodes);
    });

    test('persists seasons mode', () async {
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.smartPlaylists);
    });

    test('does not affect other preferences', () async {
      await repository.updateEpisodeFilter(1, EpisodeFilter.inProgress);
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.smartPlaylists);
      expect(pref.episodeFilter, EpisodeFilter.inProgress);
    });
  });

  group('updateEpisodeFilter', () {
    test('persists all filter', () async {
      await repository.updateEpisodeFilter(1, EpisodeFilter.all);
      final pref = await repository.getPreference(1);

      expect(pref.episodeFilter, EpisodeFilter.all);
    });

    test('persists unplayed filter', () async {
      await repository.updateEpisodeFilter(1, EpisodeFilter.unplayed);
      final pref = await repository.getPreference(1);

      expect(pref.episodeFilter, EpisodeFilter.unplayed);
    });

    test('persists inProgress filter', () async {
      await repository.updateEpisodeFilter(1, EpisodeFilter.inProgress);
      final pref = await repository.getPreference(1);

      expect(pref.episodeFilter, EpisodeFilter.inProgress);
    });

    test('does not affect other preferences', () async {
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);
      await repository.updateEpisodeFilter(1, EpisodeFilter.unplayed);
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.smartPlaylists);
      expect(pref.episodeFilter, EpisodeFilter.unplayed);
    });
  });

  group('updateEpisodeSortOrder', () {
    test('persists ascending order', () async {
      await repository.updateEpisodeSortOrder(1, SortOrder.ascending);
      final pref = await repository.getPreference(1);

      expect(pref.episodeSortOrder, SortOrder.ascending);
    });

    test('persists descending order', () async {
      await repository.updateEpisodeSortOrder(1, SortOrder.descending);
      final pref = await repository.getPreference(1);

      expect(pref.episodeSortOrder, SortOrder.descending);
    });

    test('does not affect other preferences', () async {
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);
      await repository.updateEpisodeFilter(1, EpisodeFilter.inProgress);
      await repository.updateEpisodeSortOrder(1, SortOrder.ascending);
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.smartPlaylists);
      expect(pref.episodeFilter, EpisodeFilter.inProgress);
      expect(pref.episodeSortOrder, SortOrder.ascending);
    });
  });

  group('watchPreference', () {
    test('emits defaults initially when no preference exists', () async {
      final stream = repository.watchPreference(1);
      final pref = await stream.first;

      expect(pref.podcastId, 1);
      expect(pref.viewMode, PodcastViewMode.episodes);
      expect(pref.episodeFilter, EpisodeFilter.all);
      expect(pref.episodeSortOrder, SortOrder.descending);
    });

    test('emits updates when view mode changes', () async {
      // Collect emitted values
      final emissions = <PodcastViewPreferenceData>[];
      final subscription = repository.watchPreference(1).listen(emissions.add);

      // Wait for initial emission
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Update view mode
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);

      // Wait for update emission
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      expect(emissions.length, 2);
      expect(emissions[0].viewMode, PodcastViewMode.episodes);
      expect(emissions[1].viewMode, PodcastViewMode.smartPlaylists);
    });

    test('emits updates when episode filter changes', () async {
      final emissions = <PodcastViewPreferenceData>[];
      final subscription = repository.watchPreference(1).listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.updateEpisodeFilter(1, EpisodeFilter.unplayed);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      expect(emissions.length, 2);
      expect(emissions[0].episodeFilter, EpisodeFilter.all);
      expect(emissions[1].episodeFilter, EpisodeFilter.unplayed);
    });

    test('emits updates when sort order changes', () async {
      final emissions = <PodcastViewPreferenceData>[];
      final subscription = repository.watchPreference(1).listen(emissions.add);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repository.updateEpisodeSortOrder(1, SortOrder.ascending);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await subscription.cancel();

      expect(emissions.length, 2);
      expect(emissions[0].episodeSortOrder, SortOrder.descending);
      expect(emissions[1].episodeSortOrder, SortOrder.ascending);
    });
  });

  group('updateSmartPlaylistSort', () {
    test('persists playlistNumber field with ascending order', () async {
      await repository.updateSmartPlaylistSort(
        1,
        SmartPlaylistSortField.playlistNumber,
        SortOrder.ascending,
      );
      final pref = await repository.getPreference(1);

      expect(
        pref.smartPlaylistSortField,
        SmartPlaylistSortField.playlistNumber,
      );
      expect(pref.smartPlaylistSortOrder, SortOrder.ascending);
    });

    test('persists newestEpisodeDate field with descending order', () async {
      await repository.updateSmartPlaylistSort(
        1,
        SmartPlaylistSortField.newestEpisodeDate,
        SortOrder.descending,
      );
      final pref = await repository.getPreference(1);

      expect(
        pref.smartPlaylistSortField,
        SmartPlaylistSortField.newestEpisodeDate,
      );
      expect(pref.smartPlaylistSortOrder, SortOrder.descending);
    });

    test('persists progress field', () async {
      await repository.updateSmartPlaylistSort(
        1,
        SmartPlaylistSortField.progress,
        SortOrder.ascending,
      );
      final pref = await repository.getPreference(1);

      expect(pref.smartPlaylistSortField, SmartPlaylistSortField.progress);
    });

    test('persists alphabetical field', () async {
      await repository.updateSmartPlaylistSort(
        1,
        SmartPlaylistSortField.alphabetical,
        SortOrder.ascending,
      );
      final pref = await repository.getPreference(1);

      expect(pref.smartPlaylistSortField, SmartPlaylistSortField.alphabetical);
    });

    test('does not affect other preferences', () async {
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);
      await repository.updateEpisodeFilter(1, EpisodeFilter.unplayed);
      await repository.updateSmartPlaylistSort(
        1,
        SmartPlaylistSortField.newestEpisodeDate,
        SortOrder.ascending,
      );
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.smartPlaylists);
      expect(pref.episodeFilter, EpisodeFilter.unplayed);
      expect(
        pref.smartPlaylistSortField,
        SmartPlaylistSortField.newestEpisodeDate,
      );
      expect(pref.smartPlaylistSortOrder, SortOrder.ascending);
    });
  });

  group('updateSelectedPlaylistId', () {
    test('persists selected playlist ID', () async {
      await repository.updateSelectedPlaylistId(1, 'season_3');
      final pref = await repository.getPreference(1);

      expect(pref.selectedPlaylistId, 'season_3');
    });

    test('sets view mode to smartPlaylists', () async {
      await repository.updateSelectedPlaylistId(1, 'season_1');
      final pref = await repository.getPreference(1);

      expect(pref.viewMode, PodcastViewMode.smartPlaylists);
    });

    test('clears selected playlist ID with null', () async {
      await repository.updateSelectedPlaylistId(1, 'season_5');
      await repository.updateSelectedPlaylistId(1, null);
      final pref = await repository.getPreference(1);

      expect(pref.selectedPlaylistId, isNull);
    });

    test('does not affect other preferences', () async {
      await repository.updateEpisodeFilter(1, EpisodeFilter.inProgress);
      await repository.updateSelectedPlaylistId(1, 'season_2');
      final pref = await repository.getPreference(1);

      expect(pref.episodeFilter, EpisodeFilter.inProgress);
      expect(pref.selectedPlaylistId, 'season_2');
    });
  });

  group('PodcastViewPreferenceData', () {
    test('defaults factory creates correct values', () {
      final data = PodcastViewPreferenceData.defaults(42);

      expect(data.podcastId, 42);
      expect(data.viewMode, PodcastViewMode.episodes);
      expect(data.episodeFilter, EpisodeFilter.all);
      expect(data.episodeSortOrder, SortOrder.descending);
      expect(
        data.smartPlaylistSortField,
        SmartPlaylistSortField.playlistNumber,
      );
      expect(data.smartPlaylistSortOrder, SortOrder.descending);
      expect(data.selectedPlaylistId, isNull);
    });
  });

  group('getPreference defaults for smart playlist fields', () {
    test('returns default smart playlist sort when not set', () async {
      final pref = await repository.getPreference(1);

      expect(
        pref.smartPlaylistSortField,
        SmartPlaylistSortField.playlistNumber,
      );
      expect(pref.smartPlaylistSortOrder, SortOrder.descending);
      expect(pref.selectedPlaylistId, isNull);
    });
  });

  group('preference isolation', () {
    test('preferences are isolated per podcast', () async {
      // Insert second subscription for foreign key constraint
      await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'itunes-2',
              feedUrl: 'https://example.com/feed2.xml',
              title: 'Test Podcast 2',
              artistName: 'Test Artist 2',
              subscribedAt: DateTime.now(),
            ),
          );

      // Set different preferences for each podcast
      await repository.updateViewMode(1, PodcastViewMode.smartPlaylists);
      await repository.updateViewMode(2, PodcastViewMode.episodes);
      await repository.updateEpisodeFilter(1, EpisodeFilter.unplayed);
      await repository.updateEpisodeFilter(2, EpisodeFilter.inProgress);

      final pref1 = await repository.getPreference(1);
      final pref2 = await repository.getPreference(2);

      expect(pref1.viewMode, PodcastViewMode.smartPlaylists);
      expect(pref2.viewMode, PodcastViewMode.episodes);
      expect(pref1.episodeFilter, EpisodeFilter.unplayed);
      expect(pref2.episodeFilter, EpisodeFilter.inProgress);
    });
  });
}
