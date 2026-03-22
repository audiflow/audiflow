import 'dart:async';

import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_app/features/search/presentation/controllers/search_state.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/search_mocks.dart';

void main() {
  group('SearchState', () {
    test('SearchInitial is a SearchState', () {
      const state = SearchInitial();
      expect(state, isA<SearchState>());
    });

    test('SearchLoading is a SearchState', () {
      const state = SearchLoading();
      expect(state, isA<SearchState>());
    });

    test('SearchSuccess is a SearchState with result', () {
      final result = SearchResult(
        totalCount: 1,
        podcasts: const [],
        provider: 'test',
        timestamp: DateTime.now(),
      );
      final state = SearchSuccess(result: result);

      expect(state, isA<SearchState>());
      expect(state.result, equals(result));
    });

    test('SearchSuccess.isEmpty returns true when podcasts empty', () {
      final result = SearchResult(
        totalCount: 0,
        podcasts: const [],
        provider: 'test',
        timestamp: DateTime.now(),
      );
      final state = SearchSuccess(result: result);

      expect(state.isEmpty, isTrue);
    });

    test('SearchSuccess.isEmpty returns false when podcasts exist', () {
      final podcast = Podcast(
        id: '1',
        name: 'Test Podcast',
        artistName: 'Test Artist',
      );
      final result = SearchResult(
        totalCount: 1,
        podcasts: [podcast],
        provider: 'test',
        timestamp: DateTime.now(),
      );
      final state = SearchSuccess(result: result);

      expect(state.isEmpty, isFalse);
    });

    test('SearchError is a SearchState with exception and lastQuery', () {
      final exception = SearchException.unavailable(
        providerId: 'test',
        message: 'Network error',
      );
      final state = SearchError(exception: exception, lastQuery: 'test query');

      expect(state, isA<SearchState>());
      expect(state.exception, equals(exception));
      expect(state.lastQuery, equals('test query'));
    });

    test(
      'SearchRefreshing is a SearchState with previousResult and pendingQuery',
      () {
        final result = SearchResult(
          totalCount: 1,
          podcasts: const [],
          provider: 'test',
          timestamp: DateTime.now(),
        );
        final state = SearchRefreshing(
          previousResult: result,
          pendingQuery: 'new',
        );

        expect(state, isA<SearchState>());
        expect(state.previousResult, equals(result));
        expect(state.pendingQuery, equals('new'));
      },
    );

    test('SearchError with lastResult preserves previous results', () {
      final result = SearchResult(
        totalCount: 1,
        podcasts: const [],
        provider: 'test',
        timestamp: DateTime.now(),
      );
      final exception = SearchException.unavailable(
        providerId: 'test',
        message: 'Network error',
      );
      final state = SearchError(
        exception: exception,
        lastQuery: 'query',
        lastResult: result,
      );

      expect(state.lastResult, equals(result));
    });

    test('SearchError without lastResult has null lastResult', () {
      final exception = SearchException.unavailable(
        providerId: 'test',
        message: 'Network error',
      );
      final state = SearchError(exception: exception, lastQuery: 'query');

      expect(state.lastResult, isNull);
    });
  });

  group('PodcastSearchController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is SearchInitial', () {
      final state = container.read(podcastSearchControllerProvider);

      expect(state, isA<SearchInitial>());
    });
  });

  group('PodcastSearchController search execution (Task 2.1)', () {
    test('search transitions from initial to loading to success', () async {
      final podcasts = [
        Podcast(id: '1', name: 'Tech Podcast', artistName: 'Tech Host'),
        Podcast(id: '2', name: 'Science Show', artistName: 'Science Host'),
      ];
      final mockService = MockPodcastSearchService(
        searchResult: SearchResult(
          totalCount: 2,
          podcasts: podcasts,
          provider: 'mock',
          timestamp: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final stateHistory = <SearchState>[];
      container.listen(
        podcastSearchControllerProvider,
        (_, state) => stateHistory.add(state),
        fireImmediately: true,
      );

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      await controller.search('technology');

      expect(stateHistory[0], isA<SearchInitial>());
      expect(stateHistory[1], isA<SearchLoading>());
      expect(stateHistory[2], isA<SearchSuccess>());

      final successState = stateHistory[2] as SearchSuccess;
      expect(successState.result.podcasts.length, equals(2));
      expect(successState.result.podcasts.first.name, equals('Tech Podcast'));
    });

    test(
      'search transitions from initial to loading to error on failure',
      () async {
        final mockService = MockPodcastSearchService(
          searchException: SearchException.unavailable(
            providerId: 'mock',
            message: 'Network unavailable',
          ),
        );

        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        final stateHistory = <SearchState>[];
        container.listen(
          podcastSearchControllerProvider,
          (_, state) => stateHistory.add(state),
          fireImmediately: true,
        );

        final controller = container.read(
          podcastSearchControllerProvider.notifier,
        );
        await controller.search('test query');

        expect(stateHistory[0], isA<SearchInitial>());
        expect(stateHistory[1], isA<SearchLoading>());
        expect(stateHistory[2], isA<SearchError>());

        final errorState = stateHistory[2] as SearchError;
        expect(errorState.exception.code, equals(StatusCode.unavailable));
        expect(errorState.lastQuery, equals('test query'));
      },
    );

    test('search stores last query for retry functionality', () async {
      final mockService = MockPodcastSearchService(
        searchResult: SearchResult(
          totalCount: 0,
          podcasts: const [],
          provider: 'mock',
          timestamp: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      await controller.search('  my search term  ');

      expect(mockService.lastSearchTerm, equals('my search term'));
    });

    test('search trims whitespace from query', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      await controller.search('  trimmed query  ');

      expect(mockService.lastSearchTerm, equals('trimmed query'));
    });
  });

  group('PodcastSearchController duplicate prevention (Task 2.2)', () {
    test('duplicate calls during loading are ignored', () async {
      final searchCompleter = Completer<void>();
      var searchCallCount = 0;
      String? lastSearchTerm;

      final mockService = DelayedMockSearchService(
        onSearch: (term) {
          searchCallCount++;
          lastSearchTerm = term;
        },
        searchCompleter: searchCompleter,
        searchResult: SearchResult(
          totalCount: 0,
          podcasts: const [],
          provider: 'mock',
          timestamp: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // Start first search (will be in loading state)
      // ignore: unawaited_futures
      final firstSearch = controller.search('first query');

      // Verify we're in loading state
      final loadingState = container.read(podcastSearchControllerProvider);
      expect(loadingState, isA<SearchLoading>());

      // Attempt duplicate searches while loading (these should be ignored)
      await controller.search('second query');
      await controller.search('third query');

      // Complete the first search
      searchCompleter.complete();
      await firstSearch;

      // Only the first search should have been executed
      expect(searchCallCount, equals(1));
      expect(lastSearchTerm, equals('first query'));
    });

    test('empty query does not trigger API call', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      await controller.search('');
      await controller.search('   ');
      await controller.search('\t\n');

      expect(mockService.searchCallCount, equals(0));
    });

    test('whitespace-only query does not trigger API call', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );
      await controller.search('     ');

      expect(mockService.searchCallCount, equals(0));
      final state = container.read(podcastSearchControllerProvider);
      expect(state, isA<SearchInitial>());
    });

    test('state remains unchanged when empty query submitted', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final initialState = container.read(podcastSearchControllerProvider);
      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      await controller.search('');

      final afterEmptySearch = container.read(podcastSearchControllerProvider);
      expect(afterEmptySearch, equals(initialState));
    });
  });

  group('PodcastSearchController retry functionality (Task 2.3)', () {
    test('retry re-executes last query', () async {
      final mockService = MockPodcastSearchService(
        searchResult: SearchResult(
          totalCount: 1,
          podcasts: [Podcast(id: '1', name: 'Result', artistName: 'Artist')],
          provider: 'mock',
          timestamp: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // First search
      await controller.search('original query');
      expect(mockService.searchCallCount, equals(1));
      expect(mockService.lastSearchTerm, equals('original query'));

      // Retry should use the same query
      await controller.retry();
      expect(mockService.searchCallCount, equals(2));
      expect(mockService.lastSearchTerm, equals('original query'));
    });

    test('retry does nothing when no previous query exists', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // Call retry without any previous search
      await controller.retry();

      expect(mockService.searchCallCount, equals(0));
      final state = container.read(podcastSearchControllerProvider);
      expect(state, isA<SearchInitial>());
    });

    test('retry after error re-executes the failed query', () async {
      final successResult = SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '1', name: 'Success', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      );

      final mockService = MockPodcastSearchService(
        searchException: SearchException.unavailable(
          providerId: 'mock',
          message: 'First call fails',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // First search fails
      await controller.search('retry test query');
      final errorState = container.read(podcastSearchControllerProvider);
      expect(errorState, isA<SearchError>());
      expect((errorState as SearchError).lastQuery, equals('retry test query'));

      // Create new mock that succeeds for retry
      final successService = MockPodcastSearchService(
        searchResult: successResult,
      );

      // Dispose old container and create new one with success service
      container.dispose();

      final retryContainer = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(successService),
        ],
      );
      addTearDown(retryContainer.dispose);

      final retryController = retryContainer.read(
        podcastSearchControllerProvider.notifier,
      );

      // First need to set up the lastQuery by calling search
      await retryController.search('retry test query');
      final successState = retryContainer.read(podcastSearchControllerProvider);

      expect(successState, isA<SearchSuccess>());
      expect(successService.lastSearchTerm, equals('retry test query'));
    });
  });
}
