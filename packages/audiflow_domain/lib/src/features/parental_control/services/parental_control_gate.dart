import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../models/unlock_state.dart';
import '../providers/parental_control_providers.dart';
part 'parental_control_gate.g.dart';

/// Reasons a caller may request an unlock, for audit-log purposes.
enum UnlockReason {
  subscribe,
  unsubscribe,
  opmlImport,
  deepLink,
  parentalSettings,
  developerSettings,
  unspecified,
}

/// Manages the parental-control session state machine.
///
/// States: [Locked] → [Unlocked] (on correct PIN) → [Locked] (on idle timeout
/// or explicit lock). Too many wrong PINs in a window → [LockedOut].
@Riverpod(keepAlive: true)
class ParentalControlGate extends _$ParentalControlGate {
  Timer? _idleTimer;

  /// The timeout used for the current unlock session; set on each successful
  /// unlock so that [extendIdle] can reschedule without an async settings read.
  Duration _sessionTimeout = Duration.zero;

  /// Wall-clock source; final so it is never reassigned after construction.
  final DateTime Function() _now = DateTime.now;

  @override
  UnlockState build() {
    ref.onDispose(_cancelTimer);
    return const Locked();
  }

  /// Attempts to unlock with [pin].
  ///
  /// Returns `true` and transitions to [Unlocked] on success.
  /// Returns `false` and may transition to [LockedOut] after repeated failures.
  /// Short-circuits without hashing when already [LockedOut] and the window is
  /// still active.
  Future<bool> tryUnlock(String pin, {UnlockReason? reason}) async {
    final current = state;
    if (current is LockedOut) {
      final now = _now();
      if (now.isBefore(current.retryAt)) {
        return false;
      }
      // Lockout window expired; fall through to normal verification.
    }

    final repo = ref.read(parentalControlRepositoryProvider);
    final ok = await repo.verifyPin(pin);

    if (!ok) {
      final backoff = await repo.registerFailedAttempt();
      if (backoff != null) {
        final settings = await repo.getSettings();
        state = LockedOut(
          retryAt: _now().add(backoff),
          attemptCount: settings.failedAttempts,
        );
      }
      final logger = ref.read(namedLoggerProvider('ParentalControl'));
      logger.w(
        'PIN verification failed (reason: ${reason ?? UnlockReason.unspecified})',
      );
      return false;
    }

    final settings = await repo.getSettings();
    _sessionTimeout = Duration(milliseconds: settings.unlockTimeoutMs);
    final expiresAt = _now().add(_sessionTimeout);
    state = Unlocked(expiresAt: expiresAt);
    _startIdleTimer(_sessionTimeout);
    return true;
  }

  /// Resets the idle timer without requiring re-authentication.
  ///
  /// Reschedules using [_sessionTimeout] set at unlock time, so no async
  /// settings read is needed and there is no cross-test timer leakage.
  ///
  /// No-op when the gate is not in [Unlocked] state.
  void extendIdle() {
    if (state is! Unlocked) return;
    final expiresAt = _now().add(_sessionTimeout);
    state = Unlocked(expiresAt: expiresAt);
    _startIdleTimer(_sessionTimeout);
  }

  /// Immediately locks the gate and cancels the idle timer.
  void lock() {
    _cancelTimer();
    state = const Locked();
  }

  void _startIdleTimer(Duration timeout) {
    _cancelTimer();
    _idleTimer = Timer(timeout, () {
      state = const Locked();
    });
  }

  void _cancelTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }
}
