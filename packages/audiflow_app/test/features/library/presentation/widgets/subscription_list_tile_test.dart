import 'package:audiflow_app/features/library/presentation/controllers/library_controller.dart';
import 'package:audiflow_app/features/library/presentation/widgets/subscription_list_tile.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasNewSinceVisit', () {
    final visit = DateTime(2026, 10, 8, 9);

    test('is true for an episode published after the last visit', () {
      check(
        hasNewSinceVisit(
          newestPublishedAt: visit.add(const Duration(hours: 1)),
          lastVisitedAt: visit,
          subscribedAt: DateTime(2026),
          now: DateTime(2026, 10, 9),
        ),
      ).isTrue();
    });

    test('is false once the podcast was opened after it', () {
      check(
        hasNewSinceVisit(
          newestPublishedAt: visit.subtract(const Duration(hours: 1)),
          lastVisitedAt: visit,
          subscribedAt: DateTime(2026),
          now: DateTime(2026, 10, 9),
        ),
      ).isFalse();
    });

    test('counts from the subscription when never opened', () {
      check(
        hasNewSinceVisit(
          newestPublishedAt: DateTime(2026, 2),
          lastVisitedAt: null,
          subscribedAt: DateTime(2026),
          now: DateTime(2026, 10, 9),
        ),
      ).isTrue();
      // The back catalog published before subscribing is not new.
      check(
        hasNewSinceVisit(
          newestPublishedAt: DateTime(2025),
          lastVisitedAt: null,
          subscribedAt: DateTime(2026),
          now: DateTime(2026, 10, 9),
        ),
      ).isFalse();
    });

    test('ignores an episode dated in the future until its date', () {
      // Opening the podcast must clear the dot even if the feed lists an
      // episode ahead of time.
      check(
        hasNewSinceVisit(
          newestPublishedAt: DateTime(2026, 10, 20),
          lastVisitedAt: visit,
          subscribedAt: DateTime(2026),
          now: DateTime(2026, 10, 9),
        ),
      ).isFalse();
      check(
        hasNewSinceVisit(
          newestPublishedAt: DateTime(2026, 10, 20),
          lastVisitedAt: visit,
          subscribedAt: DateTime(2026),
          now: DateTime(2026, 10, 21),
        ),
      ).isTrue();
    });

    test('is false without episodes', () {
      check(
        hasNewSinceVisit(
          newestPublishedAt: null,
          lastVisitedAt: null,
          subscribedAt: DateTime(2026),
          now: DateTime(2026, 10, 9),
        ),
      ).isFalse();
    });
  });

  group('SubscriptionListTile', () {
    Future<void> pump(WidgetTester tester, {required DateTime newest}) async {
      final subscription = Subscription()
        ..id = 1
        ..itunesId = 'itunes_1'
        ..feedUrl = 'https://example.com/1'
        ..title = 'Alpha'
        ..artistName = 'Artist'
        ..subscribedAt = DateTime(2026)
        ..lastAccessedAt = DateTime(2026, 10, 8, 9);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            newestEpisodeDateProvider.overrideWith(
              (ref, id) => Stream.value(newest),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SubscriptionListTile(
                subscription: subscription,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('marks a podcast with an episode since the last visit', (
      tester,
    ) async {
      await pump(tester, newest: DateTime(2026, 10, 8, 10));
      check(
        find.bySemanticsLabel(RegExp('New episodes')).evaluate(),
      ).length.equals(1);
    });

    testWidgets('shows no mark once caught up', (tester) async {
      await pump(tester, newest: DateTime(2026, 10, 8, 8));
      check(find.bySemanticsLabel(RegExp('New episodes')).evaluate()).isEmpty();
    });
  });
}
