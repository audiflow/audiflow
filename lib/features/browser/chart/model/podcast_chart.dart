import 'package:audiflow/entities/entities.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'itunes_chart_item.dart';

part 'podcast_chart.freezed.dart';

@freezed
class PodcastChartState with _$PodcastChartState {
  const factory PodcastChartState({
    int? size,
    String? genre,
    Country? country,
    @Default([]) List<ITunesChartItem> chartItems,
    DateTime? expiresAt,
  }) = _PodcastChartState;
}

extension PodcastChartStateExt on PodcastChartState {
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? true;
}
