/// Mutual exclusion between background code that writes download files and
/// code that removes them.
///
/// Background download workers run in separate engines from the feed
/// refresh, so only a lock that holds across engines (such as a lock file)
/// keeps a cleanup from deleting a task while a worker is starting it.
abstract interface class BackgroundDownloadWorkerLock {
  /// Takes the lock, or returns false while another holder has it.
  Future<bool> tryAcquire();

  /// Releases the lock if this holder has it.
  Future<void> release();
}
