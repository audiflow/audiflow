import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as pcast;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/bloc/search/search_state_event.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast_service_provider.dart';
import 'package:seasoning/providers/repository_provider.dart';

part 'podcast_search_provider.freezed.dart';
part 'podcast_search_provider.g.dart';

@riverpod
class PodcastSearch extends _$PodcastSearch {
  PodcastSearch() {
    _searchInput.listen(_search);
  }

  pcast.SearchResult? _chartResult;

  final BehaviorSubject<SearchEvent> _searchInput =
      BehaviorSubject<SearchEvent>();

  void Function(SearchEvent) get search => _searchInput.add;

  @override
  AsyncValue<PodcastSearchState> build() {
    ref.onDispose(_searchInput.close);
    return const AsyncData(PodcastSearchState());
  }

  Future<void> _search(SearchEvent event) async {
    switch (event) {
      case SearchClearEvent():
        state = const AsyncData(PodcastSearchState());
        return;

      case SearchChartsEvent():
        state = const AsyncLoading();

        _chartResult ??=
            await ref.read(podcastServiceProvider).charts(size: 10);
        state = AsyncData(
          PodcastSearchState(
            results: await _toPodcasts(_chartResult!.items),
          ),
        );
        return;

      case SearchTermEvent(term: final term):
        if (term.isEmpty) {
          state = AsyncData(PodcastSearchState(term: term));
          return;
        }

        // Check we have network
        final connectivityResult = await Connectivity().checkConnectivity();

        if (connectivityResult == ConnectivityResult.none) {
          state = AsyncError(Exception('no network'), StackTrace.current);
          return;
        }

        state = const AsyncLoading();
        final results =
            await ref.read(podcastServiceProvider).search(term: term);
        if (results.successful) {
          state = AsyncData(
            PodcastSearchState(
              term: term,
              results: await _toPodcasts(results.items),
            ),
          );
        } else {
          state = AsyncError(Exception(results.lastError), StackTrace.current);
        }
    }
  }

  Future<List<Podcast>> _toPodcasts(List<pcast.Item> items) async {
    final repository = ref.read(repositoryProvider);
    final podcasts = items.map(Podcast.fromSearchResultItem).toList();
    final results = await Future.wait(
      podcasts.map((p) => repository.findPodcastByGuid(p.guid)),
    );
    for (var i = 0; i < podcasts.length; i++) {
      if (results[i] != null) {
        podcasts[i] = results[i]!;
      }
    }
    return podcasts;
  }
}

@freezed
class PodcastSearchState with _$PodcastSearchState {
  const factory PodcastSearchState({
    @Default('') String term,
    @Default([]) List<Podcast> results,
    pcast.SearchResult? chartResults,
  }) = _PodcastSearchState;
}
