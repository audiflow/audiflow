import 'package:audiflow_app/features/station/presentation/controllers/station_edit_controller.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StationEditError', () {
    group('limitReached', () {
      test('produces key with prefix and max value', () {
        check(StationEditError.limitReached(5)).equals('limit_reached:5');
      });
    });

    group('isLimitReached', () {
      test('returns true for limit_reached key', () {
        check(StationEditError.isLimitReached('limit_reached:10')).isTrue();
      });

      test('returns false for other keys', () {
        check(StationEditError.isLimitReached('name_required')).isFalse();
      });
    });

    group('parseLimitMax', () {
      test('extracts max from valid key', () {
        check(StationEditError.parseLimitMax('limit_reached:20')).equals(20);
      });

      test('returns 0 for non-numeric suffix', () {
        check(StationEditError.parseLimitMax('limit_reached:abc')).equals(0);
      });

      test('returns 0 for key without limit_reached prefix', () {
        check(StationEditError.parseLimitMax('name_required')).equals(0);
      });

      test('returns 0 for empty string', () {
        check(StationEditError.parseLimitMax('')).equals(0);
      });
    });
  });
}
