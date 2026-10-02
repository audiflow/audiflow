/// How long into a background refresh downloads may keep running.
///
/// iOS grants a BGAppRefreshTask about 30 seconds in total, counted from
/// before the background engine boots, while this is measured from the
/// Dart callback. The margin covers that boot plus persisting progress and
/// closing Isar before the system expires the task.
const refreshWindowDeadline = Duration(seconds: 20);

/// Below this, a download would spend most of its time on the connection
/// handshake, so the refresh skips downloading altogether.
const minRefreshDownloadBudget = Duration(seconds: 5);

/// Returns how long downloads may run after the refresh has used [elapsed],
/// or null when too little of the window is left to be worth starting one.
Duration? refreshDownloadBudget(Duration elapsed) {
  final remaining = refreshWindowDeadline - elapsed;
  if (remaining < minRefreshDownloadBudget) return null;
  return remaining;
}
