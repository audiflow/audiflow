import 'package:audiflow_app/features/consent/presentation/utils/privacy_policy_url.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildPrivacyPolicyUrl', () {
    test('embeds lang=en and embed=1 by default for English', () {
      final uri = buildPrivacyPolicyUrl(lang: 'en');
      check(uri.host).equals('company.reedom.com');
      check(uri.path).equals('/audiflow/privacy-policy');
      check(uri.queryParameters['lang']).equals('en');
      check(uri.queryParameters['embed']).equals('1');
    });

    test('passes Japanese locale through as lang=ja', () {
      final uri = buildPrivacyPolicyUrl(lang: 'ja');
      check(uri.queryParameters['lang']).equals('ja');
    });

    test('falls back to en for unsupported lang codes', () {
      final uri = buildPrivacyPolicyUrl(lang: 'fr');
      check(uri.queryParameters['lang']).equals('en');
    });

    test('embed=0 disables embed flag (browser-mode opt-out)', () {
      final uri = buildPrivacyPolicyUrl(lang: 'en', embed: false);
      check(uri.queryParameters['embed']).isNull();
    });

    test('uses https scheme', () {
      final uri = buildPrivacyPolicyUrl(lang: 'en');
      check(uri.scheme).equals('https');
    });
  });
}
