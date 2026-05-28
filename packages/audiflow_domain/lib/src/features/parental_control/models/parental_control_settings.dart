import 'package:isar_community/isar.dart';

import '../services/parental_control_policy.dart';

part 'parental_control_settings.g.dart';

/// Singleton Isar collection that persists all parental-control state.
///
/// There is exactly one row with [id] == 0. Code that writes this row must
/// assign `id = 0` before calling `put` to guarantee uniqueness.
@collection
class ParentalControlSettings {
  /// Always 0 — this collection is a singleton row.
  Id id = 0;

  /// Base64-encoded PBKDF2 hash of the PIN, or null when no PIN is set.
  String? pinHashBase64;

  /// Base64-encoded random salt used when the current hash was computed.
  String? pinSaltBase64;

  /// PBKDF2 iteration count that was used when hashing the stored PIN.
  ///
  /// Recorded per-row so that the policy constant can be bumped for new PINs
  /// without invalidating existing hashes; verification always uses this value.
  int pinIterations = ParentalControlPolicy.pbkdf2Iterations;

  /// Whether Restricted Mode is active; gates content behind PIN entry.
  bool restrictedModeEnabled = false;

  /// How long (in seconds) an unlock session stays valid before re-prompting.
  int unlockTimeoutSeconds = 300;

  /// Whether biometric authentication is accepted as an alternative to the PIN.
  bool biometricUnlockEnabled = false;

  /// Running count of consecutive failed PIN attempts since the last success.
  int failedAttempts = 0;

  /// Absolute instant until which PIN entry is blocked, or null when not locked
  /// out. Compared against wall-clock time; always UTC.
  DateTime? lockoutUntil;
}
