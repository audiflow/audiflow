import 'package:audiflow_domain/audiflow_domain.dart';

/// The [limit] stations the Library shows: most recently played first,
/// then never-played ones in [stations]' own (manual) order.
List<Station> recentlyPlayedStations(
  List<Station> stations, {
  required int limit,
}) {
  // Indexed so equal keys keep their input order; List.sort is unstable.
  final indexed = stations.indexed.toList()
    ..sort((a, b) {
      final byRecency = _compareRecency(a.$2.lastPlayedAt, b.$2.lastPlayedAt);
      return byRecency != 0 ? byRecency : a.$1.compareTo(b.$1);
    });
  return [for (final (_, station) in indexed.take(limit)) station];
}

/// Newest first; a never-played station sorts after every played one.
int _compareRecency(DateTime? a, DateTime? b) {
  if (a == null) return b == null ? 0 : 1;
  if (b == null) return -1;
  return b.compareTo(a);
}
