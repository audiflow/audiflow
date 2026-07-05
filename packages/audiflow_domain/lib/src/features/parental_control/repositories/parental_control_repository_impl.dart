import 'dart:convert' show base64Encode;

import 'package:logger/logger.dart';

import '../../monitoring/models/analytics_event.dart';
import '../../monitoring/services/analytics_service.dart';
import '../datasources/local/parental_control_local_datasource.dart';
import '../models/parental_control_settings.dart';
import '../providers/parental_control_providers.dart';
import '../services/parental_control_policy.dart';
import '../services/pin_hasher.dart';
import 'parental_control_repository.dart';

class ParentalControlRepositoryImpl implements ParentalControlRepository {
  ParentalControlRepositoryImpl({
    required ParentalControlLocalDataSource datasource,
    required PinHasher hasher,
    required Logger logger,
    required AnalyticsService analytics,
    ParentalControlErrorSink? onError,
    DateTime Function()? clock,
  }) : _ds = datasource,
       _hasher = hasher,
       _logger = logger,
       _analytics = analytics,
       _onError = onError ?? _noOpSink,
       _now = clock ?? DateTime.now;

  static void _noOpSink(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {}

  final ParentalControlLocalDataSource _ds;
  final PinHasher _hasher;
  final Logger _logger;
  final AnalyticsService _analytics;
  final ParentalControlErrorSink _onError;
  final DateTime Function() _now;

  @override
  Stream<ParentalControlSettings> watchSettings() => _ds.watchSettings();

  @override
  Future<ParentalControlSettings> getSettings() =>
      _guarded('getSettings', () => _ds.getSettings());

  @override
  Future<void> setPin(String pin) => _guarded('setPin', () => _persistPin(pin));

  @override
  Future<void> setupPin(String pin) => _guarded('setupPin', () async {
    await _persistPin(pin, enableRestrictedMode: true);
    await _safeAnalytics(const ParentalControlEnabled());
  });

  Future<void> _persistPin(
    String pin, {
    bool enableRestrictedMode = false,
  }) async {
    final salt = _hasher.generateSalt();
    final hashBytes = _hasher.hash(
      pin: pin,
      salt: salt,
      iterations: ParentalControlPolicy.pbkdf2Iterations,
    );
    await _ds.updateSettings((s) {
      s.pinSaltBase64 = base64Encode(salt);
      s.pinHashBase64 = base64Encode(hashBytes);
      s.pinIterations = ParentalControlPolicy.pbkdf2Iterations;
      s.failedAttempts = 0;
      s.lockoutUntil = null;
      if (enableRestrictedMode) {
        s.restrictedModeEnabled = true;
      }
      return s;
    });
  }

  @override
  Future<bool> verifyPin(String pin) => _guarded('verifyPin', () async {
    final s = await _ds.getSettings();
    final lockoutUntil = s.lockoutUntil;
    if (lockoutUntil != null && _now().isBefore(lockoutUntil)) {
      // Do not run PBKDF2 during an active lockout window.
      return false;
    }
    final ok = _hasher.verify(pin: pin, settings: s);
    if (ok) {
      // Isolate counter reset so a storage glitch here does not flip a
      // successful verify into an apparent failure at the call-site.
      try {
        await clearFailedAttempts();
      } catch (e, st) {
        _logger.w(
          'clearFailedAttempts after successful verify failed; counter may be stale',
          error: e,
          stackTrace: st,
        );
      }
    }
    return ok;
  });

  @override
  Future<void> clearPin() => _guarded('clearPin', () async {
    await _ds.updateSettings((s) {
      s.pinHashBase64 = null;
      s.pinSaltBase64 = null;
      s.failedAttempts = 0;
      s.lockoutUntil = null;
      return s;
    });
  });

  @override
  Future<void> setRestrictedMode(bool enabled) =>
      _guarded('setRestrictedMode', () async {
        await _ds.updateSettings((s) {
          s.restrictedModeEnabled = enabled;
          return s;
        });
        await _safeAnalytics(
          enabled
              ? const ParentalControlEnabled()
              : const ParentalControlDisabled(),
        );
      });

  @override
  Future<void> setUnlockTimeout(Duration timeout) =>
      _guarded('setUnlockTimeout', () async {
        await _ds.updateSettings((s) {
          s.unlockTimeoutMs = timeout.inMilliseconds;
          return s;
        });
      });

  @override
  Future<void> setBiometricUnlockEnabled(bool enabled) =>
      _guarded('setBiometricUnlockEnabled', () async {
        await _ds.updateSettings((s) {
          s.biometricUnlockEnabled = enabled;
          return s;
        });
      });

  @override
  Future<Duration?> registerFailedAttempt() => _guarded(
    'registerFailedAttempt',
    () async {
      Duration? lockout;
      int updatedAttempts = 0;
      await _ds.updateSettings((s) {
        s.failedAttempts = s.failedAttempts + 1;
        updatedAttempts = s.failedAttempts;
        // First four failures are free; backoff starts on the 5th and
        // saturates at the final entry.
        if (ParentalControlPolicy.lockoutThresholdAttempts <=
            s.failedAttempts) {
          final idx =
              s.failedAttempts - ParentalControlPolicy.lockoutThresholdAttempts;
          final cappedIdx = idx < ParentalControlPolicy.backoffSeconds.length
              ? idx
              : ParentalControlPolicy.backoffSeconds.length - 1;
          lockout = Duration(
            seconds: ParentalControlPolicy.backoffSeconds[cappedIdx],
          );
          s.lockoutUntil = _now().add(lockout!);
        }
        return s;
      });
      await _safeAnalytics(
        ParentalControlUnlockFailed(attempts: updatedAttempts),
      );
      final lo = lockout;
      if (lo != null) {
        await _safeAnalytics(
          ParentalControlLockout(
            attempts: updatedAttempts,
            durationSeconds: lo.inSeconds,
          ),
        );
      }
      return lockout;
    },
  );

  @override
  Future<void> clearFailedAttempts() =>
      _guarded('clearFailedAttempts', () async {
        await _ds.updateSettings((s) {
          s.failedAttempts = 0;
          s.lockoutUntil = null;
          return s;
        });
      });

  @override
  Stream<bool> watchHideExplicit(int itunesId) =>
      _ds.watchHideExplicit(itunesId);

  @override
  Future<bool> getHideExplicit(int itunesId) async {
    final f = await _ds.getFlags(itunesId);
    return f?.hideExplicitEpisodes ?? false;
  }

  @override
  Future<void> setHideExplicit(int itunesId, bool hide) => _guarded(
    'setHideExplicit',
    () => _ds.setHideExplicit(itunesId: itunesId, hide: hide),
  );

  @override
  Future<void> pruneFlagsFor(int itunesId) =>
      _guarded('pruneFlagsFor', () => _ds.pruneFlagsFor(itunesId));

  Future<T> _guarded<T>(String op, Future<T> Function() body) async {
    try {
      return await body();
    } catch (e, st) {
      _logger.e('parentalControl.$op failed', error: e, stackTrace: st);
      // Forward to the error sink (e.g. Sentry in production).
      // NEVER pass PIN, salt, or hash — only the exception and stack.
      _onError('parentalControl.$op failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Best-effort analytics emit: an unavailable analytics service (e.g. in
  /// unit tests without the override) must not flip the underlying repository
  /// op into a failure.
  Future<void> _safeAnalytics(AnalyticsEvent event) async {
    try {
      await _analytics.log(event);
    } catch (e, st) {
      _logger.t(
        'parentalControl analytics emit failed (${event.runtimeType})',
        error: e,
        stackTrace: st,
      );
    }
  }
}
