import 'dart:io';

/// Keeps background download workers from transferring at the same time.
///
/// The one-off download task and the iOS refresh-window pass run in
/// separate background engines and both reset "downloading" tasks to
/// pending before picking work. Without coordination one could reclaim the
/// other's in-flight task and write the same file, corrupting the audio.
/// The lock is a file in the documents directory, created atomically, so it
/// holds across engines.
class BackgroundDownloadLock {
  BackgroundDownloadLock({required String directory, DateTime Function()? now})
    : _file = File('$directory/.background_download.lock'),
      _now = now ?? DateTime.now;

  /// Longer than any background download run (the download task's budget
  /// is 5 minutes), so a lock this old was left by a worker that crashed or
  /// was killed before releasing it.
  static const staleAfter = Duration(minutes: 10);

  final File _file;
  final DateTime Function() _now;
  bool _isHeld = false;

  /// Takes the lock, or returns false while another worker holds it.
  Future<bool> tryAcquire() async {
    if (await _isHeldElsewhere()) return false;
    try {
      await _file.create(exclusive: true);
      // Stamp with the injected clock so staleness checks agree with it.
      await _file.setLastModified(_now());
      _isHeld = true;
      return true;
    } on FileSystemException {
      // Another worker created it between the check and the create.
      return false;
    }
  }

  /// Releases the lock if this worker holds it.
  Future<void> release() async {
    if (!_isHeld) return;
    _isHeld = false;
    try {
      await _file.delete();
    } on FileSystemException {
      // Already gone; nothing to release.
    }
  }

  /// Whether a live lock exists; clears a stale one so it can be retaken.
  Future<bool> _isHeldElsewhere() async {
    if (!await _file.exists()) return false;
    final age = _now().difference(await _file.lastModified());
    if (age < staleAfter) return true;
    try {
      await _file.delete();
    } on FileSystemException {
      // Raced with another worker clearing it; the create decides.
    }
    return false;
  }
}
