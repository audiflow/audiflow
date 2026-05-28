import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../monitoring/models/analytics_event.dart';
import '../../monitoring/providers/analytics_providers.dart';
import '../models/unlock_state.dart';
import '../providers/parental_control_providers.dart';
import '../services/parental_control_policy.dart';
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

  Logger get _logger => ref.read(namedLoggerProvider('ParentalControl'));

  ParentalControlErrorSink get _errorSink =>
      ref.read(parentalControlErrorSinkProvider);

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
  /// still active. Storage failures are caught and logged; the gate stays
  /// [Locked] rather than crashing.
  Future<bool> tryUnlock(String pin, {UnlockReason? reason}) async {
    final current = state;
    if (current is LockedOut && _now().isBefore(current.retryAt)) {
      _logger.w(
        'tryUnlock during active lockout window'
        ' (reason=${reason ?? UnlockReason.unspecified},'
        ' retryAt=${current.retryAt.toIso8601String()},'
        ' attempts=${current.attemptCount})',
      );
      return false;
    }

    final repo = ref.read(parentalControlRepositoryProvider);

    final bool ok;
    try {
      ok = await repo.verifyPin(pin);
    } catch (e, st) {
      _logger.e(
        'verifyPin failed; treating as unlock failure',
        error: e,
        stackTrace: st,
      );
      // Forward storage failure to sink (e.g. Sentry). No PIN/hash passed.
      _errorSink('verifyPin failed', error: e, stackTrace: st);
      return false;
    }

    if (!ok) {
      try {
        final backoff = await repo.registerFailedAttempt();
        final s = await repo.getSettings();
        if (backoff != null) {
          state = LockedOut(
            retryAt: _now().add(backoff),
            attemptCount: s.failedAttempts,
          );
          _logger.w(
            'parental control lockout triggered'
            ' (reason=${reason ?? UnlockReason.unspecified},'
            ' attempts=${s.failedAttempts},'
            ' retryAt=${(_now().add(backoff)).toIso8601String()})',
          );
        } else {
          _logger.w(
            'PIN verification failed (reason: ${reason ?? UnlockReason.unspecified})',
          );
          state = const Locked();
        }
      } catch (e, st) {
        _logger.e(
          'registerFailedAttempt failed; state stays Locked',
          error: e,
          stackTrace: st,
        );
        // Forward storage failure to sink (e.g. Sentry). No PIN/hash passed.
        _errorSink('registerFailedAttempt failed', error: e, stackTrace: st);
        state = const Locked();
      }
      return false;
    }

    try {
      final s = await repo.getSettings();
      final timeoutMs = s.unlockTimeoutMs;
      // A zero or negative timeout would auto-relock the gate instantly.
      final safeMs = timeoutMs < 1
          ? ParentalControlPolicy.defaultUnlockTimeoutMs
          : timeoutMs;
      if (safeMs != timeoutMs) {
        _logger.w(
          'invalid unlockTimeoutMs=$timeoutMs; falling back to default $safeMs',
        );
      }
      _sessionTimeout = Duration(milliseconds: safeMs);
      // Arm the timer BEFORE publishing Unlocked so a re-entrant listener
      // calling lock() cannot race a not-yet-armed timer.
      _startIdleTimer(_sessionTimeout);
      state = Unlocked(expiresAt: _now().add(_sessionTimeout));
      // Analytics is best-effort; an unavailable analytics service (e.g. in
      // unit tests without the override) must not flip a successful unlock
      // to failure.
      try {
        await ref
            .read(analyticsServiceProvider)
            .log(
              ParentalControlUnlockSuccess(
                reason: (reason ?? UnlockReason.unspecified).name,
              ),
            );
      } catch (e, st) {
        _logger.t(
          'parental control unlock_success analytics emit failed',
          error: e,
          stackTrace: st,
        );
      }
      return true;
    } catch (e, st) {
      _logger.e(
        'getSettings after successful verifyPin failed; refusing to unlock',
        error: e,
        stackTrace: st,
      );
      // Forward storage failure to sink (e.g. Sentry). No PIN/hash passed.
      _errorSink(
        'getSettings after verifyPin failed',
        error: e,
        stackTrace: st,
      );
      state = const Locked();
      return false;
    }
  }

  /// Resets the idle timer without requiring re-authentication.
  ///
  /// Reschedules using [_sessionTimeout] set at unlock time, so no async
  /// settings read is needed and there is no cross-test timer leakage.
  ///
  /// No-op when the gate is not in [Unlocked] state.
  void extendIdle() {
    final current = state;
    if (current is! Unlocked) {
      _logger.t('extendIdle no-op (state=${current.runtimeType})');
      return;
    }
    // Arm the timer BEFORE publishing the new Unlocked state (same ordering
    // rationale as tryUnlock).
    _startIdleTimer(_sessionTimeout);
    state = Unlocked(expiresAt: _now().add(_sessionTimeout));
  }

  /// Immediately locks the gate and cancels the idle timer.
  ///
  /// Idempotent: calling [lock] when already [Locked] is a no-op.
  void lock() {
    if (state is Locked) {
      _logger.t('lock() no-op (already Locked)');
      return;
    }
    _cancelTimer();
    _logger.i('parental control gate locked');
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
