import 'package:meta/meta.dart';

@immutable
sealed class UnlockState {
  const UnlockState();
}

class Locked extends UnlockState {
  const Locked();

  @override
  bool operator ==(Object other) => other is Locked;

  @override
  int get hashCode => 'Locked'.hashCode;
}

class Unlocked extends UnlockState {
  const Unlocked({required this.expiresAt});

  final DateTime expiresAt;

  @override
  bool operator ==(Object other) =>
      other is Unlocked && other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash('Unlocked', expiresAt);
}

class LockedOut extends UnlockState {
  const LockedOut({required this.retryAt, required this.attemptCount});

  final DateTime retryAt;
  final int attemptCount;

  @override
  bool operator ==(Object other) =>
      other is LockedOut &&
      other.retryAt == retryAt &&
      other.attemptCount == attemptCount;

  @override
  int get hashCode => Object.hash('LockedOut', retryAt, attemptCount);
}
