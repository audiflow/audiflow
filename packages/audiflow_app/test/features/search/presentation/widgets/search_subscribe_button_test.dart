import 'package:audiflow_app/features/search/presentation/widgets/search_subscribe_button.dart';
import 'package:audiflow_app/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _podcast = Podcast(
  id: '42',
  name: 'Show',
  artistName: 'Host',
  feedUrl: 'https://example.com/feed.xml',
);

class _RecordingHapticPlayer implements HapticPlayer {
  final played = <HapticToken>[];

  @override
  void play(HapticToken token) => played.add(token);

  @override
  void prepare(HapticToken token) {}
}

void main() {
  Future<_CountingController> pump(
    WidgetTester tester, {
    required bool subscribed,
    Podcast podcast = _podcast,
    _RecordingFeedSync? feedSync,
    VoidCallback? onRowTap,
    bool fails = false,
    HapticPlayer haptics = const NoopHapticPlayer(),
  }) async {
    final controller = _CountingController(subscribed, fails: fails);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionControllerProvider('42').overrideWith(() => controller),
          feedSyncServiceProvider.overrideWithValue(
            feedSync ?? _RecordingFeedSync(),
          ),
        ],
        child: HapticsScope(
          player: haptics,
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              // Inside a tappable row, as in the search results.
              body: Center(
                child: InkWell(
                  onTap: onRowTap,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SearchSubscribeButton(podcast: podcast),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('subscribes with one tap', (tester) async {
    final controller = await pump(tester, subscribed: false);
    check(find.byIcon(Icons.add_rounded).evaluate()).length.equals(1);
    await tester.tap(find.byType(SearchSubscribeButton));
    check(controller.toggles).equals(1);
  });

  testWidgets('a subscribed podcast shows a check that does nothing', (
    tester,
  ) async {
    final controller = await pump(tester, subscribed: true);
    check(find.byIcon(Icons.check_rounded).evaluate()).length.equals(1);
    await tester.tap(find.byType(SearchSubscribeButton));
    check(controller.toggles).equals(0);
  });

  testWidgets('keeps a full touch target', (tester) async {
    await pump(tester, subscribed: false);
    final size = tester.getSize(find.byType(SearchSubscribeButton));
    check(size.width).isGreaterOrEqual(Spacing.minTouchTarget);
    check(size.height).isGreaterOrEqual(Spacing.minTouchTarget);
  });

  testWidgets('a result without a feed cannot be subscribed', (tester) async {
    // Subscribing needs the feed; the podcast screen disables it too.
    final controller = await pump(
      tester,
      subscribed: false,
      podcast: const Podcast(id: '42', name: 'Show', artistName: 'Host'),
    );
    final button = tester.widget<IconButton>(find.byType(IconButton));
    check(button.onPressed).isNull();
    await tester.tap(find.byType(SearchSubscribeButton));
    check(controller.toggles).equals(0);
  });

  testWidgets('subscribing fetches the episodes right away', (tester) async {
    // Search never opens the podcast screen, whose fetch would store them.
    final feedSync = _RecordingFeedSync();
    await pump(tester, subscribed: false, feedSync: feedSync);
    await tester.tap(find.byType(SearchSubscribeButton));
    await tester.pumpAndSettle();
    check(feedSync.synced).deepEquals([
      ['https://example.com/feed.xml'],
    ]);
  });

  testWidgets('tapping the check does not open the podcast', (tester) async {
    var rowTaps = 0;
    await pump(tester, subscribed: true, onRowTap: () => rowTaps++);
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    check(rowTaps).equals(0);
  });

  testWidgets('a failed state offers a retry', (tester) async {
    final controller = await pump(tester, subscribed: false, fails: true);
    check(find.byTooltip('Retry').evaluate()).length.equals(1);
    final builds = controller.builds;
    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();
    check(controller.builds).isGreaterThan(builds);
  });
  testWidgets('subscribing plays the success haptic', (tester) async {
    final haptics = _RecordingHapticPlayer();
    await pump(tester, subscribed: false, haptics: haptics);
    await tester.tap(find.byType(SearchSubscribeButton));
    await tester.pumpAndSettle();
    check(haptics.played).deepEquals([HapticToken.success]);
  });
}

class _CountingController extends SubscriptionController {
  _CountingController(this._isSubscribed, {this.fails = false});
  final bool _isSubscribed;
  final bool fails;
  var toggles = 0;
  var builds = 0;

  @override
  Future<bool> build(String itunesId) async {
    builds++;
    if (fails) throw Exception('read failed');
    return _isSubscribed;
  }

  @override
  Future<bool> toggleSubscription(
    BuildContext context,
    Podcast podcast, {
    SubscribeSource source = SubscribeSource.discovery,
  }) async {
    toggles++;
    state = const AsyncData(true);
    return true;
  }
}

class _RecordingFeedSync extends Fake implements FeedSyncService {
  final synced = <List<String>>[];

  @override
  Future<FeedSyncResult> syncFeedsByUrls(List<String> feedUrls) async {
    synced.add(feedUrls);
    return const FeedSyncResult(
      totalCount: 1,
      successCount: 1,
      skipCount: 0,
      errorCount: 0,
    );
  }
}
