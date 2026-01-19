import '../builders/podcast_search_entity_builder.dart';
import '../builders/search_entity_result.dart';
import '../models/charts_query.dart';
import '../models/podcast.dart';
import '../models/search_query.dart';
import '../models/search_result.dart';
import '../providers/podcast_provider.dart';

/// Abstract service interface for podcast search operations.
///
/// This service coordinates podcast search across multiple providers
/// and aggregates results. It serves as the main entry point for
/// podcast discovery functionality.
///
/// Example usage:
/// ```dart
/// final service = PodcastSearchService.create(
///   providers: [ItunesProvider()],
/// );
///
/// // Standard search
/// final query = SearchQuery.validated(term: 'technology');
/// final result = await service.search(query);
///
/// // Search with builder for zero-copy construction
/// final entityResult = await service.searchWithBuilder(
///   SearchQuery.validated(term: 'technology'),
///   builder: myDriftBuilder,
/// );
/// ```
abstract class PodcastSearchService {
  /// Creates a new podcast search service instance.
  ///
  /// [providers] must contain at least one provider.
  factory PodcastSearchService.create({
    required List<PodcastProvider> providers,
  }) {
    if (providers.isEmpty) {
      throw ArgumentError('At least one provider must be configured');
    }
    return _PodcastSearchServiceImpl(providers: providers);
  }

  /// Searches for podcasts across all configured providers.
  ///
  /// Returns a [SearchResult] containing podcasts from all providers.
  Future<SearchResult> search(SearchQuery query);

  /// Searches for podcasts using a builder for zero-copy construction.
  ///
  /// Returns a [SearchEntityResult] containing the constructed entities.
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  });

  /// Retrieves top podcast charts from a specific provider.
  ///
  /// [providerId] optionally specifies which provider to use.
  /// Returns a [SearchResult] containing the chart podcasts.
  Future<SearchResult> getTopCharts(
    ChartsQuery query, {
    String? providerId,
  });

  /// Retrieves top charts using a builder for zero-copy construction.
  ///
  /// Returns a [SearchEntityResult] containing the constructed entities.
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  });
}

/// Internal implementation of [PodcastSearchService].
class _PodcastSearchServiceImpl implements PodcastSearchService {
  _PodcastSearchServiceImpl({
    required List<PodcastProvider> providers,
  }) : _providers = providers;
  final List<PodcastProvider> _providers;

  @override
  Future<SearchResult> search(SearchQuery query) {
    if (1 == _providers.length) {
      return _searchSingleProvider(query);
    }
    return _searchMultipleProviders(query);
  }

  Future<SearchResult> _searchSingleProvider(SearchQuery query) async {
    final provider = _providers.first;
    final podcasts = await provider.search(query);

    return SearchResult(
      totalCount: podcasts.length,
      podcasts: podcasts,
      provider: provider.providerId,
      timestamp: DateTime.now(),
    );
  }

  Future<SearchResult> _searchMultipleProviders(SearchQuery query) async {
    final allPodcasts = <Podcast>[];
    final errors = <String, Object>{};

    for (final provider in _providers) {
      try {
        final podcasts = await provider.search(query);
        allPodcasts.addAll(podcasts);
      } on Exception catch (e) {
        errors[provider.providerId] = e;
      }
    }

    _throwIfAllProvidersFailed(allPodcasts, errors);

    final uniquePodcasts = _deduplicatePodcasts(allPodcasts);

    return SearchResult(
      totalCount: uniquePodcasts.length,
      podcasts: uniquePodcasts,
      provider: 'multiple',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) async {
    if (1 == _providers.length) {
      return _providers.first.searchWithBuilder(query, builder: builder);
    }

    // For multiple providers, aggregate results
    final allEntities = <T>[];
    final allErrors = <dynamic>[];
    final allWarnings = <String>[];

    for (final provider in _providers) {
      try {
        final result = await provider.searchWithBuilder(
          query,
          builder: builder,
        );
        allEntities.addAll(result.podcasts);
        allErrors.addAll(result.errors);
        allWarnings.addAll(result.warnings);
      } on Exception catch (e) {
        allWarnings.add('Provider ${provider.providerId} failed: $e');
      }
    }

    return SearchEntityResult(
      podcasts: allEntities,
      totalCount: allEntities.length,
      provider: 'multiple',
      timestamp: DateTime.now(),
      errors: allErrors.whereType<dynamic>().toList().cast(),
      warnings: allWarnings,
    );
  }

  @override
  Future<SearchResult> getTopCharts(
    ChartsQuery query, {
    String? providerId,
  }) async {
    final provider = providerId != null
        ? _findProviderById(providerId)
        : _findProviderSupportingCharts();

    final podcasts = await provider.getTopCharts(query);

    return SearchResult(
      totalCount: podcasts.length,
      podcasts: podcasts,
      provider: provider.providerId,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    final provider = providerId != null
        ? _findProviderById(providerId)
        : _findProviderSupportingCharts();

    return provider.getTopChartsWithBuilder(query, builder: builder);
  }

  List<Podcast> _deduplicatePodcasts(List<Podcast> podcasts) {
    final seenIds = <String>{};
    final uniquePodcasts = <Podcast>[];

    for (final podcast in podcasts) {
      if (!seenIds.contains(podcast.id)) {
        seenIds.add(podcast.id);
        uniquePodcasts.add(podcast);
      }
    }

    return uniquePodcasts;
  }

  void _throwIfAllProvidersFailed(
    List<Podcast> podcasts,
    Map<String, Object> errors,
  ) {
    if (podcasts.isEmpty && _providers.length == errors.length) {
      final errorMessages = errors.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');

      throw Exception(
        'All providers failed to return results. Errors: $errorMessages',
      );
    }
  }

  PodcastProvider _findProviderById(String id) {
    return _providers.firstWhere(
      (p) => p.providerId == id,
      orElse: () => throw ArgumentError('Provider with ID "$id" not found'),
    );
  }

  PodcastProvider _findProviderSupportingCharts() {
    return _providers.firstWhere(
      (p) => p.supportsCharts,
      orElse: () => throw ArgumentError('No provider supports charts'),
    );
  }
}
