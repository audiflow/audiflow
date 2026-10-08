import 'package:audiflow_app/features/station/presentation/utils/default_station_name.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

String _label(int n) => 'Station $n';

void main() {
  group('defaultStationName', () {
    test('starts at 1', () {
      check(defaultStationName(const [], _label)).equals('Station 1');
    });

    test('takes the smallest unused number', () {
      check(
        defaultStationName(const ['Station 1', 'Station 3'], _label),
      ).equals('Station 2');
    });

    test('ignores names that do not follow the pattern', () {
      check(
        defaultStationName(const ['News', 'Station 1'], _label),
      ).equals('Station 2');
    });
  });
}
