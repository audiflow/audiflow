import 'dart:convert' show base64Encode;

import '../datasources/local/parental_control_local_datasource.dart';
import '../models/parental_control_settings.dart';
import '../services/pin_hasher.dart';
import 'parental_control_repository.dart';

class ParentalControlRepositoryImpl implements ParentalControlRepository {
  ParentalControlRepositoryImpl({
    required ParentalControlLocalDataSource datasource,
    required PinHasher hasher,
    DateTime Function()? clock,
  }) : _ds = datasource,
       _hasher = hasher,
       _now = clock ?? DateTime.now;

  final ParentalControlLocalDataSource _ds;
  final PinHasher _hasher;
  final DateTime Function() _now;

  static const List<int> _backoffSeconds = [30, 60, 120, 240, 300];

  @override
  Stream<ParentalControlSettings> watchSettings() => _ds.watchSettings();

  @override
  Future<ParentalControlSettings> getSettings() => _ds.getSettings();

  @override
  Future<void> setPin(String pin) async {
    final salt = _hasher.generateSalt();
    final s = await _ds.getSettings();
    s.pinSaltBase64 = base64Encode(salt);
    s.pinHashBase64 = base64Encode(
      _hasher.hash(pin: pin, salt: salt, iterations: s.pinIterations),
    );
    s.failedAttempts = 0;
    s.lockoutUntil = null;
    await _ds.saveSettings(s);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final s = await _ds.getSettings();
    return _hasher.verify(pin: pin, settings: s);
  }

  @override
  Future<void> clearPin() async {
    final s = await _ds.getSettings();
    s.pinHashBase64 = null;
    s.pinSaltBase64 = null;
    s.failedAttempts = 0;
    s.lockoutUntil = null;
    await _ds.saveSettings(s);
  }

  @override
  Future<void> setRestrictedMode(bool enabled) async {
    final s = await _ds.getSettings();
    s.restrictedModeEnabled = enabled;
    await _ds.saveSettings(s);
  }

  @override
  Future<void> setUnlockTimeout(Duration timeout) async {
    final s = await _ds.getSettings();
    s.unlockTimeoutSeconds = timeout.inSeconds;
    await _ds.saveSettings(s);
  }

  @override
  Future<void> setBiometricUnlockEnabled(bool enabled) async {
    final s = await _ds.getSettings();
    s.biometricUnlockEnabled = enabled;
    await _ds.saveSettings(s);
  }

  @override
  Future<Duration?> registerFailedAttempt() async {
    final s = await _ds.getSettings();
    s.failedAttempts = s.failedAttempts + 1;
    Duration? lockout;
    // Lockout triggers at the 5th attempt (index 4); cap at last entry of _backoffSeconds.
    if (5 <= s.failedAttempts) {
      final idx = s.failedAttempts - 5;
      final cappedIdx = idx < _backoffSeconds.length
          ? idx
          : _backoffSeconds.length - 1;
      lockout = Duration(seconds: _backoffSeconds[cappedIdx]);
      s.lockoutUntil = _now().add(lockout);
    }
    await _ds.saveSettings(s);
    return lockout;
  }

  @override
  Future<void> clearFailedAttempts() async {
    final s = await _ds.getSettings();
    s.failedAttempts = 0;
    s.lockoutUntil = null;
    await _ds.saveSettings(s);
  }

  @override
  Stream<bool> watchHideExplicit(int itunesId) =>
      _ds.watchHideExplicit(itunesId);

  @override
  Future<bool> getHideExplicit(int itunesId) async {
    final f = await _ds.getFlags(itunesId);
    return f?.hideExplicitEpisodes ?? false;
  }

  @override
  Future<void> setHideExplicit(int itunesId, bool hide) =>
      _ds.setHideExplicit(itunesId: itunesId, hide: hide);

  @override
  Future<void> pruneFlagsFor(int itunesId) => _ds.pruneFlagsFor(itunesId);
}
