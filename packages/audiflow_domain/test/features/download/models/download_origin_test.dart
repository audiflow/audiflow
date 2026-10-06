import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a task without an explicit origin is manual', () {
    // Rows written before the origin field existed read back the field's
    // default, so they must be protected from retention.
    check(DownloadTask().downloadOrigin).equals(DownloadOrigin.manual);
  });

  test('round-trips both origins through the stored value', () {
    for (final origin in DownloadOrigin.values) {
      check(DownloadOrigin.fromDbValue(origin.dbValue)).equals(origin);
    }
  });

  test('treats an unknown stored value as manual', () {
    check(DownloadOrigin.fromDbValue(99)).equals(DownloadOrigin.manual);
    check(DownloadOrigin.fromDbValue(-1)).equals(DownloadOrigin.manual);
  });
}
