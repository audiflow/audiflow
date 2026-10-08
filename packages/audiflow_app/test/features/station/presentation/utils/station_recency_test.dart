import 'package:audiflow_app/features/station/presentation/utils/station_recency.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

Station _station(int id, {DateTime? lastPlayedAt}) => Station()
  ..id = id
  ..name = 'Station $id'
  ..sortOrder = id
  ..lastPlayedAt = lastPlayedAt
  ..createdAt = DateTime(2026)
  ..updatedAt = DateTime(2026);

List<int> _ids(List<Station> stations) => [for (final s in stations) s.id];

void main() {
  group('recentlyPlayedStations', () {
    test('puts the most recently played first', () {
      final stations = [
        _station(1, lastPlayedAt: DateTime(2026, 1)),
        _station(2, lastPlayedAt: DateTime(2026, 3)),
        _station(3, lastPlayedAt: DateTime(2026, 2)),
      ];
      check(
        _ids(recentlyPlayedStations(stations, limit: 4)),
      ).deepEquals([2, 3, 1]);
    });

    test('keeps never-played stations after, in the given order', () {
      final stations = [
        _station(1),
        _station(2),
        _station(3, lastPlayedAt: DateTime(2026)),
        _station(4),
      ];
      check(
        _ids(recentlyPlayedStations(stations, limit: 4)),
      ).deepEquals([3, 1, 2, 4]);
    });

    test('returns at most limit stations', () {
      final stations = [for (var i = 1; i <= 6; i++) _station(i)];
      check(recentlyPlayedStations(stations, limit: 4)).length.equals(4);
    });
  });
}
