/// Platform-side biometric authentication abstraction.
///
/// Concrete implementation lives in `audiflow_app` (wraps `local_auth`).
/// Domain keeps no Flutter plugin dependency so unit tests stay pure-Dart.
///
/// All methods return `false` on platform errors; callers treat any negative
/// result as "did not authenticate" without leaking the underlying cause.
abstract class BiometricAuthenticator {
  /// Whether the device has biometric hardware enrolled and available.
  ///
  /// Returns `false` if the platform reports no enrolled biometrics, the
  /// hardware is unavailable, or the call itself failed.
  Future<bool> isAvailable();

  /// Prompts the user for a biometric scan with [localizedReason] shown in
  /// the system dialog. Returns `true` only on a successful scan.
  ///
  /// Implementations MUST NOT throw — surface failures, cancellations, and
  /// platform errors as `false`.
  Future<bool> authenticate({required String localizedReason});
}
