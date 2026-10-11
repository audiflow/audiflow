// Captures the App Store / Google Play listing screenshots.
//
// Boots the production container (see `bootstrapAppContainer`) against a
// throwaway database, seeds subscriptions, then walks the app and hands each
// capture to the host driver (`test_driver/integration_test.dart`). Feeds,
// artwork and presets come from the live network on purpose: the store shows
// real shows, and preset playlists only appear for real feed URLs.
//
// Run through audiflow-store-assets' `tools/capture_screenshots.py`, which
// picks the device and passes SCREENSHOT_LOCALE (`ja` or `en`).
import 'dart:async';
import 'dart:io';

import 'package:audiflow_app/app/app_lifecycle_observer.dart';
import 'package:audiflow_app/features/library/presentation/widgets/subscription_list_tile.dart';
import 'package:audiflow_app/features/player/presentation/screens/player_screen.dart';
import 'package:audiflow_app/features/player/presentation/widgets/mini_player.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/screens/podcast_detail_screen.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/inline_group_card.dart';
import 'package:audiflow_app/features/podcast_detail/presentation/widgets/menu_selector_button.dart';
import 'package:audiflow_app/features/review_prompt/presentation/review_prompt_gate.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_app/main.dart';
import 'package:audiflow_app/routing/app_router.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screenshot_helpers.dart';
import 'screenshot_shows.dart';

const _locale = String.fromEnvironment('SCREENSHOT_LOCALE', defaultValue: 'ja');

/// Library tab index in the shell route (0=search, 1=library, 2=queue).
const _libraryTabIndex = 1;

/// Where the Player capture sits in the episode, so the scrubber is not at 0.
const _playerPosition = Duration(minutes: 12, seconds: 34);

const _queueLength = 4;

const _parentalPin = '2580';

/// The router's onboarding-completion flag (`_kOnboardingCompletedKey`).
const _onboardingCompletedKey = 'onboarding.carousel_completed_v1';

final _l10n = lookupAppLocalizations(Locale(_locale));
final _scenario = scenarioForLocale(_locale);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Simulators only run debug builds; hide the DEBUG ribbon from captures.
  WidgetsApp.debugAllowBannerOverride = false;

  testWidgets('store screenshots ($_locale)', (tester) async {
    final restoreErrorHandler = _reportOverflowsAsWarnings();
    try {
      await _captureAll(tester, binding);
    } finally {
      restoreErrorHandler();
    }
  });
}

Future<void> _captureAll(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  final container = await _bootContainer();
  final shows = await _subscribe(container);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AppLifecycleObserver(child: MyApp()),
    ),
  );
  final capture = Capturer(binding, tester);
  await capture.prepare();
  await _waitForLibrary(tester, shows.values);
  await _waitForFeedSync(tester, container);

  await _captureShowScreens(tester, capture, shows);
  await _capturePlayer(tester, capture, container, shows);
  await _captureQueue(tester, capture, container, shows);
  await _captureIntro(tester, capture);
  // Last: restricted mode hides the Search tab.
  await _captureParental(tester, capture, container);
}

/// Prints layout overflows as `SCREENSHOT_WARNING` lines instead of failing.
///
/// An overflow is a real layout bug worth fixing, but it should not block a
/// store capture; tools/capture_screenshots.py relays these lines. Returns a
/// callback that restores the framework's handler; the test binding fails a
/// test whose body ends with the handler still replaced.
VoidCallback _reportOverflowsAsWarnings() {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    if (!message.contains('overflowed')) return original?.call(details);
    // ignore: avoid_print
    print('SCREENSHOT_WARNING: $message (${details.context})');
  };
  return () => FlutterError.onError = original;
}

