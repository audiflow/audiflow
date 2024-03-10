// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepImpl _$$SleepImplFromJson(Map<String, dynamic> json) => _$SleepImpl(
      type: $enumDecode(_$SleepTypeEnumMap, json['type']),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: json['duration'] as int),
    );

Map<String, dynamic> _$$SleepImplToJson(_$SleepImpl instance) =>
    <String, dynamic>{
      'type': _$SleepTypeEnumMap[instance.type]!,
      'duration': instance.duration.inMicroseconds,
    };

const _$SleepTypeEnumMap = {
  SleepType.none: 'none',
  SleepType.time: 'time',
  SleepType.episode: 'episode',
};
