import 'dart:async';

import 'package:audiflow_app/features/review_prompt/presentation/review_prompt_gate.dart';
import 'package:audiflow_app/features/settings/presentation/utils/rate_app_service.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ReviewPromptRepository {
  ReviewPromptStats _stats = const ReviewPromptStats();
  int recordPromptShownCalls = 0;
  int markOptedOutCalls = 0;
  int markRatedCalls = 0;

  @override
  ReviewPromptStats getStats() => _stats;

  @override
  Future<void> addListened(Duration delta) async {}

  @override
  Future<void> recordPromptShown() async {
    recordPromptShownCalls++;
  }

  @override
  Future<void> markOptedOut() async {
    markOptedOutCalls++;
    _stats = _stats.copyWith(status: ReviewPromptStatus.optedOut);
  }

  @override
  Future<void> markRated() async {
    markRatedCalls++;
    _stats = _stats.copyWith(status: ReviewPromptStatus.rated);
  }

  @override
  Future<void> reset() async {}
}

class _FakeRateApp implements RateAppService {
  int calls = 0;

  @override
  Future<void> openStoreListing() async {
    calls++;
  }
}

void main() {
  late _FakeRepo repo;
  late _FakeRateApp rateApp;
  late StreamController<void> trigger;

  setUp(() {
    repo = _FakeRepo();
    rateApp = _FakeRateApp();
    trigger = StreamController<void>.broadcast();
  });

  tearDown(() async {
    await trigger.close();
  });

  Future<void> pump(WidgetTester tester, {bool foreground = true}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewPromptRepositoryProvider.overrideWithValue(repo),
          rateAppServiceProvider.overrideWithValue(rateApp),
          reviewPromptTriggerEventsProvider.overrideWith(
            (ref) => trigger.stream,
          ),
          reviewPromptForegroundCheckProvider.overrideWithValue(
            () => foreground,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReviewPromptGate(
            child: const Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ReviewPromptGate', () {
    testWidgets('shows dialog when trigger fires', (tester) async {
      await pump(tester);
      trigger.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Enjoying audiflow?'), findsOneWidget);
    });

    testWidgets('Rate now: marks rated and opens store', (tester) async {
      await pump(tester);
      trigger.add(null);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rate now'));
      await tester.pumpAndSettle();
      check(repo.markRatedCalls).equals(1);
      check(rateApp.calls).equals(1);
      check(repo.recordPromptShownCalls).equals(0);
    });

    testWidgets('Later: only records prompt shown', (tester) async {
      await pump(tester);
      trigger.add(null);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();
      check(repo.recordPromptShownCalls).equals(1);
      check(repo.markOptedOutCalls).equals(0);
      check(repo.markRatedCalls).equals(0);
      check(rateApp.calls).equals(0);
    });

    testWidgets("Don't ask again: marks opted out", (tester) async {
      await pump(tester);
      trigger.add(null);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Don't ask again"));
      await tester.pumpAndSettle();
      check(repo.markOptedOutCalls).equals(1);
      check(repo.recordPromptShownCalls).equals(0);
      check(rateApp.calls).equals(0);
    });

    testWidgets('OS-dismissed (back gesture) treated as later', (tester) async {
      await pump(tester);
      trigger.add(null);
      await tester.pumpAndSettle();
      // Dismiss via barrier tap.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      check(repo.recordPromptShownCalls).equals(1);
      check(repo.markOptedOutCalls).equals(0);
      check(repo.markRatedCalls).equals(0);
    });

    testWidgets('does not show dialog when app is backgrounded', (
      tester,
    ) async {
      await pump(tester, foreground: false);
      trigger.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Enjoying audiflow?'), findsNothing);
      check(repo.recordPromptShownCalls).equals(0);
      check(repo.markOptedOutCalls).equals(0);
      check(repo.markRatedCalls).equals(0);
    });

    testWidgets('reentrancy guard: second event while dialog open is ignored', (
      tester,
    ) async {
      await pump(tester);
      trigger.add(null);
      await tester.pump();
      trigger.add(null);
      await tester.pumpAndSettle();
      // Only one dialog should be in the tree.
      expect(find.text('Enjoying audiflow?'), findsOneWidget);
    });
  });
}
