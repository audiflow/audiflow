// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueueImpl _$$QueueImplFromJson(Map<String, dynamic> json) => _$QueueImpl(
      queue: (json['queue'] as List<dynamic>?)
              ?.map((e) => QueueItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <QueueItem>[],
    );

Map<String, dynamic> _$$QueueImplToJson(_$QueueImpl instance) =>
    <String, dynamic>{
      'queue': instance.queue,
    };

_$QueueItemImpl _$$QueueItemImplFromJson(Map<String, dynamic> json) =>
    _$QueueItemImpl(
      guid: json['guid'] as String,
      type: $enumDecode(_$QueueTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$QueueItemImplToJson(_$QueueItemImpl instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'type': _$QueueTypeEnumMap[instance.type]!,
    };

const _$QueueTypeEnumMap = {
  QueueType.primary: 'primary',
  QueueType.adhoc: 'adhoc',
};
