import 'dart:collection';

/// Decides whether a failure is seen for the first time, so one failure
/// produces one error event.
///
/// Two kinds of repeats are suppressed:
/// - The same error object surfacing again: a controller logs an error and
///   rethrows it, the provider then fails with it, and every dependent
///   provider fails with it too.
/// - An equal failure from the same scope within [window]: Riverpod retries
///   a failed provider several times, and each retry throws a new but
///   identical error.
class ErrorReportDeduplicator {
  ErrorReportDeduplicator({
    DateTime Function()? now,
    this.window = const Duration(minutes: 5),
    this.capacity = 64,
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// How long an equal failure from the same scope stays suppressed.
  final Duration window;

  /// How many recent errors and fingerprints are remembered.
  final int capacity;

  final Queue<Object> _recentErrors = Queue<Object>();
  final LinkedHashMap<String, DateTime> _fingerprintSeenAt =
      LinkedHashMap<String, DateTime>();

  /// Whether [error] from [scope] has not been seen before.
  ///
  /// Records the sighting either way, so a later surfacing of the same
  /// object is suppressed even when this one was.
  bool isFirstSighting(Object error, {required String scope}) {
    if (_isRecentError(error)) return false;
    _rememberError(error);
    return _claimFingerprint('$scope|${error.runtimeType}|$error');
  }

  // Identity rather than equality: two distinct but equal errors from
  // different scopes are different failures.
  bool _isRecentError(Object error) =>
      _recentErrors.any((recent) => identical(recent, error));

  void _rememberError(Object error) {
    _recentErrors.addLast(error);
    if (capacity < _recentErrors.length) _recentErrors.removeFirst();
  }

  bool _claimFingerprint(String fingerprint) {
    final now = _now();
    final seenAt = _fingerprintSeenAt[fingerprint];
    if (seenAt != null && now.difference(seenAt) < window) return false;
    // Re-insert so the map stays ordered oldest-first for eviction.
    _fingerprintSeenAt
      ..remove(fingerprint)
      ..[fingerprint] = now;
    if (capacity < _fingerprintSeenAt.length) {
      _fingerprintSeenAt.remove(_fingerprintSeenAt.keys.first);
    }
    return true;
  }
}