/// Boots the production container with first-launch gates and store
/// prompts switched off, so nothing covers the screens being captured.
Future<ProviderContainer> _bootContainer() async {
  FlavorConfig.initialize(FlavorConfig.dev);
  SharedPreferences.setMockInitialValues({
    SettingsKeys.privacyConsentAccepted: true,
    _onboardingCompletedKey: true,
    'review_prompt.status': 'optedOut',
    SettingsKeys.locale: _locale,
    SettingsKeys.lastTabIndex: _libraryTabIndex,
    SettingsKeys.searchCountry: _scenario.searchCountry,
  });
  final prefs = await SharedPreferences.getInstance();

  return bootstrapAppContainer(
    presetConfigBaseUrl:
        'https://audiflow.github.io/audiflow-preset/assets-dev/v7',
    prefs: prefs,
    firebaseAnalytics: null,
    databaseDirectory: await _freshDatabaseDirectory(),
    overrides: [
      reviewPromptForegroundCheckProvider.overrideWithValue(() => false),
      forceUpdateRepositoryProvider.overrideWithValue(NoUpdateRepository()),
      feedSyncServiceProvider.overrideWith(TrackedFeedSyncService.new),
    ],
  );
}

Future<String> _freshDatabaseDirectory() async {
  final temp = await getTemporaryDirectory();
  final directory = Directory('${temp.path}/store_screenshots');
  // A leftover database would carry the previous run's state.
  if (directory.existsSync()) directory.deleteSync(recursive: true);
  await directory.create(recursive: true);
  return directory.path;
}

/// Subscribes the way an OPML import does; the launch feed sync then fills
/// in artwork and episodes from the network.
Future<Map<ScreenshotShow, Subscription>> _subscribe(
  ProviderContainer container,
) async {
  final repository = container.read(subscriptionRepositoryProvider);
  await OpmlImportService(repository: repository).importEntries([
    for (final show in _scenario.all)
      OpmlEntry(
        title: await _channelTitle(container, show.feedUrl),
        feedUrl: show.feedUrl,
      ),
  ]);
  return {
    for (final show in _scenario.all)
      show: (await repository.getByFeedUrl(show.feedUrl))!,
  };
}

/// Reads the channel title from the feed with the app's own feed parser.
///
/// The feed sync never rewrites a subscription's title, so an OPML-style
/// subscribe must carry the real one.
Future<String> _channelTitle(
  ProviderContainer container,
  String feedUrl,
) async {
  final response = await container
      .read(dioProvider)
      .get<String>(feedUrl, options: Options(responseType: ResponseType.plain));
  final xml = response.data;
  if (xml == null || xml.isEmpty) throw StateError('Empty feed: $feedUrl');
  final parsed = await container
      .read(feedParserServiceProvider)
      .parseFromString(xml);
  return parsed.podcast.title;
}

/// Waits until every subscription's artwork has arrived from the feed sync.
Future<void> _waitForLibrary(
  WidgetTester tester,
  Iterable<Subscription> subscriptions,
) async {
  for (final subscription in subscriptions) {
    await pumpUntilFound(
      tester,
      find.byKey(ValueKey(subscription.itunesId)),
      settleFor: 0,
    );
  }
  await pumpUntilFound(tester, find.byType(SubscriptionListTile), settleFor: 0);
}

/// Waits for the launch feed sync to finish storing episodes, so episode
/// counts on screen are final.
Future<void> _waitForFeedSync(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final feedSync = container.read(feedSyncServiceProvider);
  if (feedSync is! TrackedFeedSyncService) {
    throw StateError('feedSyncServiceProvider is not tracked');
  }
  FeedSyncResult? result;
  Object? failure;
  unawaited(
    feedSync.firstFullSync.then(
      (value) => result = value,
      onError: (Object error) => failure = error,
    ),
  );
  // Frames keep pumping while waiting so the library keeps rendering.
  final deadline = DateTime.now().add(const Duration(minutes: 3));
  while (result == null && failure == null) {
    if (deadline.isBefore(DateTime.now())) {
      throw TestFailure('Feed sync did not finish within 3 minutes');
    }
    await pumpFor(tester, const Duration(seconds: 1));
  }
  if (failure != null) throw TestFailure('Feed sync failed: $failure');
  if (0 < result!.errorCount) {
    throw TestFailure('Feed sync had errors: $result');
  }
}

