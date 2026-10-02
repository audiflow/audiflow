/// How long into a background refresh downloads may keep running.
///
/// iOS grants a BGAppRefreshTask about 30 seconds in total; stopping short
/// of that leaves room to persist progress and close Isar before the system
/// expires the task.
const refreshWindowDeadline = Duration(seconds: 25);

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
