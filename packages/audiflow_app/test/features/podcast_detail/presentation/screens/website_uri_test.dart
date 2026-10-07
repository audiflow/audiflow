import 'package:audiflow_app/features/podcast_detail/presentation/screens/podcast_detail_screen.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts http and https websites', () {
    check(
      websiteUri(' https://example.com/show '),
    ).equals(Uri.parse('https://example.com/show'));
    check(websiteUri('http://example.com')).isNotNull();
  });

  test('rejects missing, blank, and non-web links', () {
    check(websiteUri(null)).isNull();
    check(websiteUri('  ')).isNull();
    check(websiteUri('mailto:host@example.com')).isNull();
    check(websiteUri('javascript:alert(1)')).isNull();
    check(websiteUri('example.com/show')).isNull();
  });
}
