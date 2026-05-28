import '../models/parental_control_settings.dart';

abstract class ParentalControlRepository {
  Stream<ParentalControlSettings> watchSettings();
  Future<ParentalControlSettings> getSettings();

  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();

  Future<void> setRestrictedMode(bool enabled);
  Future<void> setUnlockTimeout(Duration timeout);
  Future<void> setBiometricUnlockEnabled(bool enabled);

  /// Increments the failed-attempts counter. Returns the new lockout
  /// window (null if no lockout triggered yet).
  Future<Duration?> registerFailedAttempt();
  Future<void> clearFailedAttempts();

  Stream<bool> watchHideExplicit(int itunesId);
  Future<bool> getHideExplicit(int itunesId);
  Future<void> setHideExplicit(int itunesId, bool hide);
  Future<void> pruneFlagsFor(int itunesId);
}
