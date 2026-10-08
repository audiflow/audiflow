import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory [BackgroundDownloadWorkerLock] that records its use.
class FakeBackgroundDownloadWorkerLock implements BackgroundDownloadWorkerLock {
  /// Whether another worker holds the lock, so [tryAcquire] fails.
  bool isHeldElsewhere = false;

  bool isHeld = false;
  int acquireCount = 0;

  /// Runs once the lock is taken, to act as a worker would while it is held.
  Future<void> Function()? onAcquired;

  @override
  Future<bool> tryAcquire() async {
    if (isHeldElsewhere || isHeld) return false;
    isHeld = true;
    acquireCount++;
    await onAcquired?.call();
    return true;
  }

  @override
  Future<void> release() async => isHeld = false;
}
