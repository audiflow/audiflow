// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PodcastChartStateImpl _$$PodcastChartStateImplFromJson(
        Map<String, dynamic> json) =>
    _$PodcastChartStateImpl(
      size: json['size'] as int?,
      genre: json['genre'] as String?,
      countryCode: json['countryCode'] as String?,
      podcasts: (json['podcasts'] as List<dynamic>?)
              ?.map((e) =>
                  PodcastSearchResultItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$PodcastChartStateImplToJson(
        _$PodcastChartStateImpl instance) =>
    <String, dynamic>{
      'size': instance.size,
      'genre': instance.genre,
      'countryCode': instance.countryCode,
      'podcasts': instance.podcasts.map((e) => e.toJson()).toList(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
