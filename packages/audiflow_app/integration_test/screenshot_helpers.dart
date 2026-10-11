import 'dart:async';
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Pumps frames until [finder] matches, then keeps pumping for [settleFor]
/// seconds so network images and late list items land before a capture.
///
/// `pumpAndSettle` cannot be used: loading spinners and the mini player's
/// animations keep scheduling frames, so it would never return.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 60),
  int settleFor = 2,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      throw TestFailure('Timed out waiting for $finder');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
  await pumpFor(tester, Duration(seconds: settleFor));
}

/// Pumps frames for [duration] without waiting for anything in particular.
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final steps = duration.inMilliseconds ~/ 250;
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// Taps [finder] once it is on screen, looking it up again right before the
/// tap because background syncs can rebuild the widget in between.
Future<void> tapWhenFound(
  WidgetTester tester,
  Finder finder, {
  int settleFor = 2,
}) async {
  await pumpUntilFound(tester, finder, settleFor: 0);
  await tester.tap(finder);
  await pumpFor(tester, Duration(seconds: settleFor));
}

/// Wraps the binding's screenshot API, which differs per platform.
class Capturer {
  Capturer(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;

  /// Android renders through a platform view by default, which the
  /// screenshot API cannot read; switch it to an image surface once.
  Future<void> prepare() async {
    if (!Platform.isAndroid) return;
    await _binding.convertFlutterSurfaceToImage();
    await _tester.pump();
  }

  Future<void> take(String name) async {
    await _tester.pump();
    await _binding.takeScreenshot(name);
  }
}

/// Reports a healthy config so the force-update gate never covers a screen.
class NoUpdateRepository implements ForceUpdateRepository {
  static const _config = ForceUpdateConfig(
    schemaVersion: 1,
    minVersion: '1.0.0',
    recommendedVersion: '1.0.0',
    maintenanceMode: false,
    messageKey: 'default',
  );

  @override
  Future<ForceUpdateConfig?> refresh() async => _config;

  @override
  Future<ForceUpdateConfig?> readCachedOnly() async => _config;

  @override
  DateTime? lastFetchAt() => DateTime.now().toUtc();
}

/// Exposes when the first full feed sync finishes. The app starts that sync
/// at launch (`AppLifecycleObserver`), so this is the moment the episode
/// counts on screen become final.
class TrackedFeedSyncService extends FeedSyncService {
  TrackedFeedSyncService(Ref ref)
    : super(
        ref: ref,
        logger: ref.watch(namedLoggerProvider('FeedSync')),
        onDiagnostic: ref.watch(feedSyncDiagnosticSinkProvider),
      );

  final _firstFullSync = Completer<FeedSyncResult>();

  Future<FeedSyncResult> get firstFullSync => _firstFullSync.future;

  @override
  Future<FeedSyncResult> syncAllSubscriptions({bool forceRefresh = false}) {
    final sync = super.syncAllSubscriptions(forceRefresh: forceRefresh);
    if (!_firstFullSync.isCompleted) _firstFullSync.complete(sync);
    return sync;
  }
}
