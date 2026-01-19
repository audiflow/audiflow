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

      // Find IconButton with search icon (Requirement 1.2)
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
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
      await tester.tap(find.byIcon(Icons.search));
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
      await tester.tap(find.byIcon(Icons.search));
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
  });
}
