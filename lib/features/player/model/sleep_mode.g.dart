// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_mode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepModeImpl _$$SleepModeImplFromJson(Map<String, dynamic> json) =>
    _$SleepModeImpl(
      type: $enumDecode(_$SleepTypeEnumMap, json['type']),
      duration: json['duration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$$SleepModeImplToJson(_$SleepModeImpl instance) =>
    <String, dynamic>{
      'type': _$SleepTypeEnumMap[instance.type]!,
      'duration': instance.duration.inMicroseconds,
    };

const _$SleepTypeEnumMap = {
  SleepType.none: 'none',
  SleepType.episode: 'episode',
  SleepType.time: 'time',
};
