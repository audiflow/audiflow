import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('appName is Audiflow', () {
      expect(AppConstants.appName, 'Audiflow');
    });

    test('apiTimeout is 30 seconds', () {
      expect(AppConstants.apiTimeout, const Duration(seconds: 30));
    });

    test('apiTimeout inSeconds equals 30', () {
      expect(AppConstants.apiTimeout.inSeconds, 30);
    });

    test('minSplashDuration is 1 second', () {
      expect(AppConstants.minSplashDuration, const Duration(seconds: 1));
    });

    test('minSplashDuration inMilliseconds equals 1000', () {
      expect(AppConstants.minSplashDuration.inMilliseconds, 1000);
    });

    test('constants are compile-time const', () {
      // Verify they can be used in const contexts
      const name = AppConstants.appName;
      const timeout = AppConstants.apiTimeout;
      const splash = AppConstants.minSplashDuration;
      expect(name, isNotEmpty);
      expect(timeout, isNotNull);
      expect(splash, isNotNull);
    });
  });
}
