// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonImpl _$$SeasonImplFromJson(Map<String, dynamic> json) => _$SeasonImpl(
      id: json['id'] as int?,
      guid: json['guid'] as String,
      pguid: json['pguid'] as String,
      podcast: json['podcast'] as String,
      title: json['title'] as String?,
      seasonNum: json['seasonNum'] as int?,
    );

Map<String, dynamic> _$$SeasonImplToJson(_$SeasonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'pguid': instance.pguid,
      'podcast': instance.podcast,
      'title': instance.title,
      'seasonNum': instance.seasonNum,
    };
