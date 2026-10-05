/// One-shot events emitted by the sleep-timer controller.
///
/// Consumed by the UI layer to drive snackbars, haptics, etc.
sealed class SleepTimerEvent {
  const SleepTimerEvent();
}

final class SleepTimerFired extends SleepTimerEvent {
  const SleepTimerFired();
}

/// The timer was turned off because the listener left the episode or
/// chapter it refers to (a manual episode switch, or a seek out of the
/// target chapter).
///
/// Not emitted when the listener turns the timer off through the sheet or
/// the chip: they already know.
final class SleepTimerCancelled extends SleepTimerEvent {
  const SleepTimerCancelled();
}
