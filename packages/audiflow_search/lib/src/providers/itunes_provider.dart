import '../builders/podcast_search_entity_builder.dart';
import '../builders/search_entity_result.dart';
import '../clients/itunes_charts_client.dart';
import '../clients/itunes_search_client.dart';
import '../models/charts_query.dart';
import '../models/podcast.dart';
import '../models/search_query.dart';
import 'podcast_provider.dart';

/// iTunes Search API provider implementation.
///
/// This provider enables podcast search and discovery through Apple's iTunes
/// Search API. It supports both keyword-based search and top charts retrieval.
class ItunesProvider implements PodcastProvider {
  /// Creates an iTunes provider instance.
  ///
  /// Optionally accepts custom [searchClient] and [chartsClient] for testing.
  ItunesProvider({
    ItunesSearchClient? searchClient,
    ItunesChartsClient? chartsClient,
  }) : _searchClient = searchClient ?? ItunesSearchClient(),
       _chartsClient = chartsClient ?? ItunesChartsClient();
  final ItunesSearchClient _searchClient;
  final ItunesChartsClient _chartsClient;

  @override
  String get providerId => 'itunes';

  @override
  String get providerName => 'iTunes Search';

  @override
  bool get supportsCharts => true;

  @override
  Future<List<Podcast>> search(SearchQuery query) {
    return _searchClient.search(query);
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    return _searchClient.searchWithBuilder(query, builder: builder);
  }

  @override
  Future<List<Podcast>> getTopCharts(ChartsQuery query) {
    return _chartsClient.fetchTopCharts(query);
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    return _chartsClient.fetchTopChartsWithBuilder(query, builder: builder);
  }

  /// Closes the provider and cleans up resources.
  void close() {
    _searchClient.close();
    _chartsClient.close();
  }
}
