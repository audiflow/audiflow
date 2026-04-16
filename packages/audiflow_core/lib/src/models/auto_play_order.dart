/// Controls the order in which episodes are auto-queued
/// when playing from a podcast's episode list.
enum AutoPlayOrder {
  /// Inherit from parent scope or global setting.
  defaultOrder,

  /// Chronological order, oldest episode first.
  oldestFirst,

  /// Follow the current display order on screen.
  asDisplayed,
}
