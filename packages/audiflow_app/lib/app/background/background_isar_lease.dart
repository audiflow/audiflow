/// Shares one opened database among background tasks in the same isolate.
///
/// On iOS, Workmanager can run the feed refresh and the download task in the
/// same background engine at once. Isar allows one instance per name per
/// isolate, so a second `Isar.open` while the first task still holds the
/// database throws "Instance has already been opened". Each task takes a
/// lease instead: the first opens the database, later ones reuse it, and the
/// last one to finish closes it.
class BackgroundIsarLease<T extends Object> {
  BackgroundIsarLease({required this._open, required this._close});

  final Future<T> Function() _open;
  final Future<void> Function(T instance) _close;

  int _holders = 0;
  Future<T>? _opening;
  Future<void>? _closing;

  /// Returns the shared instance, opening it if no task holds it.
  Future<T> acquire() async {
    // A close that started when the previous holder left must finish
    // before reopening, or the new open would still see the old instance.
    await _closing;
    _holders++;
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _holders--;
      _opening = null;
      rethrow;
    }
  }

  /// Gives back a lease; the last holder closes the instance.
  Future<void> release(T instance) async {
    if (_holders <= 0) return;
    _holders--;
    if (0 < _holders) return;
    _opening = null;
    final closing = _close(instance);
    // Waiters only need to know the close is over; its error belongs to
    // the releasing task.
    final settled = closing.then<void>((_) {}, onError: (Object _) {});
    _closing = settled;
    try {
      await closing;
    } finally {
      if (identical(_closing, settled)) _closing = null;
    }
  }
}
