/// One-shot events emitted by the sleep-timer controller.
///
/// Consumed by the UI layer to drive snackbars, haptics, etc.
sealed class SleepTimerEvent {
  const SleepTimerEvent();
}

final class SleepTimerFired extends SleepTimerEvent {
  const SleepTimerFired();
}
