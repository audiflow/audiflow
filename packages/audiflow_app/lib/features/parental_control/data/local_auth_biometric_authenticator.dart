import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

/// [BiometricAuthenticator] backed by the `local_auth` plugin.
///
/// Wraps platform exceptions and converts them to a boolean: any plugin error
/// (no enrolled biometric, no hardware, user cancellation, lockout) is logged
/// at warn level and surfaced as `false` so the caller can transparently fall
/// back to the PIN entry path.
class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator({LocalAuthentication? auth, Logger? logger})
    : _auth = auth ?? LocalAuthentication(),
      _logger = logger;

  final LocalAuthentication _auth;
  final Logger? _logger;

  @override
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      if (!await _auth.canCheckBiometrics) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e, st) {
      _logger?.w('isAvailable failed', error: e, stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e, st) {
      _logger?.w('authenticate failed', error: e, stackTrace: st);
      return false;
    }
  }
}
