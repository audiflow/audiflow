import 'package:audiflow_app/features/podcast_detail/presentation/widgets/podcast_settings_sheet.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

const _feedUrl = 'https://example.com/feed.xml';

final _subscription = Subscription()
  ..itunesId = 'itunes-1'
  ..feedUrl = _feedUrl
  ..title = 'Test Podcast'
  ..artistName = 'Test Artist';

const _podcast = Podcast(
  id: 'itunes-1',
  name: 'Test Podcast',
  artistName: 'Test Artist',
  feedUrl: _feedUrl,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({
  required bool restricted,
  required bool unlocked,
  List<dynamic> extraOverrides = const [],
}) {
  return ProviderScope(
    overrides: [
      subscriptionByFeedUrlProvider(
        _feedUrl,
      ).overrideWith((ref) async => _subscription),
      isRestrictedModeOnProvider.overrideWithValue(restricted),
      isUnlockedProvider.overrideWithValue(unlocked),
      hideExplicitForPodcastProvider(
        _subscription.id,
      ).overrideWith((ref) => Stream.value(false)),
      ...extraOverrides.cast(),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              showPodcastSettingsSheet(context: context, podcast: _podcast),
          child: const Text('open sheet'),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('_HideExplicitTile gate behavior', () {
    testWidgets('tile hidden when restricted and locked', (tester) async {
      await tester.pumpWidget(
        _wrap(restricted: true, unlocked: false, extraOverrides: []),
      );

      await tester.tap(find.text('open sheet'));
      await tester.pumpAndSettle();

      // SwitchListTile for hide-explicit must not be visible.
      check(find.text('Hide explicit episodes').evaluate()).isEmpty();
    });

    testWidgets('tile visible when restricted but unlocked', (tester) async {
      await tester.pumpWidget(
        _wrap(restricted: true, unlocked: true, extraOverrides: []),
      );

      await tester.tap(find.text('open sheet'));
      await tester.pumpAndSettle();

      check(find.text('Hide explicit episodes').evaluate()).isNotEmpty();
    });

    testWidgets('tile visible when not restricted', (tester) async {
      await tester.pumpWidget(
        _wrap(restricted: false, unlocked: false, extraOverrides: []),
      );

      await tester.tap(find.text('open sheet'));
      await tester.pumpAndSettle();

      check(find.text('Hide explicit episodes').evaluate()).isNotEmpty();
    });
  });
}
