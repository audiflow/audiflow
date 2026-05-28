import 'dart:convert' show base64Encode;

import 'package:logger/logger.dart';

import '../datasources/local/parental_control_local_datasource.dart';
import '../models/parental_control_settings.dart';
import '../services/parental_control_policy.dart';
import '../services/pin_hasher.dart';
import 'parental_control_repository.dart';

class ParentalControlRepositoryImpl implements ParentalControlRepository {
  ParentalControlRepositoryImpl({
    required ParentalControlLocalDataSource datasource,
    required PinHasher hasher,
    required Logger logger,
    DateTime Function()? clock,
  }) : _ds = datasource,
       _hasher = hasher,
       _logger = logger,
       _now = clock ?? DateTime.now;

  final ParentalControlLocalDataSource _ds;
  final PinHasher _hasher;
  final Logger _logger;
  final DateTime Function() _now;

  @override
  Stream<ParentalControlSettings> watchSettings() => _ds.watchSettings();

  @override
  Future<ParentalControlSettings> getSettings() =>
      _guarded('getSettings', () => _ds.getSettings());

  @override
  Future<void> setPin(String pin) => _guarded('setPin', () async {
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
      return s;
    });
  });

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
      await clearFailedAttempts();
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
      await _ds.updateSettings((s) {
        s.failedAttempts = s.failedAttempts + 1;
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
      rethrow;
    }
  }
}
