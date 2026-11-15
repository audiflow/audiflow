import 'package:audiflow_app/features/monitoring/services/error_reporter.dart';
import 'package:audiflow_app/features/monitoring/services/unexpected_error_monitor.dart';
import 'package:audiflow_app/features/parental_control/domain/gate_guard.dart';
import 'package:audiflow_app/features/parental_control/providers/gate_guard_provider.dart';
import 'package:audiflow_app/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _DenyingGateGuard implements GateGuard {
  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async => false;
}

class _AllowingGateGuard implements GateGuard {
  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async => true;
}

/// [SubscriptionRepository] that tracks subscribe/unsubscribe calls.
class _TrackingSubscriptionRepository extends FakeSubscriptionRepository {
  bool subscribeCalled = false;
  bool unsubscribeCalled = false;

  @override
  Future<bool> isSubscribed(String itunesId) async => false;

  @override
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
    SubscribeSource source = SubscribeSource.unknown,
  }) async {
    subscribeCalled = true;
    return Subscription()
      ..itunesId = itunesId
      ..feedUrl = feedUrl
      ..title = title
      ..artistName = artistName;
  }

  @override
  Future<void> unsubscribe(String itunesId) async {
    unsubscribeCalled = true;
  }
}

/// [SubscriptionRepository] whose subscribe rejects the feed URL, as
/// [SubscriptionRepositoryImpl] does for one it cannot fetch.
class _RejectingSubscriptionRepository extends FakeSubscriptionRepository {
  @override
  Future<bool> isSubscribed(String itunesId) async => false;

  @override
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
    SubscribeSource source = SubscribeSource.unknown,
  }) async => throw InvalidFeedUrlException();
}

class _RecordingReporter implements ErrorReporter {
  final captured = <ErrorReport>[];
  final breadcrumbs = <ErrorReport>[];

  @override
  Future<void> captureException(ErrorReport report) async {
    captured.add(report);
  }

  @override
  void addBreadcrumb(ErrorReport report) => breadcrumbs.add(report);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _testPodcast = Podcast(
  id: 'test-id',
  name: 'Test Podcast',
  artistName: 'Test Artist',
  feedUrl: 'https://example.com/feed.xml',
);

/// Wraps [child] in a minimal widget tree with [ProviderScope].
Widget _wrap(
  Widget child, {
  required List<dynamic> overrides,
  List<ProviderObserver>? observers,
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    observers: observers,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SubscriptionController.toggleSubscription', () {
    testWidgets('returns false when gate denies', (tester) async {
      final repo = _TrackingSubscriptionRepository();
      late bool result;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  final container = ProviderScope.containerOf(context);
                  result = await container
                      .read(subscriptionControllerProvider('test-id').notifier)
                      .toggleSubscription(context, _testPodcast);
                },
                child: const Text('tap'),
              );
            },
          ),
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(repo),
            gateGuardProvider.overrideWithValue(_DenyingGateGuard()),
          ],
        ),
      );

      await tester.pump();
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();

      check(result).isFalse();
      check(repo.subscribeCalled).isFalse();
    });

    testWidgets('returns true when gate allows and subscribe succeeds', (
      tester,
    ) async {
      final repo = _TrackingSubscriptionRepository();
      late bool result;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  final container = ProviderScope.containerOf(context);
                  result = await container
                      .read(subscriptionControllerProvider('test-id').notifier)
                      .toggleSubscription(context, _testPodcast);
                },
                child: const Text('tap'),
              );
            },
          ),
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(repo),
            gateGuardProvider.overrideWithValue(_AllowingGateGuard()),
          ],
        ),
      );

      await tester.pump();
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();

      check(result).isTrue();
      check(repo.subscribeCalled).isTrue();
    });

    testWidgets('keeps an unfetchable feed URL out of error reports', (
      tester,
    ) async {
      // A directory result can carry a feed URL the repository rejects;
      // that is bad input, not a defect, so it must not reach Sentry.
      final reporter = _RecordingReporter();
      final monitor = UnexpectedErrorMonitor(reporter: reporter);
      const podcast = Podcast(
        id: 'test-id',
        name: 'Test Podcast',
        artistName: 'Test Artist',
        feedUrl: '',
      );
      Object? stateError;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  final container = ProviderScope.containerOf(context);
                  final provider = subscriptionControllerProvider('test-id');
                  // Keeps the auto-dispose controller alive to read its state.
                  final sub = container.listen(provider, (_, _) {});
                  await container
                      .read(provider.notifier)
                      .toggleSubscription(context, podcast);
                  stateError = sub.read().error;
                  sub.close();
                },
                child: const Text('tap'),
              );
            },
          ),
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(
              _RejectingSubscriptionRepository(),
            ),
            gateGuardProvider.overrideWithValue(_AllowingGateGuard()),
          ],
          observers: [monitor.providerObserver],
        ),
      );

      await tester.pump();
      await tester.tap(find.text('tap'));
      await tester.pumpAndSettle();

      check(stateError).isA<InvalidFeedUrlException>();
      check(reporter.captured).isEmpty();
      check(reporter.breadcrumbs).has((it) => it.length, 'length').equals(1);
    });
  });
}
