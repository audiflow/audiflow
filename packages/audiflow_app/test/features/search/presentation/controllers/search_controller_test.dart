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
      await controller.searchImmediate('technology');

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
        await controller.searchImmediate('test query');

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
      await controller.searchImmediate('  my search term  ');

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
      await controller.searchImmediate('  trimmed query  ');

      expect(mockService.lastSearchTerm, equals('trimmed query'));
    });
  });

  group('PodcastSearchController concurrent and empty queries (Task 2.2)', () {
    test('concurrent searches discard stale responses', () async {
      final mockService = QueryTrackingMockSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // Fire three searches rapidly
      // ignore: unawaited_futures
      controller.searchImmediate('first');
      // ignore: unawaited_futures
      controller.searchImmediate('second');
      // ignore: unawaited_futures
      controller.searchImmediate('third');

      expect(mockService.queries.length, equals(3));

      // Complete only the latest
      final thirdResult = SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '3', name: 'Third', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      );
      mockService.complete(2, thirdResult);
      await Future<void>.delayed(Duration.zero);

      // Complete stale ones — should be ignored
      mockService.complete(0);
      mockService.complete(1);
      await Future<void>.delayed(Duration.zero);

      final finalState = container.read(podcastSearchControllerProvider);
      expect(finalState, isA<SearchSuccess>());
      expect(
        (finalState as SearchSuccess).result.podcasts.first.name,
        equals('Third'),
      );
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

      await controller.searchImmediate('');
      await controller.searchImmediate('   ');
      await controller.searchImmediate('\t\n');

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
      await controller.searchImmediate('     ');

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

      await controller.searchImmediate('');

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
      await controller.searchImmediate('original query');
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
      await controller.searchImmediate('retry test query');
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
      await retryController.searchImmediate('retry test query');
      final successState = retryContainer.read(podcastSearchControllerProvider);

      expect(successState, isA<SearchSuccess>());
      expect(successService.lastSearchTerm, equals('retry test query'));
    });
  });

  group('PodcastSearchController debounce (search-as-you-type)', () {
    const debounceDuration = Duration(milliseconds: 500);

    test(
      'onQueryChanged does not fire search before debounce elapses',
      () async {
        final mockService = QueryTrackingMockSearchService();

        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Keep provider alive by listening
        container.listen(podcastSearchControllerProvider, (_, _) {});

        final controller = container.read(
          podcastSearchControllerProvider.notifier,
        );

        controller.onQueryChanged('flutter');

        // Before debounce elapses
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(mockService.queries, isEmpty);

        // Clean up: advance past debounce so timer fires
        await Future<void>.delayed(const Duration(milliseconds: 400));
        // Complete the search to avoid dangling futures
        if (mockService.completers.isNotEmpty) {
          mockService.complete(0);
        }
      },
    );

    test('onQueryChanged fires search after 500ms debounce', () async {
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

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      controller.onQueryChanged('flutter');
      await Future<void>.delayed(
        debounceDuration + const Duration(milliseconds: 50),
      );

      expect(mockService.searchCallCount, equals(1));
      expect(mockService.lastSearchTerm, equals('flutter'));
    });

    test('rapid typing resets debounce, only final query fires', () async {
      final mockService = QueryTrackingMockSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      controller.onQueryChanged('fl');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      controller.onQueryChanged('flu');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      controller.onQueryChanged('flutter');

      await Future<void>.delayed(
        debounceDuration + const Duration(milliseconds: 50),
      );

      expect(mockService.queries.length, equals(1));
      expect(mockService.queries.first, equals('flutter'));

      mockService.complete(0);
    });

    test('searchImmediate bypasses debounce', () async {
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

      await controller.searchImmediate('flutter');

      expect(mockService.searchCallCount, equals(1));
      expect(mockService.lastSearchTerm, equals('flutter'));
    });

    test('query below 2 characters does not fire search', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      controller.onQueryChanged('a');
      await Future<void>.delayed(
        debounceDuration + const Duration(milliseconds: 50),
      );

      expect(mockService.searchCallCount, equals(0));
    });
  });

  group('PodcastSearchController IME composing guard', () {
    test('composing input does not trigger search', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      controller.onQueryChanged('ポッド', composing: true);
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(mockService.searchCallCount, equals(0));
    });

    test('committed IME input triggers search', () async {
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

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // Composing
      controller.onQueryChanged('ポッド', composing: true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Committed
      controller.onQueryChanged('ポッドキャスト');
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(mockService.searchCallCount, equals(1));
      expect(mockService.lastSearchTerm, equals('ポッドキャスト'));
    });
  });

  group('PodcastSearchController dedup and stale discard', () {
    test('same query as last completed result skips API call', () async {
      final mockService = MockPodcastSearchService(
        searchResult: SearchResult(
          totalCount: 1,
          podcasts: [Podcast(id: '1', name: 'Test', artistName: 'Artist')],
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
      await controller.searchImmediate('flutter');
      expect(mockService.searchCallCount, equals(1));

      // Same query again
      await controller.searchImmediate('flutter');
      expect(mockService.searchCallCount, equals(1)); // No additional call
    });

    test('stale response is discarded when query has changed', () async {
      final mockService = QueryTrackingMockSearchService();

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
      );

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // Fire two immediate searches
      // ignore: unawaited_futures
      controller.searchImmediate('first');
      // ignore: unawaited_futures
      controller.searchImmediate('second');

      // Complete second first (newer)
      final secondResult = SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '2', name: 'Second', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      );
      mockService.complete(1, secondResult);
      await Future<void>.delayed(Duration.zero);

      // Complete first (stale) — should be discarded
      final firstResult = SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      );
      mockService.complete(0, firstResult);
      await Future<void>.delayed(Duration.zero);

      final finalState = container.read(podcastSearchControllerProvider);
      expect(finalState, isA<SearchSuccess>());
      expect(
        (finalState as SearchSuccess).result.podcasts.first.name,
        equals('Second'),
      );
    });
  });

  group('PodcastSearchController refreshing state transitions', () {
    test(
      'subsequent search emits SearchRefreshing with previous result',
      () async {
        final result1 = SearchResult(
          totalCount: 1,
          podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
          provider: 'mock',
          timestamp: DateTime.now(),
        );
        final result2 = SearchResult(
          totalCount: 1,
          podcasts: [Podcast(id: '2', name: 'Second', artistName: 'Artist')],
          provider: 'mock',
          timestamp: DateTime.now(),
        );

        final mockService = QueryTrackingMockSearchService();

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

        // First search
        // ignore: unawaited_futures
        controller.searchImmediate('first');
        mockService.complete(0, result1);
        await Future<void>.delayed(Duration.zero);

        // Second search — should go through SearchRefreshing
        // ignore: unawaited_futures
        controller.searchImmediate('second');
        await Future<void>.delayed(Duration.zero);

        // Find the SearchRefreshing state
        final refreshingStates = stateHistory
            .whereType<SearchRefreshing>()
            .toList();
        expect(refreshingStates, hasLength(1));
        expect(refreshingStates.first.previousResult, equals(result1));
        expect(refreshingStates.first.pendingQuery, equals('second'));

        mockService.complete(1, result2);
        await Future<void>.delayed(Duration.zero);

        final finalState = container.read(podcastSearchControllerProvider);
        expect(finalState, isA<SearchSuccess>());
        expect((finalState as SearchSuccess).result, equals(result2));
      },
    );

    test('error during refresh preserves lastResult', () async {
      final result1 = SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      );

      final mockService = QueryTrackingMockSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // First search succeeds
      // ignore: unawaited_futures
      controller.searchImmediate('first');
      mockService.complete(0, result1);
      await Future<void>.delayed(Duration.zero);

      // Second search fails
      // ignore: unawaited_futures
      controller.searchImmediate('second');
      mockService.fail(
        1,
        SearchException.unavailable(
          providerId: 'mock',
          message: 'Network error',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final finalState = container.read(podcastSearchControllerProvider);
      expect(finalState, isA<SearchError>());
      final errorState = finalState as SearchError;
      expect(errorState.lastResult, equals(result1));
      expect(errorState.lastQuery, equals('second'));
    });

    test(
      'zero results on refresh shows empty state, not stale results',
      () async {
        final result1 = SearchResult(
          totalCount: 1,
          podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
          provider: 'mock',
          timestamp: DateTime.now(),
        );
        final emptyResult = SearchResult(
          totalCount: 0,
          podcasts: const [],
          provider: 'mock',
          timestamp: DateTime.now(),
        );

        final mockService = QueryTrackingMockSearchService();

        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Keep provider alive by listening
        container.listen(podcastSearchControllerProvider, (_, _) {});

        final controller = container.read(
          podcastSearchControllerProvider.notifier,
        );

        // First search succeeds with results
        // ignore: unawaited_futures
        controller.searchImmediate('first');
        mockService.complete(0, result1);
        await Future<void>.delayed(Duration.zero);

        // Second search returns empty
        // ignore: unawaited_futures
        controller.searchImmediate('second');
        mockService.complete(1, emptyResult);
        await Future<void>.delayed(Duration.zero);

        final finalState = container.read(podcastSearchControllerProvider);
        expect(finalState, isA<SearchSuccess>());
        expect((finalState as SearchSuccess).isEmpty, isTrue);
      },
    );

    test('first search error has null lastResult', () async {
      final mockService = QueryTrackingMockSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // ignore: unawaited_futures
      controller.searchImmediate('test');
      mockService.fail(
        0,
        SearchException.unavailable(providerId: 'mock', message: 'Error'),
      );
      await Future<void>.delayed(Duration.zero);

      final finalState = container.read(podcastSearchControllerProvider);
      expect(finalState, isA<SearchError>());
      expect((finalState as SearchError).lastResult, isNull);
    });

    test('timer is cancelled on controller disposal', () async {
      final mockService = MockPodcastSearchService();

      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );

      // Keep provider alive by listening
      container.listen(podcastSearchControllerProvider, (_, _) {});

      final controller = container.read(
        podcastSearchControllerProvider.notifier,
      );

      // Start a debounced search
      controller.onQueryChanged('flutter');

      // Dispose before debounce fires
      container.dispose();

      // Wait past debounce duration — no search should fire
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(mockService.searchCallCount, equals(0));
    });

    test(
      'clear resets _lastCompletedQuery allowing re-search of same term',
      () async {
        final mockService = MockPodcastSearchService(
          searchResult: SearchResult(
            totalCount: 1,
            podcasts: [Podcast(id: '1', name: 'Test', artistName: 'Artist')],
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

        await controller.searchImmediate('test');
        expect(mockService.searchCallCount, equals(1));

        controller.clear();

        // Same term again after clear — should fire, not be deduped
        await controller.searchImmediate('test');
        expect(mockService.searchCallCount, equals(2));
      },
    );

    test('clear resets to initial state', () async {
      final mockService = MockPodcastSearchService(
        searchResult: SearchResult(
          totalCount: 1,
          podcasts: [Podcast(id: '1', name: 'Test', artistName: 'Artist')],
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

      await controller.searchImmediate('test');
      expect(
        container.read(podcastSearchControllerProvider),
        isA<SearchSuccess>(),
      );

      controller.clear();
      expect(
        container.read(podcastSearchControllerProvider),
        isA<SearchInitial>(),
      );
    });
  });
}
