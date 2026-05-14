import 'package:audiflow_app/features/force_update/presentation/update_url_resolver.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveUpdateUrl', () {
    test('configUrl is preferred when present', () {
      final uri = resolveUpdateUrl(
        configUrl: 'https://example.com/x',
        platform: TargetUpdatePlatform.ios,
      );
      check(uri.toString()).equals('https://example.com/x');
    });

    test('falls back to App Store on iOS when configUrl is null', () {
      final uri = resolveUpdateUrl(
        configUrl: null,
        platform: TargetUpdatePlatform.ios,
      );
      check(uri.toString()).startsWith('https://apps.apple.com/');
    });

    test('falls back to Play Store on Android when configUrl is null', () {
      final uri = resolveUpdateUrl(
        configUrl: null,
        platform: TargetUpdatePlatform.android,
      );
      check(uri.toString()).startsWith('market://details');
      check(uri.toString()).contains('com.reedom.audiflow_app');
    });

    test('falls back to App Store when configUrl is empty string', () {
      final uri = resolveUpdateUrl(
        configUrl: '',
        platform: TargetUpdatePlatform.ios,
      );
      check(uri.toString()).startsWith('https://apps.apple.com/');
    });

    test('other platform falls back to App Store URL', () {
      final uri = resolveUpdateUrl(
        configUrl: null,
        platform: TargetUpdatePlatform.other,
      );
      check(uri.toString()).startsWith('https://apps.apple.com/');
    });
  });
}
