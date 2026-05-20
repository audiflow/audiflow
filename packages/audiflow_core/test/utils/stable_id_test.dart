import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stableId', () {
    test('produces a 16-char lowercase hex string', () {
      final id = stableId('https://example.com/feed.xml');
      check(id).length.equals(16);
      check(id).matchesPattern(RegExp(r'^[0-9a-f]{16}$'));
    });

    test('is deterministic for the same input', () {
      check(stableId('foo')).equals(stableId('foo'));
    });

    test('differs for different inputs', () {
      check(stableId('foo')).not((s) => s.equals(stableId('bar')));
    });

    test('treats empty string as a valid input', () {
      check(stableId('')).length.equals(16);
    });
  });
}
