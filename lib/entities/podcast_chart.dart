import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seasoning/entities/entities.dart';

part 'podcast_chart.freezed.dart';
part 'podcast_chart.g.dart';

@freezed
class PodcastChartState with _$PodcastChartState {
  const factory PodcastChartState({
    int? size,
    String? genre,
    String? countryCode,
    @Default([]) List<PodcastMetadata> podcasts,
    DateTime? expiresAt,
  }) = _PodcastChartState;

  factory PodcastChartState.fromJson(Map<String, dynamic> json) =>
      _$PodcastChartStateFromJson(json);
}

extension PodcastChartStateExt on PodcastChartState {
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? true;
}
