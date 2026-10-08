import 'package:audiflow_app/features/search/presentation/widgets/podcast_search_result_tile.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastSearchResultTile', () {
    /// Creates a test podcast with all metadata fields populated.
    Podcast createTestPodcast({
      String id = 'test-id-123',
      String name = 'Test Podcast Title',
      String artistName = 'Test Author Name',
      List<String> genres = const ['Technology', 'Business', 'Comedy'],
      String? description = 'This is a test description for the podcast.',
      String? artworkUrl = 'https://example.com/artwork.jpg',
    }) {
      return Podcast(
        id: id,
        name: name,
        artistName: artistName,
        genres: genres,
        description: description,
        artworkUrl: artworkUrl,
      );
    }

    Widget buildTestWidget({
      required Podcast podcast,
      required VoidCallback onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PodcastSearchResultTile(podcast: podcast, onTap: onTap),
        ),
      );
    }

    group('renders podcast metadata fields', () {
      testWidgets('displays podcast title', (tester) async {
        final podcast = createTestPodcast(name: 'My Awesome Podcast');

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        expect(find.text('My Awesome Podcast'), findsOneWidget);
      });

      testWidgets('displays author name', (tester) async {
        final podcast = createTestPodcast(artistName: 'John Doe');

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        expect(find.text('John Doe'), findsOneWidget);
      });

      testWidgets('displays first genre from genres list', (tester) async {
        final podcast = createTestPodcast(
          genres: ['Science', 'Education', 'News'],
        );

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        expect(find.text('Science'), findsOneWidget);
      });

      testWidgets('leaves the description to the podcast screen', (
        tester,
      ) async {
        final podcast = createTestPodcast(
          description: 'A short podcast description.',
        );

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        expect(find.text('A short podcast description.'), findsNothing);
      });
    });

    group('artwork display', () {
      testWidgets('displays podcast artwork from URL', (tester) async {
        final podcast = createTestPodcast(
          artworkUrl: 'https://example.com/podcast-image.jpg',
        );

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        check(find.byType(ArtworkImage).evaluate()).length.equals(1);
      });

      testWidgets('displays placeholder when artwork URL is null', (
        tester,
      ) async {
        final podcast = createTestPodcast(artworkUrl: null);

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        // Should find a placeholder icon when no artwork
        expect(find.byIcon(Icons.podcasts), findsOneWidget);
      });
    });

    group('handles missing optional fields', () {
      testWidgets('renders without description when null', (tester) async {
        final podcast = createTestPodcast(description: null);

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        // Widget should render successfully
        expect(find.byType(PodcastSearchResultTile), findsOneWidget);
        // Title should still be visible
        expect(find.text('Test Podcast Title'), findsOneWidget);
      });

      testWidgets('renders without genre when genres list is empty', (
        tester,
      ) async {
        final podcast = createTestPodcast(genres: []);

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () {}),
        );

        // Widget should render successfully
        expect(find.byType(PodcastSearchResultTile), findsOneWidget);
        // Title should still be visible
        expect(find.text('Test Podcast Title'), findsOneWidget);
      });
    });

    group('tap gesture handling', () {
      testWidgets('tap triggers onTap callback', (tester) async {
        var tapCount = 0;
        final podcast = createTestPodcast();

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () => tapCount++),
        );

        await tester.tap(find.byType(PodcastSearchResultTile));
        await tester.pump();

        expect(tapCount, equals(1));
      });

      testWidgets('multiple taps trigger callback multiple times', (
        tester,
      ) async {
        var tapCount = 0;
        final podcast = createTestPodcast();

        await tester.pumpWidget(
          buildTestWidget(podcast: podcast, onTap: () => tapCount++),
        );

        await tester.tap(find.byType(PodcastSearchResultTile));
        await tester.pump();
        await tester.tap(find.byType(PodcastSearchResultTile));
        await tester.pump();
        await tester.tap(find.byType(PodcastSearchResultTile));
        await tester.pump();

        expect(tapCount, equals(3));
      });
    });
  });
}
