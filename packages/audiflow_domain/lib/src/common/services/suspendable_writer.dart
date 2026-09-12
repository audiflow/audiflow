/// A service that writes to local storage and can be held quiet while
/// "Reset All Data" clears that storage.
///
/// [suspend] cancels in-flight work, waits for it to settle, and keeps the
/// service idle: work started while suspended writes nothing. [resume]
/// lifts the hold; it does not restart anything on its own.
abstract interface class SuspendableWriter {
  Future<void> suspend();

  void resume();
}
