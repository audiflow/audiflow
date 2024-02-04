// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TranscriptUrlImpl _$$TranscriptUrlImplFromJson(Map<String, dynamic> json) =>
    _$TranscriptUrlImpl(
      url: json['url'] as String,
      type: $enumDecode(_$TranscriptFormatEnumMap, json['type']),
      language: json['language'] as String? ?? '',
      rel: json['rel'] as String? ?? '',
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$TranscriptUrlImplToJson(_$TranscriptUrlImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': _$TranscriptFormatEnumMap[instance.type]!,
      'language': instance.language,
      'rel': instance.rel,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

const _$TranscriptFormatEnumMap = {
  TranscriptFormat.json: 'json',
  TranscriptFormat.subrip: 'subrip',
  TranscriptFormat.unsupported: 'unsupported',
};

_$TranscriptImpl _$$TranscriptImplFromJson(Map<String, dynamic> json) =>
    _$TranscriptImpl(
      id: json['id'] as int?,
      guid: json['guid'] as String,
      subtitles: (json['subtitles'] as List<dynamic>?)
              ?.map((e) => Subtitle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Subtitle>[],
      filtered: json['filtered'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$TranscriptImplToJson(_$TranscriptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guid': instance.guid,
      'subtitles': instance.subtitles,
      'filtered': instance.filtered,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

_$SubtitleImpl _$$SubtitleImplFromJson(Map<String, dynamic> json) =>
    _$SubtitleImpl(
      index: json['index'] as int,
      start: Duration(microseconds: json['start'] as int),
      end: json['end'] == null
          ? null
          : Duration(microseconds: json['end'] as int),
      data: json['data'] as String?,
      speaker: json['speaker'] as String? ?? '',
    );

Map<String, dynamic> _$$SubtitleImplToJson(_$SubtitleImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'start': instance.start.inMicroseconds,
      'end': instance.end?.inMicroseconds,
      'data': instance.data,
      'speaker': instance.speaker,
    };
