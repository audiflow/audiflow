import '../models/parental_control_settings.dart';

/// Repository interface for all parental-control operations.
abstract class ParentalControlRepository {
  /// Streams every change to the singleton settings row.
  Stream<ParentalControlSettings> watchSettings();

  /// Returns the current settings, creating the singleton row if absent.
  Future<ParentalControlSettings> getSettings();

  /// Hashes [pin] with a fresh salt and persists it; also clears
  /// [ParentalControlSettings.failedAttempts] and
  /// [ParentalControlSettings.lockoutUntil].
  Future<void> setPin(String pin);

  /// Returns true when [pin] matches the stored hash.
  ///
  /// Returns false immediately — without invoking PBKDF2 — if a lockout window
  /// is active. Clears [ParentalControlSettings.failedAttempts] on success.
  Future<bool> verifyPin(String pin);

  /// Removes the stored PIN hash and salt; also clears failed-attempt state.
  Future<void> clearPin();

  /// Persists the Restricted Mode toggle.
  Future<void> setRestrictedMode(bool enabled);

  /// Persists how long (as a [Duration]) an unlock session stays valid.
  Future<void> setUnlockTimeout(Duration timeout);

  /// Persists whether biometric authentication is accepted alongside the PIN.
  Future<void> setBiometricUnlockEnabled(bool enabled);

  /// Increments the failed-attempts counter. If the lockout threshold is met
  /// by this call, persists `lockoutUntil` and returns the backoff duration
  /// just applied. Returns null while still below the threshold.
  Future<Duration?> registerFailedAttempt();

  /// Resets [ParentalControlSettings.failedAttempts] to 0 and clears
  /// [ParentalControlSettings.lockoutUntil].
  Future<void> clearFailedAttempts();

  /// Streams whether explicit episodes are hidden for [itunesId].
  Stream<bool> watchHideExplicit(int itunesId);

  /// Returns whether explicit episodes are hidden for [itunesId].
  Future<bool> getHideExplicit(int itunesId);

  /// Persists the hide-explicit flag for [itunesId].
  Future<void> setHideExplicit(int itunesId, bool hide);

  /// Removes the per-podcast flags row for [itunesId], if one exists.
  Future<void> pruneFlagsFor(int itunesId);
}
