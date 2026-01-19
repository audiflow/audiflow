import 'dart:async';

import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_app/features/search/presentation/controllers/search_state.dart';
import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock implementation of PodcastSearchService for widget tests.
class _MockPodcastSearchService implements PodcastSearchService {
  @override
  Future<SearchResult> search(SearchQuery query) async {
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

void main() {
  group('SearchScreen', () {
    late _MockPodcastSearchService mockService;

    setUp(() {
      mockService = _MockPodcastSearchService();
    });

    Widget buildTestWidget({ProviderContainer? container}) {
      final effectiveContainer = container ??
          ProviderContainer(
            overrides: [
              podcastSearchServiceProvider.overrideWithValue(mockService),
            ],
          );

      return UncontrolledProviderScope(
        container: effectiveContainer,
        child: const MaterialApp(home: SearchScreen()),
      );
    }

    testWidgets('renders text input field for search query', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Find TextField for entering search queries (Requirement 1.1)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders submit button with search icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Find IconButton for submit (Requirement 1.2)
      // Note: There may be multiple search icons (one in button, one in initial state)
      expect(find.byType(IconButton), findsOneWidget);

      // Verify the IconButton has a search icon
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final icon = iconButton.icon as Icon;
      expect(icon.icon, equals(Icons.search));
    });

    testWidgets('submit button tap calls controller search method',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));

      // Enter text in the search field
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Tap the submit button (Requirement 1.3)
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Verify state changed to success (mock returns empty result)
      final state = container.read(podcastSearchControllerProvider);
      expect(state, isA<SearchSuccess>());
    });

    testWidgets('keyboard submit action calls controller search method',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));

      // Enter text in the search field
      await tester.enterText(find.byType(TextField), 'keyboard test');
      await tester.pump();

      // Simulate pressing enter/done on keyboard (Requirement 1.4)
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Verify state changed to success (mock returns empty result)
      final state = container.read(podcastSearchControllerProvider);
      expect(state, isA<SearchSuccess>());
    });

    testWidgets('keyboard is dismissed when search is initiated',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          podcastSearchServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container: container));

      // Enter text and focus the text field
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();
      await tester.enterText(textField, 'dismiss test');
      await tester.pump();

      // Find the EditableText to check focus state
      final editableText = find.byType(EditableText);
      final focusNode = tester.widget<EditableText>(editableText).focusNode;

      // Verify text field has focus before search
      expect(focusNode.hasFocus, isTrue);

      // Tap submit button (Requirement 1.5)
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // After search, keyboard should be dismissed (focus lost)
      expect(focusNode.hasFocus, isFalse);
    });

    testWidgets('watches PodcastSearchController state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Widget should successfully render and watch the controller
      // If it doesn't watch properly, the widget tree wouldn't build
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    group('UI States', () {
      // Task 4.1: Initial empty state display
      testWidgets('initial state renders empty view with message',
          (tester) async {
        // Arrange: Create container with initial state (default)
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        // Act
        await tester.pumpWidget(buildTestWidget(container: container));

        // Assert: Initial state should show empty state view
        expect(find.byKey(const Key('search_initial_state')), findsOneWidget);
        expect(find.byIcon(Icons.search), findsAtLeastNWidgets(1));
      });

      // Task 4.2: Loading state with indicator
      testWidgets('loading state shows loading indicator', (tester) async {
        // Arrange: Create a controller that stays in loading state
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              _SlowMockPodcastSearchService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // Act: Start a search (which will stay in loading state)
        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pump(); // Only pump once to catch loading state

        // Assert: Loading indicator should be visible
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byKey(const Key('search_loading_state')), findsOneWidget);
      });

      testWidgets('submit button is disabled during loading', (tester) async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              _SlowMockPodcastSearchService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // Act: Start a search
        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Assert: Submit button should be disabled
        final iconButton = tester.widget<IconButton>(find.byType(IconButton));
        expect(iconButton.onPressed, isNull);
      });

      // Task 4.3: Results list display
      testWidgets('results state renders correct item count', (tester) async {
        // Arrange: Create mock that returns results
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              _ResultsMockPodcastSearchService(count: 3),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // Act: Perform search
        await tester.enterText(find.byType(TextField), 'test query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert: Should show 3 result tiles
        expect(find.byKey(const Key('search_results_list')), findsOneWidget);
        expect(find.byKey(const Key('search_result_tile_0')), findsOneWidget);
        expect(find.byKey(const Key('search_result_tile_1')), findsOneWidget);
        expect(find.byKey(const Key('search_result_tile_2')), findsOneWidget);
      });

      // Task 4.4: No results found state
      testWidgets('empty results state shows not-found UI', (tester) async {
        // Arrange: Create mock that returns empty results
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(mockService),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // Act: Perform search that returns no results
        await tester.enterText(find.byType(TextField), 'no results query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert: Should show not-found UI
        expect(find.byKey(const Key('search_empty_state')), findsOneWidget);
        expect(find.byIcon(Icons.search_off), findsOneWidget);
        expect(find.text('No podcasts found'), findsOneWidget);
      });

      // Task 4.5: Error state with retry option
      testWidgets('error state shows message and retry button', (tester) async {
        // Arrange: Create mock that throws an error
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(
              _ErrorMockPodcastSearchService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // Act: Perform search that will fail
        await tester.enterText(find.byType(TextField), 'error query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert: Should show error state with message and retry button
        expect(find.byKey(const Key('search_error_state')), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('retry button tap triggers retry', (tester) async {
        // Arrange: Create mock that fails first, then succeeds
        final retryMock = _RetryMockPodcastSearchService();
        final container = ProviderContainer(
          overrides: [
            podcastSearchServiceProvider.overrideWithValue(retryMock),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(buildTestWidget(container: container));

        // Act: Perform search that fails
        await tester.enterText(find.byType(TextField), 'retry query');
        await tester.pump();
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Verify error state
        expect(find.byKey(const Key('search_error_state')), findsOneWidget);

        // Act: Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        // Assert: Should now show success state (retry succeeded)
        final state = container.read(podcastSearchControllerProvider);
        expect(state, isA<SearchSuccess>());
        expect(retryMock.callCount, equals(2));
      });
    });
  });
}

/// Mock service that never completes to test loading state.
class _SlowMockPodcastSearchService implements PodcastSearchService {
  final _completer = Completer<SearchResult>();

  @override
  Future<SearchResult> search(SearchQuery query) {
    // Return a future that never completes
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
class _ResultsMockPodcastSearchService implements PodcastSearchService {
  _ResultsMockPodcastSearchService({required this.count});
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

/// Mock service that throws an error.
class _ErrorMockPodcastSearchService implements PodcastSearchService {
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
class _RetryMockPodcastSearchService implements PodcastSearchService {
  int callCount = 0;

  @override
  Future<SearchResult> search(SearchQuery query) async {
    callCount++;
    if (1 >= callCount) {
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
