/// Shares one opened database among background tasks in the same isolate.
///
/// On iOS, Workmanager can run the feed refresh and the download task in the
/// same background engine at once. Isar allows one instance per name per
/// isolate, so a second `Isar.open` while the first task still holds the
/// database throws "Instance has already been opened". Each task takes a
/// lease instead: the first opens the database, later ones reuse it, and the
/// last one to finish closes it.
///
/// Workmanager on iOS also runs one-off tasks (the download task) on the main
/// engine while the app is alive, where the foreground app already holds the
/// database. [findOpen] returns such an instance so the lease borrows it
/// instead of opening a second one, and never closes it: the foreground app
/// still uses it after the task ends.
class BackgroundIsarLease<T extends Object> {
  BackgroundIsarLease({
    required this._open,
    required this._close,
    this._findOpen,
  });

  final Future<T> Function() _open;
  final Future<void> Function(T instance) _close;
  final T? Function()? _findOpen;

  int _holders = 0;
  Future<T>? _opening;
  Future<void>? _closing;
  bool _borrowed = false;

  /// Returns the shared instance, opening it if no task holds it.
  Future<T> acquire() async {
    // A close that started when the previous holder left must finish
    // before reopening, or the new open would still see the old instance.
    // Only await when a close is pending: awaiting null still yields, and
    // a release in that gap would start a close this call never sees.
    for (var closing = _closing; closing != null; closing = _closing) {
      await closing;
    }
    _holders++;
    try {
      return await (_opening ??= _openOrBorrow());
    } catch (_) {
      _holders--;
      _opening = null;
      rethrow;
    }
  }

  Future<T> _openOrBorrow() {
    final existing = _findOpen?.call();
    _borrowed = existing != null;
    if (existing != null) return Future.value(existing);
    return _open();
  }

  /// Gives back a lease; the last holder closes the instance.
  Future<void> release(T instance) async {
    if (_holders <= 0) return;
    _holders--;
    if (0 < _holders) return;
    _opening = null;
    if (_borrowed) return;
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
