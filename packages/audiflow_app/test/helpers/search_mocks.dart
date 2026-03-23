import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart'
    hide podcastSearchServiceProvider;
import 'package:audiflow_search/audiflow_search.dart';

/// Fake AppSettingsRepository that stores search country in memory.
///
/// All other settings methods throw [UnimplementedError].
class FakeAppSettingsRepository implements AppSettingsRepository {
  String? _searchCountry;
  int _lastTabIndex = 0;

  @override
  String? getSearchCountry() => _searchCountry;

  @override
  Future<void> setSearchCountry(String? country) async {
    _searchCountry = country;
  }

  @override
  int getLastTabIndex() => _lastTabIndex;

  @override
  Future<void> setLastTabIndex(int index) async {
    _lastTabIndex = index;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Mock implementation of PodcastSearchService for testing.
///
/// Configurable behavior via constructor parameters.
class MockPodcastSearchService implements PodcastSearchService {
  MockPodcastSearchService({
    this.searchDelay = Duration.zero,
    this.searchResult,
    this.searchException,
  });

  final Duration searchDelay;
  final SearchResult? searchResult;
  final SearchException? searchException;

  int searchCallCount = 0;
  String? lastSearchTerm;
  String? lastSearchCountry;

  @override
  Future<SearchResult> search(SearchQuery query) async {
    searchCallCount++;
    lastSearchTerm = query.term;
    lastSearchCountry = query.country;

    if (searchDelay != Duration.zero) {
      await Future<void>.delayed(searchDelay);
    }

    final exception = searchException;
    if (exception != null) {
      throw exception;
    }

    return searchResult ??
        SearchResult(
          totalCount: 0,
          podcasts: const [],
          provider: 'mock',
          timestamp: DateTime.now(),
        );
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}

/// Mock service with completer-based async control for testing loading state.
class DelayedMockSearchService implements PodcastSearchService {
  DelayedMockSearchService({
    required this.onSearch,
    required this.searchCompleter,
    required this.searchResult,
  });

  final void Function(String term) onSearch;
  final Completer<void> searchCompleter;
  final SearchResult searchResult;

  @override
  Future<SearchResult> search(SearchQuery query) async {
    onSearch(query.term);
    await searchCompleter.future;
    return searchResult;
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}

/// Mock service that never completes to test loading state.
class SlowMockSearchService implements PodcastSearchService {
  final _completer = Completer<SearchResult>();
  int callCount = 0;

  @override
  Future<SearchResult> search(SearchQuery query) {
    callCount++;
    return _completer.future;
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}

/// Mock service that returns a specific number of results.
class ResultsMockSearchService implements PodcastSearchService {
  ResultsMockSearchService({required this.count});
  final int count;

  @override
  Future<SearchResult> search(SearchQuery query) async {
    final podcasts = List.generate(
      count,
      (index) => Podcast(
        id: 'podcast_$index',
        name: 'Podcast $index',
        artistName: 'Artist $index',
        genres: const ['Technology'],
        description: 'Description $index',
      ),
    );
    return SearchResult(
      totalCount: count,
      podcasts: podcasts,
      provider: 'mock',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}

/// Mock service that returns results with custom IDs.
class CustomIdMockSearchService implements PodcastSearchService {
  CustomIdMockSearchService({required this.ids});
  final List<String> ids;

  @override
  Future<SearchResult> search(SearchQuery query) async {
    final podcasts = ids
        .asMap()
        .entries
        .map(
          (entry) => Podcast(
            id: entry.value,
            name: 'Podcast ${entry.key}',
            artistName: 'Artist ${entry.key}',
            genres: const ['Technology'],
            description: 'Description ${entry.key}',
          ),
        )
        .toList();
    return SearchResult(
      totalCount: podcasts.length,
      podcasts: podcasts,
      provider: 'mock',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}

/// Mock service that throws an error.
class ErrorMockSearchService implements PodcastSearchService {
  @override
  Future<SearchResult> search(SearchQuery query) async {
    throw SearchException.unavailable(
      providerId: 'mock',
      message: 'Network error occurred',
    );
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}

/// Mock service that fails first, then succeeds on retry.
class RetryMockSearchService implements PodcastSearchService {
  int callCount = 0;

  @override
  Future<SearchResult> search(SearchQuery query) async {
    callCount++;
    if (callCount <= 1) {
      throw SearchException.unavailable(
        providerId: 'mock',
        message: 'Network error occurred',
      );
    }
    return SearchResult(
      totalCount: 0,
      podcasts: const [],
      provider: 'mock',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}

/// Mock service that tracks all queries and supports completer-based control.
///
/// Each call to search() creates a new Completer. The test controls
/// when each call resolves by completing the completer.
class QueryTrackingMockSearchService implements PodcastSearchService {
  final List<String> queries = [];
  final List<Completer<SearchResult>> completers = [];

  /// Default result returned when completer is completed without a value.
  final SearchResult defaultResult;

  QueryTrackingMockSearchService({SearchResult? defaultResult})
    : defaultResult =
          defaultResult ??
          SearchResult(
            totalCount: 0,
            podcasts: const [],
            provider: 'mock',
            timestamp: DateTime.now(),
          );

  @override
  Future<SearchResult> search(SearchQuery query) {
    queries.add(query.term);
    final completer = Completer<SearchResult>();
    completers.add(completer);
    return completer.future;
  }

  /// Complete the Nth search call (0-indexed) with a result.
  void complete(int index, [SearchResult? result]) {
    completers[index].complete(result ?? defaultResult);
  }

  /// Fail the Nth search call (0-indexed) with an exception.
  void fail(int index, SearchException exception) {
    completers[index].completeError(exception);
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}
