import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_detail_header.dart';
import 'package:audiflow_app/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart' show SubscribeSource;
import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
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
        theme: AppTheme.light(),
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

      check(find.text('Test Artist · Technology').evaluate()).length.equals(1);
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
      check(textWidgets.any((t) => t != null && t.contains(' · '))).isFalse();
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

    testWidgets('hides the subscribe pill when subscribed', (tester) async {
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

      // Unsubscribing lives in the more menu, so the hero shows nothing.
      check(find.text('Subscribed').evaluate()).isEmpty();
      check(find.byType(FilledButton).evaluate()).isEmpty();
    });

    testWidgets('shows no pill while subscription state loads', (tester) async {
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

      // Nothing until the state is known, so a subscribed podcast does not
      // flash a pill that then disappears.
      check(find.byType(FilledButton).evaluate()).isEmpty();
    });

    testWidgets('shows Retry button on error state', (tester) async {
      final container = ProviderContainer(
        // No automatic retry, so no timer outlives the test.
        retry: (_, _) => null,
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _ErrorController()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('hero artwork is 180 and the title is centered', (
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

      check(
        tester.getSize(find.byKey(PodcastDetailHeader.artworkKey)),
      ).equals(const Size(180, 180));
      final title = tester.widget<Text>(find.text('Test Podcast'));
      check(title.textAlign).equals(TextAlign.center);
      check(title.style?.fontSize).equals(AppTextStyles.heroTitle.fontSize);
    });

    testWidgets('subscribe is an accent filled pill', (tester) async {
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

      final style = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .style!;
      check(style.backgroundColor!.resolve({})).equals(AppColors.light.accent);
      check(style.shape!.resolve({})).isA<StadiumBorder>();
    });

    testWidgets('podcast title is selectable', (tester) async {
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

      // Verify SelectionArea wraps the header content
      expect(find.byType(SelectionArea), findsOneWidget);

      // Verify the podcast title text is present within the SelectionArea
      final titleFinder = find.text('Test Podcast');
      expect(titleFinder, findsOneWidget);
    });
  });

  _toggleTests();
}

void _toggleTests() {
  group('togglePodcastSubscription', () {
    const podcast = Podcast(
      id: 'test-id',
      name: 'Test Podcast',
      artistName: 'Test Artist',
      feedUrl: 'https://example.com/feed.xml',
    );

    Future<_CountingController> run(
      WidgetTester tester, {
      required bool actual,
      required bool expected,
    }) async {
      final controller = _CountingController(actual);
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => controller),
        ],
      );
      addTearDown(container.dispose);
      // Listened, not read: a bare read of the auto-disposed provider
      // leaves a disposal timer pending past the test.
      final subscription = container.listen(
        subscriptionControllerProvider('test-id'),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(subscriptionControllerProvider('test-id').future);
      late BuildContext context;
      late WidgetRef widgetRef;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer(
              builder: (c, ref, _) {
                context = c;
                widgetRef = ref;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await togglePodcastSubscription(
        context: context,
        ref: widgetRef,
        podcast: podcast,
        source: SubscribeSource.discovery,
        expectSubscribed: expected,
      );
      return controller;
    }

    testWidgets('toggles when the state matches what was offered', (
      tester,
    ) async {
      final controller = await run(tester, actual: true, expected: true);
      check(controller.toggles).equals(1);
    });

    testWidgets('does nothing when the state changed underneath', (
      tester,
    ) async {
      // "Subscribe" was offered, but the podcast turned out subscribed:
      // a toggle would unsubscribe it.
      final controller = await run(tester, actual: true, expected: false);
      check(controller.toggles).equals(0);
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

/// Records toggles instead of touching the repository.
class _CountingController extends SubscriptionController {
  _CountingController(this._isSubscribed);
  final bool _isSubscribed;
  var toggles = 0;

  @override
  Future<bool> build(String itunesId) async => _isSubscribed;

  @override
  Future<bool> toggleSubscription(
    BuildContext context,
    Podcast podcast, {
    SubscribeSource source = SubscribeSource.discovery,
  }) async {
    toggles++;
    return true;
  }
}

/// Fake controller that never completes to keep loading.
class _NeverCompleteController extends SubscriptionController {
  @override
  Future<bool> build(String itunesId) {
    return Completer<bool>().future;
  }
}

/// Fake controller that immediately throws an error.
class _ErrorController extends SubscriptionController {
  @override
  Future<bool> build(String itunesId) async {
    throw Exception('Network error');
  }
}
