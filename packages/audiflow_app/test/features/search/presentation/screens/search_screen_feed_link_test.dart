import 'dart:async';

import 'package:audiflow_app/features/search/presentation/controllers/feed_link_controller.dart';
import 'package:audiflow_app/features/search/presentation/controllers/search_controller.dart';
import 'package:audiflow_app/features/search/presentation/screens/search_screen.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/l10n/app_localizations_en.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/search_mocks.dart';

/// Answers every link with [result], or throws [error].
class _FakeFeedLinkResolver implements FeedLinkResolver {
  _FakeFeedLinkResolver({this.result, this.error});

  final Podcast? result;
  final FeedLinkException? error;
  final List<FeedLink> resolved = [];

  @override
  Future<Podcast> resolve(FeedLink link) async {
    resolved.add(link);
    final error = this.error;
    if (error != null) throw error;
    return result!;
  }
}

void main() {
  const feedUrl = 'https://example.com/feed.xml';
  final l10n = AppLocalizationsEn();

  late MockPodcastSearchService searchService;

  setUp(() => searchService = MockPodcastSearchService());

  Future<void> pumpScreen(
    WidgetTester tester,
    _FakeFeedLinkResolver resolver,
  ) async {
    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(searchService),
        appSettingsRepositoryProvider.overrideWithValue(
          FakeAppSettingsRepository(),
        ),
        analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        feedLinkResolverProvider.overrideWithValue(resolver),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, _) => const SearchScreen(),
          routes: [
            GoRoute(
              path: 'podcast/:id',
              builder: (_, state) =>
                  Text('detail ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterLink(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    // Past the search debounce, to prove no search fires.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('a pasted link shows the panel instead of searching', (
    tester,
  ) async {
    await pumpScreen(tester, _FakeFeedLinkResolver());

    await enterLink(tester, feedUrl);

    final panel = find.byKey(const Key('feed_link_panel'));
    expect(panel, findsOneWidget);
    expect(
      find.descendant(of: panel, matching: find.text(feedUrl)),
      findsOneWidget,
    );
    expect(searchService.searchCallCount, 0);
  });

  testWidgets('opening the link pushes the podcast preview', (tester) async {
    const podcast = Podcast(
      id: '42',
      name: 'Show',
      artistName: 'Host',
      feedUrl: feedUrl,
    );
    final resolver = _FakeFeedLinkResolver(result: podcast);
    await pumpScreen(tester, resolver);
    await enterLink(tester, feedUrl);

    await tester.tap(find.text(l10n.feedLinkOpen));
    await tester.pumpAndSettle();

    expect(resolver.resolved, [const FeedLink.direct(url: feedUrl)]);
    expect(find.text('detail ${podcast.id}'), findsOneWidget);
  });

  testWidgets('a failed link shows why, with a retry', (tester) async {
    final resolver = _FakeFeedLinkResolver(
      error: const FeedLinkException(FeedLinkFailure.notPodcastFeed),
    );
    await pumpScreen(tester, resolver);
    await enterLink(tester, feedUrl);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text(l10n.feedLinkErrorNotFeed), findsOneWidget);
    expect(find.text(l10n.commonRetry), findsOneWidget);
  });

  testWidgets('an unsupported link names its platform', (tester) async {
    final resolver = _FakeFeedLinkResolver(
      error: const FeedLinkException(
        FeedLinkFailure.unsupportedLink,
        platformName: 'Spotify',
      ),
    );
    await pumpScreen(tester, resolver);
    await enterLink(tester, 'https://open.spotify.com/show/abc');

    await tester.tap(find.text(l10n.feedLinkOpen));
    await tester.pumpAndSettle();

    expect(find.text(l10n.feedLinkErrorUnsupported('Spotify')), findsOneWidget);
  });

  testWidgets('editing the field clears a failure', (tester) async {
    final resolver = _FakeFeedLinkResolver(
      error: const FeedLinkException(FeedLinkFailure.network),
    );
    await pumpScreen(tester, resolver);
    await enterLink(tester, feedUrl);
    await tester.tap(find.text(l10n.feedLinkOpen));
    await tester.pumpAndSettle();

    await enterLink(tester, '$feedUrl?v=2');

    expect(find.text(l10n.errorNetwork), findsNothing);
    expect(find.text(l10n.feedLinkOpen), findsOneWidget);
  });

  group('add by URL', () {
    testWidgets('rejects text that is not a link', (tester) async {
      await pumpScreen(tester, _FakeFeedLinkResolver());
      await tester.tap(find.byKey(const Key('search_add_by_url')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('feed_url_dialog_field')),
        'not a link',
      );
      await tester.tap(find.widgetWithText(FilledButton, l10n.feedLinkOpen));
      await tester.pumpAndSettle();

      expect(find.text(l10n.feedLinkDialogInvalid), findsOneWidget);
    });

    testWidgets('opens an entered link', (tester) async {
      final resolver = _FakeFeedLinkResolver(
        error: const FeedLinkException(FeedLinkFailure.notFound),
      );
      await pumpScreen(tester, resolver);
      await tester.tap(find.byKey(const Key('search_add_by_url')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('feed_url_dialog_field')),
        'feed://example.com/feed.xml',
      );
      await tester.tap(find.widgetWithText(FilledButton, l10n.feedLinkOpen));
      await tester.pumpAndSettle();

      expect(resolver.resolved, [const FeedLink.direct(url: feedUrl)]);
      expect(find.text(l10n.feedLinkErrorNotFound), findsOneWidget);
    });
  });

  test('controller reports an Error as a failure', () async {
    final container = ProviderContainer(
      overrides: [
        feedLinkResolverProvider.overrideWithValue(
          _DeferredFeedLinkResolver(Future.error(StateError('db'))),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      feedLinkControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final opened = await container
        .read(feedLinkControllerProvider.notifier)
        .open(const FeedLink.direct(url: feedUrl));

    expect(opened, isNull);
    expect(
      container.read(feedLinkControllerProvider),
      isA<FeedLinkFailed>().having((s) => s.error, 'error', isNull),
    );
  });

  test('controller drops a result once the link is reset', () async {
    final pending = Completer<Podcast>();
    final container = ProviderContainer(
      overrides: [
        feedLinkResolverProvider.overrideWithValue(
          _DeferredFeedLinkResolver(pending.future),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      feedLinkControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    final controller = container.read(feedLinkControllerProvider.notifier);

    final opened = controller.open(const FeedLink.direct(url: feedUrl));
    controller.reset();
    pending.complete(
      const Podcast(id: '1', name: 'Show', artistName: '', feedUrl: feedUrl),
    );

    expect(await opened, isNull);
    expect(container.read(feedLinkControllerProvider), isA<FeedLinkIdle>());
  });

  test('controller ignores an earlier attempt at the same link', () async {
    final first = Completer<Podcast>();
    final second = Completer<Podcast>();
    final resolver = _QueuedFeedLinkResolver([first.future, second.future]);
    final container = ProviderContainer(
      overrides: [feedLinkResolverProvider.overrideWithValue(resolver)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      feedLinkControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    final controller = container.read(feedLinkControllerProvider.notifier);
    const link = FeedLink.direct(url: feedUrl);
    const podcast = Podcast(
      id: '1',
      name: 'Show',
      artistName: '',
      feedUrl: feedUrl,
    );

    final stale = controller.open(link);
    controller.reset();
    final latest = controller.open(link);
    first.completeError(const FeedLinkException(FeedLinkFailure.network));
    second.complete(podcast);

    expect(await stale, isNull);
    expect(await latest, podcast);
    expect(container.read(feedLinkControllerProvider), isA<FeedLinkIdle>());
  });
}

class _DeferredFeedLinkResolver implements FeedLinkResolver {
  _DeferredFeedLinkResolver(this._result);

  final Future<Podcast> _result;

  @override
  Future<Podcast> resolve(FeedLink link) => _result;
}

/// Answers each resolve with the next of [_results].
class _QueuedFeedLinkResolver implements FeedLinkResolver {
  _QueuedFeedLinkResolver(this._results);

  final List<Future<Podcast>> _results;

  @override
  Future<Podcast> resolve(FeedLink link) => _results.removeAt(0);
}
