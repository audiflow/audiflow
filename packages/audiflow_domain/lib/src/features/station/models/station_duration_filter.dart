import 'package:isar_community/isar.dart';

part 'station_duration_filter.g.dart';

@embedded
class StationDurationFilter {
  /// 'shorterThan' or 'longerThan'
  String durationOperator = 'shorterThan';
  int durationMinutes = 30;
}
