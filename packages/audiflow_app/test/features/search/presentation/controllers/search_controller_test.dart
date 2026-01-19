import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_app/features/search/presentation/controllers/search_state.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('search method exists and transitions to error state (stub)', () async {
      final controller = container.read(podcastSearchControllerProvider.notifier);

      await controller.search('test query');
      final state = container.read(podcastSearchControllerProvider);

      expect(state, isA<SearchError>());
    });

    test('retry method exists and delegates to search', () async {
      final controller = container.read(podcastSearchControllerProvider.notifier);

      // First search to set lastQuery
      await controller.search('retry test');

      // Reset to initial for retry test
      // Note: retry should re-use the last query
      await controller.retry();

      final state = container.read(podcastSearchControllerProvider);
      // In stub implementation, retry should also return error
      expect(state, isA<SearchError>());
    });
  });
}
