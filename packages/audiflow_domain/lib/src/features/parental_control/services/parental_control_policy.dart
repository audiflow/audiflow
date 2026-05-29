/// Centralized parental-control policy constants.
///
/// Tuning here (iteration count, backoff, lockout threshold) is a security
/// decision: bumping [pbkdf2Iterations] invalidates existing hashes if the
/// per-row [ParentalControlSettings.pinIterations] field is not honored, which
/// is why every stored settings row records its own iteration count.
abstract final class ParentalControlPolicy {
  /// OWASP 2023 minimum for PBKDF2-HMAC-SHA256.
  static const int pbkdf2Iterations = 100000;

  /// Length of the randomly generated PIN salt in bytes.
  static const int saltLengthBytes = 16;

  /// Number of consecutive failures that trigger the first lockout.
  static const int lockoutThresholdAttempts = 5;

  /// Backoff durations in seconds, applied at the 5th failure and each
  /// subsequent failure. Saturates at the final entry.
  ///
  /// Doubling backoff capped at 5 minutes per product decision.
  static const List<int> backoffSeconds = [30, 60, 120, 240, 300];

  /// Default unlock session timeout in milliseconds (5 minutes).
  ///
  /// Used as a fallback when the persisted [ParentalControlSettings.unlockTimeoutMs]
  /// is zero or negative, which would auto-relock the gate instantly.
  static const int defaultUnlockTimeoutMs = 300000;
}