Future<void> _captureShowScreens(
  WidgetTester tester,
  Capturer capture,
  Map<ScreenshotShow, Subscription> shows,
) async {
  await _openShow(tester, shows[_scenario.primary]!);
  await capture.take('shows');

  await _openSeriesTab(tester);
  // The open group menu shows that a show's playlists can be switched.
  await tapWhenFound(tester, _groupMenuButton, settleFor: 1);
  await capture.take('series');
  await _closeGroupMenu(tester);

  // The newest group is often a season that has only just started; the
  // second one has a full list.
  await tapWhenFound(tester, find.byType(InlineGroupCard).at(1), settleFor: 4);
  await capture.take('curated');
  await _goTo(tester, AppRoutes.library);
}

Future<void> _openShow(WidgetTester tester, Subscription subscription) async {
  await tapWhenFound(tester, find.byKey(ValueKey(subscription.itunesId)));
  // The episode list is fetched from the feed after the route opens.
  await pumpUntilFound(tester, find.byType(PodcastDetailScreen), settleFor: 6);
}

final _seriesTab = find.descendant(
  of: find.byKey(AppSegmentedControl.trackKey),
  matching: find.text(_l10n.podcastDetailSeriesTab),
);

Future<void> _openSeriesTab(WidgetTester tester) async {
  await tapWhenFound(tester, _seriesTab, settleFor: 4);
}

final _groupMenuButton = find.byWidgetPredicate(
  (widget) => widget is MenuSelectorButton,
);

/// Dismisses the group menu without changing the selected group.
Future<void> _closeGroupMenu(WidgetTester tester) async {
  Navigator.of(tester.element(find.byType(PopupMenuItem<int>).first)).pop();
  await pumpFor(tester, const Duration(seconds: 1));
}

/// Plays the chaptered show's newest episode from [_playerPosition] and
/// opens the full player, then pauses so the rest of the run is silent.
Future<void> _capturePlayer(
  WidgetTester tester,
  Capturer capture,
  ProviderContainer container,
  Map<ScreenshotShow, Subscription> shows,
) async {
  final subscription = shows[_scenario.chaptered]!;
  final episode = (await container
      .read(episodeRepositoryProvider)
      .getNewestByPodcastId(subscription.id))!;
  final player = container.read(audioPlayerControllerProvider.notifier);
  await player.play(
    episode.audioUrl,
    metadata: _nowPlayingInfo(episode, subscription),
    startAt: _playerPosition,
  );

  // Let the mini player finish sliding in, or the tap lands beside it.
  await pumpUntilFound(tester, find.byType(MiniPlayer), settleFor: 3);
  await tapWhenFound(tester, find.byType(MiniPlayer), settleFor: 0);
  await pumpUntilFound(tester, find.byType(PlayerScreen), settleFor: 5);
  await capture.take('player');

  await player.pause();
  Navigator.of(tester.element(find.byType(PlayerScreen))).pop();
  await pumpFor(tester, const Duration(seconds: 2));
}

NowPlayingInfo _nowPlayingInfo(Episode episode, Subscription subscription) {
  return NowPlayingInfo(
    episodeUrl: episode.audioUrl,
    episodeTitle: episode.title,
    podcastTitle: subscription.title,
    artworkUrl: episode.imageUrl ?? subscription.artworkUrl,
    totalDuration: episode.durationMs == null
        ? null
        : Duration(milliseconds: episode.durationMs!),
    episode: episode,
    itunesId: subscription.itunesId,
    episodeGuid: episode.guid,
    feedUrl: subscription.feedUrl,
  );
}

