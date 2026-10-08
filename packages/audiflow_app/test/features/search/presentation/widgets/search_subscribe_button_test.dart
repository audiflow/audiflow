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

void main() {
  Future<_CountingController> pump(
    WidgetTester tester, {
    required bool subscribed,
    Podcast podcast = _podcast,
  }) async {
    final controller = _CountingController(subscribed);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionControllerProvider('42').overrideWith(() => controller),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(child: SearchSubscribeButton(podcast: podcast)),
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
}

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
