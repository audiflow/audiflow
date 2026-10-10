import 'package:audiflow_app/features/monitoring/services/error_report_deduplicator.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late ErrorReportDeduplicator deduplicator;

  setUp(() {
    now = DateTime(2026, 10, 10, 12);
    deduplicator = ErrorReportDeduplicator(now: () => now);
  });

  group('ErrorReportDeduplicator', () {
    test('accepts a failure the first time', () {
      check(
        deduplicator.isFirstSighting(StateError('a'), scope: 'logger:A'),
      ).isTrue();
    });

    test('rejects the same error object from another scope', () {
      // A controller logs and rethrows; the provider then fails with it.
      final error = StateError('Unique index violated.');
      deduplicator.isFirstSighting(error, scope: 'logger:PodcastDetail');

      check(
        deduplicator.isFirstSighting(error, scope: 'provider:podcastDetail'),
      ).isFalse();
    });

    test('rejects an equal error from the same scope within the window', () {
      // Riverpod retries throw a fresh but equal error each time.
      deduplicator.isFirstSighting(StateError('a'), scope: 'provider:P');
      now = now.add(const Duration(minutes: 4));

      check(
        deduplicator.isFirstSighting(StateError('a'), scope: 'provider:P'),
      ).isFalse();
    });

    test('accepts an equal error from the same scope after the window', () {
      deduplicator.isFirstSighting(StateError('a'), scope: 'provider:P');
      now = now.add(const Duration(minutes: 5));

      check(
        deduplicator.isFirstSighting(StateError('a'), scope: 'provider:P'),
      ).isTrue();
    });

    test('accepts an equal error from a different scope', () {
      deduplicator.isFirstSighting(StateError('a'), scope: 'provider:P');

      check(
        deduplicator.isFirstSighting(StateError('a'), scope: 'provider:Q'),
      ).isTrue();
    });

    test('accepts a different error from the same scope', () {
      deduplicator.isFirstSighting(StateError('a'), scope: 'provider:P');

      check(
        deduplicator.isFirstSighting(StateError('b'), scope: 'provider:P'),
      ).isTrue();
    });

    test('forgets the oldest entries beyond its capacity', () {
      deduplicator = ErrorReportDeduplicator(now: () => now, capacity: 2);
      final first = StateError('first');
      deduplicator.isFirstSighting(first, scope: 'S');
      deduplicator.isFirstSighting(StateError('second'), scope: 'S');
      deduplicator.isFirstSighting(StateError('third'), scope: 'S');

      check(deduplicator.isFirstSighting(first, scope: 'S')).isTrue();
    });
  });
}
