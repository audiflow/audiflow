import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_detail_header.dart';
import 'package:audiflow_app/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testPodcast = Podcast(
    id: 'test-id',
    name: 'Test Podcast',
    artistName: 'Test Artist',
    feedUrl: 'https://example.com/feed.xml',
  );

  const testPodcastWithGenres = Podcast(
    id: 'test-id',
    name: 'Test Podcast',
    artistName: 'Test Artist',
    genres: ['Technology', 'Science'],
    feedUrl: 'https://example.com/feed.xml',
  );

  const testPodcastNoArtwork = Podcast(
    id: 'test-id',
    name: 'Test Podcast',
    artistName: 'Test Artist',
    feedUrl: 'https://example.com/feed.xml',
  );

  Widget buildTestWidget(ProviderContainer container, Podcast podcast) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PodcastDetailHeader(podcast: podcast),
          ),
        ),
      ),
    );
  }

  group('PodcastDetailHeader', () {
    testWidgets('shows podcast title', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      expect(find.text('Test Podcast'), findsOneWidget);
    });

    testWidgets('shows artist name', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      expect(find.text('Test Artist'), findsOneWidget);
    });

    testWidgets('shows genres when present', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestWidget(container, testPodcastWithGenres),
      );
      await tester.pumpAndSettle();

      expect(find.text('Technology, Science'), findsOneWidget);
    });

    testWidgets('hides genres when empty', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      // No genres text should exist besides
      // podcast name and artist name.
      final textWidgets = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .toList();
      expect(textWidgets.any((t) => t != null && t.contains(', ')), isFalse);
    });

    testWidgets('shows podcast icon placeholder when no artwork', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcastNoArtwork));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.podcasts), findsOneWidget);
    });

    testWidgets('shows Subscribe button when not subscribed', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      expect(find.text('Subscribe'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows Subscribed with check icon when subscribed', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(true)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      expect(find.text('Subscribed'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows loading state for subscription button', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _NeverCompleteController()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      // Pump a frame to render loading state.
      await tester.pump();
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

/// Fake controller that immediately returns a value.
class _FakeSubscriptionController extends SubscriptionController {
  _FakeSubscriptionController(this._isSubscribed);
  final bool _isSubscribed;

  @override
  Future<bool> build(String itunesId) async => _isSubscribed;
}

/// Fake controller that never completes to keep loading.
class _NeverCompleteController extends SubscriptionController {
  @override
  Future<bool> build(String itunesId) {
    return Completer<bool>().future;
  }
}
