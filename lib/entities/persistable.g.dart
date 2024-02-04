// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersistableImpl _$$PersistableImplFromJson(Map<String, dynamic> json) =>
    _$PersistableImpl(
      pguid: json['pguid'] as String,
      episodeId: json['episodeId'] as int,
      position: json['position'] as int,
      state: $enumDecode(_$LastStateEnumMap, json['state']),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$PersistableImplToJson(_$PersistableImpl instance) =>
    <String, dynamic>{
      'pguid': instance.pguid,
      'episodeId': instance.episodeId,
      'position': instance.position,
      'state': _$LastStateEnumMap[instance.state]!,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };

const _$LastStateEnumMap = {
  LastState.none: 'none',
  LastState.completed: 'completed',
  LastState.stopped: 'stopped',
  LastState.paused: 'paused',
};
