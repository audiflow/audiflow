import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Records a play from station [stationId], so the Library shows recently
/// played stations first. Fire-and-forget: a failed write only leaves the
/// Library order stale.
void recordStationPlay(WidgetRef ref, int stationId) {
  // Read before awaiting: the caller may be gone when the write fails.
  final stations = ref.read(stationRepositoryProvider);
  final logger = ref.read(namedLoggerProvider('StationPlay'));
  unawaited(
    stations.markPlayed(stationId, at: DateTime.now()).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      logger.w(
        'Failed to record station play',
        error: error,
        stackTrace: stackTrace,
      );
    }),
  );
}
