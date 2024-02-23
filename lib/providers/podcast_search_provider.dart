import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:podcast_search/podcast_search.dart' as pcast;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/bloc/search/search_state_event.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';

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

  // ignore: avoid_public_notifier_properties
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
          PodcastSearchState(results: _toPodcasts(_chartResult!.items)),
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
              results: _toPodcasts(results.items),
            ),
          );
        } else {
          state = AsyncError(Exception(results.lastError), StackTrace.current);
        }
    }
  }

  List<PodcastSearchResultItem> _toPodcasts(List<pcast.Item> items) =>
      items.map(PodcastSearchResultItem.fromSearchResultItem).toList();
}

@freezed
class PodcastSearchState with _$PodcastSearchState {
  const factory PodcastSearchState({
    @Default('') String term,
    @Default([]) List<PodcastSearchResultItem> results,
    pcast.SearchResult? chartResults,
  }) = _PodcastSearchState;
}
