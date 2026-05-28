import 'package:meta/meta.dart';

/// Represents the current parental-control gate state for a session.
///
/// - [Locked]: PIN is set but the user has not yet authenticated this session.
/// - [Unlocked]: User authenticated successfully; session expires at [Unlocked.expiresAt].
/// - [LockedOut]: Too many failed attempts; PIN entry is blocked until [LockedOut.retryAt].
///
/// [Locked] and [LockedOut] are distinct: [Locked] means no failed attempts
/// have triggered a backoff window, while [LockedOut] means attempts are
/// temporarily blocked.
@immutable
sealed class UnlockState {
  const UnlockState();
}

/// PIN is set but the user has not yet authenticated this session.
class Locked extends UnlockState {
  const Locked();

  @override
  bool operator ==(Object other) => other is Locked;

  @override
  int get hashCode => 'Locked'.hashCode;
}

/// User authenticated successfully; the session expires at [expiresAt].
///
/// [expiresAt] is an absolute UTC instant.
class Unlocked extends UnlockState {
  const Unlocked({required this.expiresAt});

  /// Absolute UTC instant at which this unlock session expires.
  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      other is Unlocked && other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash('Unlocked', expiresAt);
}

/// PIN entry is temporarily blocked after too many failed attempts.
///
/// [retryAt] is an absolute UTC instant after which entry is permitted again.
class LockedOut extends UnlockState {
  const LockedOut({required this.retryAt, required this.attemptCount});

  /// Absolute UTC instant after which PIN entry is permitted again.
  final DateTime retryAt;

  /// Total number of consecutive failed attempts that triggered this lockout.
  final int attemptCount;

  @override
  bool operator ==(Object other) =>
      other is LockedOut &&
      other.retryAt == retryAt &&
      other.attemptCount == attemptCount;

  @override
  int get hashCode => Object.hash('LockedOut', retryAt, attemptCount);
}
