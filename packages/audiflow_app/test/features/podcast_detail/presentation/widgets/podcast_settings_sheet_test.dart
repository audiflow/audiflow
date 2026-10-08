import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_settings_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart'
    show AutoPlayOrder, SettingsDefaults;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fakes.dart';

const _feedUrl = 'https://example.com/feed.xml';

Subscription _subscription({DateTime? pausedAt}) {
  return Subscription()
    ..id = 1
    ..itunesId = 'itunes_1'
    ..feedUrl = _feedUrl
    ..title = 'Podcast'
    ..artistName = 'Artist'
    ..subscribedAt = DateTime(2026)
    ..autoDownload = true
    ..autoDownloadsSinceLastPlay = pausedAt == null ? 0 : 5
    ..autoDownloadPausedAt = pausedAt;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> openSheet(
    WidgetTester tester,
    Subscription subscription, {
    VoidCallback? onPlayOrderChanged,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subscriptionRepositoryProvider.overrideWithValue(
            FakeSubscriptionRepository(subscriptions: [subscription]),
          ),
          subscriptionByFeedUrlProvider(
            _feedUrl,
          ).overrideWith((ref) async => subscription),
          isRestrictedModeOnProvider.overrideWithValue(false),
          isUnlockedProvider.overrideWithValue(true),
          hideExplicitForPodcastProvider(
            subscription.id,
          ).overrideWith((ref) => Stream.value(false)),
          // The sheet's play order and audio rows read these from the database.
          playOrderPreferenceRepositoryProvider.overrideWithValue(
            FakePlayOrderPreferenceRepository(),
          ),
          effectiveAudioSettingsProvider(1).overrideWithValue(null),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPodcastSettingsSheet(
                context: context,
                podcast: const Podcast(
                  id: 'itunes_1',
                  name: 'Podcast',
                  artistName: 'Artist',
                  feedUrl: _feedUrl,
                ),
                onPlayOrderChanged: onPlayOrderChanged,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('hides the paused row while auto-download is active', (
    tester,
  ) async {
    await openSheet(tester, _subscription());

    expect(find.text('Auto-download paused'), findsNothing);
  });

  testWidgets('shows the paused row and resumes on tap', (tester) async {
    final subscription = _subscription(pausedAt: DateTime(2026, 10, 1));
    await openSheet(tester, subscription);

    expect(find.text('Auto-download paused'), findsOneWidget);

    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    check(subscription.autoDownloadPausedAt).isNull();
    check(subscription.autoDownloadsSinceLastPlay).equals(0);
  });

  testWidgets('groups play order, downloads, and display', (tester) async {
    await openSheet(tester, _subscription());

    for (final header in ['playback', 'downloads', 'display']) {
      final found = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data?.toLowerCase() == header,
      );
      check(found.evaluate()).isNotEmpty();
    }
    check(find.text('Play order').evaluate()).length.equals(1);
  });

  testWidgets('play order row shows the default and opens the picker', (
    tester,
  ) async {
    await openSheet(tester, _subscription());

    check(
      find.text('Follow global setting (Oldest first)').evaluate(),
    ).isNotEmpty();
    await tester.tap(find.text('Play order'));
    await tester.pumpAndSettle();
    check(
      find.byType(RadioListTile<AutoPlayOrder>).evaluate(),
    ).length.equals(3);
  });

  testWidgets('reports a saved play order to the podcast screen', (
    tester,
  ) async {
    var changes = 0;
    await openSheet(
      tester,
      _subscription(),
      onPlayOrderChanged: () => changes++,
    );

    await tester.tap(find.text('Play order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oldest first'));
    await tester.pumpAndSettle();

    check(changes).equals(1);
  });

  testWidgets('every keep-count choice is reachable on a short screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openSheet(tester, _subscription());

    await tester.tap(find.text('Auto-Download Keep Count'));
    await tester.pumpAndSettle();
    final last = find.text(
      '${SettingsDefaults.autoDownloadKeepCountOptions.last} episodes',
    );
    await tester.scrollUntilVisible(
      last,
      50,
      scrollable: find.byType(Scrollable).last,
    );
    check(last.evaluate()).length.equals(1);
  });

  testWidgets('the sheet hosts its own snackbars', (tester) async {
    await openSheet(tester, _subscription());
    check(
      find
          .descendant(
            of: find.byType(PodcastSettingsSheet),
            matching: find.byType(Scaffold),
          )
          .evaluate(),
    ).length.equals(1);
  });
}
