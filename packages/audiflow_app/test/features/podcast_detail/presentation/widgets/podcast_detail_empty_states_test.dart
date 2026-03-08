import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_detail_empty_states.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  Widget buildSliverTestWidget(Widget sliver) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: CustomScrollView(slivers: [sliver])),
    );
  }

  group('PodcastDetailNoFeedUrlState', () {
    testWidgets('shows RSS feed icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailNoFeedUrlState()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.rss_feed_outlined), findsOneWidget);
    });

    testWidgets('shows feed URL missing text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailNoFeedUrlState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Feed URL not available'), findsOneWidget);
    });

    testWidgets('shows feed URL missing subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailNoFeedUrlState()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('This podcast does not have a feed URL'),
        findsOneWidget,
      );
    });
  });

  group('PodcastDetailErrorState', () {
    testWidgets('shows error icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PodcastDetailErrorState(error: 'Network error', onRetry: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows failed to load episodes title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PodcastDetailErrorState(error: 'Network error', onRetry: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to load episodes'), findsOneWidget);
    });

    testWidgets('shows the error message passed in', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          PodcastDetailErrorState(
            error: 'Connection timed out',
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Connection timed out'), findsOneWidget);
    });

    testWidgets('shows retry button with text and refresh icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          PodcastDetailErrorState(error: 'Error', onRetry: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('tapping retry calls the onRetry callback', (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(
        buildTestWidget(
          PodcastDetailErrorState(
            error: 'Error',
            onRetry: () => retryCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });
  });

  group('PodcastDetailEmptyFilterState', () {
    testWidgets('shows filter icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailEmptyFilterState()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list_off), findsOneWidget);
    });

    testWidgets('shows no matching episodes text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailEmptyFilterState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No matching episodes'), findsOneWidget);
    });

    testWidgets('shows try different filter text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailEmptyFilterState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Try a different filter'), findsOneWidget);
    });
  });

  group('PodcastDetailEmptyPlaylistState', () {
    testWidgets('shows folder icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailEmptyPlaylistState()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
    });

    testWidgets('shows no episodes found text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailEmptyPlaylistState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No episodes found'), findsOneWidget);
    });

    testWidgets('shows playlist empty text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const PodcastDetailEmptyPlaylistState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('This playlist has no episodes'), findsOneWidget);
    });
  });

  group('PodcastDetailSearchEmptyState', () {
    testWidgets('shows no results found text inside CustomScrollView', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSliverTestWidget(const PodcastDetailSearchEmptyState()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });
  });
}