/// Queues the newest episode of each show, then fills up from the primary.
/// The chaptered show's newest episode is skipped: it is the one playing.
Future<void> _captureQueue(
  WidgetTester tester,
  Capturer capture,
  ProviderContainer container,
  Map<ScreenshotShow, Subscription> shows,
) async {
  final episodes = container.read(episodeRepositoryProvider);
  // A run of one series, then the next show: within a series a listener
  // plays oldest first, so the queue does too.
  final upNext = await _seriesRun(
    container,
    shows[_scenario.primary]!,
    _queueLength - 1,
  );
  final themed = await episodes.getNewestByPodcastId(
    shows[_scenario.themed]!.id,
  );
  if (themed != null && upNext.every((episode) => episode.id != themed.id)) {
    upNext.add(themed);
  }

  final queue = container.read(queueRepositoryProvider);
  for (final episode in upNext) {
    await queue.addToEnd(episode.id);
  }

  await _goTo(tester, AppRoutes.queue);
  await pumpFor(tester, const Duration(seconds: 3));
  await capture.take('queue');
}

/// The latest [length] episodes of [show]'s most recent series that has
/// that many, oldest first.
Future<List<Episode>> _seriesRun(
  ProviderContainer container,
  Subscription show,
  int length,
) async {
  // Auto-dispose: without a listener the provider is torn down mid-build.
  final provider = podcastSmartPlaylistsProvider(show.id);
  final keepAlive = container.listen(provider, (_, _) {});
  final SmartPlaylistGrouping? grouping;
  try {
    grouping = await container.read(provider.future);
  } finally {
    keepAlive.close();
  }
  final episodes = container.read(episodeRepositoryProvider);
  List<Episode>? latest;
  for (final playlist in grouping?.playlists ?? const <SmartPlaylist>[]) {
    for (final group in playlist.groups ?? const <SmartPlaylistGroup>[]) {
      final run = (await episodes.getByIds(group.episodeIds))
        ..sort(_byPublishedAt);
      if (run.length < length) continue;
      if (latest == null || 0 < _byPublishedAt(run.last, latest.last)) {
        latest = run;
      }
    }
  }
  if (latest == null) {
    throw StateError('${show.title} has no series of $length episodes');
  }
  return latest.sublist(latest.length - length);
}

int _byPublishedAt(Episode a, Episode b) {
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  return (a.publishedAt ?? epoch).compareTo(b.publishedAt ?? epoch);
}

/// The onboarding carousel's three pages, as the Search, Stations and
/// Smart Playlists slides. The router only shows the carousel before
/// onboarding is completed, so the flag is cleared for the visit.
Future<void> _captureIntro(WidgetTester tester, Capturer capture) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingCompletedKey, false);
  await _goTo(tester, AppRoutes.onboarding);
  await pumpUntilFound(
    tester,
    find.text(_l10n.onboardingPageSearchTitle),
    settleFor: 1,
  );
  await capture.take('search');
  for (final (name, title) in [
    ('stations', _l10n.onboardingPageStationsTitle),
    ('smart', _l10n.onboardingPageSmartPlaylistsTitle),
  ]) {
    await tapWhenFound(tester, find.byType(FilledButton), settleFor: 0);
    await pumpUntilFound(tester, find.text(title), settleFor: 1);
    await capture.take(name);
  }
  await prefs.setBool(_onboardingCompletedKey, true);
  await _goTo(tester, AppRoutes.library);
}

Future<void> _captureParental(
  WidgetTester tester,
  Capturer capture,
  ProviderContainer container,
) async {
  await container
      .read(parentalControlRepositoryProvider)
      .setupPin(_parentalPin);
  await _goTo(tester, '${AppRoutes.settings}/parental-control');
  await pumpUntilFound(
    tester,
    find.text(_l10n.parentalControlTitle),
    settleFor: 2,
  );
  await capture.take('parental');
}

/// Switches route through the app's router; tapping tabs would differ
/// between the phone bottom bar and the tablet top tabs.
Future<void> _goTo(WidgetTester tester, String location) async {
  GoRouter.of(rootNavigatorKey.currentContext!).go(location);
  // Let the route transition finish so the next tap hits the new screen.
  await pumpFor(tester, const Duration(seconds: 2));
}
