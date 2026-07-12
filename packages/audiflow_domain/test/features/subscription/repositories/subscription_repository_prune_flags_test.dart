import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/isar_test_helper.dart';

// ---------------------------------------------------------------------------
// Fake parental control repository
// ---------------------------------------------------------------------------

/// Simulates a [ParentalControlRepository] whose [pruneFlagsFor] throws.
///
/// Used to verify that [SubscriptionRepositoryImpl.unsubscribe] swallows
/// the error and still completes successfully.
class _ThrowingParentalControlRepository implements ParentalControlRepository {
  bool pruneCalled = false;

  @override
  Future<void> pruneFlagsFor(int itunesId) async {
    pruneCalled = true;
    // Throw an Error (not an Exception) to exercise the broad catch clause.
    throw StateError('simulated Isar failure in pruneFlagsFor');
  }

  @override
  Stream<ParentalControlSettings> watchSettings() => const Stream.empty();

  @override
  Future<ParentalControlSettings> getSettings() async =>
      ParentalControlSettings();

  @override
  Future<void> setRestrictedMode(bool enabled) async {}

  @override
  Future<void> setUnlockTimeout(Duration timeout) async {}

  @override
  Future<bool> verifyPin(String pin) async => false;

  @override
  Future<void> setPin(String pin) async {}

  @override
  Future<void> setupPin(String pin) async {}

  @override
  Future<void> clearPin() async {}

  @override
  Future<Duration?> registerFailedAttempt() async => null;

  @override
  Future<void> clearFailedAttempts() async {}

  @override
  Stream<bool> watchHideExplicit(int itunesId) => const Stream.empty();

  @override
  Future<bool> getHideExplicit(int itunesId) async => false;

  @override
  Future<void> setHideExplicit(int itunesId, bool hide) async {}
}

// ---------------------------------------------------------------------------
// Log-capture sink
// ---------------------------------------------------------------------------

/// Captures log events so tests can assert that a warning was emitted.
class _CapturingOutput extends LogOutput {
  final List<OutputEvent> events = [];

  @override
  void output(OutputEvent event) => events.add(event);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Isar isar;
  late _ThrowingParentalControlRepository fakeParentalControl;
  late _CapturingOutput logOutput;
  late Logger logger;
  late SubscriptionRepositoryImpl repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([SubscriptionSchema]);
    fakeParentalControl = _ThrowingParentalControlRepository();
    logOutput = _CapturingOutput();
    logger = Logger(
      filter: ProductionFilter(),
      output: logOutput,
      printer: SimplePrinter(),
    );
    repository = SubscriptionRepositoryImpl(
      datasource: SubscriptionLocalDatasource(isar),
      parentalControlRepository: fakeParentalControl,
      logger: logger,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('unsubscribe — pruneFlagsFor error handling', () {
    test(
      'unsubscribe succeeds even when pruneFlagsFor throws an Error',
      () async {
        await repository.subscribe(
          itunesId: 'itunes-1',
          feedUrl: 'https://example.com/feed.xml',
          title: 'Test Podcast',
          artistName: 'Test Artist',
        );

        // Should not throw despite pruneFlagsFor raising a StateError.
        await repository.unsubscribe('itunes-1');

        final isStillSubscribed = await repository.isSubscribed('itunes-1');
        check(isStillSubscribed).isFalse();
      },
    );

    test('pruneFlagsFor is called during unsubscribe', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      await repository.unsubscribe('itunes-1');

      check(fakeParentalControl.pruneCalled).isTrue();
    });

    test('warning is logged when pruneFlagsFor throws', () async {
      await repository.subscribe(
        itunesId: 'itunes-1',
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        artistName: 'Test Artist',
      );

      await repository.unsubscribe('itunes-1');

      // At least one warning-level event should have been captured.
      final warnings = logOutput.events
          .where((e) => e.level == Level.warning)
          .toList();
      check(warnings).isNotEmpty();
    });
  });
}
