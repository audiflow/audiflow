import 'dart:async';

import 'package:audiflow_app/features/podcast_detail/presentation/widgets/detail_hero_layout.dart';
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
    const phoneSize = Size(390, 844);
    const tabletSize = Size(820, 1180);

    void useViewSize(WidgetTester tester, Size size) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    // The default 800x600 test view is tablet sized (shortest side 600),
    // so the shared cases run on a phone view.
    Future<void> pumpOnPhone(WidgetTester tester, Widget widget) {
      useViewSize(tester, phoneSize);
      return tester.pumpWidget(widget);
    }

    Future<void> pumpHeader(WidgetTester tester, Size size) async {
      useViewSize(tester, size);
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
    }

    Rect artworkRect(WidgetTester tester) =>
        tester.getRect(find.byKey(PodcastDetailHeader.artworkKey));

    testWidgets('a tablet puts the artwork left of the content', (
      tester,
    ) async {
      await pumpHeader(tester, tabletSize);

      final title = find.text('Test Podcast');
      check(artworkRect(tester).right).isLessThan(tester.getRect(title).left);
      check(artworkRect(tester).size).equals(const Size(180, 180));
      // Square column: top inset 8 + artwork 180 + gap 16.
      check(
        tester.getSize(find.byKey(DetailHeroLayout.artworkColumnKey)),
      ).equals(const Size(204, 204));
      check(tester.widget<Text>(title).textAlign).equals(TextAlign.start);
      // Content is left-aligned, so the pill starts where the title does.
      check(
        tester.getRect(find.byType(FilledButton)).left,
      ).equals(tester.getRect(title).left);
    });

    testWidgets('a long title keeps the full hero style on a tablet', (
      tester,
    ) async {
      useViewSize(tester, tabletSize);
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(true)),
        ],
      );
      addTearDown(container.dispose);
      const longName = 'A Podcast Name Long Enough To Shrink';
      await tester.pumpWidget(
        buildTestWidget(container, testPodcast.copyWith(name: longName)),
      );
      await tester.pumpAndSettle();

      final title = tester.widget<Text>(find.text(longName));
      check(title.style?.fontSize).equals(AppTextStyles.heroTitle.fontSize);
      // Short content: the hero ends with the square artwork column.
      check(
        tester.getSize(find.byType(PodcastDetailHeader)).height,
      ).equals(204);
    });

    testWidgets('a phone keeps the artwork above the content', (tester) async {
      await pumpHeader(tester, phoneSize);

      final titleRect = tester.getRect(find.text('Test Podcast'));
      check(artworkRect(tester).bottom).isLessThan(titleRect.top);
      check(artworkRect(tester).center.dx).equals(titleRect.center.dx);
      check(find.byKey(DetailHeroLayout.artworkColumnKey).evaluate()).isEmpty();
    });

    testWidgets('shows podcast title', (tester) async {
      final container = ProviderContainer(
        overrides: [
          subscriptionControllerProvider(
            'test-id',
          ).overrideWith(() => _FakeSubscriptionController(false)),
        ],
      );
      addTearDown(container.dispose);

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(
        tester,
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(
        tester,
        buildTestWidget(container, testPodcastNoArtwork),
      );
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(
        tester,
        buildTestWidget(container, testPodcastNoArtwork),
      );
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
      await tester.pumpAndSettle();

      // Verify SelectionArea wraps the header content
      expect(find.byType(SelectionArea), findsOneWidget);

      // Verify the podcast title text is present within the SelectionArea
      final titleFinder = find.text('Test Podcast');
      expect(titleFinder, findsOneWidget);
    });

    group('after subscribing', () {
      Future<_FlippingController> pumpUnsubscribed(
        WidgetTester tester, {
        Size size = phoneSize,
      }) async {
        final controller = _FlippingController();
        final container = ProviderContainer(
          overrides: [
            subscriptionControllerProvider(
              'test-id',
            ).overrideWith(() => controller),
          ],
        );
        addTearDown(container.dispose);
        useViewSize(tester, size);
        await tester.pumpWidget(buildTestWidget(container, testPodcast));
        await tester.pumpAndSettle();
        return controller;
      }

      testWidgets('a slow subscribe keeps the pill in place', (tester) async {
        final controller = await pumpUnsubscribed(tester);
        final hold = controller.hold = Completer<void>();
        final height = tester.getSize(find.byType(PodcastDetailHeader)).height;

        await tester.tap(find.text('Subscribe'));
        for (var frame = 0; frame < 5; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
          check(find.text('Subscribe').evaluate()).length.equals(1);
          check(
            tester.getSize(find.byType(PodcastDetailHeader)).height,
          ).equals(height);
        }

        hold.complete();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        check(find.text('Subscribed').evaluate()).length.equals(1);
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
      });

      testWidgets('unsubscribing mid-confirmation drops the confirmation', (
        tester,
      ) async {
        final controller = await pumpUnsubscribed(tester);

        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        check(find.text('Subscribed').evaluate()).length.equals(1);

        // As the `...` menu would, well inside the 700ms hold.
        await controller.toggleSubscription(
          tester.element(find.byType(PodcastDetailHeader)),
          testPodcast,
        );
        await tester.pumpAndSettle();

        check(find.text('Subscribed').evaluate()).isEmpty();
        check(find.text('Subscribe').evaluate()).length.equals(1);
      });

      testWidgets('on a tablet the pill stays on the start edge', (
        tester,
      ) async {
        await pumpUnsubscribed(tester, size: tabletSize);
        final start = tester.getTopLeft(find.text('Test Podcast')).dx;

        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));

        // Mid-resize, a centered box would push its content past the start
        // edge while the box is narrower than the pills.
        final content = find
            .descendant(
              of: find.byType(AnimatedSize),
              matching: find.byType(Stack),
            )
            .first;
        check(tester.getTopLeft(content).dx).equals(start);
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
      });

      testWidgets('confirms, then collapses the pill', (tester) async {
        await pumpUnsubscribed(tester);

        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        check(find.text('Subscribed').evaluate()).length.equals(1);

        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();
        check(find.byType(FilledButton).evaluate()).isEmpty();
      });

      testWidgets('iOS Reduce Motion closes the space without sizing', (
        tester,
      ) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(reduceMotion: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await pumpUnsubscribed(tester);
        await tester.pump();

        check(find.byType(AnimatedSize).evaluate()).isEmpty();
        // The switcher still fades; it only stops scaling.
        final switcher = find.byType(AnimatedSwitcher);
        check(switcher.evaluate()).length.equals(1);
        check(
          find
              .descendant(of: switcher, matching: find.byType(ScaleTransition))
              .evaluate(),
        ).isEmpty();
      });

      testWidgets('without Reduce Motion the space closes by sizing', (
        tester,
      ) async {
        await pumpUnsubscribed(tester);
        await tester.pump();

        check(find.byType(AnimatedSize).evaluate()).length.equals(1);
      });

      testWidgets('the confirmation cannot be tapped', (tester) async {
        final controller = await pumpUnsubscribed(tester);

        await tester.tap(find.text('Subscribe'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.text('Subscribed'), warnIfMissed: false);
        await tester.pumpAndSettle();

        check(controller.toggles).equals(1);
      });
    });

    testWidgets('the pill appears without animating on first load', (
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

      await pumpOnPhone(tester, buildTestWidget(container, testPodcast));
      await tester.pump();
      await tester.pump();
      final firstHeight = tester
          .getSize(find.byType(PodcastDetailHeader))
          .height;
      await tester.pumpAndSettle();

      check(find.text('Subscribe').evaluate()).length.equals(1);
      check(
        tester.getSize(find.byType(PodcastDetailHeader)).height,
      ).equals(firstHeight);
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

/// Starts unsubscribed and subscribes through a loading state, as the real
/// controller does.
class _FlippingController extends SubscriptionController {
  var toggles = 0;

  /// When set, the toggle stays loading until this completes, like a slow
  /// write.
  Completer<void>? hold;

  @override
  Future<bool> build(String itunesId) async => false;

  @override
  Future<bool> toggleSubscription(
    BuildContext context,
    Podcast podcast, {
    SubscribeSource source = SubscribeSource.discovery,
  }) async {
    toggles++;
    final next = !(state.value ?? false);
    state = const AsyncValue.loading();
    await (hold?.future ?? Future<void>.value());
    state = AsyncData(next);
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
